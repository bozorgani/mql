# SPR6-007 — Frozen Configuration Contract Patch — Implementation Report

**Status:** **COMPLETE (SOURCE-LEVEL) — CONTRACT IMPLEMENTED; COMPILE/RUNTIME NOT VERIFIED**
**Task type:** Controlled implementation (first source-modification task of Sprint 6)
**Baseline HEAD:** `80a0dcc` (`docs: finalize Sprint 6 configuration authorization`)
**PATCH-CFG-01:** **IMPLEMENTED AT SOURCE LEVEL** — see §14 for the exact verdict and its conditions

> SPR6-007 implements the formally authorized frozen configuration contract (the blocker recorded by SPR6-006G §11). Values, ownership, validation rules, and interface preservation follow the SPR6-006G authorization exactly. No strategy behavior, no new inputs, no configuration files, and no engine-calculation changes were introduced. The known `appliedPrice` consumption limitation was **not** fixed (explicitly out of scope) and is recorded in §5.3.

---

## 1. Status

| Item | Value |
|---|---|
| Contract implemented | YES — typed `IndicatorConfig` record owned by ConfigSystem (Option A, per SPR6-006G §4) |
| Values | Authorized per SPR6-006G: EMA 50, PRICE_CLOSE (0), ATR 14 |
| Compiler | **NOT AVAILABLE — MQL5 compiler not present; COMPILE: NOT VERIFIED** |
| Runtime | **NOT AVAILABLE — no MT5/Strategy Tester; RUNTIME: NOT VERIFIED** |
| Source files modified | 3 (ConfigSystem, ConfigValidator, IndicatorManager) |
| Frozen engines modified | 0 (EMAEngine, ATREngine untouched) |
| EAMain modified | 0 |

## 2. Baseline Commit / HEAD

- Actual HEAD before this task: **`80a0dcc`** (`docs: finalize Sprint 6 configuration authorization`), parent `2e0eb02` (`docs: define Sprint 6 configuration contract approval package`), root `e941b60` (`update all`) — verified via `git log` and `git status` at task start.
- Working tree at start: only the six untracked SPR6-006…006E report files (pre-existing snapshot state; not part of this task).
- SPR6-006G was re-read and its authorized values/ownership confirmed against the task brief — **no contradiction found** (stop-condition 2 not triggered).

## 3. Source Files Modified

| File | Change |
|---|---|
| `mql5/modules/ConfigSystem.mq5` | Added `#include <mql5/include/CommonTypes.mqh>`; added authorized constants, `IndicatorConfig` struct + `indicatorConfig` record; `ConfigInit()` populates the record; `ConfigValidate()` and `ConfigStatus()` completed from stubs |
| `mql5/modules/ConfigValidator.mq5` | Added `#include <mql5/include/CommonTypes.mqh>`; `ValidateConfiguration()` completed from `VAL_PENDING` to real validation of the three fields (signature unchanged, zero-arg) |
| `mql5/modules/IndicatorManager.mq5` | `IndicatorManagerInit()`: validate → init children → apply configuration from record → reverse-order child rollback on any failure (public signature unchanged) |
| All other files | **Untouched** (verified: `git diff --name-only` lists exactly the three files above) |

## 4. Exact Frozen Interface Changes

The task authorized modifying only the minimum required frozen interface. The complete list:

**ConfigSystem (frozen Sprint 1 module — the approved frozen contract change):**
1. **New public record type** `struct IndicatorConfig { int emaPeriod; int emaAppliedPrice; int atrPeriod; }` — the approved typed transport (Option A). No getters were added (record access via the shared compilation unit; minimal surface).
2. **New public record instance** `IndicatorConfig indicatorConfig;` — sole configuration data holder.
3. **New public authorized-value constants**: `CONFIG_EMA_PERIOD = 50`, `CONFIG_EMA_APPLIED_PRICE = 0` (PRICE_CLOSE), `CONFIG_ATR_PERIOD = 14` — single auditable representation of the approved values.
4. **`ConfigValidate()` completed**: stub `return true` → `return (ValidateConfiguration() == VAL_OK);`
5. **`ConfigStatus()` completed**: stub `return true` → `return ConfigValidate();` (status now reflects validated configuration; called by EAMain `VerifyInfrastructureReady()` — no EAMain change needed).
6. **`ConfigInit()` populated**: assigns the three authorized constants into the record (acquisition step).
7. **`ConfigLoad()` unchanged** (still `return true` — authorized values are compile-time constants; no external payload exists).

**ConfigValidator (frozen Sprint 1 module):**
8. **`ValidateConfiguration()` completed** from `VAL_PENDING` to validation of EMA period > 0, ATR period > 0, applied price in 0..6 — reusing existing primitives only (`ValidatePositive`, `ValidateEnumValue`). Signature (zero-arg) unchanged. `ValidateDuplicate()`/`ValidateConsistency()` remain `VAL_PENDING` (unrelated).

**IndicatorManager (frozen Sprint 2 module):**
9. **`IndicatorManagerInit()`** now performs validate → `EMAInit` → `ATRInit` → `EMAConfigure` → `ATRConfigure` → reverse-order rollback on failure. Public signature unchanged.

**Unchanged public signatures (mandatory preservation):**
- `bool EMAConfigure(int period, int appliedPrice)` — `EMAEngine.mq5:11` — unchanged
- `bool ATRConfigure(int period)` — `ATREngine.mq5:9` — unchanged
- `EMAReady()` / `ATRReady()` — unchanged
- `IndicatorManagerInit()` / `IndicatorManagerShutdown()` / `IndicatorManagerStatus()` / `VerifyEMAReady()` / `VerifyATRReady()` — unchanged
- `ConfigInit()` / `ConfigLoad()` / `ConfigValidate()` / `ConfigStatus()` — signatures unchanged (bodies completed)
- `ValidateConfiguration()` — signature unchanged (body completed)

**Include additions note:** `CommonTypes.mqh` has `#pragma once`; the two added includes are idempotent in the EAMain unit and resolve a pre-existing latent declaration-order exposure (ConfigValidator already used `ValidationResult` before CommonTypes was textually included). This is part of the contract patch, not unrelated remediation.

## 5. Configuration Contract Implemented

### 5.1 Data flow (implemented)

```text
ConfigSystem (source/data owner)
  CONFIG_EMA_PERIOD=50, CONFIG_EMA_APPLIED_PRICE=0 (PRICE_CLOSE), CONFIG_ATR_PERIOD=14
    → ConfigInit() populates IndicatorConfig indicatorConfig
    → ConfigValidate()/ConfigStatus() gate via ValidateConfiguration()
        ↓
ConfigValidator (validation owner)
  ValidateConfiguration(): emaPeriod > 0, atrPeriod > 0, emaAppliedPrice ∈ [0,6]  → VAL_OK
        ↓
IndicatorManager (application/child-lifecycle owner)
  IndicatorManagerInit(): ValidateConfiguration()==VAL_OK
    → EMAInit() → ATRInit()
    → EMAConfigure(indicatorConfig.emaPeriod, indicatorConfig.emaAppliedPrice)
    → ATRConfigure(indicatorConfig.atrPeriod)
        ↓
EMA / ATR engines (frozen contracts, unchanged signatures)
  EMAReady() = initialized && configured ; ATRReady() = initialized && configured
```

### 5.2 Exact authorized values (single representation in ConfigSystem)

| Field | Authorized value | Constant | Validation |
|---|---|---|---|
| EMA period | **50** | `CONFIG_EMA_PERIOD` | `ValidatePositive` (> 0) |
| EMA applied price | **PRICE_CLOSE (0)** | `CONFIG_EMA_APPLIED_PRICE` | `ValidateEnumValue(0, 6)` (MQL `ENUM_APPLIED_PRICE`) |
| ATR period | **14** | `CONFIG_ATR_PERIOD` | `ValidatePositive` (> 0) |

Values were **not** obtained from strategy documents, engine private initializers, test fixtures, IndicatorManager literals, or hidden fallback logic — they exist only as the ConfigSystem-owned approved constants (verified: `IndicatorManager.mq5` contains no numeric literals for these values; the only other occurrences in the repository are the frozen engine initializers and test fixtures, which are superseded/non-authoritative).

### 5.3 Known limitation — recorded, NOT fixed (per task instruction)

`EMAEngine` stores `appliedPrice` but `EMAUpdate()` (`EMAEngine.mq5:12–18`) calculates from `SYMBOL_BID` and does not read it. **Not fixed in this task** (explicitly out of scope). Consequence: the contract delivers and validates `PRICE_CLOSE (0)`, and `EMAConfigure(50, 0)` records it, but the runtime calculation remains bid-based until a separate, future, frozen-EMA-engine change is approved. This is the same limitation disclosed in SPR6-006G §2.4 and does not block the configuration contract itself.

## 6. Validation Behavior

- `ValidateConfiguration()` (ConfigValidator) returns:
  - `VAL_FAIL` if `emaPeriod <= 0` (covers uninitialized record — completeness: a record ConfigInit has not populated has `0` fields and fails),
  - `VAL_FAIL` if `atrPeriod <= 0`,
  - `VAL_FAIL` if `emaAppliedPrice` outside `0..6`,
  - `VAL_OK` otherwise.
- `ConfigValidate()` (ConfigSystem) → `ValidateConfiguration() == VAL_OK`; `ConfigStatus()` → `ConfigValidate()`.
- EAMain's existing `VerifyInfrastructureReady()` calls `ConfigStatus()` — so invalid/missing configuration aborts startup **before indicator initialization** (authorized Step 6 semantics), with no EAMain change.
- `IndicatorManagerInit()` re-checks `ValidateConfiguration() != VAL_OK` before touching any child (authorized "only after successful configuration validation").
- `ValidateDuplicate`/`ValidateConsistency` remain `VAL_PENDING` (unrelated; not touched).

## 7. Startup / Configuration Sequence

Implemented sequence (matches the authorized contract of SPR6-006G §6, realized in the existing EAMain orchestration without EAMain edits):

```text
EAMain.InitializeInfrastructureLayer()  → ConfigInit() populates indicatorConfig
EAMain.VerifyInfrastructureReady()     → ConfigStatus() = ConfigValidate() = ValidateConfiguration()==VAL_OK
EAMain.InitializeIndicatorLayer()      → IndicatorManagerInit()
    IndicatorManagerInit():
      1. ValidateConfiguration() == VAL_OK        (gate)
      2. EMAInit()
      3. ATRInit()
      4. EMAConfigure(50, PRICE_CLOSE=0)          (from record)
      5. ATRConfigure(14)                         (from record)
      6. indicatorInitialized = true
EAMain.VerifyIndicatorsReady()         → IndicatorManagerStatus() && EMAReady() && ATRReady()  (now reachable)
EAMain.VerifyStructureReady()          → Structure layer (unchanged)
EAMain.VerifyPriceActionReady()        → Price Action layer (unchanged; B-09 remains deferred)
```

## 8. Failure / Rollback Behavior (implemented)

| Failure | Behavior | Owner |
|---|---|---|
| Configuration acquisition/validation failure | `IndicatorManagerInit()` returns false **before any child init**; EAMain infra verification fails first via `ConfigStatus()` | ConfigSystem/ConfigValidator gate; EAMain layer rollback |
| `EMAInit()` failure | return false; nothing else initialized | IndicatorManager |
| `ATRInit()` failure | `EMAShutdown()` (only successfully initialized child rolled back) | IndicatorManager |
| `EMAConfigure()` failure | `IndicatorManagerShutdown()` — reverse-order child rollback (ATR, then EMA) | IndicatorManager |
| `ATRConfigure()` failure | `IndicatorManagerShutdown()` — reverse-order child rollback (ATR, then EMA) | IndicatorManager |
| Readiness failure | EAMain `RollbackIndicatorLayer()` → `IndicatorManagerShutdown()`, then `RollbackInfrastructureLayer()` (existing code, unchanged) | EAMain (layers), IndicatorManager (children) |

Preserved: manager owns children; EAMain owns layers; reverse-order rollback; **EAMain never calls `EMAConfigure`/`ATRConfigure`/`EMAShutdown`/`ATRShutdown` directly** (verified by grep).

## 9. Regression Audit (Step 8 — all verified)

| Check | Result |
|---|---|
| `git diff` / `git diff --stat` | Only the 3 authorized files; 70 insertions, 7 deletions |
| `git diff --check` | **CLEAN** (no whitespace errors) |
| Duplicate configuration ownership | None — values exist only in ConfigSystem constants; IndicatorManager reads the record; engines receive values via Configure (their private initializers 50/0/14 remain frozen, non-authoritative, and are always overwritten — no fallback path since Configure is mandatory before Ready) |
| Unauthorized public interfaces | None — the ConfigSystem record/constants are the authorized frozen contract change (§4); no getters, no new manager functions, no EAMain changes |
| Strategy contamination | None — no strategy/signal/entry/exit/order/risk/money-management/AI code touched or referenced |
| ConfigSystem sole configuration source | Verified (`indicatorConfig` defined only in ConfigSystem; read by ConfigValidator + IndicatorManager) |
| ConfigValidator validates the three fields | Verified (`ValidateConfiguration` at `ConfigValidator.mq5:19–24`) |
| IndicatorManager applies configuration | Verified (`IndicatorManager.mq5:13,17`) |
| EAMain does not directly configure EMA/ATR | Verified (grep: zero `EMAConfigure`/`ATRConfigure` in EAMain) |
| `EMAConfigure`/`ATRConfigure` signatures unchanged | Verified (engines untouched — not in `git diff`) |
| Hidden defaults used as fallback | None — no fallback path exists |
| Test fixture impact | `IndicatorManagerTests.mq5` (includes only IndicatorManager) and `ConfigurationRegressionTests.mq5` were already not self-contained compilation units (missing engine/CommonTypes includes, pre-existing); `ConfigurationRegressionTests` is *improved* by the new guarded CommonTypes includes. Tests were not modified (not required files). |

## 10. Compiler / Runtime Status

```text
COMPILE: NOT VERIFIED — MQL5 COMPILER UNAVAILABLE
RUNTIME: NOT VERIFIED
```
No compiler/MetaEditor/MT5 exists in the sandbox (verified in prior tasks); no compile or runtime success is claimed or simulated. Static ordering analysis: in the EAMain compilation unit, `indicatorConfig` and `VAL_OK`/`ValidationResult` (via the ConfigSystem include of the `#pragma once`-guarded CommonTypes) are declared before every use in ConfigValidator and IndicatorManager; `ValidateConfiguration()` is defined before its IndicatorManager call site; the only forward reference is ConfigSystem's `ConfigValidate()` → `ValidateConfiguration()` (MQL5 permits calling functions defined later in the unit).

## 11. Scope Firewall Verification (Step 7)

Not modified: strategy/signal/entry/exit/orders/execution/risk/money-management/AI/optimization; B-09; EMA applied-price calculation behavior (`EMAUpdate` untouched); logging remediation (B-07); deinit remediation (B-08); CommonTypes collision remediation (B-01/PATCH-CT-01); TrendEngine remediation (B-02/PATCH-INT-02); unrelated rollback (B-06 beyond the two child-rollback lines directly required by Step 6 for `ATRInit`/Configure failures). The one B-06-adjacent change (`ATRInit` failure → `EMAShutdown()`) is **directly required** by Step 6 ("Manager rolls back only children it successfully initialized") and is documented as such.

## 12. Self-Audit

| Requirement | Result |
|---|---|
| Source modifications | **3 files** (ConfigSystem, ConfigValidator, IndicatorManager) — all authorized |
| Frozen interfaces modified | Only the authorized minimum: ConfigSystem record/constants + ConfigValidate/ConfigStatus completion; ConfigValidator `ValidateConfiguration` completion; IndicatorManager `IndicatorManagerInit` internals — signatures preserved |
| CommonTypes modified | **0** |
| EAMain modified | **0** |
| TrendEngine modified | **0** |
| EMAEngine modified | **0** |
| ATREngine modified | **0** |
| Strategy logic added | **0** |
| B-09 | **deferred** |
| New inputs / config files | **0** |
| Values invented | **0** — only SPR6-006G-authorized values (50 / PRICE_CLOSE / 14) implemented |
| appliedPrice consumption limitation fixed | **No** (out of scope; recorded in §5.3) |

## 13. Remaining Blockers

1. **COMPILER / RUNTIME VERIFICATION** — MQL5 compiler and MT5 runtime unavailable; compile/runtime status remains NOT VERIFIED. (Environment blocker, not a code blocker.)
2. **B-02 / PATCH-INT-02 (pre-existing, unrelated, blocks compilation)** — `TrendEngine.mq5:2` includes `<mql5/modules/CommonTypes.mqh>` (nonexistent path). Not fixed (scope firewall); requires the separately authorized PATCH-INT-02.
3. **B-04 / PATCH-B04 (pre-existing, unrelated, blocks runtime startup reachability)** — `EAMain.mq5:149` `if(!ConfigInit())` inverts `INIT_SUCCEEDED` (0). The contract is implemented regardless, but observable startup cannot pass this line until PATCH-B04 lands. Not fixed (scope firewall).
4. **Engine applied-price consumption (recorded, not a blocker of this contract)** — `EMAUpdate()` ignores `appliedPrice` (bid-based); separate future frozen-EMA change required.
5. **B-01, B-05-adjacent, B-06 remainder, B-07, B-08, B-09** — separate authorized patches/deferrals, untouched.
6. **Test fixture self-containment** — pre-existing; fixtures are not part of the EA build; not modified.

## 14. Explicit PATCH-CFG-01 Readiness Verdict

```text
PATCH-CFG-01: IMPLEMENTED AT SOURCE LEVEL
```

Conditions genuinely satisfied (all prerequisites from SPR6-006G §11):
1. ✅ Frozen configuration contract patch delivered: ConfigSystem typed record (Option A) + `ValidateConfiguration()` completion — **this task**.
2. ✅ `bool EMAConfigure(int,int)` and `bool ATRConfigure(int)` preserved unchanged.
3. ✅ Authorized values adopted unchanged: EMA **50**, applied price **PRICE_CLOSE (0)**, ATR **14**; validation rules as authorized (periods > 0, domain 0..6, completeness, aggregate VAL_OK gate).
4. ✅ `appliedPrice` engine-consumption limitation recorded (§5.3), not silently fixed.
5. ✅ EMA/ATR are configured before `VerifyIndicatorsReady()` — the original B-05 gap is closed inside IndicatorManager (the authorized application owner).

Conditions NOT satisfied (therefore PATCH-CFG-01 is implemented, but the *system* is not yet verifiable):
- ❌ **COMPILE: NOT VERIFIED — MQL5 COMPILER UNAVAILABLE** (and pre-existing B-02 include-path defect remains a separate blocker).
- ❌ **RUNTIME: NOT VERIFIED** (and pre-existing B-04 `ConfigInit` check inversion blocks startup observability — separate PATCH-B04).

**Conclusion:** the frozen configuration contract is complete at source level exactly as authorized; PATCH-CFG-01's implementation portion is done. Final compile/runtime confirmation and end-to-end startup observability require the compiler (and separately authorized PATCH-INT-02/PATCH-B04), none of which are part of this task.

---

*SPR6-007 — controlled implementation of the authorized frozen configuration contract. No push. Stopping after SPR6-007.*
