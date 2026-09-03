# SPR6-006C — Controlled Remediation Report

**Status:** **SPR6-006C BLOCKED — CONFIGURATION CONTRACT REQUIRED**  
**Validation mode:** Manual source verification  
**MQL5 source modifications:** **0**  
**B-09:** **DEFERRED**

## 1. Executive Summary

SPR6-006C began with the required baseline/configuration audit before source modification. The audit reached the approved PATCH-CFG-01 stop condition: the repository provides no authoritative EMA/ATR startup configuration values.

`ConfigSystem` provides only `ConfigInit`, `ConfigLoad`, `ConfigValidate`, and `ConfigStatus`; it exposes no EMA period, EMA applied-price, ATR period, settings object, getter, input, or validated configuration record. The only apparent values (EMA 50/applied-price 0 and ATR 14) are private engine field initializers, which PATCH-CFG-01 expressly prohibits treating as approved values. Documentation with strategy-oriented EMA values is not an authoritative existing configuration layer and is excluded from this architecture-only patch.

Per the instruction to **STOP immediately** when authoritative configuration values are unavailable, no approved B-01 through B-08 source patch was applied. This report is the sole file created by this task.

## 2. Baseline audit

| Check | Result |
|---|---|
| Current branch | `arena/01a01e68-mql` |
| Current MQL5 source delta from frozen base | None before SPR6-006C work |
| `CommonTypes.mqh` modified | No |
| `EAMain.mq5` modified | No |
| `TrendEngine.mq5` modified | No |
| Frozen module modified | No |
| Existing public interface changed | No |
| Compiler available | No |
| MT5 runtime available | No |

## 3. PATCH-CFG-01 source trace and stop condition

### Verified from source

| Contract point | Source evidence |
|---|---|
| Config public surface | `mql5/modules/ConfigSystem.mq5:2–5` provides only `ConfigInit()`, `ConfigLoad()`, `ConfigValidate()`, `ConfigStatus()` |
| Config validation | `mql5/modules/ConfigValidator.mq5:13–14` returns `VAL_PENDING`; no indicator configuration is exposed |
| EMA initialization | `mql5/modules/EMAEngine.mq5:8` — `EMAInit()` sets initialized only |
| EMA configuration | `EMAEngine.mq5:11` — `EMAConfigure(int p,int ap)` sets values/configured |
| EMA readiness | `EMAEngine.mq5:20` — requires initialized and configured |
| ATR initialization | `mql5/modules/ATREngine.mq5:6` — `ATRInit()` sets initialized only |
| ATR configuration | `ATREngine.mq5:9` — `ATRConfigure(int p)` sets value/configured |
| ATR readiness | `ATREngine.mq5:22` — requires initialized and configured |
| Manager sequence | `mql5/modules/IndicatorManager.mq5:3–8` calls only `EMAInit()` then `ATRInit()` |
| EAMain ready check | `mql5/modules/EAMain.mq5:110–115` requires `EMAReady()` and `ATRReady()` |
| Repository-wide call audit | The only `EMAConfigure`/`ATRConfigure` occurrences are their definitions; no startup caller or config getter exists |

### Root cause

The frozen indicator contracts require configuration before Ready, but the current architecture contains no approved configuration owner/value source in the startup path. The private initializers `period = 50`, `appliedPrice = 0`, and `period = 14` are implementation defaults, not values supplied by an authoritative configuration contract.

### Stop decision

PATCH-CFG-01 states: *“If authoritative values are not available from the existing configuration layer: STOP before inventing values. Do NOT silently use 50/14 or any other defaults.”*

The condition is met. SPR6-006C therefore stops before modifying any B-01 through B-08 source.

### Required architecture decision

A follow-up architecture decision must define all of the following before controlled remediation resumes:

1. authoritative source of EMA period, EMA applied price, and ATR period;
2. owner responsible for obtaining and validating those values;
3. whether the owner is ConfigSystem/EAMain orchestration or IndicatorManager;
4. configuration failure behavior and rollback interaction; and
5. confirmation that values are infrastructure/indicator configuration rather than strategy parameters.

No new public interface, manager API, Strategy input, or hidden fallback was introduced.

## 4. Approved patches not applied

| Approved patch | Source modification applied? | Reason |
|---|---:|---|
| PATCH-CT-01 — CommonTypes PatternStrength names | No | Global stop condition reached before edits |
| PATCH-INT-02 — TrendEngine include | No | Global stop condition reached before edits |
| PATCH-INT-01 — internal collision names | No | Global stop condition reached before edits |
| PATCH-CFG-01 — EMA/ATR configuration | No | Authoritative values absent; mandatory stop |
| PATCH-B04 — explicit ConfigInit comparison | No | Global stop condition reached before edits |
| PATCH-RB-01 — rollback completion | No | Global stop condition reached before edits |
| PATCH-LOG-01 — logger lifetime ordering | No | Global stop condition reached before edits |
| PATCH-DEINIT-01 — state-safe deinit | No | Global stop condition reached before edits |

## 5. Files modified

| File | Exact reason |
|---|---|
| `docs/reports/SPR6-006C-REMEDIATION-REPORT.md` | Documents the required PATCH-CFG-01 stop condition and source evidence |

No `.mq5` or `.mqh` source file was modified.

## 6. Public interfaces before/after

| Category | Before | After | Result |
|---|---|---|---|
| CommonTypes enum types/members | Existing frozen contract | Unchanged | No PATCH-CT-01 application |
| EMA interfaces | `EMAInit`, `EMAConfigure(int,int)`, `EMAReady`, etc. | Unchanged | No signature change |
| ATR interfaces | `ATRInit`, `ATRConfigure(int)`, `ATRReady`, etc. | Unchanged | No signature change |
| Config interface | `int ConfigInit()` and existing helpers | Unchanged | No signature change |
| Event IDs / Error Codes | Existing frozen registries | Unchanged | No change |

## 7. CommonTypes compatibility impact

PATCH-CT-01 was **not applied**. `TrendStrength` and `PatternStrength` still contain the duplicate `STRENGTH_UNKNOWN`, `STRENGTH_WEAK`, `STRENGTH_NORMAL`, and `STRENGTH_STRONG` members identified in SPR6-006A/006B. The approved rename has not been performed, so no compatibility impact has occurred in this task.

## 8. Collision remediation inventory

PATCH-INT-01 was **not applied**. The verified direct-include collision inventory remains unchanged:

| Identifier | Current duplicate declarations |
|---|---:|
| `initialized` | 20 |
| `configured` | 14 |
| `ready` | 13 |
| `detectedPattern` | 4 |
| `period` | 2 |

No private variables or public identifiers were renamed.

## 9. Configuration source used

**None.** No authoritative existing configuration source exists for EMA/ATR startup values. No fallback/default/private initializer was used.

## 10. Rollback matrix

PATCH-RB-01 was not applied. The SPR6-006B proposed reverse-order matrix remains a plan only. Current known defects therefore remain:

- infrastructure rollback omits successfully initialized SymbolInfo, MarketData, and TimeService services;
- IndicatorManager can retain EMA after ATR init failure;
- PriceActionManager can retain earlier children after later child init failure;
- StructureManager is the only verified manager with explicit child failure cleanup.

No duplicate child shutdown ownership was introduced.

## 11. Logging lifecycle audit

PATCH-LOG-01 was not applied. Existing unsafe calls remain unchanged:

- `STARTUP_BEGIN` is emitted in `OnInit` before LoggerInit;
- another `STARTUP_BEGIN` is emitted in `EAStartup` before LoggerInit;
- infrastructure initialization logging begins before logger availability;
- `FATAL_INIT_FAILURE` can follow logger rollback;
- infrastructure-complete and shutdown-complete events occur after `ShutdownManagerStop()` tears LoggerFile/Logger down.

No frozen Logger interface was modified and no second logging system was added.

## 12. Deinit state matrix

PATCH-DEINIT-01 was not applied. Current EAMain behavior remains unchanged:

| Entry state | Current result | Required future behavior |
|---|---|---|
| `EA_UNINITIALIZED` | unconditional `EA_STOPPING` path | safe no-op |
| `EA_INITIALIZING` | unconditional shutdown, not progress-aware | rollback initialized layers only |
| `EA_READY` | normal shutdown path | normal shutdown |
| `EA_RUNNING` | normal shutdown path | normal shutdown |
| `EA_STOPPING` | repeats shutdown | no-op |
| `EA_SHUTDOWN` | transitions back to STOPPING | safe no-op |

No state enum name, value, or public accessor changed.

## 13. B-09 deferred confirmation

**B-09 remains deferred.** No Price Action module was changed to read Structure output. No Structure write, circular dependency, pattern-context logic, signal, strategy, or trading behavior was added.

## 14. Regression result

Because no source patch was permitted, post-patch regression validation is not applicable. Baseline static results remain:

| Check | Result |
|---|---|
| Duplicate Init in normal EAMain path | 0 |
| Duplicate Update in normal EAMain path | 0 |
| Duplicate Shutdown in normal EAMain path | 0 |
| New circular dependency introduced | 0 |
| New hidden dependency introduced | 0 |
| New public interface introduced | 0 |
| New Strategy/Entry/Exit/Order/Execution logic | 0 |
| New Risk/Money Management/AI logic | 0 |

Existing compile-blocking include/global/enum defects remain unresolved because the controlled stop condition prevented implementation.

## 15. Compiler and runtime status

```text
COMPILE: NOT VERIFIED — MQL5 COMPILER UNAVAILABLE
RUNTIME: NOT VERIFIED
```

No MetaEditor/MQL5 compiler, MT5 terminal, or Strategy Tester is available. No compile or runtime result is claimed.

## 16. Self-audit

| Question | Result |
|---|---|
| Source files modified | **0** |
| Frozen modules modified | **0** |
| Frozen public interfaces changed | **0** |
| CommonTypes modified | **0** |
| EAMain modified | **0** |
| TrendEngine modified | **0** |
| PatternStrength consumers changed | **0** |
| Global collisions fixed | **0** |
| Authoritative EMA/ATR configuration source found | **No** |
| ConfigInit semantics fixed | **0** |
| Rollback fixed | **0** |
| Logging lifecycle fixed | **0** |
| Deinit guard fixed | **0** |
| B-09 implemented | **0 — deferred** |
| Strategy / signals / Entry / Exit added | **0** |
| Execution / Orders added | **0** |
| Risk / Money Management / AI added | **0** |

## 17. Architecture verdict

```text
SPR6-006C BLOCKED — CONFIGURATION CONTRACT REQUIRED

SOURCE MODIFICATIONS: 0
FROZEN PUBLIC INTERFACE CHANGES: 0
B-09: DEFERRED
COMPILER: NOT VERIFIED — MQL5 COMPILER UNAVAILABLE
RUNTIME: NOT VERIFIED

STOP: Authoritative EMA/ATR configuration ownership and values must be approved before any controlled source remediation can proceed.
```
