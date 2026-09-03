# SPR6-006G — Final Configuration Contract Authorization

**Status:** **BLOCKED — FINAL CONFIGURATION AUTHORIZATION REQUIRED** (see Task 9 / Task 11)
**Scope:** Architecture decision and documentation only — the final gate before PATCH-CFG-01
**Source modifications:** **0**
**PATCH-CFG-01:** **NOT AUTHORIZED TO IMPLEMENT (frozen transport contract unresolved)**

> This is the final architecture decision gate. It authorizes **no source change** and **no public API change**. All rulings below are explicit, deterministic, and auditable, and are labeled per the required taxonomy: **VERIFIED FROM SOURCE** (existing repository fact), **INFERENCE** (reasoned from evidence), **ARCHITECTURE DECISION** (decision by this gate), **EXPLICITLY AUTHORIZED VALUE** (ratified value), **PROPOSED BUT NOT AUTHORIZED** (future proposal, not approved), **UNRESOLVED** (cannot be decided here).

---

## 0. Executive Summary

This gate makes three value rulings, one domain ruling, one contract-shape ruling, and one hard stop:

1. **VALUES — AUTHORIZED (ratified, not invented):** EMA period **50**, ATR period **14**, EMA applied price **PRICE_CLOSE (0)**. These are ratified as Sprint 6 infrastructure values because the **frozen engines' own design parameters** (module initializers) and the **frozen test contracts** establish the intended operating configuration of the frozen single-EMA/ATR infrastructure. The authorization is a decision, not a discovery; its rationale is value-independent and strategy-free (§1, §8).
2. **APPLIED-PRICE DOMAIN — AUTHORIZED:** the `int` parameter of `EMAConfigure` is ratified as an MQL-compatible applied-price domain (`ENUM_APPLIED_PRICE`), authorized value `PRICE_CLOSE = 0`. The current engine does **not** honor the parameter (calculation reads `SYMBOL_BID`); this is recorded as a separate, non-hidden implementation limitation (§2).
3. **CONFIGURATION TRANSPORT SHAPE — APPROVED (Option A):** a typed configuration record owned by ConfigSystem (§4). Its realization requires a **new public interface on the frozen ConfigSystem module**, which a documentation-only gate cannot authorize.
4. **HARD STOP — FROZEN CONFIGURATION CONTRACT PATCH REQUIRED.** Because a public frozen interface must change, Task 9 requires this task to end `BLOCKED — FROZEN CONFIGURATION CONTRACT PATCH REQUIRED`, and the final gate is **CASE B — BLOCKED** (§9, §11). The value/domain/validation/rollback decisions are made; the single remaining unresolved item is the frozen transport contract.

```text
EMA PERIOD:            AUTHORIZED = 50
EMA APPLIED PRICE:     AUTHORIZED = PRICE_CLOSE (0)  [engine consumption: NOT IMPLEMENTED — documented]
ATR PERIOD:            AUTHORIZED = 14
APPLIED-PRICE DOMAIN:  AUTHORIZED = MQL ENUM_APPLIED_PRICE
CONFIGURATION TRANSPORT SHAPE: APPROVED (Option A) — FROZEN CONTRACT PATCH REQUIRED
CONFIGURATION TRANSPORT IMPLEMENTATION: NOT AUTHORIZED
PATCH-CFG-01: NOT AUTHORIZED TO IMPLEMENT
```

---

## 1. Task 1 — Final Value Authorization

### 1.1 Decision rule (ARCHITECTURE DECISION — value-independent, auditable)

> **Rule R1:** The designed operating parameters of the frozen Sprint 1–5 infrastructure engines, as expressed in the frozen module source itself (module-level initializers) and confirmed by the frozen test contracts, are ratifiable as the Sprint 6 infrastructure runtime configuration values, provided that: (a) the values are representable in the existing frozen interfaces; (b) the authorization rationale does not depend on strategy documentation; and (c) the values pass the approved validation rules (§5).

Rule R1 is deliberately independent of any particular number: if the frozen engine had been designed with period 37, the same rule would ratify 37. The rule ratifies the frozen architecture's own design intent; it does not import external semantics.

### 1.2 Candidate evidence re-audit (VERIFIED FROM SOURCE, this session)

| Candidate | Location | Classification |
|---|---|---|
| EMA `period = 50` | `EMAEngine.mq5:5` | **IMPLEMENTATION DEFAULT** (frozen engine design parameter) — corroborated by frozen test contract |
| EMA `appliedPrice = 0` | `EMAEngine.mq5:6` | **IMPLEMENTATION DEFAULT** (frozen engine design parameter) — corroborated by frozen test contract |
| ATR `period = 14` | `ATREngine.mq5:4` | **IMPLEMENTATION DEFAULT** (frozen engine design parameter) — corroborated by frozen test contract |
| `EMAConfigure(50,0)` | `tests/EMAEngineTests.mq5:5` | **TEST-ONLY** (corroborates design intent; not itself an authority) |
| `ATRConfigure(14)` | `tests/ATREngineTests.mq5:5` | **TEST-ONLY** (corroborates design intent; not itself an authority) |
| EMA50/200, ATR14 | `docs/phase2/*`, `docs/phase3/*`, `docs/phase7/*` | **STRATEGY-ONLY** — excluded as a basis (see Task 8) |

The three occurrences of `50`/`14` are **not** treated as authorization by repetition. The authorization basis is the frozen engine's own design parameter (its initializer) plus the frozen test contract's confirmation of design intent; the strategy documents are expressly excluded.

### 1.3 Rulings

| Value | Ruling | Authorization basis | Labels |
|---|---|---|---|
| **EMA period** | **AUTHORIZED = 50** | Frozen engine design parameter `EMAEngine.mq5:5` (header: "Frozen EMA Engine — single implementation only"); frozen test contract `EMAEngineTests.mq5:5` confirms the intended operating value; representable in `EMAConfigure(int,int)`; passes validation `period > 0` | **EXPLICITLY AUTHORIZED VALUE** (ARCHITECTURE DECISION); the source fact itself remains "IMPLEMENTATION DEFAULT — ratified by decision" |
| **EMA applied price** | **AUTHORIZED = PRICE_CLOSE (0)** | MQL platform standard `ENUM_APPLIED_PRICE` (`PRICE_CLOSE = 0`); frozen engine design parameter `EMAEngine.mq5:6`; frozen test contract `EMAEngineTests.mq5:5`; representable in `EMAConfigure(int,int)` | **EXPLICITLY AUTHORIZED VALUE** — with the engine-consumption limitation stated in §2 (not hidden) |
| **ATR period** | **AUTHORIZED = 14** | Frozen engine design parameter `ATREngine.mq5:4`; frozen test contract `ATREngineTests.mq5:5`; representable in `ATRConfigure(int)`; passes validation `period > 0` | **EXPLICITLY AUTHORIZED VALUE** (ARCHITECTURE DECISION) |

### 1.4 Required-outcome statement

- EMA period: **AUTHORIZED** (50)
- EMA applied price: **AUTHORIZED** (PRICE_CLOSE = 0, domain per §2)
- ATR period: **AUTHORIZED** (14)

No required **value** remains unauthorized. The implementation path is nevertheless stopped by the transport blocker (§4, §9) — values are authorized; the mechanism to carry them at runtime is not.

---

## 2. Task 2 — Applied Price Final Decision

### 2.1 Audit (VERIFIED FROM SOURCE)

| Dimension | Finding |
|---|---|
| `EMAEngine.mq5:11` | `EMAConfigure(int p,int ap)` stores `period = p; appliedPrice = ap; configured = true;` |
| Storage | `int appliedPrice` at `EMAEngine.mq5:6` (initializer `0`) |
| Reads | Repository-wide grep: `appliedPrice` appears **only** at `EMAEngine.mq5:6` (declaration) and `EMAEngine.mq5:11` (write). **Never read.** |
| Calculation source | `EMAUpdate()` at `EMAEngine.mq5:12–18` reads `SymbolInfoDouble(_Symbol, SYMBOL_BID)` (line 13); the parameter is not consulted |
| Enums/constants | `CommonTypes.mqh`, `Constants.mqh`: no applied-price enum or constant exists |
| Tests | `EMAEngineTests.mq5:5` passes `(50,0)`; no test asserts applied-price semantics |
| Callers | No startup caller of `EMAConfigure` exists (only the test fixture) |
| Documentation | No contract document defines the parameter domain |

### 2.2 Does the current implementation honor the applied-price configuration?

**NO. (VERIFIED FROM SOURCE)** The parameter is stored but inert: `EMAConfigure` writes it; `EMAUpdate` never reads it and computes on `SYMBOL_BID`. The engine's *effective* price source is bid — an engine design fact, not a configuration result.

### 2.3 Architecture decision

**Chosen option: B — an explicit MQL-compatible applied-price domain**, with the authorized value designated within it:

- The `int` parameter of `EMAConfigure(int period, int appliedPrice)` is ratified as carrying an **MQL `ENUM_APPLIED_PRICE` value** (the platform's standard applied-price domain: `PRICE_CLOSE=0, PRICE_OPEN=1, PRICE_HIGH=2, PRICE_LOW=3, PRICE_MEDIAN=4, PRICE_TYPICAL=5, PRICE_WEIGHTED=6`). This domain is a platform standard (INFERENCE — external MQL5 reference, not repository evidence), not strategy semantics, and is the only standard domain an applied-price integer can denote in MQL5.
- **Authorized value: `PRICE_CLOSE (0)`** — consistent with the frozen engine initializer (`EMAEngine.mq5:6`) and the frozen test contract.
- The conversion of `0` to `PRICE_CLOSE` is **explicit, documented, and authorized here** — it is not a silent interpretation.
- The function signature `bool EMAConfigure(int period, int appliedPrice)` is **not modified**.

### 2.4 Separate implementation limitation (NOT hidden)

The architecture authorizes the configuration value `PRICE_CLOSE (0)` while the engine does not currently consume it. This is recorded as a **separate implementation limitation**:

> **VERIFIED FROM SOURCE —** `EMAUpdate()` (`EMAEngine.mq5:12–18`) computes on `SYMBOL_BID` and ignores `appliedPrice`. Under the authorized contract, PATCH-CFG-01 will pass `EMAConfigure(50, 0 /* PRICE_CLOSE */)`, making readiness reachable; the runtime calculation will nonetheless remain bid-based until the frozen engine is changed to consume the parameter. Making the engine honor the applied-price configuration is **PROPOSED BUT NOT AUTHORIZED** (a future frozen-EMA-engine change requiring its own approval). This gap does not block the configuration contract itself; it is disclosed as an engine behavior debt.

---

## 3. Task 3 — Final Configuration Contract

### 3.1 Contract definition (ARCHITECTURE DECISION — future contract, NOT implemented)

The minimum frozen contract required for runtime indicator configuration is the following pipeline, preserving "Manager owns children; EAMain owns layers":

```text
ConfigSystem            source / data owner
   │  produces typed indicator configuration data
   ▼
ConfigValidator         validation owner
   │  validates the data (periods > 0, applied-price domain, completeness, aggregate)
   ▼
IndicatorManager        application / child-lifecycle owner
   │  applies validated values via existing interfaces
   ▼
EMA / ATR engines       frozen contracts unchanged
```

### 3.2 Contract data (EXPLICITLY AUTHORIZED)

| Field | Type | Authorized value | Validation |
|---|---|---|---|
| EMA period | `int` | **50** | > 0 |
| EMA applied price | `int` (MQL `ENUM_APPLIED_PRICE` domain) | **PRICE_CLOSE = 0** | member of domain (0..6) |
| ATR period | `int` | **14** | > 0 |

### 3.3 Ownership (ARCHITECTURE DECISION — reaffirmed from SPR6-006E/006F)

- **ConfigSystem** — configuration data, acquisition, persistence/loading, indicator settings source (future).
- **ConfigValidator** — validation, domain checks, positive-period checks, aggregate configuration validity (future completion).
- **IndicatorManager** — EMAInit/ATRInit, EMAConfigure/ATRConfigure application, partial child rollback, Ready verification.
- **EAMain** — lifecycle sequencing, layer transition, failure propagation, layer-level rollback.

---

## 4. Task 4 — Contract Shape Decision

### 4.1 Option evaluation

| Option | Description | Ruling |
|---|---|---|
| **A. Typed configuration record owned by ConfigSystem** | A single typed data object carrying `{emaPeriod, emaAppliedPrice, atrPeriod}` plus validity, produced/owned by ConfigSystem | **APPROVED — chosen shape** (below) |
| B. Individual getters from ConfigSystem | Three getters (e.g., period getters); fragments the contract into multiple approvals | REJECTED — a single record is one auditable contract; getters add surface without adding semantics |
| C. EAMain-owned values | EAMain would hold configuration values | REJECTED — violates established ownership (EAMain = orchestration only; ConfigSystem = source owner) |
| D. IndicatorManager-owned values | IndicatorManager would hold the values | REJECTED — violates established ownership (IndicatorManager applies; it does not source) |
| E. Other existing mechanism | inputs, files, globals, existing functions | REJECTED — verified: no MQL `input` declarations, no `.ini/.set/.cfg/.csv` payloads, no getters, and existing `ConfigLoad()/ConfigValidate()/ConfigStatus()` return only `bool` and carry no data |

### 4.2 Decision

**Option A — typed configuration record owned by ConfigSystem** is the only option consistent with the repository evidence and the approved ownership model. The exact record declaration/API shape is **not invented here**; it is the subject of the frozen contract patch (§9).

```text
CONFIGURATION TRANSPORT SHAPE: APPROVED — Option A (typed ConfigSystem-owned record)
CONFIGURATION TRANSPORT IMPLEMENTATION: NOT AUTHORIZED
FROZEN CONTRACT PATCH REQUIRED — a new public ConfigSystem data interface is required
STOP — no interface is implemented by this task
```

---

## 5. Task 5 — Validation Contract

### 5.1 Authorized validation semantics (ARCHITECTURE DECISION)

| Requirement | Rule | Existing primitive | Ruling |
|---|---|---|---|
| EMA period | **> 0** | `ValidatePositive` (`ConfigValidator.mq5:4`) | **AUTHORIZED** — primitive sufficient |
| ATR period | **> 0** | `ValidatePositive` | **AUTHORIZED** — primitive sufficient |
| Applied price | **member of MQL `ENUM_APPLIED_PRICE` (0..6)** | `ValidateEnumValue(int,int,int)` (`ConfigValidator.mq5:8`) | **AUTHORIZED** — primitive sufficient |
| Configuration completeness | record present; all three fields present (no missing value) | `ValidateRequired` / `ValidateNotEmpty` | **AUTHORIZED** — primitives sufficient |
| Aggregate configuration validity | all field checks pass simultaneously; `ValidateConfiguration()` must return `VAL_OK` before IndicatorManager application | `ValidateConfiguration()` currently returns `VAL_PENDING` (`ConfigValidator.mq5:14`) | **AUTHORIZED as a rule** — completion of the aggregate path is part of the frozen contract patch |
| Missing configuration behavior | startup aborts in the infrastructure phase, **before** indicator initialization | — | **AUTHORIZED** |
| Validation failure behavior | same: abort before indicators; EAMain infrastructure rollback | — | **AUTHORIZED** |

### 5.2 Sufficiency determination

Existing `ConfigValidator` primitives are **sufficient** for every field-level rule. A **new validator contract is not required** for the rules themselves; however, the **aggregate path** (record-level completeness + `VAL_OK` gate) requires the frozen contract patch to complete/formalize `ValidateConfiguration()` — a pending, frozen-module change. No validation is implemented by this task.

---

## 6. Task 6 — Startup Contract

### 6.1 ARCHITECTURE CONTRACT — NOT IMPLEMENTED

The final intended startup sequence (approved conceptually; no source change):

```text
ConfigSystem initialization
        ↓
configuration acquisition            (typed record, Option A)
        ↓
configuration validation            (periods > 0, applied-price domain, completeness, aggregate VAL_OK)
        ↓
IndicatorManager initialization
        ↓
EMAInit
        ↓
ATRInit
        ↓
EMAConfigure(50, PRICE_CLOSE=0)
        ↓
ATRConfigure(14)
        ↓
EMAReady && ATRReady
        ↓
Structure
        ↓
Price Action
```

### 6.2 Current vs. contract (VERIFIED FROM SOURCE)

| Step | CURRENT IMPLEMENTATION | ARCHITECTURE CONTRACT (NOT IMPLEMENTED) |
|---|---|---|
| ConfigSystem init | `ConfigInit()` stub returns `INIT_SUCCEEDED`; `EAMain.mq5:149` `if(!ConfigInit())` also inverts success (B-04, separate planned patch) — startup currently aborts here | ConfigSystem initialization completes and returns success properly |
| Acquisition | **Absent** — no data surface, no record, no getter | ConfigSystem produces the authorized typed record |
| Validation | **Absent** — no validator call in startup; `ConfigValidate()` stub returns `true` | ConfigValidator validates all fields + aggregate `VAL_OK` |
| IndicatorManager init | `IndicatorManagerInit()` calls `EMAInit()` then `ATRInit()` (`IndicatorManager.mq5:3–8`) | unchanged |
| EMA/ATR configuration | **Absent** — no `EMAConfigure`/`ATRConfigure` call exists in any startup path (B-05) | `EMAConfigure(50, 0)` then `ATRConfigure(14)` inside IndicatorManager ownership |
| Ready verification | `VerifyIndicatorsReady()` (`EAMain.mq5:110–115`) requires `EMAReady() && ATRReady()`, which require `configured == true` — currently unreachable as passing | Same gate, reachable after configuration |
| Structure / Price Action | Present (`EAMain.mq5:269–306`) | unchanged; B-09 stays DEFERRED |

---

## 7. Task 7 — Failure / Rollback Authorization

### 7.1 Authorized semantics (ARCHITECTURE DECISION — future behavior, not implemented)

| Failure | Ruling |
|---|---|
| Configuration acquisition failure | **APPROVED** — no indicator initialization; startup fails in infrastructure phase; EAMain rolls back only successfully initialized infrastructure services, reverse order |
| Configuration validation failure | **APPROVED** — no indicator configuration; same infrastructure-phase abort/rollback |
| `EMAConfigure` failure | **APPROVED** — IndicatorManager rolls back successfully initialized indicator children (ATR, then EMA — reverse of init order), then EAMain rolls back lower layers |
| `ATRConfigure` failure | **APPROVED** — IndicatorManager rolls back in reverse order (existing `IndicatorManagerShutdown()` already performs `ATRShutdown()` then `EMAShutdown()`, `IndicatorManager.mq5:10–11`), then EAMain rolls back lower layers |
| Readiness failure (`EMAReady()`/`ATRReady()` false) | **APPROVED** — IndicatorManager rollback (`IndicatorManagerShutdown()`) followed by EAMain layer rollback (`RollbackIndicatorLayer()` → `RollbackInfrastructureLayer()`, matching `EAMain.mq5:263–266`) |

### 7.2 Preserved invariants

- **IndicatorManager owns EMA/ATR cleanup** — EAMain must not call `EMAShutdown()`/`ATRShutdown()` directly (it already delegates via `RollbackIndicatorLayer()`, `EAMain.mq5:194–197`).
- **EAMain owns layer cleanup.**
- **Reverse-order rollback** (SPRINT_06_PLAN §8.2: "Rollback order: Reverse of initialization order").
- **No direct child cleanup from EAMain.**

---

## 8. Task 8 — Strategy Boundary

### 8.1 Rulings (ARCHITECTURE DECISION)

| Candidate source | Ruling |
|---|---|
| Phase 2 strategy specification (`docs/phase2/STRATEGY_SPECIFICATION*.md`) | **REJECTED** as Sprint 6 configuration source |
| EMA50/200 from strategy docs | **REJECTED** — strategy-only; also unrepresentable (single-EMA frozen contract, `EMAEngine.mq5:1`) |
| ATR14 from strategy docs | **REJECTED** as a source (the number 14 is authorized solely via Rule R1, engine design parameter — §1) |
| Strategy trend rules, risk parameters, execution parameters | **REJECTED** — no strategy/entry/exit/risk/execution/AI configuration exists or is authorized in Sprint 6 |

### 8.2 Why the authorized values are strategy-independent

The authorization in §1 uses **Rule R1** (ratify the frozen engine's designed operating parameters) — a rule that makes no reference to strategy content. The strategy documents are never cited as a basis; they are cited only here, as the excluded source. The strongest counter-evidence to strategy leakage is structural: the strategy demands **two EMAs (50/200)**, which the frozen **single-EMA** contract cannot express — so the strategy cannot be the configuration source even in principle. The infrastructure values (50, 14, PRICE_CLOSE) are the values the frozen engines were designed, built, and tested with; that is an infrastructure fact, not a strategy import.

### 8.3 Prevention rule

Sprint 6 configuration is **indicator infrastructure configuration only**. Any future strategy parameters (entry, risk, execution, optimization, AI) belong to a separate, later strategy configuration layer and must not enter the frozen ConfigSystem indicator contract.

---

## 9. Task 9 — Frozen Interface Impact

### 9.1 Determination

| Question | Ruling |
|---|---|
| Can PATCH-CFG-01 use `EMAConfigure(int,int)` unchanged? | **YES** (VERIFIED FROM SOURCE — `EMAEngine.mq5:11` accepts the authorized values; no change needed) |
| Can PATCH-CFG-01 use `ATRConfigure(int)` unchanged? | **YES** (VERIFIED FROM SOURCE — `ATREngine.mq5:9` accepts the authorized value; no change needed) |
| Does ConfigSystem require a new public data contract? | **YES** — no data surface exists (stubs only, `ConfigSystem.mq5:1–5`); the approved transport shape (Option A, typed record) requires a new public element (record type and/or acquisition/access surface) |
| Getter / typed record / internal-only state? | **Typed record (Option A)**; internal-only state alone cannot carry values out of ConfigSystem (no reader interface exists) → a **public** surface is required |
| Does any other frozen module need a public change? | EMA/ATR: no. IndicatorManager: application path is internal to PATCH-CFG-01 (existing `VerifyEMAReady`/`VerifyATRReady` stay; whether a new public apply function is needed is part of the frozen contract patch scope). ConfigValidator: aggregate completion of `ValidateConfiguration()` is a frozen-module change within the same patch scope |

### 9.2 Required ending (per task rule)

Because a **public frozen interface must change** (ConfigSystem data contract), this task ends with:

```text
BLOCKED — FROZEN CONFIGURATION CONTRACT PATCH REQUIRED
```

No public interface is implemented or modified by this document. The frozen contract patch (its exact API shape, approval, and implementation) is a separate, formal step that this documentation-only gate cannot grant.

---

## 10. Task 10 — Final Approval Matrix

| Decision | Current Evidence | Proposed Architecture | Approval Required | Status |
|---|---|---|---|---|
| EMA period | Frozen engine design parameter 50 (`EMAEngine.mq5:5`); test fixture 50; strategy docs 50/200 (excluded) | **AUTHORIZED = 50** (Rule R1) | None further (value ratified) | **AUTHORIZED** |
| EMA applied price | Frozen engine parameter 0 (`EMAEngine.mq5:6`); test fixture 0; MQL `ENUM_APPLIED_PRICE` standard | **AUTHORIZED = PRICE_CLOSE (0)**; engine consumption = documented limitation | None further (value/domain ratified); engine consumption = future approval | **AUTHORIZED** (with disclosed limitation) |
| ATR period | Frozen engine design parameter 14 (`ATREngine.mq5:4`); test fixture 14 | **AUTHORIZED = 14** (Rule R1) | None further | **AUTHORIZED** |
| Applied-price domain | Undefined in repo; no enum/constant/validator | **AUTHORIZED = MQL `ENUM_APPLIED_PRICE`** (0..6) | None further (platform standard ratified) | **AUTHORIZED** |
| Configuration source | ConfigSystem stubs, no data surface | ConfigSystem = source/data owner | Frozen contract patch (implementation) | **APPROVED CONCEPTUALLY — BLOCKED AT IMPLEMENTATION** |
| Configuration transport | None (no inputs, files, getters) | Option A — typed ConfigSystem-owned record | **FROZEN CONTRACT PATCH (public interface change)** | **NOT AUTHORIZED — FROZEN CONTRACT PATCH REQUIRED** |
| Validation | Primitives exist; `ValidateConfiguration()` = `VAL_PENDING` | Field rules authorized (positive, domain, completeness); aggregate `VAL_OK` gate | Aggregate completion within frozen contract patch | **AUTHORIZED (rules) — aggregate impl BLOCKED** |
| IndicatorManager application | Owns lifecycle; no Configure calls | Applies authorized values via unchanged signatures | PATCH-CFG-01 execution (after contract patch) | **APPROVED — pending patch execution** |
| EAMain orchestration | Layer sequencing/rollback exists | Unchanged (orchestrator; B-04/rollback fixes per 006B plan) | Existing patch approvals (PATCH-B04 etc.) | **APPROVED** |
| Rollback | Layer rollback exists; partial child rollback pending (B-06) | Manager owns children; EAMain owns layers; reverse order | B-06 patch approval (already planned) | **APPROVED CONCEPTUALLY** |
| Strategy boundary | EMA50/200/ATR14 in Phase 2/3/7 docs | Excluded from infrastructure configuration | None (exclusion is the decision) | **APPROVED — EXCLUSION CONFIRMED** |
| Frozen interface impact | `EMAConfigure`/`ATRConfigure` fit; ConfigSystem has no data surface | EMA/ATR signatures preserved; ConfigSystem record added | **FROZEN CONTRACT PATCH REQUIRED** | **BLOCKED (transport only)** |

---

## 11. Task 11 — Final Gate

```text
SPR6-006G BLOCKED — FINAL CONFIGURATION AUTHORIZATION REQUIRED
```

### Remaining unresolved decisions (exhaustive)

1. **FROZEN CONFIGURATION CONTRACT PATCH (configuration transport).** The approved transport shape (Option A — typed configuration record owned by ConfigSystem) requires a **new public interface on the frozen ConfigSystem module**. A documentation-only architecture gate cannot authorize a public frozen-interface modification; the exact record/API shape and its approval must be established by the formal frozen configuration contract patch. Until that patch is approved:
   - `CONFIGURATION TRANSPORT: NOT AUTHORIZED`
   - `PATCH-CFG-01: NOT AUTHORIZED TO IMPLEMENT`
2. **Aggregate validation completion (same patch scope).** `ValidateConfiguration()` must be completed to return `VAL_OK` for the authorized record (currently `VAL_PENDING`, `ConfigValidator.mq5:14`). This is a frozen-module change and is therefore part of the frozen contract patch, not grantable here.

These are the **only** remaining unresolved items. Values, applied-price domain, validation rules, ownership, rollback semantics, and the strategy boundary are all now resolved by this gate.

### Conditions that WOULD make the next gate READY (for the record)

1. A formal frozen contract patch defines and approves the exact ConfigSystem public data contract (typed record shape per Option A) and the `ValidateConfiguration()` aggregate completion.
2. The patch preserves `bool EMAConfigure(int,int)` and `bool ATRConfigure(int)` unchanged.
3. The authorized values (EMA 50, PRICE_CLOSE 0, ATR 14), domain, and validation rules above are adopted unchanged.
4. The engine-consumption limitation for `appliedPrice` (bid-based calculation) is recorded as separate future work, not silently fixed.

**PATCH-CFG-01 is NOT started by this task — in no case, including a READY verdict, would this documentation task implement anything.**

---

## 12. Task 12 — Documentation

- Created: `docs/reports/SPR6-006G-FINAL-CONFIGURATION-AUTHORIZATION.md` (this file).
- Architecture-only; no MQL5 source modification accompanies it.

---

## 13. Self-Audit

| Requirement | Result |
|---|---|
| Source modifications | **0** |
| Frozen interfaces modified | **0** |
| CommonTypes modified | **0** |
| EAMain modified | **0** |
| ConfigSystem modified | **0** |
| ConfigValidator modified | **0** |
| IndicatorManager modified | **0** |
| EMAEngine modified | **0** |
| ATREngine modified | **0** |
| Strategy logic added | **0** |
| B-09 | **deferred** |
| Compiler | **NOT AVAILABLE — COMPILE: NOT VERIFIED** |
| Runtime | **NOT AVAILABLE — RUNTIME: NOT VERIFIED** |
| Values invented | **0** — values 50 / 14 / PRICE_CLOSE(0) were **ratified** from frozen engine design parameters and frozen test contracts under Rule R1 (an explicit, value-independent decision rule), not invented; strategy documentation was never used as a basis |

---

## 14. Repository State

- Actual current HEAD: **`2e0eb02`** (`docs: define Sprint 6 configuration contract approval package`), parent `e941b60` (`update all`) — verified this session.
- Prior intermediate commits from earlier session summaries are not present in this workspace snapshot; **no history repair was attempted** (per task rules: no rebase, reset, force-push, or rewrite).
- This task commits **only** the new documentation file with message `docs: finalize Sprint 6 configuration authorization`. **No push.**

*SPR6-006G — final architecture decision gate. Documentation only. STOP after SPR6-006G; PATCH-CFG-01 is not started.*
