# SPR6-006D — EMA/ATR Configuration Contract Architecture Decision

**Status:** **SPR6-006D BLOCKED — CONFIGURATION CONTRACT DECISION REQUIRED**  
**Mode:** Architecture analysis only  
**Source modifications:** **0**  
**Compiler:** NOT AVAILABLE  
**Runtime:** NOT AVAILABLE

> No MQL5 source, configuration input, CommonTypes, EAMain, TrendEngine, frozen module, rollback, logging, deinit, or B-09 integration was modified.

## 1. Executive Summary

PATCH-CFG-01 is **not ready for implementation**. The repository contains EMA/ATR configuration functions and test fixture values, but it contains no authoritative runtime configuration mechanism that owns and supplies the three required values:

- EMA period (`int`)
- EMA applied price (`int`)
- ATR period (`int`)

`ConfigSystem` has no parameter fields, settings type, getter, loader output, input declaration, or validated configuration record. `ConfigValidator` contains generic scalar validators only and its aggregate configuration validation returns `VAL_PENDING`. The only runtime definitions of `EMAConfigure` and `ATRConfigure` are the functions themselves; no startup caller exists.

Repository documentation mentions EMA50/200 and ATR14 in a Phase 2 **strategy specification**. That document is strategy-oriented, says it is awaiting review, includes entry/risk/execution concerns, and is incompatible with the current single-EMA engine contract. It is neither a runtime configuration object nor a frozen indicator-configuration contract. Test fixtures calling `EMAConfigure(50,0)` and `ATRConfigure(14)` demonstrate API usage only; they are not an authoritative startup source.

No value has been selected or inferred. A new architecture decision is required before B-01 through B-08 controlled remediation can resume.

## 2. Source Evidence

### 2.1 ConfigSystem and ConfigValidator

| File and location | Verified source fact |
|---|---|
| `mql5/modules/ConfigSystem.mq5:1–5` | Defines only `ConfigInit()`, `ConfigLoad()`, `ConfigValidate()`, and `ConfigStatus()`; no settings structure, parameter fields, getters, or loading result exists. |
| `ConfigSystem.mq5:2` | `ConfigInit()` returns `INIT_SUCCEEDED`; it does not accept or provide indicator values. |
| `mql5/modules/ConfigValidator.mq5:2–8` | Generic validators exist: required/range/positive/non-negative/string length/enum value. |
| `ConfigValidator.mq5:13–14` | `ValidateConfiguration()` returns `VAL_PENDING`; its source comment says full config is deferred. |
| Repository input audit | No MQL `input` declaration was found in repository MQL source. |

**Finding:** no existing ConfigSystem mechanism can legitimately supply EMA period, EMA applied price, or ATR period at startup.

### 2.2 Existing EMA/ATR interface and call audit

| Interface | Definition | Runtime callers found | Test callers found |
|---|---|---|---|
| `EMAConfigure(int p, int ap)` | `mql5/modules/EMAEngine.mq5:11` | None | `tests/EMAEngineTests.mq5:5` calls `(50,0)` |
| `ATRConfigure(int p)` | `mql5/modules/ATREngine.mq5:9` | None | `tests/ATREngineTests.mq5:5` calls `(14)` |
| `EMAReady()` | `EMAEngine.mq5:20` | EAMain verification and IndicatorManager wrapper only | EMA tests |
| `ATRReady()` | `ATREngine.mq5:22` | EAMain verification and IndicatorManager wrapper only | ATR tests |

The repository-wide search found only the two Configure definitions plus these test-fixture calls. In particular, `IndicatorManagerInit()` (`IndicatorManager.mq5:3–8`) calls `EMAInit()` and `ATRInit()` but neither Configure interface. `EAMain` then requires both Ready predicates at `EAMain.mq5:110–115`.

### 2.3 Period and applied-price references

| Item | Source evidence | Authority assessment |
|---|---|---|
| EMA private initialization | `EMAEngine.mq5:5–6`: `period = 50`, `appliedPrice = 0` | Internal engine state initializer; not runtime configuration input or approved owner |
| ATR private initialization | `ATREngine.mq5:4`: `period = 14` | Internal engine state initializer; not runtime configuration input or approved owner |
| Test fixture values | EMA test `(50,0)`; ATR test `(14)` | Tests demonstrate API use; no startup/config ownership authority |
| Phase 2 strategy document | `docs/phase2/STRATEGY_SPECIFICATION_EXPANDED.md:4,35–42` states EMA50/200 on H4 closes and ATR14 | Strategy specification, marked “Awaiting Review”; not a runtime config layer and not compatible as a direct single-EMA startup contract |
| Phase 2 configuration section | Same document `:139–142` says parameters are external but provides no MQL implementation/config record for EMA period, applied price, or ATR period | Design intent only; no authoritative values/load path |

## 3. Configuration Ownership Analysis

The frozen Sprint 6 plan identifies ConfigSystem as infrastructure and IndicatorManager as part of the Indicators layer. It states that configuration is loaded/validated during infrastructure initialization and that EAMain orchestrates layer lifecycle. It does not define an EMA/ATR parameter record, source, or owner-specific Configure call.

| Candidate owner | Evidence and assessment | Decision |
|---|---|---|
| A. ConfigSystem | Architecturally the natural owner of loaded runtime configuration, but current frozen ConfigSystem cannot expose any indicator values. | Not currently implementable without an approved configuration-contract patch. |
| B. EAMain orchestration | EAMain owns sequencing, not values. It can call existing Configure functions only after an authoritative source is defined. | May orchestrate approved values, but cannot originate them. |
| C. IndicatorManager | Owns EMA/ATR lifecycle, but its current frozen interface has no configuration inputs and does not define values. | May own applying an approved config record internally only after an architecture decision; cannot choose values. |
| D. Another existing component | No existing module exposes indicator settings. Tests and strategy documentation are not runtime components. | None found. |

**Architecture conclusion:** ConfigSystem is the appropriate future *source-of-values* layer, EAMain can sequence infrastructure-to-indicator handoff, and IndicatorManager remains the appropriate child lifecycle owner. That is an architectural recommendation only. It cannot be implemented under the current frozen interfaces because ConfigSystem has no setting representation/getters and IndicatorManager has no configuration-bearing interface.

## 4. EMA Contract

### Existing frozen interface

```mql5
bool EMAConfigure(int p, int ap)
```

### Verified prerequisites

1. `EMAInit()` must succeed.
2. A valid, authoritative `p` and `ap` must exist.
3. `EMAConfigure(p, ap)` must succeed.
4. Only then can `EMAReady()` return true (`initialized && configured`).

### Contract decision status

- **EMA period source:** Not defined.
- **EMA applied-price source:** Not defined.
- **Validation rules:** No EMA-specific rule exists. Generic `ValidatePositive` could validate period, but no approved applied-price enum/range contract or source exists.
- **Owner:** Not finalized; recommended source/apply split described in Section 3 is approval-required.
- **Value:** Not selected. `50` and `0` are not adopted by this report.

## 5. ATR Contract

### Existing frozen interface

```mql5
bool ATRConfigure(int p)
```

### Verified prerequisites

1. `ATRInit()` must succeed.
2. A valid, authoritative `p` must exist.
3. `ATRConfigure(p)` must succeed.
4. Only then can `ATRReady()` return true (`initialized && configured`).

### Contract decision status

- **ATR period source:** Not defined.
- **Validation rules:** No ATR-specific rule exists. Generic `ValidatePositive` could validate a supplied period but no approved source exists.
- **Owner:** Not finalized; recommended source/apply split described in Section 3 is approval-required.
- **Value:** Not selected. `14` is not adopted by this report.

## 6. Validation Contract

**Verified current state:** ConfigValidator supplies generic primitives but no indicator configuration record/validator. `ValidateConfiguration()` is explicitly pending.

**Required future decision—not implementation:** define a typed indicator configuration contract containing EMA period, EMA applied price, and ATR period; define authoritative storage/load semantics; then define validation with existing or approved interfaces. At minimum, period values require a positive-value rule. The applied-price domain must be explicitly defined from the relevant MQL enum/contract rather than inferred from integer `0`.

No validation source, value, or new input is created by this decision document.

## 7. Startup Sequence

### Current verified sequence

```text
IndicatorManagerInit
  → EMAInit
  → ATRInit
  → indicatorInitialized = true
VerifyIndicatorsReady
  → EMAReady false (configured is false)
  → ATRReady false (configured is false)
```

### Required future sequence, pending architecture decision

```text
ConfigSystem initializes and obtains approved indicator configuration
  → values are validated by approved contract
  → IndicatorManagerInit
      → EMAInit
      → ATRInit
      → apply EMAConfigure(approvedPeriod, approvedAppliedPrice)
      → apply ATRConfigure(approvedPeriod)
  → VerifyIndicatorsReady
```

The exact value transport and caller are intentionally unspecified because no current authoritative configuration source exists.

## 8. Failure and Rollback Contract

No new behavior is implemented. The architecture decision required before resuming remediation must specify:

1. configuration validation failure occurs before IndicatorManager initialization;
2. Configure failure after EMA/ATR initialization is an IndicatorManager-owned partial failure;
3. IndicatorManager rolls back only successfully initialized/configured EMA/ATR children in reverse order;
4. EAMain rolls back completed layers in reverse layer order; and
5. EAMain never directly shuts down manager children.

This preserves the approved rollback ownership rule while avoiding any implementation before values and ownership are approved.

## 9. Frozen Interface Impact

| Interface | Can existing signature support the eventual contract? | Current change required? |
|---|---|---|
| `EMAConfigure(int,int)` | Yes, once values/source are approved | No signature change proposed |
| `ATRConfigure(int)` | Yes, once value/source is approved | No signature change proposed |
| `EMAReady()` / `ATRReady()` | Yes | No change proposed |
| ConfigSystem current interface | No value retrieval/record exists | Architecture decision required; do not modify in this task |
| IndicatorManager current interface | No configuration-bearing operation exists | Architecture decision required; do not modify in this task |

The recommended future configuration contract will likely require a formal frozen configuration-interface patch if ConfigSystem must expose typed settings or getters. This task does not define or add that patch.

## 10. Strategy Boundary Audit

| Boundary | Result |
|---|---|
| Strategy | No source changed; no strategy rules introduced |
| Signal generation | None |
| Entry/Exit | None |
| Orders / Execution | None |
| Risk / Money Management | None |
| AI / optimization | None |

The Phase 2 strategy document cannot be used as a runtime source without an explicit architecture decision precisely because it contains strategy/trend/risk/entry context and refers to EMA50/200 while the frozen runtime module has a single EMA interface.

## 11. Decision Matrix

| Question | Finding | Evidence | Decision Required? |
|---|---|---|---|
| EMA authoritative source | None exists | ConfigSystem has no settings/getters; Configure has no runtime caller | **Yes** |
| ATR authoritative source | None exists | Same ConfigSystem/call audit | **Yes** |
| Configuration owner | No current owner; ConfigSystem is architecturally suitable source, IndicatorManager suitable child apply owner, EAMain suitable sequencer | Sprint 6 layer ownership + current interfaces | **Yes** |
| Configuration values | No approved runtime values | Private initializers/tests are non-authoritative; Phase 2 strategy document is not runtime contract | **Yes** |
| Validation | Only generic primitives; aggregate config is pending | ConfigValidator:2–14 | **Yes** |
| Startup sequence | Current sequence never configures indicators | IndicatorManager:3–8; EAMain:110–115 | **Yes** |
| Failure behavior | Not defined for Configure failures | No current Configure startup path | **Yes** |
| Rollback owner | Existing architectural rule: manager owns children, EAMain owns layers; exact Configure failure path absent | Sprint 6 plan and current manager lifecycle | **Yes** |
| Frozen API impact | Existing Configure signatures can accept values; source transport lacks contract | EMA/ATR interfaces; ConfigSystem source | **Yes — likely ConfigSystem/manager contract patch** |
| Strategy contamination | No change made; using Phase 2 directly would cross strategy boundary | Phase 2 content and Sprint 6 exclusions | **No implementation permitted** |

## 12. Final Architecture Verdict

```text
STATUS: SPR6-006D BLOCKED — CONFIGURATION CONTRACT DECISION REQUIRED
SOURCE MODIFICATIONS: 0

PATCH-CFG-01: NOT READY FOR APPROVED IMPLEMENTATION

Reason: No authoritative existing runtime configuration source supplies
EMA period, EMA applied price, or ATR period. Private engine defaults,
test fixture values, and strategy-document values are not an approved
startup configuration contract.
```

## 13. Required Next Action

Obtain a formal architecture decision that defines an authoritative, non-strategy indicator-configuration source and its ownership model. The decision must specify exact values/types, applied-price domain, validation, startup placement, Configure-failure behavior, and manager/EAMain rollback responsibility. It must also state whether a frozen ConfigSystem and/or IndicatorManager interface patch is authorized.

Until that approval is made, do not modify source and do not resume SPR6-006C remediation.
