# SPR6-006B — Architecture Remediation Plan & Patch Specification

**Status:** **SPR6-006B COMPLETE — REMEDIATION PLAN ONLY**  
**Next gate:** **ARCHITECTURE PATCH REQUIRED BEFORE SOURCE MODIFICATION**  
**Source modifications by this task:** **0**  
**Validation:** Manual source/contract analysis only. Actual MQL5 compilation and MT5 runtime validation were not performed.

> This is a patch specification, not an authorization to patch. No MQL5 source, frozen module, `CommonTypes.mqh`, `EAMain.mq5`, or `TrendEngine.mq5` was modified.

## 1. Executive Summary

The current EAMain integration cannot reach a trustworthy compiler or runtime gate. Actual source confirms the blockers recorded by SPR6-006 and SPR6-006A: one invalid include, direct-include translation-unit global collisions, a frozen shared enum-member collision, deterministic initialization/readiness failures, incomplete partial-failure cleanup, unsafe logger-lifetime ordering, and unguarded deinitialization transitions.

The first required decision is a **frozen CommonTypes contract patch**. The same public `STRENGTH_*` identifiers occur in two unscoped enums. It cannot be resolved by include order, aliases, or implementation-only changes while preserving both identical public member-name sets. No source remediation may start until that decision is approved.

Structure → Price Action remains read-only, but current Price Action skeleton modules do not consume Structure getters. Because no concrete frozen non-strategy consumer behavior exists, this plan classifies consumption as deferred technical debt—not an implementation target for this remediation patch.

## 2. Evidence classification

- **VERIFIED FROM SOURCE:** directly observed in current repository files.
- **INFERENCE:** conclusion derived from verified source and direct include composition.
- **PROPOSED REMEDIATION:** an approval-required plan; no source change has been made.

The Sprint 6 plan was reviewed. It requires manager ownership, reverse-order rollback, lifecycle logging, and the existing state machine, while explicitly excluding strategy, signals, entry/exit, execution/orders, risk, money management, and AI. The prior reviews also establish that the affected frozen source matches the frozen baseline; the defects are not Sprint 6 interface drift.

## 3. Complete blocker inventory

| ID | Blocker | Root cause | Severity | Frozen/approval impact |
|---|---|---|---|---|
| B-01 | CommonTypes duplicate enum members | Two unscoped public enums export the same names | Critical | Frozen public-contract patch required |
| B-02 | TrendEngine invalid include | Wrong `modules` directory in CommonTypes include | Critical | Frozen implementation correction; no public API change |
| B-03 | Global state collisions | Direct `.mq5` inclusion plus un-namespaced globals | Critical | Internal frozen implementation remediation approval required |
| B-04 | ConfigInit result inversion | MQL init return code tested as boolean | Critical | EAMain-only control-flow patch; interface unchanged |
| B-05 | EMA/ATR cannot become Ready | Init occurs, Configure does not | Critical | Configuration owner/value contract required |
| B-06 | Incomplete rollback | EAMain/manager cleanup ownership is inconsistent | High | Manager-owned cleanup and EAMain orchestration patch approval |
| B-07 | Unsafe logging lifetime | Lifecycle logs occur before init and after logger teardown | High | EAMain ordering policy; logger interfaces unchanged |
| B-08 | Unguarded deinit | Existing states have no idempotent state gate | High | EAMain state policy patch; no new enum required |
| B-09 | No actual PA Structure read | Skeleton PA modules have no specified consumer behavior | Medium | Deferred; no remediation implementation now |

## 4. Blocker evidence and minimal proposed remediation

### B-01 — CommonTypes duplicate public enum members

**VERIFIED FROM SOURCE**

`mql5/include/CommonTypes.mqh:5`:

```mql5
enum TrendStrength { STRENGTH_UNKNOWN=0, STRENGTH_WEAK, STRENGTH_NORMAL, STRENGTH_STRONG };
```

`mql5/include/CommonTypes.mqh:13`:

```mql5
enum PatternStrength { STRENGTH_UNKNOWN, STRENGTH_WEAK, STRENGTH_NORMAL, STRENGTH_STRONG };
```

`TrendEngine.mq5:6–9` consumes `TrendStrength` and `STRENGTH_UNKNOWN`. There is no current source consumer of `PatternStrength`; that does not authorize removing a frozen public type.

**INFERENCE**

MQL enum members inhabit the integrated translation-unit identifier namespace. Both enums cannot legally export the same four names.

**Frozen-contract determination**

- **A — Frozen contract must be patched:** **YES**.
- **B — Collision resolvable with no public-contract change:** **NO**.
- **C — Compatibility alias/type redesign required:** an approved redesign is possible, but it cannot retain both identical unscoped member-name sets. An alias cannot solve duplicate names.

**PROPOSED MINIMAL REMEDIATION**

Retain `TrendStrength` and its existing members because current source consumes them. Preserve the `PatternStrength` type but, only after approval, give its members distinct public names such as `PATTERN_STRENGTH_UNKNOWN`, `PATTERN_STRENGTH_WEAK`, `PATTERN_STRENGTH_NORMAL`, and `PATTERN_STRENGTH_STRONG`. This is an explicit frozen compatibility decision, not an automatic rename.

**Affected files/modules:** `CommonTypes.mqh`; all direct/indirect includers; TrendEngine is the current verified Strength consumer.

### B-02 — TrendEngine include path

**VERIFIED FROM SOURCE**

`mql5/modules/TrendEngine.mq5:2` contains:

```mql5
#include <mql5/modules/CommonTypes.mqh>
```

The existing file is `mql5/include/CommonTypes.mqh`; no `mql5/modules/CommonTypes.mqh` exists. `EAMain.mq5:22` includes TrendEngine.

**PROPOSED MINIMAL REMEDIATION**

After B-01 approval, change only the include target to:

```mql5
#include <mql5/include/CommonTypes.mqh>
```

This changes no public function, type signature, event ID, or error code. Do not add a duplicate CommonTypes file or a second TrendEngine implementation.

### B-03 — translation-unit global-variable collisions

**VERIFIED FROM SOURCE**

EAMain directly includes module implementation sources at `EAMain.mq5:6–32`. Collision inventory from current source:

| Global identifier | Declarations | Modules |
|---|---:|---|
| `initialized` | 20 | ATR, BOS, CHOCH, CandleClassifier, Confluence, EMA, Engulfing, Fibonacci, InitManager, InsideBar, LoggerCore, MarketData, OutsideBar, PinBar, PriceActionManager, Retracement, StructureManager, SwingDetector, SwingStorage, TrendEngine |
| `configured` | 14 | ATR, BOS, CHOCH, CandleClassifier, Confluence, EMA, Engulfing, Fibonacci, InsideBar, OutsideBar, PinBar, Retracement, SwingDetector, TrendEngine |
| `ready` | 13 | BOS, CHOCH, CandleClassifier, Confluence, Engulfing, Fibonacci, InsideBar, OutsideBar, PinBar, Retracement, SwingDetector, SwingStorage, TrendEngine |
| `detectedPattern` | 4 | Engulfing, PinBar, InsideBar, OutsideBar |
| `period` | 2 | EMA, ATR |

**ROOT CAUSE**

This is both direct include composition and duplicate un-namespaced global definitions. It is not a duplicate public-function problem.

**PROPOSED MINIMAL REMEDIATION**

Approve a frozen-internal implementation patch to prefix each module’s existing state variables with its module identity, updating only references in that owner module. Example direction: `emaInitialized`, `atrInitialized`, `trendConfigured`, `priceActionManagerInitialized`. Preserve every public function name, parameter list, return type, and lifecycle ownership.

**Rejected alternative:** changing EAMain to include only managers is not a minimal safe repair. Existing managers do not self-include all children and currently rely on the EAMain include composition; such a redesign would introduce unresolved symbols and hidden dependency changes.

### B-04 — ConfigInit result handling

**VERIFIED FROM SOURCE**

`ConfigSystem.mq5:2` is `int ConfigInit() { return INIT_SUCCEEDED; }`. EAMain tests it at `EAMain.mq5:149–151` with `if(!ConfigInit())`.

**ROOT CAUSE**

`INIT_SUCCEEDED` is the successful zero return. Boolean negation therefore sends success down the failure branch.

**PROPOSED EXACT CONTROL FLOW**

After architecture approval, preserve the `int ConfigInit()` interface and use explicit result semantics:

```mql5
int configResult = ConfigInit();
if(configResult != INIT_SUCCEEDED) {
  // Pre-logger failure behavior approved under B-07.
  return false;
}
```

Only success continues to `LoggerInit()`. No Config public-interface modification is proposed.

### B-05 — EMA/ATR configuration before Ready

**VERIFIED FROM SOURCE**

- `EMAInit()` sets initialization only; `EMAConfigure(int p,int ap)` sets configuration; `EMAReady()` requires both (`EMAEngine.mq5:8–20`).
- `ATRInit()` sets initialization only; `ATRConfigure(int p)` sets configuration; `ATRReady()` requires both (`ATREngine.mq5:6–22`).
- `IndicatorManagerInit()` invokes only EMA/ATR init (`IndicatorManager.mq5:3–8`).
- `VerifyIndicatorsReady()` requires both Ready predicates (`EAMain.mq5:110–115`).

**ROOT CAUSE**

No existing startup stage supplies/configures approved values before readiness verification.

**PROPOSED REMEDIATION / REQUIRED DECISION**

No values will be invented from internal defaults (EMA 50/applied price 0, ATR 14). Architecture approval must designate:

1. the configuration owner (existing configuration layer plus EAMain orchestration, or IndicatorManager),
2. authoritative non-trading values and validation policy,
3. whether configuration occurs within or immediately after `IndicatorManagerInit()`, and
4. failure/rollback behavior.

Frozen signatures need not change: existing `EMAConfigure` and `ATRConfigure` already accept required inputs.

### B-06 — rollback completeness

**VERIFIED FROM SOURCE**

- Infrastructure order is Config → Logger → LoggerFile → TimeService → MarketData → SymbolInfo (`EAMain.mq5:149–169`), but `RollbackInfrastructureLayer()` only shuts LoggerFile/Logger (`:175–179`).
- If ATR init fails after EMA init, IndicatorManager returns false without EMA cleanup (`IndicatorManager.mq5:3–8`).
- StructureManager already contains reverse child cleanup for each child-init failure (`StructureManager.mq5:4–8`).
- PriceActionManager returns false on any child failure without child cleanup (`PriceActionManager.mq5:3–14`).
- EAMain does not roll back Price Action when its initialization call itself fails (`EAMain.mq5:287–293`).

**PROPOSED REVERSE-ORDER MATRIX**

| Failure point | Required owner and rollback |
|---|---|
| Config failure | no module teardown; approved pre-logger failure path |
| LoggerFile failure | EAMain infrastructure: Logger shutdown |
| TimeService failure | EAMain infrastructure: LoggerFile → Logger |
| MarketData failure | EAMain infrastructure: TimeService → LoggerFile → Logger |
| SymbolInfo failure | EAMain infrastructure: MarketData → TimeService → LoggerFile → Logger; assess partial SymbolInfo init before calling its shutdown |
| Infrastructure verification failure | EAMain infrastructure: SymbolInfo → MarketData → TimeService → LoggerFile → Logger |
| ATR failure after EMA success | IndicatorManager: EMA shutdown; then EAMain infrastructure rollback |
| Indicator verification failure | IndicatorManager shutdown; then EAMain infrastructure rollback |
| Structure child failure | StructureManager-owned reverse cleanup; then IndicatorManager → infrastructure |
| Structure verification failure | StructureManager → IndicatorManager → infrastructure |
| Price Action child failure | PriceActionManager-owned reverse cleanup; then StructureManager → IndicatorManager → infrastructure |
| Price Action verification failure | PriceActionManager → StructureManager → IndicatorManager → infrastructure |

**Ownership rule:** EAMain rolls back layers; each manager alone rolls back its own children. EAMain must not call child shutdown functions directly.

### B-07 — lifecycle logging boundaries

**VERIFIED FROM SOURCE**

| Location | Invalid timing |
|---|---|
| `EAMain.mq5:399–400` | `STARTUP_BEGIN` before LoggerInit |
| `EAMain.mq5:239–240` | second `STARTUP_BEGIN`, also pre-logger |
| `EAMain.mq5:144–153` | Infrastructure-init event pre-logger |
| `EAMain.mq5:175–177` then `:403–405` | fatal event after rollback shuts logger down |
| `ShutdownManager.mq5:4–10`, EAMain `:388–392` | infrastructure-complete and shutdown-complete after logger teardown |

**SAFE BOUNDARIES / PROPOSED REMEDIATION**

1. Before Logger/LoggerFile are active: do not call EAMain `Log*Event` / `CreateLogEvent`.
2. Emit `STARTUP_BEGIN` once, after logging is active, or use an explicitly approved non-logger pre-init diagnostic path.
3. Emit every logger-backed shutdown event before LoggerFile/Logger teardown.
4. Do not modify frozen logger interfaces. If a semantic event must occur after teardown, an approved non-logger sink is required; it must not be falsely logged through a stopped logger.

### B-08 — legal state transitions and OnDeinit

**VERIFIED FROM SOURCE**

Existing states are `UNINITIALIZED`, `INITIALIZING`, `READY`, `RUNNING`, `STOPPING`, and `SHUTDOWN` (`EAMain.mq5:38–45`). `OnDeinit()` always calls `EADeinit()` (`:412–414`), which unconditionally sets STOPPING (`:367–370`).

**PROPOSED LEGAL DEINIT TABLE**

| Entry state | Required approved behavior |
|---|---|
| UNINITIALIZED | safe no-op; no blind manager shutdown |
| INITIALIZING | state-aware rollback of successfully initialized layers, then terminal shutdown |
| READY | normal Price Action → Structure → Indicators → Infrastructure shutdown |
| RUNNING | same normal shutdown |
| STOPPING | no-op/return; avoid duplicate shutdown |
| SHUTDOWN | no-op/return; preserve terminal state |

No new public state enum is needed. Approval must choose an implementation mechanism for partial-init awareness: a private progress indicator in EAMain or explicitly idempotent existing layer rollback. It must preserve manager ownership.

### B-09 — Structure → Price Action consumption

**VERIFIED FROM SOURCE**

EAMain updates Structure before Price Action (`:344–354`). Structure public read getters exist. None of the nine Price Action sources—CandleClassifier, Engulfing, PinBar, InsideBar, OutsideBar, Fibonacci, Retracement, Confluence, or PriceActionManager—references `GetLastSwing*`, `GetStoredSwing*`, `GetLastBOS*`, `GetLastCHOCH*`, or `GetTrend*`. They also do not write Structure state or create a circular dependency.

**CONCLUSION**

- **a. Missing actual integration:** yes, no output is currently read.
- **b. Documentation-only integration:** public getters and read-only direction are documented.
- **c. Intentionally deferred logic:** yes; the Price Action modules are skeleton/foundation code and no concrete consumer behavior is frozen.

**PROPOSED REMEDIATION:** no source change in this patch. A getter call with no approved non-signal purpose would be invented hidden logic. Defer until a future approved contract defines module, getter(s), retained read-only data, and non-strategy observable behavior.

## 5. Dependency/order of fixes

1. Approve frozen CommonTypes compatibility decision (B-01).
2. Apply approved CommonTypes change and audit consumers.
3. Correct TrendEngine include (B-02).
4. Repair global module-private state collisions (B-03).
5. Approve configuration owner/values and implement indicator configuration (B-05).
6. Correct ConfigInit result control flow (B-04).
7. Repair manager/infrastructure rollback (B-06).
8. Reorder logging to logger lifetime boundaries (B-07).
9. Add state-aware idempotent deinit behavior (B-08).
10. Complete source regression audit; then actual compilation and runtime only when tools exist.
11. Keep B-09 deferred.

## 6. Risk analysis

| Risk | Mitigation |
|---|---|
| PatternStrength compatibility break | Formal frozen contract decision, consumer audit, documented version/compatibility consequence |
| Missed internal variable reference during collision repair | Generate inventory; rename by module; signature/reference audit; actual compiler gate when available |
| Hidden strategy parameters through indicator configuration | Approval must name infrastructure-only values, owner, and validation source |
| Shutdown called on never-initialized child | Progress-aware or explicitly idempotent manager-owned cleanup |
| Lost lifecycle event due logger sequencing | Event-by-event timeline against pre-active-active-post logger boundaries |
| New circular dependency from Structure reads | B-09 deferred; future use restricted to existing public getters |
| False compile/runtime claim | Record only actual MetaEditor/MT5 results |

## 7. Required architecture PATCH decisions

1. **PATCH-CT-01:** frozen `CommonTypes` enum-member compatibility decision (mandatory blocker).
2. **PATCH-INT-01:** authorize internal state-name remediation in frozen modules while preserving every public interface exactly.
3. **PATCH-CFG-01:** define EMA/ATR configuration owner, values, validation, and sequence.
4. **PATCH-RB-01:** approve manager-owned partial rollback and EAMain infrastructure rollback/idempotence policy.
5. **PATCH-LOG-01:** define pre-logger failure behavior and final logger-backed event boundary.
6. **PATCH-DEINIT-01:** define state-safe/idempotent deinit behavior using existing states.
7. **PATCH-PA-01:** formally defer B-09 until a concrete non-strategy consumer contract exists.

## 8. Exact files that would be modified if approved

| File / set | Approved-only purpose |
|---|---|
| `mql5/include/CommonTypes.mqh` | B-01 public enum correction only |
| `mql5/modules/TrendEngine.mq5` | B-02 include correction; B-03 internal state rename |
| `mql5/modules/EAMain.mq5` | B-04, B-05 orchestration, B-06 infrastructure rollback, B-07, B-08 |
| `mql5/modules/IndicatorManager.mq5` | B-05 ownership if approved and B-06 child cleanup |
| `mql5/modules/PriceActionManager.mq5` | B-06 child cleanup and B-03 internal state rename |
| `mql5/modules/StructureManager.mq5` | B-03 internal state rename; alter rollback only if approved audit shows required |
| Collision inventory modules | B-03 internal state renames only: ATR, BOS, CHOCH, CandleClassifier, Confluence, EMA, Engulfing, Fibonacci, InitManager, InsideBar, LoggerCore, MarketData, OutsideBar, PinBar, Retracement, SwingDetector, SwingStorage, TrendEngine, and managers named above |

## 9. Files that must remain untouched

Unless separately approved, remediation must not modify:

- `mql5/include/ErrorCodes.mqh`
- `mql5/include/EventIDs.mqh`
- `mql5/include/PriceActionErrorCodes.mqh`
- `mql5/include/PriceActionEventIDs.mqh`
- `mql5/include/StructureEventIDs.mqh`
- any public function signature, return type, Event ID, or Error Code
- any Strategy, Entry, Exit, Orders, Execution, Risk, Money Management, optimization, or AI source
- Price Action consumer/pattern logic for B-09
- duplicate implementations or compatibility-copy files

`CommonTypes.mqh` remains untouched until PATCH-CT-01 approval.

## 10. Pre-patch acceptance criteria

1. PATCH-CT-01 through PATCH-DEINIT-01 have written approval; PATCH-PA-01 records B-09 as deferred.
2. Complete collision inventory and frozen public API baseline are captured.
3. EMA/ATR values and owner are defined without inferred defaults or trading parameters.
4. Per-failure rollback matrix and logger event timeline are approved.
5. Approved file list is limited to Section 8 and excludes B-09 behavior.
6. No source edit begins before the frozen contract decision is recorded.

## 11. Post-patch verification criteria

1. No duplicate enum member identifier remains; approved compatibility impact is documented.
2. Every project include resolves; TrendEngine uses the existing CommonTypes path.
3. No duplicate global state identifier remains in EAMain’s direct included unit.
4. Public signatures, return types, Event IDs, and Error Codes match baseline except the explicitly approved CommonTypes patch.
5. `ConfigInit() == INIT_SUCCEEDED` continues initialization; non-success returns fail safely.
6. EMA/ATR are configured once by the approved owner before Ready verification.
7. Every failure path follows the rollback matrix and preserves manager ownership.
8. Duplicate Init = 0, Duplicate Update = 0, Duplicate Shutdown = 0 in normal lifecycle paths.
9. No logger-backed event runs outside logger lifetime.
10. OnDeinit is safe/idempotent for every existing EA state.
11. No circular/hidden dependency, Structure write, Strategy, signal, execution, orders, risk, money management, or AI logic is added.
12. Actual `COMPILE PASS` requires actual MetaEditor compilation; actual `RUNTIME PASS` requires MT5 lifecycle execution.

## 12. Recommended implementation sequence

1. Obtain required architecture approvals.
2. Create an approved, file-limited remediation patch.
3. Apply B-01, then B-02 and B-03 compilation foundations.
4. Apply approved B-05 configuration ownership and B-04 result handling.
5. Apply B-06 rollback, B-07 logging order, and B-08 deinit controls.
6. Perform manual source regression audit.
7. When available, run MetaEditor compilation, then bounded MT5 lifecycle validation.
8. Stop. Do not start SPR6-007 and do not implement B-09.

## 13. Final self-audit

| Requirement | Result |
|---|---|
| Source files modified | **0** |
| Frozen interfaces modified | **0** |
| CommonTypes modified | **0** |
| EAMain modified | **0** |
| TrendEngine modified | **0** |
| Strategy logic added | **0** |
| Execution/Risk/AI added | **0** |
| Architecture decisions requiring approval | **Explicitly listed in Section 7** |
| Compiler status | **NOT AVAILABLE** |
| Runtime status | **NOT AVAILABLE** |

```text
SPR6-006B COMPLETE — REMEDIATION PLAN ONLY
ARCHITECTURE PATCH REQUIRED BEFORE SOURCE MODIFICATION
SOURCE MODIFICATIONS: 0
STOP.
```
