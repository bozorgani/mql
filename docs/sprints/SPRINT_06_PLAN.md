# Sprint 6 Plan — First Runnable Version (Integration & Execution Framework)

**Status:** PLANNING PHASE  
**Constraint:** Documentation Only — No Source Code Implementation  
**Prerequisite:** Sprint 1-5 Frozen, Architecture Approved

---

## 1. Sprint 6 Objective

Create the complete integration and execution framework that transforms the frozen Sprint 1-5 modules into a runnable MetaTrader 5 Expert Advisor capable of:

- Initializing all infrastructure and business modules in correct order
- Executing the update pipeline on each tick/bar
- Shutting down gracefully
- Providing runtime validation and observability
- Preparing for Strategy Tester execution

**NOT IN SCOPE:** Strategy logic, entry/exit rules, order management, risk calculations, AI integration

---

## 2. Scope Definition

### 2.1 In Scope

| Category | Description |
|----------|-------------|
| EA Framework | Main expert advisor entry points (OnInit, OnDeinit, OnTick/OnCalculate) |
| Module Orchestration | Initialize/Shutdown all frozen modules in correct dependency order |
| Update Pipeline | Execute update sequence across Infrastructure → Indicators → Structure → Price Action |
| Runtime State | Track EA lifecycle state machine (UNINITIALIZED → READY → RUNNING → SHUTDOWN) |
| Validation Hooks | Runtime checks for module readiness, update success, state consistency |
| Logging Integration | Connect LoggerCore/LoggerFile to runtime events (startup, module init, update, shutdown) |
| Error Handling | Centralized error handling for initialization failures, runtime failures, shutdown errors |
| Strategy Tester Support | Prepare framework for historical backtesting (closed-bar execution, repeatable runs) |
| Configuration | Load and validate configuration parameters for runtime behavior |

### 2.2 Out of Scope (Explicit Exclusions)

| Excluded | Reason |
|----------|--------|
| Strategy logic | Sprint 7+ |
| Entry rules | Sprint 7+ |
| Exit rules | Sprint 7+ |
| Order placement | Sprint 8+ |
| Risk management | Sprint 8+ |
| Money management | Sprint 8+ |
| Position management | Sprint 8+ |
| AI integration | Sprint 7+ |
| Signal generation | Sprint 7+ |
| Performance optimization | Post-Sprint 6 |
| New trading modules | Future sprints |

---

## 3. Runtime Architecture

### 3.1 Execution Environment

**Platform:** MetaTrader 5 (MT5)  
**Module Type:** Expert Advisor (EA)  
**Execution Model:** Event-driven (OnInit, OnDeinit, OnTick/OnCalculate)

### 3.2 Module Ownership

| Layer | Modules | Owner |
|-------|---------|-------|
| Infrastructure (Sprint 1) | ConfigSystem, ConfigValidator, LoggerCore, LoggerFile, TimeService, MarketData, SymbolInfoService, InitManager, ShutdownManager, Utils, CommonTypes, Constants, EventIDs, ErrorCodes | EA Framework (initialized by EA) |
| Indicators (Sprint 2) | EMAEngine, ATREngine, IndicatorManager | EA Framework (initialized after Infrastructure) |
| Structure (Sprint 3) | SwingDetector, SwingStorage, BOSDetector, CHOCHDetector, TrendEngine, StructureManager | EA Framework (initialized after Indicators) |
| Price Action (Sprint 4) | CandleClassifier, EngulfingDetector, PinBarDetector, InsideBarDetector, OutsideBarDetector, FibonacciEngine, RetracementDetector, ConfluenceManager, PriceActionManager | EA Framework (initialized after Structure) |
| Integration (Sprint 6) | **EAMain** (NEW — orchestration only) | Sprint 6 deliverable |

### 3.3 Dependency Graph (Runtime)

```
                     ┌─────────────────┐
                     │   EAMain        │ (Sprint 6 — Orchestrator)
                     │  (NEW)          │
                     └────────┬────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐   ┌─────────────────┐   ┌─────────────────┐
│ Infrastructure│   │  Indicators     │   │  Structure      │
│ (Sprint 1)    │   │  (Sprint 2)     │   │  (Sprint 3)     │
├───────────────┤   ├─────────────────┤   ├─────────────────┤
│ ConfigSystem  │   │  EMAEngine      │   │  SwingDetector  │
│ ConfigValidator│  │  ATREngine      │   │  SwingStorage   │
│ LoggerCore    │   │  IndicatorManager│  │  BOSDetector    │
│ LoggerFile    │   └─────────────────┘   │  CHOCHDetector  │
│ TimeService   │                        │  TrendEngine    │
│ MarketData    │                        │  StructureManager│
│ SymbolInfoSvc │                        └─────────────────┘
│ InitManager   │                              │
│ ShutdownMgr   │                              ▼
│ Utils         │                    ┌─────────────────┐
│ CommonTypes   │                    │ Price Action    │
│ Constants     │                    │ (Sprint 4)      │
│ EventIDs      │                    ├─────────────────┤
│ ErrorCodes    │                    │ CandleClassifier│
└───────────────┘                    │ EngulfingDetector│
                                     │ PinBarDetector   │
                                     │ InsideBarDetect │
                                     │ OutsideBarDetect│
                                     │ FibonacciEngine │
                                     │ RetracementDet  │
                                     │ ConfluenceMgr   │
                                     │ PriceActionMgr  │
                                     └─────────────────┘
```

### 3.4 Module Communication

All inter-module communication uses **public interfaces only**:

| From | To | Via |
|------|-----|------|
| EAMain | Any module | Init/Shutdown/Status/Update functions |
| StructureManager | Swing/BOS/CHOCH/Trend | Public getter functions (GetLastSwingPrice, etc.) |
| PriceActionManager | CandleClassifier/Engulfing/PinBar/etc. | Public Update functions |
| PriceAction modules | Structure (read-only) | Public getter functions from Structure modules |
| EAMain | Logger | LoggerCore/LoggerFile public interfaces |

**NO direct state access. NO private variable manipulation. NO bypassing public interfaces.**

---

## 4. Lifecycle State Machine

### 4.1 State Definitions

| State | Description | Entry Condition | Exit Condition |
|-------|-------------|-----------------|----------------|
| UNINITIALIZED | EA loaded, no initialization started | EA attached to chart | OnInit() called |
| INITIALIZING | Initialization in progress | OnInit() entered | All modules initialized OR failure |
| READY | All modules initialized, awaiting market data | Init complete, all Status() true | First tick/market data received OR shutdown |
| RUNNING | Active processing, update pipeline executing | Market data received, OnTick/OnCalculate active | OnDeinit() called OR emergency stop |
| STOPPING | Shutdown sequence in progress | OnDeinit() entered | All modules shutdown complete |
| SHUTDOWN | EA fully deinitialized, ready for removal | All Shutdown() complete | EA removed from chart |

### 4.2 State Transitions

```
                    ┌──────────────┐
                    │ UNINITIALIZED│
                    └──────┬───────┘
                           │ OnInit()
                           ▼
                    ┌──────────────┐
         ┌─────────│ INITIALIZING │─────────┐
         │ Failure │              │ Success │
         ▼         └──────┬───────┘         ▼
┌──────────────┐         │                 ┌──────────────┐
│  FAILED      │         │ All modules     │    READY     │
│  (HALT)      │         │ initialized     └──────┬───────┘
└──────────────┘         │ and Status()    │ OnTick/First │
                         │ true             │ tick/calc    │
                         └─────────────────┘      │
                                                  ▼
                                         ┌──────────────┐
                                         │   RUNNING    │
                                         └──────┬───────┘
                                                │ OnDeinit()
                                                │ or Emergency
                                                ▼
                                         ┌──────────────┐
                                         │   STOPPING   │
                                         └──────┬───────┘
                                                │ All modules
                                                │ shutdown
                                                ▼
                                         ┌──────────────┐
                                         │  SHUTDOWN    │
                                         └──────────────┘
```

### 4.3 Transition Rules

| Transition | Rule |
|------------|------|
| UNINITIALIZED → INITIALIZING | OnInit() called by MT5 platform |
| INITIALIZING → FAILED | Any module Init() returns false; halt immediately, do not continue |
| INITIALIZING → READY | All modules Init() return true; all Status() return true; configured if required |
| READY → RUNNING | First tick/market data event received (OnTick or OnCalculate) |
| RUNNING → STOPPING | OnDeinit() called by MT5 OR emergency shutdown triggered |
| STOPPING → SHUTDOWN | All module Shutdown() complete; ShutdownManagerStatus() true |
| SHUTDOWN → (terminal) | EA removed from chart by user or MT5 |

### 4.4 Error Transition Handling

| Error Type | State Transition | Action |
|------------|------------------|--------|
| Init failure (single module) | INITIALIZING → FAILED | Return false from OnInit(); log ERROR; no partial state |
| Init failure (multiple) | INITIALIZING → FAILED | Same as above; report all failures |
| Runtime update failure | RUNNING → RUNNING (continue) | Log ERROR/WARNING; continue processing if non-critical |
| Runtime critical failure | RUNNING → STOPPING | Log CRITICAL; trigger shutdown sequence |
| Shutdown failure | STOPPING → STOPPING (retry) | Log ERROR; attempt graceful cleanup; force if needed |

---

## 5. Integration Sequence

### 5.1 EA Startup Sequence (OnInit)

```
OnInit()
  │
  ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ PHASE 1: INFRASTRUCTURE INITIALIZATION (Sprint 1 — Frozen)             │
├─────────────────────────────────────────────────────────────────────────┤
│ 1.1 ConfigInit() — Load configuration                                    │
│ 1.2 LoggerInit() — Initialize logger core                               │
│ 1.3 LoggerFileInit() — Initialize file logger                           │
│ 1.4 TimeServiceInit() — Initialize time service                         │
│ 1.5 MarketDataInit() — Initialize market data interface                 │
│ 1.6 SymbolInfoInit() — Initialize symbol info service                   │
│ 1.7 InitManager.InitializeInfrastructure() — Verify all infra ready     │
└─────────────────────────────────────────────────────────────────────────┘
                              │ All success
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ PHASE 2: INDICATOR INITIALIZATION (Sprint 2 — Frozen)                   │
├─────────────────────────────────────────────────────────────────────────┤
│ 2.1 EMAInit() — Initialize EMA engine                                   │
│ 2.2 ATRInit() — Initialize ATR engine                                  │
│ 2.3 IndicatorManagerInit() — Verify EMA+ATR ready                       │
└─────────────────────────────────────────────────────────────────────────┘
                              │ All success
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ PHASE 3: STRUCTURE INITIALIZATION (Sprint 3 — Frozen)                   │
├─────────────────────────────────────────────────────────────────────────┤
│ 3.1 SwingInit() — Initialize swing detector                              │
│ 3.2 SwingStorageInit() — Initialize swing storage                        │
│ 3.3 BOSInit() — Initialize BOS detector                                 │
│ 3.4 CHOCHInit() — Initialize CHOCH detector                             │
│ 3.5 TrendInit() — Initialize trend engine                               │
│ 3.6 StructureManagerInit() — Verify full structure chain ready           │
└─────────────────────────────────────────────────────────────────────────┘
                              │ All success
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ PHASE 4: PRICE ACTION INITIALIZATION (Sprint 4 — Frozen)                │
├─────────────────────────────────────────────────────────────────────────┤
│ 4.1 CandleClassifierInit() — Initialize candle classifier               │
│ 4.2 EngulfingInit() — Initialize engulfing detector                     │
│ 4.3 PinBarInit() — Initialize pin bar detector                          │
│ 4.4 InsideBarInit() — Initialize inside bar detector                    │
│ 4.5 OutsideBarInit() — Initialize outside bar detector                   │
│ 4.6 FibonacciInit() — Initialize Fibonacci engine                       │
│ 4.7 RetracementInit() — Initialize retracement detector                 │
│ 4.8 ConfluenceInit() — Initialize confluence manager                    │
│ 4.9 PriceActionManagerInit() — Verify full PA chain ready                │
└─────────────────────────────────────────────────────────────────────────┘
                              │ All success
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ PHASE 5: FINALIZATION                                                    │
├─────────────────────────────────────────────────────────────────────────┤
│ 5.1 Log STARTUP_COMPLETE event                                          │
│ 5.2 Set EA state to READY                                               │
│ 5.3 Return INIT_SUCCEEDED                                               │
└─────────────────────────────────────────────────────────────────────────┘
```

### 5.2 Initialization Failure Handling

```
If any Init() returns false:
  │
  ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ ROLLBACK SEQUENCE (Reverse order of initialization)                      │
├─────────────────────────────────────────────────────────────────────────┤
│ Shutdown in REVERSE order:                                               │
│ - PriceActionManagerShutdown() (if PriceAction modules initialized)     │
│ - StructureManagerShutdown() (if Structure modules initialized)         │
│ - IndicatorManagerShutdown() (if Indicator modules initialized)         │
│ - LoggerFileShutdown()                                                  │
│ - LoggerShutdown()                                                      │
│ - Config (documented TODO — no explicit shutdown interface)             │
└─────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ LOG FAILURE                                                             │
├─────────────────────────────────────────────────────────────────────────┤
│ Log ERROR event: INIT_FAILED with module name and error code            │
└─────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
Return INIT_FAILED from OnInit()
```

### 5.3 Update Pipeline Sequence (OnTick/OnCalculate)

```
OnTick() / OnCalculate()
  │
  ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ PRECONDITION: EA state must be RUNNING or READY                         │
└─────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ STEP 1: INFRASTRUCTURE UPDATE (lightweight)                             │
├─────────────────────────────────────────────────────────────────────────┤
│ 1.1 RefreshMarketData() — Refresh market data feed                     │
│ 1.2 Verify MarketStatus() true                                          │
└─────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ STEP 2: INDICATOR UPDATE                                                 │
├─────────────────────────────────────────────────────────────────────────┤
│ 2.1 EMAUpdate() — Update EMA value                                     │
│ 2.2 ATRUpdate() — Update ATR value                                     │
│ 2.3 Verify EMAReady() and ATRReady()                                   │
└─────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ STEP 3: STRUCTURE UPDATE (via StructureManager)                         │
├─────────────────────────────────────────────────────────────────────────┤
│ 3.1 StructureManagerUpdate() — Calls:                                   │
│     - SwingUpdate()                                                     │
│     - SaveSwing() (if SwingReady)                                      │
│     - BOSUpdate()                                                       │
│     - CHOCHUpdate()                                                     │
│     - TrendUpdate()                                                     │
└─────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ STEP 4: PRICE ACTION UPDATE (via PriceActionManager)                    │
├─────────────────────────────────────────────────────────────────────────┤
│ 4.1 PriceActionManagerUpdate() — Calls:                                │
│     - CandleClassifierUpdate()                                         │
│     - EngulfingUpdate()                                                │
│     - PinBarUpdate()                                                   │
│     - InsideBarUpdate()                                                │
│     - OutsideBarUpdate()                                               │
│     - FibonacciUpdate()                                                │
│     - RetracementUpdate()                                              │
│     - ConfluenceUpdate()                                               │
└─────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ STEP 5: VALIDATION (runtime checks)                                     │
├─────────────────────────────────────────────────────────────────────────┤
│ 5.1 Verify StructureManagerStatus() true                               │
│ 5.2 Verify PriceActionManagerStatus() true                             │
│ 5.3 Capture diagnostic outputs (GetPattern, GetTrendDirection, etc.)   │
│ 5.4 Log UPDATE_COMPLETE event (DEBUG/INFO level)                       │
└─────────────────────────────────────────────────────────────────────────┘
```

### 5.4 Shutdown Sequence (OnDeinit)

```
OnDeinit()
  │
  ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ PHASE 1: PRICE ACTION SHUTDOWN (Sprint 4 — Frozen)                      │
├─────────────────────────────────────────────────────────────────────────┤
│ 1.1 PriceActionManagerShutdown() — Calls in reverse order:             │
│     - ConfluenceShutdown()                                              │
│     - RetracementShutdown()                                             │
│     - FibonacciShutdown()                                               │
│     - OutsideBarShutdown()                                              │
│     - InsideBarShutdown()                                               │
│     - PinBarShutdown()                                                  │
│     - EngulfingShutdown()                                               │
│     - CandleClassifierShutdown()                                       │
└─────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ PHASE 2: STRUCTURE SHUTDOWN (Sprint 3 — Frozen)                         │
├─────────────────────────────────────────────────────────────────────────┤
│ 2.1 StructureManagerShutdown() — Calls in reverse order:               │
│     - TrendShutdown()                                                   │
│     - CHOCHShutdown()                                                   │
│     - BOSShutdown()                                                     │
│     - SwingStorageShutdown()                                            │
│     - SwingShutdown()                                                   │
└─────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ PHASE 3: INDICATOR SHUTDOWN (Sprint 2 — Frozen)                         │
├─────────────────────────────────────────────────────────────────────────┤
│ 3.1 IndicatorManagerShutdown() — Calls:                                │
│     - ATRShutdown()                                                     │
│     - EMAShutdown()                                                     │
└─────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ PHASE 4: INFRASTRUCTURE SHUTDOWN (Sprint 1 — Frozen)                    │
├─────────────────────────────────────────────────────────────────────────┤
│ 4.1 ShutdownManager.Stop() — Calls:                                    │
│     - SymbolInfoShutdown()                                              │
│     - MarketDataShutdown()                                              │
│     - TimeServiceShutdown()                                             │
│     - LoggerFileShutdown()                                              │
│     - LoggerShutdown()                                                  │
│     - Config (documented TODO — no explicit shutdown)                   │
└─────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ PHASE 5: FINALIZATION                                                    │
├─────────────────────────────────────────────────────────────────────────┤
│ 5.1 Log SHUTDOWN_COMPLETE event                                         │
│ 5.2 Set EA state to SHUTDOWN                                            │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Runtime Validation Plan

### 6.1 Validation Points

| Validation Point | When | Check | Expected |
|------------------|------|-------|----------|
| Post-Init Check | After OnInit() completes | All module Status() true | PASS/FAIL |
| Post-Init Check | After OnInit() completes | All module Ready() where applicable | PASS/FAIL |
| Pre-Update Check | Before each OnTick/OnCalculate | EA state == RUNNING or READY | Continue/Skip |
| Post-Update Check | After each update pipeline | StructureManagerStatus() true | PASS/WARNING |
| Post-Update Check | After each update pipeline | PriceActionManagerStatus() true | PASS/WARNING |
| Diagnostic Capture | After each update | GetPattern(), GetTrendDirection(), GetLastSwingPrice() etc. | Logged |
| Periodic Health Check | Every N ticks (configurable) | All Status() true, no state corruption | PASS/WARNING |
| Pre-Shutdown Check | Before OnDeinit() | State documented, no pending operations | OK |
| Post-Shutdown Check | After OnDeinit() | All Status() false, initialized flags false | PASS/FAIL |

### 6.2 Validation Methods

| Method | Description |
|--------|-------------|
| Status Polling | Call Status() on each module, verify expected state |
| Ready Verification | Call Ready() where available, verify operational state |
| Output Capture | Call getter functions, log outputs for verification |
| State Consistency | Verify no module in unexpected state (e.g., initialized but not configured) |
| Sequence Integrity | Verify update calls executed in documented order |

### 6.3 Validation Logging

All validation results logged at appropriate level:

| Result | Log Level | Event |
|--------|-----------|-------|
| PASS | INFO | VALIDATION_PASS with module name |
| WARNING | WARNING | VALIDATION_WARNING with details |
| FAIL | ERROR | VALIDATION_FAIL with module and reason |

---

## 7. Logging Plan

### 7.1 Log Levels

| Level | Usage |
|-------|-------|
| DEBUG | Detailed development info, per-tick diagnostic data, module internal state |
| INFO | Normal operational events (startup, shutdown, update complete, validation pass) |
| WARNING | Non-critical issues (validation warning, retry, degraded state) |
| ERROR | Initialization failures, runtime errors, validation failures |
| CRITICAL | Emergency shutdown trigger, fatal errors, unrecoverable state |

### 7.2 Startup Logs

| Event | Level | Content |
|-------|-------|---------|
| EA_STARTUP | INFO | "EA starting on {Symbol} {Timeframe}" |
| CONFIG_LOAD | INFO | "Configuration loaded: {param count} parameters" |
| MODULE_INIT | INFO | "Module {name} initialized" (per module) |
| MODULE_INIT_FAILED | ERROR | "Module {name} initialization failed: {reason}" |
| INFRASTRUCTURE_READY | INFO | "Infrastructure layer ready" |
| INDICATORS_READY | INFO | "Indicator layer ready" |
| STRUCTURE_READY | INFO | "Structure layer ready" |
| PRICE_ACTION_READY | INFO | "Price Action layer ready" |
| STARTUP_COMPLETE | INFO | "EA initialization complete, state: READY" |
| STARTUP_FAILED | ERROR | "EA initialization failed at {phase}: {reason}" |

### 7.3 Runtime Logs

| Event | Level | Content |
|-------|-------|---------|
| TICK_PROCESSING | DEBUG | "Processing tick: {time}, bid: {bid}, ask: {ask}" |
| UPDATE_START | DEBUG | "Update pipeline started" |
| MODULE_UPDATE | DEBUG | "Module {name} updated" (per module, optional) |
| UPDATE_COMPLETE | INFO | "Update pipeline completed" |
| PATTERN_DETECTED | INFO | "Pattern: {pattern type}, strength: {strength}" |
| STRUCTURE_CHANGE | INFO | "Structure: {BOS/CHOCH/Trend change}" |
| VALIDATION_PASS | INFO | "Validation passed: {check}" |
| VALIDATION_WARNING | WARNING | "Validation warning: {check} - {details}" |
| VALIDATION_FAIL | ERROR | "Validation failed: {check} - {reason}" |
| ERROR_OCCURRED | ERROR | "Error in {module}: {error code} - {message}" |
| CRITICAL_ERROR | CRITICAL | "Critical error: {description}, initiating shutdown" |

### 7.4 Shutdown Logs

| Event | Level | Content |
|-------|-------|---------|
| SHUTDOWN_START | INFO | "Shutdown initiated" |
| MODULE_SHUTDOWN | INFO | "Module {name} shutdown complete" (per module) |
| SHUTDOWN_COMPLETE | INFO | "EA shutdown complete" |

### 7.5 Logger Integration Approach

**Strategy:** Connect EAMain to existing LoggerCore/LoggerFile through public interfaces.

**Implementation approach (documented, not coded):**
- EAMain calls LoggerInit()/LoggerFileInit() during startup
- EAMain calls CreateLogEvent() or equivalent for each log event
- Log format follows Logging Specification (Timestamp|Module|EventID|Severity|...)
- Event IDs use existing registries (CFG-, LOG-, SYS-, MOD- prefixes) plus new EA-specific IDs

**EA-specific Event IDs (proposed):**
```
EA_STARTUP = "EA-001"
EA_SHUTDOWN = "EA-002"
EA_UPDATE = "EA-003"
EA_VALIDATION = "EA-004"
EA_ERROR = "EA-005"
EA_CRITICAL = "EA-006"
```

---

## 8. Error Handling Strategy

### 8.1 Initialization Failure Policy

| Scenario | Response |
|----------|----------|
| Single module Init() fails | Abort initialization; rollback initialized modules; log ERROR; return INIT_FAILED |
| Multiple module Init() fails | Same as single; report all failures in log |
| Configuration invalid | Abort before any Init(); log ERROR; return INIT_FAILED |
| Market data unavailable | Retry once; if still unavailable, abort; log ERROR |
| Symbol not available | Abort; log ERROR; return INIT_FAILED |

**Principle:** Fail fast. No partial initialization state. Rolled back cleanly.

### 8.2 Rollback Policy

| Phase | Modules to Rollback |
|-------|---------------------|
| After Phase 1 (Infrastructure) | LoggerFile, Logger, Config (TODO) |
| After Phase 2 (Indicators) | IndicatorManager, ATREngine, EMAEngine, then Infrastructure |
| After Phase 3 (Structure) | StructureManager, Trend, CHOCH, BOS, SwingStorage, Swing, then Indicators, then Infrastructure |
| After Phase 4 (Price Action) | PriceActionManager, Confluence, Retracement, Fibonacci, OutsideBar, InsideBar, PinBar, Engulfing, CandleClassifier, then Structure, then Indicators, then Infrastructure |

**Rollback order:** Reverse of initialization order.

### 8.3 Runtime Failure Policy

| Failure Type | Response |
|--------------|----------|
| Non-critical module update fails | Log ERROR/WARNING; continue pipeline if possible |
| Critical module update fails (StructureManager, PriceActionManager) | Log ERROR; consider emergency shutdown |
| Market data feed fails | Log ERROR; skip update tick; retry next tick |
| Logger fails | Continue operation; log to alternative (console/Print as fallback per existing TODO) |

### 8.4 Fatal Error Policy

| Condition | Action |
|-----------|--------|
| Unrecoverable state corruption | Log CRITICAL; trigger emergency shutdown |
| Repeated initialization failures | Log CRITICAL; halt EA |
| Memory/resource exhaustion | Log CRITICAL; trigger shutdown |
| Module responding incorrectly (status mismatch) | Log ERROR; attempt reset; if persistent, shutdown |

---

## 9. Regression Strategy

### 9.1 Regression Scope for Sprint 6

| Area | Regression Requirement |
|------|----------------------|
| Module Interfaces | Verify all frozen interfaces (S1-S4) still match contracts |
| Initialization Order | Verify init sequence produces correct state |
| Shutdown Order | Verify shutdown sequence cleans up correctly |
| Update Pipeline | Verify update sequence executes all modules |
| State Machine | Verify state transitions occur correctly |
| No Hidden Changes | Verify no frozen module was modified |

### 9.2 Regression Tests (Documented)

| Test ID | Description | Type |
|---------|-------------|------|
| SPR6-REG-001 | Full initialization sequence | Integration |
| SPR6-REG-002 | Full shutdown sequence | Integration |
| SPR6-REG-003 | Init → Update → Shutdown cycle | Integration |
| SPR6-REG-004 | Init failure rollback | Failure injection |
| SPR6-REG-005 | Multiple update cycles | Stability |
| SPR6-REG-006 | State machine transitions | State verification |
| SPR6-REG-007 | Frozen interface compliance | Contract audit |
| SPR6-REG-008 | No-module-left-behind check | Completeness |

### 9.3 Regression Execution Plan

| Phase | Test | Expected |
|-------|------|----------|
| Pre-implement | Document test cases | Ready for implementation |
| Post-implement | Execute all regression tests | All pass |
| Pre-commit | Verify no frozen module changed | Git diff clean for S1-S4 files |
| Post-commit | Run regression again | All pass |

---

## 10. Strategy Tester Preparation

### 10.1 Strategy Tester Compatibility Requirements

| Requirement | Implementation Approach |
|-------------|------------------------|
| OnInit/OnDeinit/OnTick/OnCalculate | EAMain must implement these standard MT5 entry points |
| Historical data handling | Use closed-bar data (index 1 and older); bar 0 excluded |
| Repeatable execution | Same inputs → same outputs; no random/non-deterministic behavior |
| Indicator compatibility | EMA/ATR must work with MT5 indicator mode (iMA/iATR or custom) |
| No external dependencies | All modules self-contained; no file/network access during backtest |
| Time handling | Use TimeCurrent()/TimeLocal() for timestamps; no reliance on real-time clock |

### 10.2 Backtest Configuration

| Parameter | Default | Description |
|-----------|---------|-------------|
| Symbol | Current chart symbol | Instrument to test |
| Timeframe | Current chart timeframe | Period for analysis |
| Modeling | Closed-bar + real ticks (if available) | MT5 backtest mode |
| Date range | User-selectable | Test period |
| Spread | Current or fixed | Spread configuration |
| Initial deposit | User-configurable | Starting capital (for future risk integration) |

### 10.3 Backtest Validation Points

| Validation | Method |
|------------|--------|
| Init in tester | Verify OnInit() completes successfully in tester environment |
| Update in tester | Verify OnTick/OnCalculate processes historical bars |
| Output consistency | Verify same bar sequence produces same outputs on repeated runs |
| No runtime errors | Verify no ERROR/CRITICAL logs during backtest |
| Module readiness | Verify all modules reach Ready() state in tester |

### 10.4 Strategy Tester Limitations (Documented)

- No live market data (historical only)
- No execution testing (no order placement in Sprint 6)
- No slippage/execution delay modeling (reserved for future)
- Pattern detection accuracy not validated (requires domain expert review)
- No performance metrics beyond module execution

---

## 11. Risks and Mitigation

### 11.1 Integration Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Module init order incorrect | Low | High | Follow documented sequence exactly; rollback on failure |
| Module interface mismatch discovered | Low | High | Pre-implementation contract audit; stop if mismatch found |
| Update sequence performance | Medium | Medium | Measure; optimize only if needed (post-Sprint 6) |
| Module state inconsistency | Low | High | Runtime validation checks; status polling |

### 11.2 Runtime Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Market data feed interruption | Medium | Medium | Retry logic; skip tick if unavailable; log warning |
| Logger failure | Low | Low | Fallback to Print(); continue operation |
| Symbol/instrument changes | Low | Medium | Re-verify symbol info; handle gracefully |
| Timezone/session issues | Low | Low | Use TimeService for all time operations |

### 11.3 Dependency Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Frozen module modified externally | Low | High | Pre-implementation audit; git status check; no modifications allowed |
| CommonTypes change | Low | High | Freeze CommonTypes; any change requires architecture review |
| New MT5 platform version | Low | Medium | Test on target MT5 version; document compatibility |

### 11.4 Validation Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Incomplete validation coverage | Medium | Medium | Document all validation points; review against requirements |
| False positive validation | Low | Low | Clear pass/fail criteria; multiple checks |
| Performance impact of validation | Low | Low | Validation lightweight; DEBUG level for detailed checks |

### 11.5 Recovery Plan

| Scenario | Recovery Action |
|----------|-----------------|
| Init failure at Phase 1 | Fix configuration or infrastructure; retry |
| Init failure at Phase 2+ | Review module; fix; re-init from scratch |
| Runtime failure | Log; attempt recovery; if persistent, shutdown and restart |
| Architecture violation discovered | STOP; report; do not proceed until resolved |

---

## 12. Sprint 6 Exit Criteria

### 12.1 Documentation Deliverables

| Criterion | Status Target |
|-----------|---------------|
| Sprint 6 Plan document created | ✓ |
| SPR6-001 Report created | ✓ |
| Runtime lifecycle defined | ✓ |
| Integration sequence documented | ✓ |
| Validation strategy documented | ✓ |
| Logging strategy documented | ✓ |
| Error handling documented | ✓ |
| Strategy Tester preparation documented | ✓ |
| Risks documented with mitigations | ✓ |

### 12.2 Architecture Preservation

| Criterion | Verification |
|-----------|--------------|
| No frozen interface modified | Pre- and post-audit comparison |
| No architecture changes | Dependency graph unchanged |
| No hidden logic introduced | Code review of any new module |
| No Strategy/Entry/Exit/Orders/Risk/Money/AI | Explicit exclusion verified |

### 12.3 Implementation Readiness

| Criterion | Status |
|-----------|--------|
| Plan reviewed and approved | Pending review |
| All interfaces documented | ✓ |
| Sequence documented | ✓ |
| Error handling defined | ✓ |
| Logging defined | ✓ |
| Validation defined | ✓ |

---

## 13. Sprint 6 Module List (Proposed)

### 13.1 New Module: EAMain

**File:** `mql5/modules/EAMain.mq5` (proposed)  
**Responsibility:** EA entry point orchestration, lifecycle management, runtime coordination  
**Interfaces:**
- OnInit() → bool (MT5 entry point)
- OnDeinit() → void (MT5 entry point)
- OnTick() → void (MT5 entry point, if applicable)
- OnCalculate() → int (MT5 entry point, if applicable)
- EAStartup() → bool (internal: orchestrates module initialization)
- EADeinit() → void (internal: orchestrates module shutdown)
- EAUpdate() → bool (internal: executes update pipeline)
- EAStatus() → bool (internal: returns EA running state)
- GetEATState() → EAState (internal: returns current state machine state)

**EAState enum (proposed, in EAMain only):**
```
enum EAState { EA_UNINITIALIZED, EA_INITIALIZING, EA_READY, EA_RUNNING, EA_STOPPING, EA_SHUTDOWN };
```

### 13.2 No Other New Modules

Sprint 6 introduces ONLY EAMain as the orchestration layer. All other modules are frozen Sprint 1-5 modules.

---

## 14. Technical Debt Carry-Forward

The following documented technical debt carries into Sprint 6+ (not addressed in Sprint 6):

| Debt | Origin | Status |
|------|--------|--------|
| Logger integration TODO comments | Sprint 1-4 | Deferred |
| PatternType shared import (SPR4-013) | Sprint 4 | Partially done; TODO comments remain |
| Swing/BOS/Trend algorithm placeholders | Sprint 3 | Deferred to future |
| Price source placeholder (SymbolInfoDouble) | Sprint 2 | Deferred to MarketData integration |
| PinBar/Engulfing/etc. detection algorithms | Sprint 4 | Deferred to future sprints |
| Config shutdown interface missing | Sprint 1 | Documented TODO |

---

## 15. Self-Audit Checklist

| Check | Status |
|-------|--------|
| No source code written | ✓ (plan only) |
| No frozen interfaces modified | ✓ (documentation only) |
| No architecture changes proposed | ✓ (uses existing architecture) |
| No Strategy/Entry/Exit/Orders/Risk/Money/AI | ✓ (explicitly excluded) |
| All frozen modules referenced correctly | ✓ (verified against contracts) |
| Integration sequence matches dependency order | ✓ (Infra → Indicators → Structure → PA) |
| Shutdown sequence is reverse of init | ✓ (documented) |
| Error handling covers init/runtime/shutdown/fatal | ✓ |
| Logging plan uses existing LoggerCore/LoggerFile | ✓ |
| Strategy Tester preparation documented | ✓ |
| Regression strategy defined | ✓ |
| Risks identified with mitigations | ✓ |

---

**END OF SPRINT 6 PLAN**

*This document defines the complete scope, architecture, and approach for Sprint 6. Implementation (SPR6-002+) will follow this plan exactly.*
