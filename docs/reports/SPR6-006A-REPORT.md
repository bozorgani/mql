# SPR6-006A Report — Defect Remediation Before Runtime Gate

**Date:** 2026-08-20  
**Method:** MANUAL SOURCE VALIDATION only  
**Source patch:** none — stop condition reached before any source modification  
**Status:** **SPR6-006A BLOCKED — ARCHITECTURE REVIEW REQUIRED**

## Scope and stop decision

This review re-inspected the repository source; it did not rely on the SPR6-006 report as proof. The source confirms a duplicate public-enumerator defect in the frozen shared contract `mql5/include/CommonTypes.mqh`. The required minimal correction would rename or remove public enum members. That is a frozen-interface contract change.

Per the task stop condition, no source defect was patched after that finding. This includes otherwise small non-interface corrections such as the TrendEngine include path and EAMain result check. This report is the only file created by SPR6-006A.

A baseline comparison against `e941b604754feaa70cd6db3fc7dcdf0421d2d4a4` shows that the inspected source files are unchanged from the frozen baseline. The defects are existing baseline defects, not drift introduced by Sprint 6 work.

## 1. Finding — TrendEngine include path

| Item | Result |
|---|---|
| Source location | `mql5/modules/TrendEngine.mq5:2` |
| Exact source | `#include <mql5/modules/CommonTypes.mqh>` |
| Existing valid file | `mql5/include/CommonTypes.mqh` |
| Root cause | Directory component is `modules` rather than `include` |
| Severity | Critical compile blocker |
| Affected interface | No public function/type signature would need to change; the source needs the existing shared type declarations |
| Frozen status | `TrendEngine.mq5` is part of the Sprint 3 frozen baseline |
| Fix applied | **Not applied** because the frozen-contract stop condition below was reached before modification |
| Smallest safe correction after disposition | Change only this include target to `<mql5/include/CommonTypes.mqh>`; do not add a duplicate file or TrendEngine implementation |

`EAMain.mq5` includes `TrendEngine.mq5` directly (`EAMain.mq5:22`), so the invalid include is part of the primary integrated translation unit.

## 2. Finding — global variable collisions from direct include composition

| Item | Result |
|---|---|
| Composition mechanism | `EAMain.mq5:6–32` directly includes all module implementation `.mq5` files into one translation unit |
| Root cause | Module-private state is declared as un-namespaced global variables in many included implementation files |
| Severity | Critical compile blocker |
| Interface impact | Public function signatures need not change; internal state names/encapsulation would need coordinated repair |
| Frozen status | Affected module sources are Sprint 1–5 frozen baseline files |
| Fix applied | **Not applied** due to frozen-contract stop condition |

Verified collisions include:

| Global identifier | Number of declarations | Representative locations |
|---|---:|---|
| `initialized` | 20 | `EMAEngine.mq5:2`, `ATREngine.mq5:2`, `StructureManager.mq5:2`, `PriceActionManager.mq5:2` |
| `configured` | 14 | `EMAEngine.mq5:3`, `ATREngine.mq5:3`, `TrendEngine.mq5:4` |
| `ready` | 13 | `SwingDetector.mq5:4`, `CandleClassifier.mq5:6`, `TrendEngine.mq5:5` |
| `detectedPattern` | 4 | Engulfing, PinBar, InsideBar, and OutsideBar detector sources |
| `period` | 2 | `EMAEngine.mq5:5`, `ATREngine.mq5:4` |

These are not separate runtime instances when their `.mq5` source files are included by EAMain: they are declarations in the same integrated compilation unit. The smallest eventual compatible remedy is unique module-private state identifiers (or an architecture-approved isolation mechanism), while preserving all existing public function names, signatures, and behavior. Adding hidden global state or a second implementation is not appropriate.

## 3. Finding — frozen CommonTypes enum collision (STOP CONDITION)

| Item | Result |
|---|---|
| Source location | `mql5/include/CommonTypes.mqh:5` and `:13` |
| Exact duplicates | `STRENGTH_UNKNOWN`, `STRENGTH_WEAK`, `STRENGTH_NORMAL`, `STRENGTH_STRONG` |
| First enum | `TrendStrength` at line 5 |
| Second enum | `PatternStrength` at line 13 |
| Affected modules | At minimum TrendEngine consumes `TrendStrength` and `STRENGTH_UNKNOWN` (`TrendEngine.mq5:6–9`); all pattern modules include CommonTypes directly or through EAMain |
| Baseline status | Present unchanged in `e941b604754feaa70cd6db3fc7dcdf0421d2d4a4` |
| Severity | Critical compile blocker and frozen public-contract defect |
| Fix applied | **Not applied** |

`PatternStrength` has no current source consumer outside `CommonTypes.mqh`, but that does not make its public members safe to remove or rename. In an MQL translation unit enum members are unscoped/global identifiers; the same four names cannot legally be declared by both enums.

**Minimal architecture-approved correction required:** an explicit frozen-contract decision must choose distinct public enumerator names for one enum, or formally remove/replace the unused public enum. The decision must identify compatibility expectations for both `TrendStrength` and `PatternStrength`. SPR6-006A does not silently alter this frozen shared contract.

## 4. Finding — ConfigInit result semantics

| Item | Result |
|---|---|
| Source locations | `mql5/modules/ConfigSystem.mq5:2`; `mql5/modules/EAMain.mq5:149–151` |
| Actual contract | `ConfigInit()` returns `int` and returns `INIT_SUCCEEDED` on success |
| Root cause | EAMain evaluates the int with `if(!ConfigInit())` |
| Severity | Critical lifecycle blocker |
| Effect | `INIT_SUCCEEDED` is zero; negation evaluates true, so a successful config init follows the failure branch and startup aborts |
| Interface impact | No Config public interface change is required |
| Frozen status | ConfigSystem is frozen; EAMain is the non-frozen orchestration implementation |
| Fix applied | **Not applied** due to the earlier frozen-contract stop condition |
| Smallest safe correction after disposition | Compare the result explicitly with the actual `INIT_SUCCEEDED`/failure semantics, preserving `ConfigInit()` signature |

## 5. Finding — EMA/ATR configuration and readiness

| Item | Result |
|---|---|
| Source locations | `EMAEngine.mq5:8–20`, `ATREngine.mq5:6–22`, `IndicatorManager.mq5:3–16`, `EAMain.mq5:110–115`, `:181–191` |
| Actual lifecycle | `EMAReady()` requires `initialized && configured`; `ATRReady()` requires `initialized && configured` |
| Root cause | `IndicatorManagerInit()` calls only `EMAInit()` then `ATRInit()`. It calls neither `EMAConfigure(int p, int ap)` nor `ATRConfigure(int p)`. EAMain immediately requires both Ready predicates. |
| Severity | Critical readiness blocker |
| Interface impact | Existing configuration interfaces have the needed parameters; no signature change is justified |
| Frozen status | Engines and IndicatorManager are frozen baseline modules; EAMain is orchestration implementation |
| Fix applied | **Not applied** |

No current startup configuration contract supplies the required values. Although the engines contain internal defaults (`EMA` period 50/applied price 0 and `ATR` period 14), treating those implementation values as an approved startup configuration would be guessing configuration policy. The required correction is an architecture decision that assigns existing `EMAConfigure` and `ATRConfigure` calls to an owner and defines their source values, without introducing strategy/trading parameters. Until then, `VerifyIndicatorsReady()` cannot legitimately pass.

## 6. Finding — rollback completeness

| Layer / failure path | Exact source and result |
|---|---|
| Infrastructure | `RollbackInfrastructureLayer()` at `EAMain.mq5:175–179` stops only LoggerFile and Logger. It does not stop successfully initialized SymbolInfo, MarketData, or TimeService on later infrastructure failure. |
| Indicators | If `ATRInit()` fails after `EMAInit()` succeeds, `IndicatorManagerInit()` returns false without calling `EMAShutdown()` (`IndicatorManager.mq5:3–8`). EAMain’s manager-init failure branch at `:255–260` rolls back only infrastructure. |
| Structure | `StructureManagerInit()` contains explicit reverse cleanup at `StructureManager.mq5:4–8`; this layer has the intended manager-owned failure cleanup shape. |
| Price Action | `PriceActionManagerInit()` returns directly on child failure without cleanup (`PriceActionManager.mq5:3–14`). EAMain’s manager-init failure branch `:287–293` does not call `RollbackPriceActionLayer()`. |

**Severity:** High.  
**Root cause:** rollback assumes manager init failures self-clean, but IndicatorManager and PriceActionManager do not; infrastructure rollback is partial.  
**Interface impact:** existing shutdown functions are sufficient; no public signature change is apparent.  
**Fix applied:** **Not applied** due to frozen-contract stop condition.  
**Smallest eventual correction:** ensure each manager owns cleanup of only its successfully initialized children, and make EAMain infrastructure rollback invoke shutdown only for infrastructure services already initialized. Do not introduce direct child shutdowns in EAMain.

## 7. Finding — lifecycle logging ordering

| Source location | Defect |
|---|---|
| `EAMain.mq5:399–400` | `OnInit()` emits `STARTUP_BEGIN` before `LoggerInit()` |
| `EAMain.mq5:239–240` | `EAStartup()` emits a second `STARTUP_BEGIN`, also before LoggerInit |
| `EAMain.mq5:144–153` | Infrastructure-init event is logged before logger lifetime begins |
| `EAMain.mq5:175–177`, `:403–405` | a rollback shuts logger down, then OnInit emits `FATAL_INIT_FAILURE` |
| `ShutdownManager.mq5:4–10`, `EAMain.mq5:388–392` | `ShutdownManagerStop()` shuts LoggerFile/Logger down, then EAMain emits infrastructure-complete and shutdown-complete events |

**Severity:** High.  
**Root cause:** lifecycle event placement is not bounded by LoggerInit/LoggerShutdown.  
**Interface impact:** no frozen event identifier need change.  
**Fix applied:** **Not applied**.  
**Smallest eventual correction:** retain Logger/LoggerFile through the last required lifecycle event, suppress/prefer a valid non-logger mechanism for the pre-logger phase, and emit `STARTUP_BEGIN` once.

## 8. Finding — OnDeinit / EADeinit state guard

`EADeinit()` unconditionally logs and assigns `EA_STOPPING` (`EAMain.mq5:367–370`). `OnDeinit()` calls it without a guard (`:412–414`).

| State on entry | Current behavior | Required safe behavior |
|---|---|---|
| `EA_UNINITIALIZED` | transitions to STOPPING and invokes all shutdowns | safe no-op/deinit without illegal transition |
| `EA_INITIALIZING` | transitions to STOPPING; no explicit partial-init state-aware cleanup | safe rollback/deinit |
| `EA_READY` | normal shutdown | normal shutdown |
| `EA_RUNNING` | normal shutdown | normal shutdown |
| `EA_STOPPING` | repeats shutdown | avoid duplicate shutdown |
| `EA_SHUTDOWN` | transitions back to STOPPING and repeats shutdown | avoid duplicate shutdown |

**Severity:** High.  
**Interface impact:** no new state is needed; guard existing state values.  
**Fix applied:** **Not applied**.  
**Smallest eventual correction:** make deinitialization idempotent and gate normal shutdown to READY/RUNNING, while making UNINITIALIZED/SHUTDOWN safe no-ops and INITIALIZING use valid rollback behavior.

## 9. Finding — Structure → Price Action read-only consumption

Actual Price Action sources (`CandleClassifier`, `EngulfingDetector`, `PinBarDetector`, `InsideBarDetector`, `OutsideBarDetector`, `FibonacciEngine`, `RetracementDetector`, `ConfluenceManager`, and `PriceActionManager`) contain no reference to Structure public getters or Structure modules.

The public read-only getters exist, including `GetLastSwingPrice()`, `GetStoredSwingPrice()`, `GetLastBOSPrice()`, `GetLastCHOCHPrice()`, `GetTrendDirection()`, and `GetTrendStrength()`. Price Action does not write Structure state and no circular dependency was found.

The current frozen implementation sources are explicitly skeleton/foundation modules with deferred algorithms. No existing concrete Price Action consumer behavior defines what a Structure read should do. Adding a getter call solely to claim consumption would invent behavior and violate the no-hidden-logic rule.

| Result | Status |
|---|---|
| Read-only direction / no writes / no cycle | Preserved |
| Actual Structure-output consumption | Not implemented |
| Fix applied | **Not applied — deferred technical debt, not safe to invent** |
| Interface impact | Existing public getters are sufficient when an approved consumer behavior is defined |

## 10. Regression result

No source correction was made, so no regression test/actual compilation could be performed. Static re-audit results:

| Check | Result |
|---|---|
| Duplicate Init in normal EAMain ownership path | 0 |
| Duplicate Update in one EAMain update cycle | 0 |
| Duplicate Shutdown in normal EAMain path | 0 |
| Circular dependency | None found |
| Hidden dependency | No new dependency introduced by this task |
| New public interface | None |
| Frozen interface drift from baseline | None |
| Strategy / Entry / Exit / Orders / Execution | None added |
| Risk / Money Management / AI | None added |

## 11. Files changed

| File | Change |
|---|---|
| `docs/reports/SPR6-006A-REPORT.md` | Created remediation review and stop-condition report |

No `.mq5` or `.mqh` file was changed.

## 12. Compiler result

**Compiler: NOT AVAILABLE**

Checked for MetaEditor, terminal, Wine, and MQL5 compiler executables; none is installed. No actual compilation was run.

**Actual compilation:** NOT PERFORMED.  
**Manual validation:** FAIL/BLOCKED because the invalid include, global-name collisions, and frozen enum collision remain.

## 13. Runtime result

**Runtime: NOT AVAILABLE**

No MT5 terminal or Strategy Tester was found. No actual lifecycle test was run.

**Actual runtime:** NOT PERFORMED.

## 14. Remaining blockers

1. **Architecture review required:** resolve frozen `CommonTypes.mqh` public enum-member collision.
2. Correct the invalid TrendEngine include only after the frozen-contract review allows remediation to proceed.
3. Establish a safe module-private-state isolation/naming remediation for the direct-include translation unit.
4. Define approved EMA/ATR startup configuration ownership and values using existing interfaces.
5. Repair EAMain/manager rollback, logger lifetime ordering, and deinit state guards.
6. Keep actual Structure consumption deferred until concrete approved Price Action consumer behavior exists.
7. Obtain an actual MetaEditor/MQL5 compiler and MT5 Strategy Tester environment after source blockers are remediated.

## 15. Architecture verdict

```text
STATUS: SPR6-006A BLOCKED — ARCHITECTURE REVIEW REQUIRED

MANUAL VALIDATION: BLOCKED
ARCHITECTURE: NOT APPROVED
ACTUAL COMPILATION: NOT PERFORMED
ACTUAL RUNTIME: NOT PERFORMED

Compiler: NOT AVAILABLE
Runtime: NOT AVAILABLE
```

The frozen CommonTypes public contract must be dispositioned before source remediation continues. Do not start SPR6-007.

## 16. Final self-audit

| Question | Result |
|---|---|
| Frozen files modified? | **NO** |
| Frozen interfaces changed? | **NO** |
| Trend include fixed? | **NO** — verified invalid; deferred by stop condition |
| Global collisions fixed? | **NO** — verified; deferred by stop condition |
| CommonTypes duplicate verified? | **YES** — four duplicate public enumerator names; baseline-existing |
| ConfigInit semantics fixed? | **NO** — inversion verified; deferred |
| EMA/ATR configuration resolved? | **NO** — configuration ownership/value contract missing |
| Rollback complete? | **NO** — incomplete paths verified |
| Logging lifecycle safe? | **NO** — pre-init/post-shutdown calls verified |
| Deinit guarded? | **NO** — illegal/repeated transitions verified |
| Structure → Price Action integration status? | **Read-only non-write direction preserved; actual consumption deferred** |
| Duplicate Init? | **0** normal path |
| Duplicate Update? | **0** normal path |
| Duplicate Shutdown? | **0** normal path |
| Circular dependency? | **NO** |
| Hidden logic? | **NO** |
| Strategy logic? | **NO** |
| Execution? | **NO** |
| Risk? | **NO** |
| Money? | **NO** |
| AI? | **NO** |
