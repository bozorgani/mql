# SPR6-006E — Formal Indicator Configuration Contract Architecture Decision

**Status:** **BLOCKED — VALUES / CONFIGURATION CONTRACT STILL REQUIRE APPROVAL**  
**Scope:** Architecture decision and documentation only  
**Source modifications:** **0**  
**PATCH-CFG-01:** **NOT READY FOR PATCH**

> This document makes no source change and does not select indicator values. All references to a future contract below are architecture decisions/proposals, not existing implementation.

## 1. Executive Summary

The repository has no approved non-strategy runtime configuration source for EMA period, EMA applied price, or ATR period. Re-inspection confirms the results of SPR6-006C and SPR6-006D:

- ConfigSystem has lifecycle stubs only and no settings data, getters, loader output, or runtime inputs.
- ConfigValidator has generic validation helpers, but aggregate configuration validation is pending.
- The only runtime definitions of `EMAConfigure(int,int)` and `ATRConfigure(int)` have no startup callers.
- Private engine initializers, test fixture calls, and Phase 2 strategy documentation are not authoritative runtime configuration.

**Architecture decision:** a **new typed indicator configuration contract is required**. Its intended ownership separation is: ConfigSystem is the future source owner; ConfigValidator is the future validation owner; IndicatorManager is the future application/child-lifecycle owner; EAMain is the lifecycle orchestrator. This ownership decision does not by itself create an implementation or authorize an interface change.

Exact runtime values and the applied-price domain remain undefined. Therefore PATCH-CFG-01 is not ready and all source remediation remains stopped.

## 2. Source Evidence

### VERIFIED FROM SOURCE — ConfigSystem and ConfigValidator

| Source | Finding |
|---|---|
| `mql5/modules/ConfigSystem.mq5:1–5` | Public surface is only `ConfigInit()`, `ConfigLoad()`, `ConfigValidate()`, and `ConfigStatus()`. There is no configuration record, EMA/ATR field, getter, loader output, or input. |
| `ConfigSystem.mq5:2` | `ConfigInit()` returns `INIT_SUCCEEDED`; it does not acquire indicator values. |
| `mql5/modules/ConfigValidator.mq5:2–8` | Generic validation helpers exist: required, range, positive, non-negative, string length, enum value. |
| `ConfigValidator.mq5:13–14` | Aggregate `ValidateConfiguration()` returns `VAL_PENDING`; its source explicitly says full config is deferred. |
| Repository-wide input audit | No MQL `input` declarations were found in `mql5` or `tests`. |
| Repository file audit | No `.ini`, `.set`, `.cfg`, CSV, or other runtime configuration payload exists for indicator settings. |

### VERIFIED FROM SOURCE — Indicator contracts and current callers

| Interface | Definition | Current startup caller | Other caller/evidence |
|---|---|---|---|
| `EMAConfigure(int p,int ap)` | `EMAEngine.mq5:11` | None | `tests/EMAEngineTests.mq5:5` calls `(50,0)` |
| `EMAReady()` | `EMAEngine.mq5:20` | EAMain verification at `EAMain.mq5:112` | IndicatorManager wrapper at `IndicatorManager.mq5:15` |
| `ATRConfigure(int p)` | `ATREngine.mq5:9` | None | `tests/ATREngineTests.mq5:5` calls `(14)` |
| `ATRReady()` | `ATREngine.mq5:22` | EAMain verification at `EAMain.mq5:113` | IndicatorManager wrapper at `IndicatorManager.mq5:16` |
| `IndicatorManagerInit()` | `IndicatorManager.mq5:3–8` | EAMain calls it at `EAMain.mq5:185` | Calls only `EMAInit()` then `ATRInit()` |

### VERIFIED FROM SOURCE — non-authoritative values

| Candidate | Evidence | Decision |
|---|---|---|
| EMA private fields | `EMAEngine.mq5:5–6` initializes `period = 50`, `appliedPrice = 0` | Internal implementation state, **not authoritative configuration** |
| ATR private field | `ATREngine.mq5:4` initializes `period = 14` | Internal implementation state, **not authoritative configuration** |
| Tests | EMA test calls `(50,0)`; ATR test calls `(14)` | Test fixtures, **not runtime configuration** |
| Phase 2 documentation | `docs/phase2/STRATEGY_SPECIFICATION_EXPANDED.md` mentions EMA50/200 and ATR14 | Strategy document marked “Awaiting Review”; not runtime configuration and incompatible with current single-EMA contract |

## 3. Current Configuration Gap

### VERIFIED FROM SOURCE

The current startup sequence is:

```text
IndicatorManagerInit()
  → EMAInit()
  → ATRInit()
  → indicatorInitialized = true
VerifyIndicatorsReady()
  → EMAReady() requires initialized && configured
  → ATRReady() requires initialized && configured
```

No source performs either Configure call before EAMain requires readiness.

### INFERENCE

The frozen EMA/ATR contracts are sufficient to *apply* values, but the architecture has no contract to supply, validate, transport, or own those values at runtime. Calling Configure with any private/default/test/strategy number would manufacture semantics and violate the stop condition.

## 4. Authoritative Source Decision

### ARCHITECTURE DECISION

**Choice A:** **5. A new configuration contract is required.**

No existing component is an implemented authoritative source. The future contract should be introduced under ConfigSystem ownership because the Sprint 6 plan places configuration acquisition in the infrastructure phase and lists ConfigSystem as the configuration component. However, this is a future architecture contract, not proof that current ConfigSystem can already perform the role.

**Decision boundaries:**

- Do not make EAMain the value authority; it is orchestration only.
- Do not make IndicatorManager the value authority; it owns indicator children, not system configuration data.
- Do not use a test or strategy document as an adapter/source.
- Do not introduce an input/file/getter in this task.

## 5. Ownership Model

### ARCHITECTURE DECISION — future approved model

| Responsibility | Owner | Rationale | Current implementation status |
|---|---|---|---|
| Configuration source/data | ConfigSystem | Infrastructure layer is the natural configuration source; Sprint 6 starts with Config initialization | Not implemented; contract needed |
| Configuration validation | ConfigValidator | Existing generic validation component | Generic primitives exist; indicator contract validation absent |
| Configuration application to EMA/ATR | IndicatorManager | Existing owner of EMA/ATR lifecycle | Lifecycle exists; configuration application absent |
| Lifecycle sequencing/failure propagation | EAMain | Existing integration orchestrator | Exists but currently incomplete/blocked |

This model preserves “manager owns children; EAMain owns layers.” It does not accept a new source interface automatically; a formal frozen configuration-contract patch is required later.

## 6. EMA Contract

### VERIFIED FROM SOURCE

Existing interface:

```mql5
bool EMAConfigure(int period, int appliedPrice)
```

`EMAReady()` is true only when EMA is initialized and configured.

### ARCHITECTURE DECISION — conceptual future contract

| Field | Type | Source | Validation | Owner | Lifecycle availability | Failure behavior |
|---|---|---|---|---|---|---|
| EMA period | `int` | Future approved ConfigSystem indicator settings record | Positive integer; any further allowed range requires approval | Source: ConfigSystem; validation: ConfigValidator; apply: IndicatorManager | Validated before IndicatorManager configuration | Configuration failure aborts indicator layer; manager rolls back initialized children |
| EMA applied price | `int` only at the existing engine interface boundary | Future approved ConfigSystem indicator settings record | Domain is undefined; must be explicitly approved | Same ownership split | Validated before EMAConfigure | Invalid/undefined domain aborts before Configure |

**VALUES:** **UNDEFINED / ARCHITECTURE APPROVAL REQUIRED.**

No period or applied-price value is selected by this decision.

## 7. ATR Contract

### VERIFIED FROM SOURCE

Existing interface:

```mql5
bool ATRConfigure(int period)
```

`ATRReady()` is true only when ATR is initialized and configured.

### ARCHITECTURE DECISION — conceptual future contract

| Field | Type | Source | Validation | Owner | Lifecycle availability | Failure behavior |
|---|---|---|---|---|---|---|
| ATR period | `int` | Future approved ConfigSystem indicator settings record | Positive integer; any further allowed range requires approval | Source: ConfigSystem; validation: ConfigValidator; apply: IndicatorManager | Validated before IndicatorManager configuration | Configuration failure aborts indicator layer; manager rolls back initialized children |

**VALUES:** **UNDEFINED / ARCHITECTURE APPROVAL REQUIRED.**

No ATR period is selected by this decision.

## 8. Applied Price Contract

### VERIFIED FROM SOURCE

The EMA interface accepts an `int`; the module stores it in an `int` field. No source defines an applied-price enum/domain, validates a permissible value, or documents a runtime mapping from configuration to MQL applied price. The current EMA calculation reads `SYMBOL_BID` directly and does not consume the stored `appliedPrice` field.

### ARCHITECTURE DECISION

**Applied-price domain is undefined.** The future configuration contract must explicitly approve the domain represented by the `int` parameter, including its MQL-compatible values and validation. This report does not adopt `0`, does not assume `PRICE_CLOSE`, and does not modify the existing interface.

## 9. Value Authorization Decision

### VERIFIED FROM SOURCE

There is no frozen, non-strategy runtime contract that provides exact EMA period, EMA applied price, or ATR period values.

### DECISION

```text
VALUES: UNDEFINED / ARCHITECTURE APPROVAL REQUIRED
```

The Phase 2 strategy text cannot authorize values for this Sprint 6 infrastructure configuration because it is strategy-oriented, references two EMAs while only one frozen engine exists, and does not provide a runtime configuration mechanism. Test values and private initializers likewise do not authorize runtime values.

## 10. Validation Contract

### ARCHITECTURE DECISION — proposed future validation duties

1. ConfigSystem acquires a typed indicator settings record only after its contract is approved.
2. ConfigValidator validates record presence and positive periods using existing generic primitives where applicable.
3. The applied-price domain must have an explicitly approved validation rule before `EMAConfigure` is called.
4. No configuration is considered valid while values/domain are undefined.
5. Validation failure is an infrastructure/configuration failure and prevents indicator initialization/configuration.

This is a proposed future contract only. Existing `ValidateConfiguration()` remains pending and was not changed.

## 11. Startup Sequence

### ARCHITECTURE DECISION — approved conceptual order, not implementation

```text
1. ConfigSystem initialization
2. Configuration acquisition from the future approved indicator settings contract
3. ConfigValidator validation of all indicator fields
4. IndicatorManager initialization
     4.1 EMAInit()
     4.2 ATRInit()
     4.3 EMAConfigure(validated EMA period, validated applied-price value)
     4.4 ATRConfigure(validated ATR period)
5. EMAReady() and ATRReady() verification
6. Structure initialization
7. Price Action initialization
```

EAMain orchestrates these layer transitions. IndicatorManager owns steps 4.1–4.4 because they concern its child modules. The sequence is not an authorization to add an IndicatorManager interface or modify its implementation yet.

## 12. Failure / Rollback Contract

### ARCHITECTURE DECISION — conceptual future behavior

| Failure | Immediate owner | Return behavior | Rollback owner | Rollback order |
|---|---|---|---|---|
| Config acquisition failure | ConfigSystem / EAMain infrastructure phase | Initialization fails before indicators | EAMain infrastructure owner | Only successfully initialized infrastructure services, reverse order |
| Config validation failure | ConfigValidator / EAMain infrastructure phase | Initialization fails before indicators | EAMain infrastructure owner | Only successfully initialized infrastructure services, reverse order |
| EMA configuration failure | IndicatorManager | IndicatorManager initialization/configuration fails | IndicatorManager, then EAMain | EMA/ATR children successfully initialized by manager, then lower layers |
| ATR configuration failure | IndicatorManager | IndicatorManager initialization/configuration fails | IndicatorManager, then EAMain | ATR/EMA cleanup in manager-owned reverse order, then lower layers |
| Indicator readiness failure | IndicatorManager/EAMain verification boundary | Initialization fails | IndicatorManager, then EAMain | IndicatorManager shutdown, then infrastructure rollback |

The detailed implementation of safe partial rollback remains subject to the approved B-06 patch work. This decision does not alter any rollback source.

## 13. Frozen Interface Impact

| Question | Decision |
|---|---|
| Can `EMAConfigure(int,int)` remain unchanged? | **Yes.** Existing signature can apply approved values. |
| Can `ATRConfigure(int)` remain unchanged? | **Yes.** Existing signature can apply an approved value. |
| Does ConfigSystem require a configuration contract/interface? | **Yes.** No record/getter/acquisition output currently exists. Exact public shape requires separate frozen-contract approval. |
| Does IndicatorManager require a configuration/apply interface? | **Possibly.** Existing manager can conceptually own application, but a public apply interface is not authorized/defined. An internal implementation change versus public manager interface must be decided in the later patch approval. |
| Would a public/frozen interface need modification? | **Yes, likely ConfigSystem.** A typed source/data contract must be approved before implementation. No change is made here. |
| Exact contract requiring approval | Typed non-strategy indicator settings acquisition/transport contract: EMA period, EMA applied-price domain/value, ATR period, validation result, and read/access ownership. |

## 14. Strategy Boundary Audit

The future contract is **indicator infrastructure configuration only**. It is not:

- strategy configuration;
- signal generation;
- entry/exit configuration;
- order or execution configuration;
- risk or money-management configuration; or
- AI or optimization configuration.

No value is imported from strategy documentation. The Phase 2 document remains evidence of why using it directly would contaminate this infrastructure decision: it mixes EMA/ATR mentions with trend classification, entry requirements, risk, execution, and trade logging.

## 15. B-09 Deferred Confirmation

B-09 remains **DEFERRED**. No Structure getter call, Price Action consumer, pattern context, signal, read/write dependency, or circular dependency was added.

## 16. Implementation Preconditions

No PATCH-CFG-01 source implementation may begin until all conditions hold:

1. A formal frozen configuration-contract patch approves the exact ConfigSystem data/acquisition interface (or an explicitly approved alternate source).
2. Exact non-strategy values for EMA period, EMA applied price, and ATR period are approved.
3. The applied-price domain and validation semantics are explicitly approved.
4. Validation ownership and failure behavior are approved.
5. IndicatorManager configuration-application ownership is approved without adding an unapproved public manager interface.
6. B-06 partial rollback behavior is compatible with configuration failure at each step.
7. The decision explicitly preserves existing `EMAConfigure` and `ATRConfigure` signatures.

## 17. Architecture Decision Matrix

| Question | VERIFIED FROM SOURCE | INFERENCE | ARCHITECTURE DECISION | Ready? |
|---|---|---|---|---|
| EMA authoritative source | None | Existing modules cannot supply it | New configuration contract required | No |
| ATR authoritative source | None | Existing modules cannot supply it | New configuration contract required | No |
| Configuration owner | None implemented | Infrastructure is appropriate source layer | ConfigSystem future source owner | No |
| Validation owner | Generic validators only | Separate validation is appropriate | ConfigValidator future validation owner | No |
| Application owner | IndicatorManager owns EMA/ATR lifecycle | Child owner should apply child configuration | IndicatorManager future application owner | No |
| Orchestration owner | EAMain initializes layers | Layer orchestration belongs there | EAMain future sequence/failure owner | No |
| EMA value | Undefined | Defaults/tests/docs non-authoritative | Approval required | No |
| ATR value | Undefined | Defaults/tests/docs non-authoritative | Approval required | No |
| Applied-price domain | Undefined | `int` alone has no documented domain | Approval required | No |
| Existing Configure APIs | Present | Can receive values once supplied | Preserve signatures | Yes, signature only |
| New ConfigSystem contract | Absent | Values cannot flow without it | Formal frozen patch required | No |
| Strategy contamination | No source change | Strategy docs cannot be source | Exclude strategy docs | Yes |

## 18. Final Verdict

```text
STATUS: BLOCKED — VALUES / CONFIGURATION CONTRACT STILL REQUIRE APPROVAL

AUTHORITATIVE SOURCE: NOT IMPLEMENTED; NEW CONFIGURATION CONTRACT REQUIRED
VALUES: UNDEFINED / ARCHITECTURE APPROVAL REQUIRED
APPLIED-PRICE DOMAIN: UNDEFINED / ARCHITECTURE APPROVAL REQUIRED
PATCH-CFG-01: NOT READY FOR PATCH
SOURCE MODIFICATIONS: 0
```

The ownership model is now architecturally defined for future approval, but it does not establish an existing authoritative runtime source or exact values. Therefore it cannot authorize PATCH-CFG-01 implementation.

## 19. Self-Audit

| Requirement | Result |
|---|---|
| Re-inspected ConfigSystem and ConfigValidator | Yes |
| Repository-wide Configure/Ready caller audit completed | Yes |
| Existing non-strategy runtime values found | No |
| Private engine values used as configuration | No |
| Test values used as configuration | No |
| Strategy-document values used as configuration | No |
| Source file modified | 0 |
| Frozen interface modified | 0 |
| New input added | 0 |
| PATCH-CFG-01 implemented | 0 |
| B-01 through B-08 implemented | 0 |
| B-09 implemented | 0 — deferred |
| Strategy/Signal/Entry/Exit/Orders/Execution/Risk/Money/AI added | 0 |
| Compiler claimed passed | No — unavailable |
| Runtime claimed passed | No — unavailable |
