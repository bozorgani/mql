# SPR6-006 Report — Formal Sprint 6 Integration Review / Pre-Execution Gate

**Review date:** 2026-08-20 (UTC)  
**Review method:** MANUAL ARCHITECTURAL VALIDATION (source and repository inspection only)  
**Source changes made by this task:** none  
**Result:** **BLOCKED — pre-execution defects found; compiler and runtime gates remain unperformed.**

> This review deliberately does not claim compilation or runtime success. The defects below were discovered by inspecting the current source, rather than relying on the earlier Sprint 6 reports.

## 1. Executive Summary

`EAMain.mq5` has the intended high-level layer order and manager ownership for normal initialization, updates, and shutdown. In particular, it has no direct duplicate child lifecycle calls where a manager owns the lifecycle, and the update order is Indicators → Structure → Price Action.

However, the project is **not structurally ready for real MQL5 compilation and runtime testing**:

1. `TrendEngine.mq5` includes a non-existent file, which blocks preprocessing/compilation.
2. Multiple included modules declare the same un-namespaced global variables (for example, `initialized`, `configured`, and `ready`), and `CommonTypes.mqh` duplicates public enumerator names. Because `EAMain.mq5` includes the modules into one translation unit, these are compile-blocking global-name collisions.
3. The success value of `ConfigInit()` is `INIT_SUCCEEDED` (zero), but EAMain tests it as a boolean negation. A successful config initialization therefore follows the failure branch.
4. Even if that test were corrected, `EMAReady()` and `ATRReady()` cannot pass because EAMain/IndicatorManager do not configure EMA or ATR before `VerifyIndicatorsReady()`.
5. Failure rollback does not fully roll back infrastructure or partially initialized manager children.
6. Lifecycle logging occurs before logger initialization and after logger shutdown; `STARTUP_BEGIN` is also emitted twice on a successful start.
7. `EADeinit()` permits illegal state transitions from `EA_UNINITIALIZED` or `EA_SHUTDOWN` to `EA_STOPPING`.

No frozen-interface *drift* was found against commit `e941b604754feaa70cd6db3fc7dcdf0421d2d4a4`; the frozen-source defects above already exist in that baseline. The enum collision is nevertheless a frozen public-interface defect and needs an approved contract decision rather than an automatic patch.

## 2. Source Inspection Results

Inspected actual source:

- `mql5/modules/EAMain.mq5`
- all EAMain-included module sources
- `mql5/include/CommonTypes.mqh`, `ErrorCodes.mqh`, `EventIDs.mqh`, `PriceActionErrorCodes.mqh`, `PriceActionEventIDs.mqh`, and `StructureEventIDs.mqh`
- required Sprint 6 reports: `SPR6-001`, `SPR6-002`, `SPR6-002B`, `SPR6-003`, `SPR6-004`, and `SPR6-005`

The previous reports correctly describe the intended manager topology, but their manual conclusions did not identify the current include path, global-symbol, configuration/readiness, rollback, state, and logging-order defects recorded here.

## 3. EAMain Lifecycle Audit

### Entry-point thinness

| Entry point | Current body | Result |
|---|---|---|
| `OnInit()` | sets state, calls `EAStartup()`, returns MQL result | Thin, but has pre-logger logging and failure-state issues |
| `OnTick()` | state gate then `EAUpdate()` | Thin |
| `OnCalculate()` | state gate then `EAUpdate()`, returns `rates_total` | Thin |
| `OnDeinit()` | calls `EADeinit()` | Thin |

### State machine

The required six states are present at `EAMain.mq5:38–45`:

`EA_UNINITIALIZED`, `EA_INITIALIZING`, `EA_READY`, `EA_RUNNING`, `EA_STOPPING`, `EA_SHUTDOWN`.

Normal-path transitions are intended as:

`UNINITIALIZED → INITIALIZING → READY → RUNNING → STOPPING → SHUTDOWN`.

**Finding D-06 — illegal transitions are not prevented.** `EADeinit()` unconditionally assigns `EA_STOPPING` (`EAMain.mq5:367–370`). This permits `UNINITIALIZED → STOPPING` and `SHUTDOWN → STOPPING`, contrary to the frozen Sprint 6 transition plan (where SHUTDOWN is terminal). In the initialization-failure path, `OnInit()` explicitly sets `EA_SHUTDOWN` (`:403–406`); a subsequent platform `OnDeinit()` call would then make the latter illegal transition.

**Finding D-07 — no distinct failure state exists.** The planned `INITIALIZING → FAILED (halt)` transition is represented as `INITIALIZING → SHUTDOWN` (`:403–405`). This is not one of the declared states and obscures failed initialization from ordinary completed shutdown. This is implementation behavior, not a frozen-interface signature change.

## 4. Initialization Ownership

The normal EAMain calls are correctly owned and appear once in the normal startup path:

| Layer | Calls | Ownership result |
|---|---|---|
| Infrastructure | `ConfigInit()`, `LoggerInit()`, `LoggerFileInit()`, `TimeServiceInit()`, `MarketDataInit()`, `SymbolInfoInit()` | Direct infrastructure ownership is correct |
| Indicators | `IndicatorManagerInit()` | Correct manager delegation; no direct EMA/ATR init from EAMain |
| Structure | `StructureManagerInit()` | Correct manager delegation |
| Price Action | `PriceActionManagerInit()` | Correct manager delegation |

**Duplicate Init (normal EAMain path): 0.**

### Initialization blockers

**Finding D-01 — `ConfigInit()` success is treated as failure (critical).** `ConfigSystem.mq5:2` returns `INIT_SUCCEEDED`; in MQL5 this success constant is zero. `EAMain.mq5:149` uses `if(!ConfigInit())`, so success becomes `!0`, which is true, and startup returns false. `EA_READY` cannot be reached in the current source.

**Finding D-02 — indicator readiness cannot be reached (critical).** `EMAReady()` and `ATRReady()` require both initialization and configuration (`EMAEngine.mq5:20`, `ATREngine.mq5:22`). `IndicatorManagerInit()` only invokes `EMAInit()` and `ATRInit()` (`IndicatorManager.mq5:3–8`); neither EAMain nor the manager calls `EMAConfigure()` or `ATRConfigure()` before `VerifyIndicatorsReady()` (`EAMain.mq5:110–115`). Therefore, even after D-01 is addressed, the indicator verification fails and prevents `EA_READY`.

## 5. Update Ownership

`EAUpdate()` uses the required ownership pattern:

1. `RefreshMarketData()`
2. direct `EMAUpdate()`
3. direct `ATRUpdate()`
4. `StructureManagerUpdate()`
5. `PriceActionManagerUpdate()`

`IndicatorManager.mq5` has no frozen `Update()` facade, so the direct EMA/ATR calls are appropriate. No `IndicatorManagerUpdate()` was added.

**Duplicate Update: 0** in one successful EAMain update cycle. `StructureManagerUpdate()` owns Structure child updates and `PriceActionManagerUpdate()` owns Price Action child updates.

## 6. Shutdown Ownership

`EADeinit()` uses the required top-level order:

1. `PriceActionManagerShutdown()`
2. `StructureManagerShutdown()`
3. `IndicatorManagerShutdown()`
4. `ShutdownManagerStop()`

EAMain does not directly shut down children owned by the three managers.

**Duplicate Shutdown: 0** in the normal EAMain deinitialization path. (Occurrences in the separate rollback helpers are alternate failure paths, not duplicate normal-path calls.)

## 7. Rollback Audit

The declared layer ordering is correct: Price Action → Structure → Indicators → Infrastructure.

**Finding D-03 — infrastructure rollback is incomplete (high).** `RollbackInfrastructureLayer()` only calls `LoggerFileShutdown()` and `LoggerShutdown()` (`EAMain.mq5:175–179`). If `TimeServiceInit()`, `MarketDataInit()`, or `SymbolInfoInit()` succeeded before a later failure, their matching shutdowns are not called. Config has no frozen shutdown interface, but the other initialized infrastructure services do.

**Finding D-04 — manager-init failure paths can retain initialized children (high).**

- `IndicatorManagerInit()` returns false when `ATRInit()` fails but does not shut down a prior successful EMA initialization (`IndicatorManager.mq5:3–8`). EAMain then rolls back only infrastructure (`EAMain.mq5:255–260`).
- `PriceActionManagerInit()` returns false without rolling back previously successful Price Action child initializations (`PriceActionManager.mq5:3–14`). EAMain does not call `RollbackPriceActionLayer()` when this manager-init call fails (`EAMain.mq5:287–294`).

Thus the stated “no partially initialized layer” policy is not met. No failure path can set `EA_READY` because READY is assigned only after all verifications (`EAMain.mq5:296–310`), but cleanup integrity is still insufficient.

## 8. Structure → Price Action Audit

The call order is correct: indicators are updated before structure, and structure before Price Action (`EAMain.mq5:334–354`). Price Action module sources contain no Structure include or Structure/Swing/BOS/CHOCH/Trend write call. Therefore:

- Price Action does **not** modify Structure.
- Price Action does **not** bypass a Structure public interface.
- No Structure ↔ Price Action circular include/call dependency was found.

**Finding D-08 — the specified Structure-output read is absent.** The Price Action modules and `PriceActionManager.mq5` contain no read of Structure public outputs either. This preserves non-modification and acyclicity, but does not substantiate the required “Price Action reads Structure outputs” integration. It is a missing integration dependency, not permission to add strategy logic.

## 9. Frozen Interface Audit

`git diff e941b604754feaa70cd6db3fc7dcdf0421d2d4a4..HEAD` is empty for the checked frozen contract files and Indicator/Structure/Price Action manager modules. No signature change, removed public function, renamed public function, new mandatory parameter, return-type change, Event ID change, or Error Code change was found.

**Frozen interface drift: NONE.**

**Finding D-09 — frozen CommonTypes interface collision (compile blocker; contract disposition required).** `CommonTypes.mqh` declares both `TrendStrength` and `PatternStrength` with the enumerator identifiers `STRENGTH_UNKNOWN`, `STRENGTH_WEAK`, `STRENGTH_NORMAL`, and `STRENGTH_STRONG` (`:5` and `:13`). MQL enum values are global identifiers, so these collide when the header is included. The collision is already present in the baseline; it is not drift. Resolving it requires a frozen-interface naming decision and must not be patched automatically under this task’s policy.

## 10. Include/Dependency Audit

- EAMain has **27 includes**, all unique; it has no duplicate direct include.
- No circular include graph was found.
- The direct EAMain lifecycle/update call targets have textual definitions in the included source set.
- No reference to a deleted module was found.

**Finding D-10 — invalid/missing include (compile blocker).** `TrendEngine.mq5:2` contains:

```mql5
#include <mql5/modules/CommonTypes.mqh>
```

The repository has `mql5/include/CommonTypes.mqh`, not `mql5/modules/CommonTypes.mqh`. This include cannot resolve.

**Finding D-11 — translation-unit global collisions (compile blocker).** EAMain includes all module implementation files directly. At least 20 modules define the global variable `initialized`; at least 14 define `configured`; and at least 13 define `ready`. `period` also appears in both EMA and ATR engines. Examples include `EMAEngine.mq5:2–5`, `ATREngine.mq5:2–4`, `StructureManager.mq5:2`, and `PriceActionManager.mq5:2`. These un-namespaced duplicate declarations inhabit the same EAMain translation unit and are not viable as a compiled integration unit.

There is also an order/dependency concern: `ConfigValidator.mq5` uses `ValidationResult` but does not include `CommonTypes.mqh`; EAMain includes ConfigValidator before the first valid CommonTypes include. It relies on later textual inclusion rather than declaring its own type dependency.

## 11. Logging Audit

All requested lifecycle event strings are declared in EAMain, and normal-path event ordering is conceptually startup → update → shutdown. However, the lifecycle logging implementation does not meet logger-lifetime requirements.

**Finding D-05 — logger ordering and duplicate startup event (high).**

- `OnInit()` logs `STARTUP_BEGIN` before `LoggerInit()` (`EAMain.mq5:399–400` versus `:153`).
- `EAStartup()` logs `STARTUP_BEGIN` a second time, also before logger initialization (`:239–240`). This is duplicate lifecycle-start logging on a successful start.
- `InitializeInfrastructureLayer()` logs `INFRASTRUCTURE_INIT` before Config/Logger initialization (`:144–153`).
- After a failed startup and infrastructure rollback, `OnInit()` logs `FATAL_INIT_FAILURE` after `LoggerShutdown()` (`:175–177`, `:403–405`).
- `ShutdownManagerStop()` shuts down LoggerFile and Logger (`ShutdownManager.mq5:4–10`), but EAMain then emits “infrastructure shutdown complete” and `SHUTDOWN_COMPLETE` (`EAMain.mq5:388–392`) after logger shutdown.

Consequently, the required events exist but cannot be relied upon to be emitted through an initialized logger. The review does not treat paired begin/complete layer messages with the same layer event ID as duplicate execution calls; the duplicate `STARTUP_BEGIN` is a duplicate lifecycle meaning.

## 12. Compiler Availability

**Compiler: NOT AVAILABLE**

Availability was checked for `metaeditor`, `MetaEditor`, `terminal64`, `terminal`, `wine`, `wine64`, and `mql5compiler`, and by filesystem search for MetaEditor/MT5 executable names. No real MQL5 compiler, MetaEditor, or compatible MQL5 build environment is installed in this sandbox.

## 13. Compile Result

**Compile verification: NOT PERFORMED**

No compile result is claimed. Independently of the unavailable compiler, manual source inspection found D-09, D-10, and D-11, which are compile blockers that must be addressed before a meaningful actual compilation attempt.

## 14. Runtime Availability

**MT5 Runtime: NOT AVAILABLE**

No MetaTrader 5 terminal or Strategy Tester installation was found.

## 15. Runtime Result

**Runtime verification: NOT PERFORMED**

The requested lifecycle test (`OnInit → READY → multiple updates → OnDeinit → SHUTDOWN`) was not executed. Current manual inspection also shows D-01 and D-02 prevent reaching READY.

## 16. Files Modified

| File | Change |
|---|---|
| `docs/reports/SPR6-006-REPORT.md` | Created this formal review report |

No MQL5 source file was modified. No frozen source was modified.

## 17. Defects Found

| ID | Severity | Defect | Recommended minimal disposition |
|---|---|---|---|
| D-01 | Critical | `ConfigInit()` success is inverted as a boolean failure | Correct the non-frozen EAMain success check, with an approved explicit comparison to the MQL init result |
| D-02 | Critical | EMA/ATR never configured before readiness verification | Define/approve the existing configuration ownership and call sequence; do not add strategy parameters |
| D-03 | High | Infrastructure rollback omits initialized Time/Market/Symbol services | Make rollback invoke the matching existing shutdown ownership path |
| D-04 | High | Failed manager init can leave child modules initialized | Repair rollback inside each owning manager or invoke its existing manager shutdown on failed init, subject to frozen-module policy |
| D-05 | High | Lifecycle logs before logger init, after logger shutdown, and duplicate startup begin | Reorder EAMain logging around logger lifetime; emit final logs before logger teardown or use an approved fallback |
| D-06 | High | Unchecked deinit allows illegal state transitions | Gate deinit by permitted states and make terminal shutdown idempotent |
| D-07 | Medium | Failed init is indistinguishable from completed shutdown | Use an approved explicit failure representation/policy without changing frozen contracts |
| D-08 | Medium | Price Action does not read Structure outputs | Clarify and implement only the intended existing public Structure-read contract; no strategy logic |
| D-09 | Critical | Frozen `CommonTypes` duplicate enum members | STOP: obtain frozen-interface governance decision; do not auto-rename public enum members |
| D-10 | Critical | TrendEngine includes a non-existent CommonTypes path | Correct include path only after defect disposition; this is not a signature change |
| D-11 | Critical | Many included modules collide on global state names | Establish module-private state naming/namespacing approach; assess as a coordinated compile-readiness repair |

## 18. Technical Debt

- `ConfigSystem` has no shutdown interface (already documented in source); rollback must still clean the services that do have shutdown interfaces.
- EAMain directly includes implementation `.mq5` files, magnifying global namespace and dependency-order risks.
- `ConfigValidator` lacks a direct dependency include for `ValidationResult`.
- Several module `Ready()` contracts require configuration while startup lacks an evident configuration phase.
- Logging core/file functions are placeholder implementations, so even correctly ordered logging needs real runtime verification later.
- `OnTick()` and `OnCalculate()` are both present in the same source; actual MetaEditor compilation is needed to verify the intended program/event-handler usage.

## 19. Architecture Verdict

```text
STATUS: SPR6-006 BLOCKED — DEFECT REMEDIATION AND EXECUTION GATES PENDING

MANUAL ARCHITECTURAL VALIDATION: FAIL (pre-execution blockers found)
ARCHITECTURE: NOT APPROVED FOR REAL COMPILATION/RUNTIME TESTING

Compiler: NOT AVAILABLE
Compile verification: NOT PERFORMED
MT5 Runtime: NOT AVAILABLE
Runtime verification: NOT PERFORMED
```

The prescribed “ARCHITECTURE PASS — EXECUTION GATE PENDING” status does not apply because actual source inspection found compile, initialization/readiness, rollback, state-machine, and logging defects. No trading feature work was started.

## 20. Self-Audit

| Question | Answer |
|---|---|
| Frozen source modified? | **NO** — this task created only this report |
| Frozen interfaces changed? | **NO** — no drift from baseline; D-09 is an existing frozen-interface collision |
| Duplicate Init? | **NO** — 0 in the normal EAMain startup ownership path |
| Duplicate Update? | **NO** — 0 in one EAMain update cycle |
| Duplicate Shutdown? | **NO** — 0 in normal EAMain deinit ownership path |
| Circular dependency? | **NO** found |
| Invalid include? | **YES** — `TrendEngine.mq5` CommonTypes path |
| Missing symbol/function? | **YES** — missing include target; direct lifecycle function targets otherwise have source definitions |
| Hidden logic? | **NO** — orchestration/configuration defects only |
| Strategy logic? | **NO** |
| Execution? | **NO** |
| Orders? | **NO** |
| Risk? | **NO** |
| Money Management? | **NO** |
| AI? | **NO** |
| Compiler actually run? | **NO** — unavailable |
| Runtime actually run? | **NO** — MT5/Strategy Tester unavailable |

**Stop point:** Review complete. Do not begin feature work. Remediate/disposition the listed defects, especially the frozen-interface collision, then perform an actual MetaEditor compile followed by the bounded lifecycle runtime test.
