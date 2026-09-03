# SPR6-006F — Configuration Contract Approval Package

**Status:** **BLOCKED — CONFIGURATION CONTRACT APPROVAL STILL REQUIRED**
**Scope:** Architecture / decision / documentation only
**Source modifications:** **0**
**PATCH-CFG-01:** **NOT READY FOR PATCH**

> This document is the formal architecture approval package requested by SPR6-006F. It authorizes **no source change**, selects **no indicator value**, and defines **no implemented interface**. Every proposal below is labeled as ARCHITECTURE DECISION (future), VERIFIED FROM SOURCE (existing fact), or INFERENCE. Where the repository evidence and the explicit approval criteria cannot establish a decision, the decision is recorded as UNRESOLVED rather than guessed.

---

## 0. Executive Summary

The repository does **not** provide sufficient evidence to approve exact runtime values for EMA period, EMA applied price, or ATR period, and it does **not** define a valid authoritative domain for the EMA applied-price integer. Every candidate value found in the repository is either an internal implementation default, a test fixture argument, or a strategy/documentation mention. No MQL `input` declaration, no configuration payload file, and no startup caller of `EMAConfigure`/`ATRConfigure` exists.

Consequently this approval package cannot reach READY:

```text
VALUES: NOT AUTHORIZED
APPLIED-PRICE DOMAIN: NOT AUTHORIZED
CONFIGURATION TRANSPORT CONTRACT: NOT AUTHORIZED (UNDEFINED)
NEW FROZEN CONFIGURATION INTERFACE: NOT APPROVED
PATCH-CFG-01: NOT READY
```

The ownership model proposed by SPR6-006E (ConfigSystem = future source owner; ConfigValidator = future validation owner; IndicatorManager = future application owner; EAMain = orchestrator) is reaffirmed here as the approved *conceptual* architecture, but an architecture decision is not an authorization to implement. A formal frozen configuration-contract patch and explicit value approval remain required.

---

## 1. Authoritative Configuration Values — Repository-Wide Evidence Audit

### 1.1 Audit method

- Inspected `mql5/modules/ConfigSystem.mq5`, `ConfigValidator.mq5`, `EMAEngine.mq5`, `ATREngine.mq5`, `IndicatorManager.mq5`, `EAMain.mq5` directly.
- Ran repository-wide greps for `EMAConfigure` / `ATRConfigure` (all definitions and callers), `input` declarations, `PRICE_` identifiers, `appliedPrice`, and configuration payload files (`.ini`, `.set`, `.cfg`, `.csv`) across `mql5/`, `tests/`, and `docs/`.
- Cross-checked every candidate value against the classification categories requested by the task.

### 1.2 Candidate value register (VERIFIED FROM SOURCE)

| # | Candidate | Location | Evidence | Classification |
|---|---|---|---|---|
| V-01 | EMA `period = 50` | `mql5/modules/EMAEngine.mq5:5` | Private module field initializer; `EMAConfigure(int,int)` overwrites it; never read by any other module at startup | **IMPLEMENTATION DEFAULT** — NON-AUTHORITATIVE |
| V-02 | EMA `appliedPrice = 0` | `mql5/modules/EMAEngine.mq5:6` | Private module field initializer; written by `EMAConfigure` at line 11 but **never read anywhere** in the repository (see §2) | **IMPLEMENTATION DEFAULT** — NON-AUTHORITATIVE |
| V-03 | ATR `period = 14` | `mql5/modules/ATREngine.mq5:4` | Private module field initializer; overwritten by `ATRConfigure(int)`; no startup caller | **IMPLEMENTATION DEFAULT** — NON-AUTHORITATIVE |
| V-04 | `EMAConfigure(50,0)` | `tests/EMAEngineTests.mq5:5` | Test fixture exercising the API contract; not a runtime configuration source | **TEST-ONLY** — NON-AUTHORITATIVE |
| V-05 | `ATRConfigure(14)` | `tests/ATREngineTests.mq5:5` | Test fixture exercising the API contract; not a runtime configuration source | **TEST-ONLY** — NON-AUTHORITATIVE |
| V-06 | EMA50 / EMA200, "on H4 close prices" | `docs/phase2/STRATEGY_SPECIFICATION_EXPANDED.md:5,28–31,35–40` | Phase 2 **strategy** specification, marked "Awaiting Review"; describes a two-EMA trend system; mixed with trend/entry/risk/execution content | **STRATEGY-ONLY** — NON-AUTHORITATIVE |
| V-07 | EMA50/200 | `docs/phase2/STRATEGY_SPECIFICATION.md:9` | Same strategy document family | **STRATEGY-ONLY** — NON-AUTHORITATIVE |
| V-08 | EMA50/200, ATR14 | `docs/phase3/INTERFACE_CONTRACTS.md:8–9` and `docs/phase3/SOFTWARE_DESIGN.md:6` | Phase 3 design/strategy-oriented interface sketches (two EMAs, H4/H1 inputs); not a runtime configuration contract, not frozen | **STRATEGY-ONLY** — NON-AUTHORITATIVE |
| V-09 | EMA50/200, ATR14 | `docs/phase7/AI_DATASET_SPEC.md:4,8` | AI/optimization dataset spec; explicitly out of Sprint 6 infrastructure scope | **STRATEGY-ONLY / AI-ONLY** — NON-AUTHORITATIVE |
| V-10 | EMA period, EMA applied price, ATR period | `mql5/modules/ConfigSystem.mq5:1–5` | ConfigSystem has **no** settings fields, record type, getter, loader output, or input — nothing to supply values | **UNRESOLVED — NO AUTHORITATIVE SOURCE EXISTS** |
| V-11 | EMA period, EMA applied price, ATR period | `mql5/modules/ConfigValidator.mq5:2–14` | Generic scalar validators only; aggregate `ValidateConfiguration()` returns `VAL_PENDING` (line 14) | **UNRESOLVED — NO AUTHORITATIVE VALUES** |
| V-12 | Any value in `EMAConfigure`/`ATRConfigure` startup call | None — no startup caller exists | `EMAConfigure`/`ATRConfigure` have zero callers outside the test fixtures (V-04/V-05); `IndicatorManagerInit()` (`IndicatorManager.mq5:3–8`) calls only `EMAInit()` and `ATRInit()`; `VerifyIndicatorsReady()` (`EAMain.mq5:110–115`) requires `EMAReady()` and `ATRReady()`, both of which require `configured == true` | **UNRESOLVED — ABSENT** |

### 1.3 Repeated-appearance analysis (INFERENCE)

The value `50` (EMA) and `14` (ATR) appear in a private initializer, a test fixture, and strategy documentation. Per the task rule, **repetition is not approval**: the three occurrences have three different statuses (implementation default, test-only, strategy-only), none of which is an approved runtime configuration source. The strategy documents describe a **two-EMA** (50/200) system while the frozen engine is a **single-EMA** contract (`EMAEngine.mq5` header comment: "single implementation only"), so even the strategy values could not be applied without contradiction.

### 1.4 Verdict

```text
VALUES: NOT AUTHORIZED
```

No exact runtime value for EMA period, EMA applied price, or ATR period can be legitimately approved from existing repository evidence. Approval requires an explicit, separate decision that (a) names the authoritative non-strategy source and (b) states the exact values and their validation rules.

---

## 2. Applied Price Decision

### 2.1 Audit (VERIFIED FROM SOURCE)

| Audit dimension | Finding |
|---|---|
| Existing types | Only `int appliedPrice` field; no dedicated enum/type for applied price anywhere in `mql5/` or `tests/` |
| Enums | `CommonTypes.mqh` defines `TrendDirection`, `TrendStrength`, `SwingType`, `LogLevel`, `ModuleStatus`, `ValidationResult`, `PatternType`, `PatternStrength`, `FibonacciLevel` — **none** relates to price type/domain |
| Constants | `Constants.mqh` contains version/buffer/log constants only; no price-type constants |
| Validators | `ConfigValidator.mq5` has `ValidateEnumValue(int,int,int)` and range/positive helpers; **no validator is applied to `appliedPrice` anywhere** (no production caller exists) |
| Comments/contracts | No comment, header, or contract document defines the domain of the `int` parameter of `EMAConfigure` |
| Actual EMA calculation behavior | `EMAUpdate()` (`EMAEngine.mq5:12–18`) reads `SymbolInfoDouble(_Symbol, SYMBOL_BID)` directly (line 13) and **never reads the `appliedPrice` field**. The field is written by `EMAConfigure` (line 11) and otherwise unused — repository-wide grep confirms only those two occurrences |
| All callers | Zero startup callers; only `tests/EMAEngineTests.mq5:5` calls `EMAConfigure(50,0)` |
| All tests | Same single fixture call; no test validates or asserts applied-price semantics |

### 2.2 Findings

1. The `int` parameter of `EMAConfigure` has **no documented domain** — neither MQL `ENUM_APPLIED_PRICE` values nor a custom contract.
2. The stored `appliedPrice` field is **semantically inactive**: the calculation ignores it (`SYMBOL_BID` is hard-coded). It is a stored-but-unused field, so `0` cannot be interpreted as "PRICE_CLOSE" or any other active semantic.
3. `0` must **not** be interpreted as `PRICE_CLOSE`. MQL's `ENUM_APPLIED_PRICE` does define `PRICE_CLOSE = 0`, but there is no evidence that the engine's `int` maps to `ENUM_APPLIED_PRICE`, and the value is not consumed by the calculation.

### 2.3 Verdict

```text
APPLIED-PRICE DOMAIN: NOT AUTHORIZED
```

**Exactly what architecture approval is required:** a decision that either
- (a) defines a frozen mapping of the `EMAConfigure` `int` parameter to a specific enumerated domain (e.g., MQL `ENUM_APPLIED_PRICE`, with the engine modified to consume it), including the exact allowed values and validation rule, or
- (b) explicitly approves a fixed, documented constant domain for the parameter (e.g., "always close price" as an infrastructure decision, not a strategy inference) and a validation rule enforcing it.

Option (b) still requires the engine to be approved to consume the field; neither option is decided by this package. This approval item cannot be resolved from repository evidence.

---

## 3. Configuration Contract Shape

### 3.1 Required elements (ARCHITECTURE DECISION — future contract, NOT implemented)

The minimum runtime indicator-configuration contract must define, or explicitly mark unresolved:

| Element | State in this package | Required definition |
|---|---|---|
| EMA period | **UNRESOLVED** — value not authorized (§1) | Exact positive integer value(s) and any allowed range |
| EMA applied price | **UNRESOLVED** — domain not authorized (§2) | Exact domain and value, plus consumption semantics in the engine |
| ATR period | **UNRESOLVED** — value not authorized (§1) | Exact positive integer value(s) and any allowed range |
| Configuration validity | **UNRESOLVED** — `ValidateConfiguration()` returns `VAL_PENDING` (`ConfigValidator.mq5:14`) | Validity predicate: record present, periods > 0, applied-price domain valid, aggregate consistent |
| Acquisition/source responsibility | **APPROVED CONCEPTUALLY** — ConfigSystem (SPR6-006E §5) | A typed, non-strategy source/transport (see §3.3); exact interface pending approval |
| Validation responsibility | **APPROVED CONCEPTUALLY** — ConfigValidator | Domain checks, positive-period checks, aggregate validity (§6) |
| Application responsibility | **APPROVED CONCEPTUALLY** — IndicatorManager | Calls `EMAConfigure`/`ATRConfigure` with validated values only |
| Lifecycle ownership | **APPROVED CONCEPTUALLY** — IndicatorManager owns indicator children; EAMain owns layers | Unchanged from frozen model |
| Failure semantics | **APPROVED CONCEPTUALLY** — see §8 | Configuration failure aborts before/at indicator layer; reverse-order rollback |

### 3.2 Interface signature preservation (VERIFIED FROM SOURCE + DECISION)

```mql5
bool EMAConfigure(int period, int appliedPrice)   // EMAEngine.mq5:11 — preserved
bool ATRConfigure(int period)                     // ATREngine.mq5:9  — preserved
```

**Decision:** preservation is possible and required. Both signatures can receive approved values unchanged; no repository evidence makes preservation impossible. **No signature change is proposed.**

### 3.3 Transport contract (UNRESOLVED — approval item)

There is **no transport**: no `input` declaration, no `.ini`/`.set`/`.cfg`/`.csv` payload, no getter, no loader output. The exact transport shape is an **undecided approval item** with candidate options that are *not selected here*:

- a typed indicator-settings record produced by ConfigSystem (source/data owner), or
- an explicitly approved equivalent non-strategy source.

A **new frozen configuration interface will be required** (ConfigSystem currently has no data surface at all — §4). Because ConfigSystem is a frozen Sprint 1 module, this is a formal frozen-interface change requiring separate approval.

---

## 4. Ownership Contract

### 4.1 Formal evaluation (VERIFIED FROM SOURCE + ARCHITECTURE DECISION)

| Owner | Must it own? | Evidence / rationale | Current implementation |
|---|---|---|---|
| **ConfigSystem** | **Configuration data: YES (future).** **Acquisition: YES (future).** **Persistence/loading: YES (future, `ConfigLoad()` exists as stub).** **Indicator settings source: YES (future).** | `ConfigSystem.mq5:1–5` is the designated configuration component (SPRINT_06_PLAN §7 line 37: "Load and validate configuration parameters"); it currently has no data surface | Stubs only: `ConfigInit()/ConfigLoad()/ConfigValidate()/ConfigStatus()` all return success constants; zero settings |
| **ConfigValidator** | **Validation: YES.** **Domain checks: YES (future).** **Positive-period checks: YES (future).** **Aggregate configuration validity: YES (future).** | Generic primitives exist (`ConfigValidator.mq5:2–8`); aggregate `ValidateConfiguration()` is `VAL_PENDING` (line 14) and its own comment defers full config to Sprint 6+ | Generic scalar helpers only; no indicator-config validator, no production caller |
| **IndicatorManager** | **EMAInit: YES.** **ATRInit: YES.** **EMAConfigure/ATRConfigure application: YES (future).** **Partial child rollback: YES (future, B-06 scope).** **Ready verification: YES.** | Owns EMA/ATR lifecycle (`IndicatorManager.mq5:3–16`); `VerifyEMAReady()/VerifyATRReady()` exist; currently calls only `Init`, never `Configure` | Lifecycle exists; configuration application and partial-child rollback absent |
| **EAMain** | **Lifecycle sequencing: YES.** **Layer transition: YES.** **Failure propagation: YES.** **Layer-level rollback: YES.** | `EAMain.mq5:145–307` orchestrates Infrastructure → Indicators → Structure → Price Action with per-layer rollback calls; `VerifyIndicatorsReady()` at `EAMain.mq5:110–115` is the readiness gate | Exists; currently unblocked only by the missing configuration contract (B-05) |

### 4.2 Governing rule (VERIFIED FROM SOURCE + PRESERVED)

> **Manager owns children; EAMain owns layers.**

This rule is preserved exactly as in the frozen architecture: IndicatorManager (and only IndicatorManager) touches EMA/ATR lifecycle; EAMain calls layer-level init/verify/rollback functions and never reaches into child modules directly. The current EAMain code already follows this shape for the indicator layer (`RollbackIndicatorLayer()` delegates to `IndicatorManagerShutdown()`, `EAMain.mq5:194–197`).

---

## 5. Strategy Boundary

### 5.1 Rejection rule (ARCHITECTURE DECISION, reaffirmed)

Any proposed configuration value derived from strategy specification, entry logic, trend strategy, risk, execution, optimization, or trading parameters is **rejected as Sprint 6 infrastructure configuration** unless separately and explicitly approved as such. This package approves **none** of them.

### 5.2 Audit of Phase 2 document references (VERIFIED FROM SOURCE)

`docs/phase2/STRATEGY_SPECIFICATION_EXPANDED.md` and `docs/phase2/STRATEGY_SPECIFICATION.md` contain EMA50/200 and ATR14 mentions. They **cannot legally become** the runtime EMA/ATR configuration source because:

1. They are **strategy documents** (trend classification, entry rules, risk %, SL/TP, session filters, trade logging fields) — the values appear inside strategy logic, not as a configuration contract.
2. The expanded spec is explicitly marked **"Awaiting Review"** — not approved.
3. They describe a **two-EMA** (50/200) system; the frozen engine is a **single-EMA** contract (`EMAEngine.mq5:1`), so the documented values cannot even map onto the engine.
4. They provide **no transport mechanism** (no input, no file, no record) — nothing for ConfigSystem to load.
5. Same classification applies to `docs/phase3/INTERFACE_CONTRACTS.md:8–9`, `docs/phase3/SOFTWARE_DESIGN.md:6` (design sketches) and `docs/phase7/AI_DATASET_SPEC.md:4,8` (AI dataset, explicitly out of scope).

**Decision:** the Phase 2/3/7 mentions are classified **STRATEGY-ONLY** and are excluded from runtime configuration. They remain useful only as future *strategy-phase* input for a separately approved strategy configuration layer — which is not Sprint 6 infrastructure scope.

---

## 6. Validation Contract

### 6.1 Minimum validation requirements (ARCHITECTURE DECISION — future)

| Requirement | Owner | Status |
|---|---|---|
| EMA period > 0 | ConfigValidator | Primitive exists (`ValidatePositive`, `ConfigValidator.mq5:4`) but has no production caller; rule itself is trivially satisfiable **once a value source exists** |
| ATR period > 0 | ConfigValidator | Same as above |
| Applied-price domain validity | ConfigValidator | **No domain exists** (§2) — validation rule cannot be defined until domain approval; `ValidateEnumValue` exists for an eventual enumerated domain |
| Configuration completeness | ConfigValidator | Requires the future typed record; presence checks possible via `ValidateRequired`/`ValidateNotEmpty` once a record exists |
| Aggregate configuration validity | ConfigValidator | `ValidateConfiguration()` (`ConfigValidator.mq5:14`) currently returns `VAL_PENDING`; the contract must define its completion |

### 6.2 Sufficiency of existing primitives (VERIFIED FROM SOURCE + INFERENCE)

- **Partially sufficient:** `ValidatePositive`, `ValidateNonNegative`, `ValidateRange`, `ValidateRequired`, `ValidateNotEmpty`, `ValidateEnumValue`, `ValidateStringLength` cover scalar checks.
- **Not sufficient:** there is no validator invocation path for indicator settings (no caller), no typed record to validate, and no applied-price domain rule. The aggregate `ValidateConfiguration()` is explicitly pending.
- **Conclusion:** an **additional frozen configuration contract must be approved** (transport + record + domain + aggregate-validation semantics). The generic primitives can then be composed by the future ConfigValidator-owned validation path. No validation is implemented by this package.

---

## 7. Startup Contract

### 7.1 Approved conceptual sequence (ARCHITECTURE DECISION — future, from SPR6-006E §11, reaffirmed)

```text
1. Configuration acquisition            (ConfigSystem — future source)
2. Configuration validation             (ConfigValidator — future)
3. IndicatorManager initialization
   3.1 EMAInit()
   3.2 ATRInit()
   3.3 EMAConfigure(validated EMA period, validated applied price)
   3.4 ATRConfigure(validated ATR period)
4. Ready verification                   (EMAReady() && ATRReady())
5. Structure initialization
6. Price Action initialization
```

### 7.2 Current vs. approved vs. future (VERIFIED FROM SOURCE)

| Step | CURRENT IMPLEMENTATION | APPROVED ARCHITECTURE | FUTURE IMPLEMENTATION |
|---|---|---|---|
| Configuration acquisition | **Absent** — `ConfigInit()` (`EAMain.mq5:149`) is a stub that returns `INIT_SUCCEEDED` without acquiring anything | ConfigSystem is the future source owner | ConfigSystem must expose the approved typed contract and populate it |
| Configuration validation | **Absent** — no validator call in `EAStartup()`; `ConfigValidate()` stub returns `true` | ConfigValidator owns validation of the typed record | EAMain (or the infra layer) calls the validated acquisition before indicators |
| IndicatorManager initialization | Present — `InitializeIndicatorLayer()` → `IndicatorManagerInit()` (`EAMain.mq5:185`), which calls `EMAInit()` + `ATRInit()` (`IndicatorManager.mq5:3–8`) | IndicatorManager owns child init/configure | **Absent:** `EMAConfigure`/`ATRConfigure` calls (steps 3.3/3.4) do not exist anywhere in startup |
| Ready verification | Present and **unreachable as passing** — `VerifyIndicatorsReady()` (`EAMain.mq5:110–115`) requires `EMAReady() && ATRReady()`, both of which require `configured == true`, but no Configure call precedes it (B-05) | Verification after configuration application | Same gate, reachable once configuration exists |
| Structure / Price Action | Present — `EAMain.mq5:269–306` | Unchanged | Unchanged; B-09 consumption stays deferred |

**No source is altered to realize this sequence.**

---

## 8. Failure / Rollback Contract

### 8.1 Architecture-level behavior (ARCHITECTURE DECISION — future, from SPR6-006E §12, reaffirmed)

| Failure | Immediate owner | Return behavior | Rollback owner | Rollback order |
|---|---|---|---|---|
| Configuration acquisition failure | ConfigSystem / EAMain infrastructure phase | Startup fails **before** indicator layer | EAMain (layer owner) | Only successfully initialized infrastructure services, reverse order |
| Configuration validation failure | ConfigValidator / EAMain infrastructure phase | Startup fails **before** indicator layer | EAMain (layer owner) | Same as above |
| `EMAConfigure` failure | IndicatorManager | IndicatorManager configuration fails; indicator layer aborts | **IndicatorManager rolls back its children** (EMA/ATR already initialized), then EAMain rolls back lower layers | Child reverse order inside manager → infrastructure reverse order |
| `ATRConfigure` failure | IndicatorManager | Same | **IndicatorManager rolls back its children** (EMA/ATR), then EAMain | Same |
| Readiness failure (`EMAReady()`/`ATRReady()` false) | IndicatorManager / EAMain verification boundary | Indicator layer verification fails | IndicatorManager (child shutdown) then EAMain (layer rollback) | Matches existing `RollbackIndicatorLayer()` + `RollbackInfrastructureLayer()` shape (`EAMain.mq5:263–266`) |

### 8.2 Preserved invariants

- **Child rollback belongs to IndicatorManager** — EAMain must not call `EMAShutdown()`/`ATRShutdown()` directly (it already delegates via `RollbackIndicatorLayer()` → `IndicatorManagerShutdown()`, `EAMain.mq5:194–197`).
- **Layer rollback belongs to EAMain** — per-layer rollback functions already exist and are sequenced in reverse order in `EAStartup()`.
- **Reverse-order cleanup** — rollback order mirrors initialization order (SPRINT_06_PLAN §8.2).
- **No direct child ownership leakage into EAMain.**

This package does not implement rollback; the partial-child-rollback details remain B-06 scope.

---

## 9. Frozen Interface Impact

### 9.1 Determination (VERIFIED FROM SOURCE + DECISION)

Implementation of PATCH-CFG-01 **would require a new/modified frozen configuration interface** (in the sense that a data/acquisition surface must be created or exposed) **plus** zero changes to the existing Configure/Ready signatures.

### 9.2 Explicit lists

**Interfaces that remain unchanged (must remain frozen):**

| Interface | Location | Status |
|---|---|---|
| `bool EMAConfigure(int period, int appliedPrice)` | `EMAEngine.mq5:11` | Preserved |
| `bool ATRConfigure(int period)` | `ATREngine.mq5:9` | Preserved |
| `EMAInit/EMAReady/EMAUpdate/EMAValue/EMAStatus/EMAShutdown` | `EMAEngine.mq5` | Preserved |
| `ATRInit/ATRReady/ATRUpdate/ATRValue/ATRStatus/ATRShutdown` | `ATREngine.mq5` | Preserved |
| `IndicatorManagerInit/IndicatorManagerShutdown/IndicatorManagerStatus/VerifyEMAReady/VerifyATRReady` | `IndicatorManager.mq5` | Preserved (public surface; whether a new apply interface is added is a separate approval item) |
| `ConfigInit/ConfigLoad/ConfigValidate/ConfigStatus` | `ConfigSystem.mq5:1–5` | Preserved as-is until the new contract is approved |
| `ConfigValidator` generic helpers | `ConfigValidator.mq5:2–8` | Preserved |
| All other frozen Sprint 1–5 modules and all `CommonTypes.mqh` enums | — | Preserved (PATCH-CT-01 rename remains the only approved-but-unapplied frozen change) |

**Interfaces that may need approval:**

1. A **new frozen configuration contract for ConfigSystem** — typed indicator-settings record and/or acquisition/access surface. This is the primary approval item. Exact public shape is **not invented here**.
2. **Possibly an IndicatorManager configuration-application surface** — the manager must apply values, but whether that requires a new public manager function or an internal change is undecided and must be approved before implementation.
3. Any **domain/validation contract** for the applied-price parameter (§2, §6).

**Interfaces that must remain frozen (no change permitted):**

- `bool EMAConfigure(int period, int appliedPrice)` and `bool ATRConfigure(int period)` — signatures must not change (no evidence makes preservation impossible).
- `CommonTypes.mqh`, `Constants.mqh`, `ErrorCodes.mqh`, `EventIDs.mqh`, `PriceActionErrorCodes.mqh`, `PriceActionEventIDs.mqh`, `StructureEventIDs.mqh`, `Utils.mqh` — unchanged except for the separately approved PATCH-CT-01.
- All frozen Sprint 1–5 module public surfaces not listed under "may need approval".

No interface is modified by this package.

---

## 10. Approval Matrix

| Decision | Current Evidence | Proposed Architecture | Approval Required | Status |
|---|---|---|---|---|
| EMA period | IMPLEMENTATION DEFAULT 50; TEST-ONLY 50; STRATEGY-ONLY 50/200; no authoritative source | Exact positive integer from approved non-strategy contract | Exact value + range + source approval | **BLOCKED** |
| EMA applied price | IMPLEMENTATION DEFAULT 0 (stored, never read); TEST-ONLY 0; no domain defined | Explicit domain (or fixed documented constant) + engine consumption semantics | Domain + value + semantics approval | **BLOCKED** |
| ATR period | IMPLEMENTATION DEFAULT 14; TEST-ONLY 14; STRATEGY-ONLY 14; no authoritative source | Exact positive integer from approved non-strategy contract | Exact value + range + source approval | **BLOCKED** |
| Applied-price domain | Undefined; no enum/constant/validator; field semantically inactive | Enumerated domain or fixed constant with validation | New frozen domain/validation contract | **BLOCKED** |
| ConfigSystem ownership | Stubs only; no data surface | Future configuration source/data owner | Frozen interface contract for data/acquisition | **APPROVED CONCEPTUALLY — IMPLEMENTATION BLOCKED** |
| ConfigValidator ownership | Generic primitives; aggregate pending | Future validation owner (domain, positive-period, aggregate) | Validation path contract for indicator settings | **APPROVED CONCEPTUALLY — IMPLEMENTATION BLOCKED** |
| IndicatorManager ownership | Owns EMA/ATR lifecycle; no Configure calls | Future configuration application + child rollback owner | Application-path approval (public vs. internal) | **APPROVED CONCEPTUALLY — IMPLEMENTATION BLOCKED** |
| EAMain ownership | Layer sequencing/rollback exists | Lifecycle sequencing + layer failure propagation owner | No change (exists); unblocked only by config | **APPROVED — EXISTING** |
| Configuration transport | None (no inputs, no payloads, no getters) | Typed non-strategy indicator settings transport | Transport contract approval | **BLOCKED** |
| Validation contract | Primitives only; `ValidateConfiguration()` = VAL_PENDING | Compose primitives behind approved record/domain validation | Contract approval (record + domain + aggregate) | **BLOCKED** |
| Rollback behavior | EAMain layer rollback exists; manager child rollback partially missing (B-06) | Manager owns children, EAMain owns layers, reverse order | B-06 patch approval (already planned) | **APPROVED CONCEPTUALLY — B-06 PENDING** |
| Strategy boundary | EMA50/200/ATR14 in Phase 2/3/7 docs | Excluded from runtime configuration | None (exclusion is the decision) | **APPROVED — EXCLUSION CONFIRMED** |
| Frozen interface impact | Configure/Ready signatures fit future application | No signature change; new ConfigSystem data contract needed | New frozen contract approval | **BLOCKED (only for the new contract)** |

---

## 11. Explicit Gate Decision

```text
SPR6-006F BLOCKED — CONFIGURATION CONTRACT APPROVAL STILL REQUIRED
```

The READY outcome is **not** authorized because required values and contract decisions remain unresolved.

### Remaining blockers (exhaustive)

1. **VALUES: NOT AUTHORIZED** — no exact, non-strategy, authoritative runtime values exist for:
   - EMA period,
   - EMA applied price,
   - ATR period.
   (Private engine initializers, test fixtures, and Phase 2/3/7 strategy documentation are all classified NON-AUTHORITATIVE; repetition of a number is not approval.)
2. **APPLIED-PRICE DOMAIN: NOT AUTHORIZED** — the repository defines no domain for the `int` parameter of `EMAConfigure`; the stored field is never consumed by the calculation; `0` must not be interpreted as `PRICE_CLOSE` without an approved mapping.
3. **CONFIGURATION TRANSPORT CONTRACT: UNDEFINED** — no input, payload file, getter, or loader output exists; a typed non-strategy acquisition/transport contract must be approved.
4. **NEW FROZEN CONFIGURATION INTERFACE: NOT APPROVED** — ConfigSystem (frozen Sprint 1 module) has no data surface; a formal frozen configuration-contract patch is required before any implementation.
5. **VALIDATION CONTRACT: NOT APPROVED** — aggregate `ValidateConfiguration()` is `VAL_PENDING`; the applied-price domain rule and record-completeness semantics are undefined.
6. **INDICATOR MANAGER APPLICATION PATH: NOT APPROVED** — whether configuration application uses a new public manager surface or an internal change is undecided.

**PATCH-CFG-01: NOT READY FOR PATCH.** No implementation begins as a result of this package — not even in the READY case — per the task rule.

---

## 12. Self-Audit

| Requirement | Result |
|---|---|
| MQL5 source modified | **0** |
| Frozen interface modified | **0** |
| CommonTypes modified | **0** |
| EAMain modified | **0** |
| TrendEngine modified | **0** |
| ConfigSystem modified | **0** |
| ConfigValidator modified | **0** |
| IndicatorManager modified | **0** |
| EMA/ATR modules modified | **0** |
| Strategy logic added | **0** |
| B-09 implemented | **0 — deferred** |
| B-01 … B-08 implemented | **0** |
| New input declaration added | **0** |
| New public API signature invented | **0** (future contract shape explicitly left as an approval item) |
| Compiler | **NOT AVAILABLE — MQL5 compiler not present in sandbox; COMPILE: NOT VERIFIED** |
| Runtime | **NOT AVAILABLE — no MT5/Strategy Tester; RUNTIME: NOT VERIFIED** |

**Confirmation — no value was invented.** No EMA period, no applied-price value, and no ATR period is proposed, adopted, or implied by this package. All candidates were classified (§1) and rejected as non-authoritative. The applied-price domain was declared NOT AUTHORIZED rather than interpreted. The gate decision is BLOCKED precisely because values and contracts could not be legitimately established from repository evidence.

---

*SPR6-006F — documentation only. No source change accompanies this report. Committed per repository rules; not pushed.*
