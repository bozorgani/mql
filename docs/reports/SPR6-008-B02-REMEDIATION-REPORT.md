# SPR6-008 — Configuration Regression + B-02 Controlled Remediation Report

**Status:** **COMPLETE** — B-02 remediated (one-line include-path correction); SPR6-007 configuration regression verified clean
**Baseline HEAD:** `8798dcf` (`feat: implement frozen configuration contract (SPR6-007)`)
**B-02 verdict:** **FIXED** (all Step 3 stop-conditions satisfied; smallest possible correction applied)
**Compiler:** **NOT VERIFIED — MQL5 COMPILER UNAVAILABLE**

---

## 1. Status

| Item | Value |
|---|---|
| Task scope | (A) Regression verification of SPR6-007 configuration implementation; (B) controlled remediation of B-02 ONLY |
| B-02 patch | Applied — `TrendEngine.mq5` line 2, single include declaration |
| Configuration regression | PASS (all values/flow/ownership/signatures verified unchanged — §6) |
| Source files modified | 1 (`mql5/modules/TrendEngine.mq5`) |
| Public interface changes | **None** |
| Compiler / runtime | NOT VERIFIED (unavailable) |

## 2. Baseline HEAD (Step 1)

- `git rev-parse HEAD` at task start: **`8798dcf5b1d4d5f70fd72907cee9cf1a92bf3c4a`** = `8798dcf` (`feat: implement frozen configuration contract (SPR6-007)`) — verified.
- SPR6-007 commit contains exactly: `docs/reports/SPR6-007-CONFIGURATION-CONTRACT-IMPLEMENTATION-REPORT.md`, `mql5/modules/ConfigSystem.mq5`, `mql5/modules/ConfigValidator.mq5`, `mql5/modules/IndicatorManager.mq5` — verified via `git show --name-only`.
- Working tree at start: only the six pre-existing untracked SPR6-006…006E report files (snapshot state; not part of this task).
- SPR6-007 report re-read; all five config modules re-inspected (ConfigSystem, ConfigValidator, IndicatorManager, EAMain, TrendEngine). **No unauthorized source changes have appeared since SPR6-007** — `git status` shows no tracked modifications at task start.
- Configuration flow verified still: **ConfigSystem → ConfigValidator → IndicatorManager → EMA/ATR** (§6).

## 3. B-02 Source Evidence (Step 2 — independent verification)

| Question | Finding |
|---|---|
| Exact include currently used | `mql5/modules/TrendEngine.mq5:2`: `#include <mql5/modules/CommonTypes.mqh>` |
| Actual filesystem location of target | `mql5/include/CommonTypes.mqh` **exists**; `mql5/modules/CommonTypes.mqh` **does not exist** (`ls` verified) |
| Intentionally frozen? | `CommonTypes.mqh` is frozen ("SPR1-002 Final Freeze + SPR1-003 Prep — CommonTypes frozen") — **not modified**; only the path referencing it is corrected |
| Another source using the correct form | **Yes — 5 modules**: CandleClassifier, EngulfingDetector, InsideBarDetector, OutsideBarDetector, PinBarDetector all use `#include <mql5/include/CommonTypes.mqh>` — correct form is unambiguous |
| New dependency / circular include? | **No.** TrendEngine already semantically depends on CommonTypes (`TrendDirection currentDirection`, `TrendStrength currentStrength`, `TREND_UNKNOWN`, `STRENGTH_UNKNOWN` — `TrendEngine.mq5:6,7,9,19,20`); the fix repairs the broken reference. `CommonTypes.mqh` includes nothing and is `#pragma once`-guarded → no cycle possible |
| Compile blocker? | **Yes.** In the EAMain unit, CommonTypes first appears textually at line 24 (via CandleClassifier), *after* TrendEngine (line 22) — `TrendDirection`/`STRENGTH_UNKNOWN` are used before any declaration. In `tests/StructureRegressionTests.mq5` / `tests/StructureVerificationTests.mq5` (include TrendEngine at line 5, no CommonTypes include before it), the same symbols are unresolved. The nonexistent include path is a genuine compile blocker |
| CommonTypes involved? | Yes — it is the sole dependency; the fix resolves the path to it |

### Step 3 stop-condition gate (all TRUE → patch permitted)

1. ✅ Wrong include path confirmed directly from source (`TrendEngine.mq5:2`)
2. ✅ Correct target path unambiguous from the repository filesystem (`mql5/include/CommonTypes.mqh`; 5 existing correct usages)
3. ✅ Correction requires no public interface change (include declaration only)
4. ✅ Correction does not modify configuration architecture (TrendEngine is not part of the config flow)
5. ✅ Correction introduces no new dependency direction (TrendEngine → CommonTypes already existed semantically)
6. ✅ No changes required outside B-02 scope

## 4. Exact Correction (Step 4)

**Before:** `#include <mql5/modules/CommonTypes.mqh>`
**After:** `#include <mql5/include/CommonTypes.mqh> // B-02: corrected include path`

- One declaration changed; a short B-02 marker comment added.
- No refactoring, no identifier renames, no behavior change, no `TrendStrength`/`PatternStrength` change, no EAMain/ConfigSystem/ConfigValidator/IndicatorManager change, no opportunistic fixes.

## 5. Files Modified

| File | Change |
|---|---|
| `mql5/modules/TrendEngine.mq5` | Line 2: include path corrected (`modules/` → `include/`) |

All other files: **untouched** (`git diff --name-only` = `mql5/modules/TrendEngine.mq5` only).

## 6. Configuration Regression Result (Step 5 — PASS)

| Check | Result |
|---|---|
| Authorized values intact | `CONFIG_EMA_PERIOD = 50`, `CONFIG_EMA_APPLIED_PRICE = 0` (PRICE_CLOSE), `CONFIG_ATR_PERIOD = 14` — `ConfigSystem.mq5:14–16` (verified) |
| ConfigSystem sole configuration source | No other `= 50;` / `= 14;` literals exist in `mql5/modules/` outside the frozen engines' private initializers (which are non-authoritative and always overwritten by the mandatory Configure calls) |
| No duplicate configuration source | Verified — `indicatorConfig` defined only in ConfigSystem; read by ConfigValidator + IndicatorManager |
| `EMAConfigure` signature unchanged | `bool EMAConfigure(int p,int ap)` — `EMAEngine.mq5:11` (file untouched) |
| `ATRConfigure` signature unchanged | `bool ATRConfigure(int p)` — `ATREngine.mq5:9` (file untouched) |
| IndicatorManager still owns EMA/ATR children | `IndicatorManager.mq5` untouched since SPR6-007; `IndicatorManagerInit` validates → inits → configures → reverse-order child rollback |
| EAMain does not directly configure EMA/ATR | Grep: EAMain contains **zero** `EMAConfigure`/`ATRConfigure`/`EMAShutdown`/`ATRShutdown` calls (only a comment at line 196) |
| No strategy logic changed | `git diff` = one include line |
| No B-09 changes | B-09 untouched (deferred) |
| Public interface changes | **None** (expected per task; verified) |
| Circular include introduced | None — `CommonTypes.mqh` includes nothing; `#pragma once` guarded; TrendEngine → CommonTypes direction unchanged |
| Old incorrect include path repo-wide | **Zero** occurrences of `#include <mql5/modules/CommonTypes.mqh>` after the patch (`grep` exit 1) |

## 7. Dependency / Circular-Include Audit

- TrendEngine → CommonTypes (`include/CommonTypes.mqh`): direct include, no intermediate; CommonTypes has no includes → acyclic.
- EAMain unit: TrendEngine (line 22) now self-resolves its CommonTypes dependency; no ordering hazard remains for `TrendDirection`/`TrendStrength`.
- Test units (`StructureRegressionTests`, `StructureVerificationTests`): TrendEngine now self-contained via the corrected include.
- No new dependency direction introduced; no module now depends on a nonexistent path.

## 8. Compiler Status

```text
COMPILE: NOT VERIFIED — MQL5 COMPILER UNAVAILABLE
```
No MQL5 compiler/MetaEditor exists in the sandbox; no compile result is claimed or simulated. Static analysis: the corrected path resolves to the existing frozen header; declaration order is now self-sufficient for every unit that includes TrendEngine.

## 9. Runtime Status

```text
RUNTIME: NOT VERIFIED
```
No MT5/Strategy Tester available.

## 10. Self-Audit (Step 9)

| Question | Answer |
|---|---|
| Did I reopen the configuration decision? | **NO** |
| Did I change EMA period? | **NO** |
| Did I change ATR period? | **NO** |
| Did I change applied price? | **NO** |
| Did I modify EMAConfigure signature? | **NO** |
| Did I modify ATRConfigure signature? | **NO** |
| Did I change strategy logic? | **NO** |
| Did I implement B-09? | **NO** |
| Did I fix B-04? | **NO** |
| Did I fix B-06 remainder? | **NO** |
| Did I fix B-07? | **NO** |
| Did I fix B-08? | **NO** |
| Did I modify EMA applied-price calculation? | **NO** |
| Did I introduce a new public interface? | **NO** |
| Did I modify files outside B-02 scope? | **NO** (TrendEngine include line only) |

## 11. Remaining Sprint 6 Blockers (unchanged, out of scope)

1. **COMPILER / RUNTIME verification** — environment-blocked (MQL5 compiler, MT5 runtime unavailable).
2. **B-04** — `EAMain.mq5:149` `if(!ConfigInit())` inverts `INIT_SUCCEEDED` (0); blocks observable startup; separate PATCH-B04.
3. **B-06 remainder** — rollback gaps (TimeService/MarketData/SymbolInfo omission, PriceActionManager partial rollback); separate PATCH-RB-01.
4. **B-07** — logging outside logger lifetime; separate PATCH-LOG-01.
5. **B-08** — unguarded deinit; separate PATCH-DEINIT-01.
6. **EMA applied-price consumption** — `EMAUpdate()` bid-based, ignores `appliedPrice`; recorded, future separate approval.
7. **B-01** (CommonTypes PatternStrength collision) — PATCH-CT-01, separate.
8. **B-09** — deferred by decision.

## 12. Final B-02 Verdict

```text
B-02: FIXED — include path corrected from <mql5/modules/CommonTypes.mqh>
      to <mql5/include/CommonTypes.mqh> in mql5/modules/TrendEngine.mq5:2.
      One-line change; no public interface, configuration, dependency,
      or behavior impact. COMPILE: NOT VERIFIED — MQL5 COMPILER UNAVAILABLE.
```

---

*SPR6-008 — configuration regression verified + B-02 controlled remediation only. No push. Stopping after SPR6-008; no other remediation started.*
