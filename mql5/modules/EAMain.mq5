// SPR6-002 EAMain — Runtime Bootstrap Orchestration Layer
// SPR6-004 — Runtime Logging & Error Handling Foundation
// First Runnable Version — Integration Framework Only
// No Strategy, No Entry, No Exit, No Orders, No Risk, No AI

#include <mql5/modules/ConfigSystem.mq5>
#include <mql5/modules/ConfigValidator.mq5>
#include <mql5/modules/LoggerCore.mq5>
#include <mql5/modules/LoggerFile.mq5>
#include <mql5/modules/TimeService.mq5>
#include <mql5/modules/MarketData.mq5>
#include <mql5/modules/SymbolInfoService.mq5>
#include <mql5/modules/InitManager.mq5>
#include <mql5/modules/ShutdownManager.mq5>
#include <mql5/modules/EMAEngine.mq5>
#include <mql5/modules/ATREngine.mq5>
#include <mql5/modules/IndicatorManager.mq5>
#include <mql5/modules/SwingDetector.mq5>
#include <mql5/modules/SwingStorage.mq5>
#include <mql5/modules/BOSDetector.mq5>
#include <mql5/modules/CHOCHDetector.mq5>
#include <mql5/modules/TrendEngine.mq5>
#include <mql5/modules/StructureManager.mq5>
#include <mql5/modules/CandleClassifier.mq5>
#include <mql5/modules/EngulfingDetector.mq5>
#include <mql5/modules/PinBarDetector.mq5>
#include <mql5/modules/InsideBarDetector.mq5>
#include <mql5/modules/OutsideBarDetector.mq5>
#include <mql5/modules/FibonacciEngine.mq5>
#include <mql5/modules/RetracementDetector.mq5>
#include <mql5/modules/ConfluenceManager.mq5>
#include <mql5/modules/PriceActionManager.mq5>

// ============================================================================
// STATE MACHINE (Preserved from SPR6-002)
// ============================================================================

enum EAState {
  EA_UNINITIALIZED = 0,
  EA_INITIALIZING,
  EA_READY,
  EA_RUNNING,
  EA_STOPPING,
  EA_SHUTDOWN
};

// ============================================================================
// GLOBAL STATE
// ============================================================================

EAState eaState = EA_UNINITIALIZED;
bool emergencyStop = false;
int updateCount = 0;

// ============================================================================
// LIFECYCLE EVENT IDENTIFIERS (Internal to EAMain)
// ============================================================================

// Startup events
string EVENT_STARTUP_BEGIN      = "STARTUP_BEGIN";
string EVENT_INFRASTRUCTURE_INIT = "INFRASTRUCTURE_INIT";
string EVENT_INDICATOR_INIT     = "INDICATOR_INIT";
string EVENT_STRUCTURE_INIT     = "STRUCTURE_INIT";
string EVENT_PRICE_ACTION_INIT  = "PRICE_ACTION_INIT";
string EVENT_STARTUP_COMPLETE   = "STARTUP_COMPLETE";
string EVENT_EA_READY           = "EA_READY";
string EVENT_FATAL_INIT_FAILURE = "FATAL_INIT_FAILURE";

// Runtime events
string EVENT_RUNTIME_UPDATE     = "RUNTIME_UPDATE";
string EVENT_RUNTIME_UPDATE_FAILURE = "RUNTIME_UPDATE_FAILURE";

// Shutdown events
string EVENT_SHUTDOWN_BEGIN     = "SHUTDOWN_BEGIN";
string EVENT_PA_SHUTDOWN        = "PRICE_ACTION_SHUTDOWN";
string EVENT_STRUCTURE_SHUTDOWN = "STRUCTURE_SHUTDOWN";
string EVENT_INDICATOR_SHUTDOWN = "INDICATOR_SHUTDOWN";
string EVENT_INFRA_SHUTDOWN     = "INFRASTRUCTURE_SHUTDOWN";
string EVENT_SHUTDOWN_COMPLETE  = "SHUTDOWN_COMPLETE";

// ============================================================================
// LOGGING HELPERS
// ============================================================================

void LogInfoEvent(string eventId, string msg) {
  CreateLogEvent("EAMain", eventId, 1, msg);  // INFO level
}

void LogErrorEvent(string eventId, string msg) {
  CreateLogEvent("EAMain", eventId, 3, msg);  // ERROR level
}

void LogCriticalEvent(string eventId, string msg) {
  CreateLogEvent("EAMain", eventId, 4, msg);  // CRITICAL level
}

// ============================================================================
// MODULES VERIFICATION
// ============================================================================

bool VerifyInfrastructureReady() {
  if(!ConfigStatus()) { LogErrorEvent("INIT_VERIFY_FAIL", "ConfigStatus false"); return false; }
  if(!LoggerStatus()) { LogErrorEvent("INIT_VERIFY_FAIL", "LoggerStatus false"); return false; }
  if(!LogFileStatus()) { LogErrorEvent("INIT_VERIFY_FAIL", "LogFileStatus false"); return false; }
  if(!MarketStatus()) { LogErrorEvent("INIT_VERIFY_FAIL", "MarketStatus false"); return false; }
  if(!SymbolInfoStatus()) { LogErrorEvent("INIT_VERIFY_FAIL", "SymbolInfoStatus false"); return false; }
  return true;
}

bool VerifyIndicatorsReady() {
  if(!IndicatorManagerStatus()) { LogErrorEvent("INIT_VERIFY_FAIL", "IndicatorManagerStatus false"); return false; }
  if(!EMAReady()) { LogErrorEvent("INIT_VERIFY_FAIL", "EMAReady false"); return false; }
  if(!ATRReady()) { LogErrorEvent("INIT_VERIFY_FAIL", "ATRReady false"); return false; }
  return true;
}

bool VerifyStructureReady() {
  if(!StructureManagerStatus()) { LogErrorEvent("INIT_VERIFY_FAIL", "StructureManagerStatus false"); return false; }
  if(!SwingStatus()) { LogErrorEvent("INIT_VERIFY_FAIL", "SwingStatus false"); return false; }
  if(!SwingStorageStatus()) { LogErrorEvent("INIT_VERIFY_FAIL", "SwingStorageStatus false"); return false; }
  if(!BOSStatus()) { LogErrorEvent("INIT_VERIFY_FAIL", "BOSStatus false"); return false; }
  if(!CHOCHStatus()) { LogErrorEvent("INIT_VERIFY_FAIL", "CHOCHStatus false"); return false; }
  if(!TrendStatus()) { LogErrorEvent("INIT_VERIFY_FAIL", "TrendStatus false"); return false; }
  return true;
}

bool VerifyPriceActionReady() {
  if(!PriceActionManagerStatus()) { LogErrorEvent("INIT_VERIFY_FAIL", "PriceActionManagerStatus false"); return false; }
  if(!CandleClassifierStatus()) { LogErrorEvent("INIT_VERIFY_FAIL", "CandleClassifierStatus false"); return false; }
  if(!EngulfingStatus()) { LogErrorEvent("INIT_VERIFY_FAIL", "EngulfingStatus false"); return false; }
  if(!PinBarStatus()) { LogErrorEvent("INIT_VERIFY_FAIL", "PinBarStatus false"); return false; }
  if(!InsideBarStatus()) { LogErrorEvent("INIT_VERIFY_FAIL", "InsideBarStatus false"); return false; }
  if(!OutsideBarStatus()) { LogErrorEvent("INIT_VERIFY_FAIL", "OutsideBarStatus false"); return false; }
  if(!FibonacciStatus()) { LogErrorEvent("INIT_VERIFY_FAIL", "FibonacciStatus false"); return false; }
  if(!RetracementStatus()) { LogErrorEvent("INIT_VERIFY_FAIL", "RetracementStatus false"); return false; }
  if(!ConfluenceStatus()) { LogErrorEvent("INIT_VERIFY_FAIL", "ConfluenceStatus false"); return false; }
  return true;
}

// ============================================================================
// INITIALIZATION
// ============================================================================

bool InitializeInfrastructureLayer() {
  eaState = EA_INITIALIZING;
  
  LogInfoEvent(EVENT_INFRASTRUCTURE_INIT, "Initializing infrastructure layer");
  
  if(ConfigInit() != INIT_SUCCEEDED) {
    LogErrorEvent("INIT_FAILED", "ConfigInit failed"); 
    return false; 
  }
  LoggerInit();
  if(!LoggerFileInit()) { 
    LogErrorEvent("INIT_FAILED", "LoggerFileInit failed"); 
    return false; 
  }
  if(!TimeServiceInit()) { 
    LogErrorEvent("INIT_FAILED", "TimeServiceInit failed"); 
    return false; 
  }
  if(!MarketDataInit()) { 
    LogErrorEvent("INIT_FAILED", "MarketDataInit failed"); 
    return false; 
  }
  if(!SymbolInfoInit()) { 
    LogErrorEvent("INIT_FAILED", "SymbolInfoInit failed"); 
    return false; 
  }
  
  LogInfoEvent(EVENT_INFRASTRUCTURE_INIT, "Infrastructure layer initialized successfully");
  return true;
}

void RollbackInfrastructureLayer() {
  LoggerFileShutdown();
  LoggerShutdown();
  // ConfigSystem has no explicit shutdown (documented TODO from Sprint 1)
}

bool InitializeIndicatorLayer() {
  // Delegate to IndicatorManager — it owns EMA and ATR lifecycle
  LogInfoEvent(EVENT_INDICATOR_INIT, "Initializing indicator layer");
  
  if(!IndicatorManagerInit()) { 
    LogErrorEvent("INIT_FAILED", "IndicatorManagerInit failed"); 
    return false; 
  }
  
  LogInfoEvent(EVENT_INDICATOR_INIT, "Indicator layer initialized successfully (EMA+ATR)");
  return true;
}

void RollbackIndicatorLayer() {
  IndicatorManagerShutdown();
  // IndicatorManagerShutdown calls ATRShutdown() and EMAShutdown() internally
}

bool InitializeStructureLayer() {
  // Delegate to StructureManager — it owns Swing, SwingStorage, BOS, CHOCH, Trend lifecycle
  LogInfoEvent(EVENT_STRUCTURE_INIT, "Initializing structure layer");
  
  if(!StructureManagerInit()) { 
    LogErrorEvent("INIT_FAILED", "StructureManagerInit failed"); 
    return false; 
  }
  
  LogInfoEvent(EVENT_STRUCTURE_INIT, "Structure layer initialized successfully (Swing/BOS/CHOCH/Trend)");
  return true;
}

void RollbackStructureLayer() {
  StructureManagerShutdown();
  // StructureManagerShutdown calls TrendShutdown, CHOCHShutdown, BOSShutdown, SwingStorageShutdown, SwingShutdown
}

bool InitializePriceActionLayer() {
  // Delegate to PriceActionManager — it owns all 8 Price Action module lifecycle
  LogInfoEvent(EVENT_PRICE_ACTION_INIT, "Initializing price action layer");
  
  if(!PriceActionManagerInit()) { 
    LogErrorEvent("INIT_FAILED", "PriceActionManagerInit failed"); 
    return false; 
  }
  
  LogInfoEvent(EVENT_PRICE_ACTION_INIT, "Price Action layer initialized successfully (8 modules)");
  return true;
}

void RollbackPriceActionLayer() {
  PriceActionManagerShutdown();
  // PriceActionManagerShutdown calls in reverse: Confluence, Retracement, Fibonacci, OutsideBar, InsideBar, PinBar, Engulfing, CandleClassifier
}

// ============================================================================
// FULL INITIALIZATION
// ============================================================================

bool EAStartup() {
  LogInfoEvent(EVENT_STARTUP_BEGIN, "EA startup sequence initiated");
  
  // Phase 1: Infrastructure
  if(!InitializeInfrastructureLayer()) {
    LogErrorEvent("STARTUP_FAILED", "Infrastructure initialization failed");
    return false;
  }
  
  // Verify infrastructure ready
  if(!VerifyInfrastructureReady()) {
    LogErrorEvent("STARTUP_FAILED", "Infrastructure verification failed");
    RollbackInfrastructureLayer();
    return false;
  }
  
  // Phase 2: Indicators (delegate to IndicatorManager)
  if(!InitializeIndicatorLayer()) {
    LogErrorEvent("STARTUP_FAILED", "Indicator initialization failed");
    RollbackInfrastructureLayer();
    return false;
  }
  
  // Verify indicators ready
  if(!VerifyIndicatorsReady()) {
    LogErrorEvent("STARTUP_FAILED", "Indicator verification failed");
    RollbackIndicatorLayer();
    RollbackInfrastructureLayer();
    return false;
  }
  
  // Phase 3: Structure (delegate to StructureManager)
  if(!InitializeStructureLayer()) {
    LogErrorEvent("STARTUP_FAILED", "Structure initialization failed");
    RollbackIndicatorLayer();
    RollbackInfrastructureLayer();
    return false;
  }
  
  // Verify structure ready
  if(!VerifyStructureReady()) {
    LogErrorEvent("STARTUP_FAILED", "Structure verification failed");
    RollbackStructureLayer();
    RollbackIndicatorLayer();
    RollbackInfrastructureLayer();
    return false;
  }
  
  // Phase 4: Price Action (delegate to PriceActionManager)
  if(!InitializePriceActionLayer()) {
    LogErrorEvent("STARTUP_FAILED", "Price Action initialization failed");
    RollbackStructureLayer();
    RollbackIndicatorLayer();
    RollbackInfrastructureLayer();
    return false;
  }
  
  // Verify price action ready
  if(!VerifyPriceActionReady()) {
    LogErrorEvent("STARTUP_FAILED", "Price Action verification failed");
    RollbackPriceActionLayer();
    RollbackStructureLayer();
    RollbackIndicatorLayer();
    RollbackInfrastructureLayer();
    return false;
  }
  
  eaState = EA_READY;
  LogInfoEvent(EVENT_STARTUP_COMPLETE, "EA initialization complete, state: READY");
  LogInfoEvent(EVENT_EA_READY, "EA is ready for runtime operation");
  
  return true;
}

// ============================================================================
// UPDATE PIPELINE
// ============================================================================

bool EAUpdate() {
  // State validation
  if(eaState != EA_READY && eaState != EA_RUNNING) {
    LogErrorEvent(EVENT_RUNTIME_UPDATE_FAILURE, "EAUpdate failed: invalid state (eaState=" + IntegerToString(eaState) + ")");
    return false;
  }
  
  if(emergencyStop) {
    LogErrorEvent(EVENT_RUNTIME_UPDATE_FAILURE, "EAUpdate failed: emergency stop active");
    return false;
  }
  
  LogInfoEvent(EVENT_RUNTIME_UPDATE, "Runtime update cycle started, count: " + IntegerToString(updateCount + 1));
  
  // Step 1: Infrastructure refresh
  RefreshMarketData();
  
  // Step 2: Indicator update (IndicatorManager has no Update facade — direct call required)
  if(!EMAUpdate()) {
    LogErrorEvent(EVENT_RUNTIME_UPDATE_FAILURE, "EAUpdate failed: EMAUpdate returned false");
    return false;
  }
  if(!ATRUpdate()) {
    LogErrorEvent(EVENT_RUNTIME_UPDATE_FAILURE, "EAUpdate failed: ATRUpdate returned false");
    return false;
  }
  
  // Step 3: Structure update (via StructureManager)
  if(!StructureManagerUpdate()) {
    LogErrorEvent(EVENT_RUNTIME_UPDATE_FAILURE, "EAUpdate failed: StructureManagerUpdate returned false");
    return false;
  }
  
  // Step 4: Price Action update (via PriceActionManager)
  if(!PriceActionManagerUpdate()) {
    LogErrorEvent(EVENT_RUNTIME_UPDATE_FAILURE, "EAUpdate failed: PriceActionManagerUpdate returned false");
    return false;
  }
  
  updateCount++;
  eaState = EA_RUNNING;
  
  LogInfoEvent(EVENT_RUNTIME_UPDATE, "Runtime update cycle completed successfully, count: " + IntegerToString(updateCount));
  return true;
}

// ============================================================================
// SHUTDOWN
// ============================================================================

void EADeinit() {
  LogInfoEvent(EVENT_SHUTDOWN_BEGIN, "EA shutdown sequence initiated");
  eaState = EA_STOPPING;
  
  // Phase 1: Price Action shutdown (reverse order)
  LogInfoEvent(EVENT_PA_SHUTDOWN, "Shutting down price action layer");
  PriceActionManagerShutdown();
  LogInfoEvent(EVENT_PA_SHUTDOWN, "Price action layer shutdown complete");
  
  // Phase 2: Structure shutdown (reverse order)
  LogInfoEvent(EVENT_STRUCTURE_SHUTDOWN, "Shutting down structure layer");
  StructureManagerShutdown();
  LogInfoEvent(EVENT_STRUCTURE_SHUTDOWN, "Structure layer shutdown complete");
  
  // Phase 3: Indicator shutdown
  LogInfoEvent(EVENT_INDICATOR_SHUTDOWN, "Shutting down indicator layer");
  IndicatorManagerShutdown();
  LogInfoEvent(EVENT_INDICATOR_SHUTDOWN, "Indicator layer shutdown complete");
  
  // Phase 4: Infrastructure shutdown
  LogInfoEvent(EVENT_INFRA_SHUTDOWN, "Shutting down infrastructure layer");
  ShutdownManagerStop();
  LogInfoEvent(EVENT_INFRA_SHUTDOWN, "Infrastructure layer shutdown complete");
  
  eaState = EA_SHUTDOWN;
  LogInfoEvent(EVENT_SHUTDOWN_COMPLETE, "EA shutdown complete, state: SHUTDOWN");
}

// ============================================================================
// MT5 ENTRY POINTS
// ============================================================================

int OnInit() {
  LogInfoEvent(EVENT_STARTUP_BEGIN, "OnInit called — beginning EA initialization");
  eaState = EA_INITIALIZING;
  
  if(!EAStartup()) {
    eaState = EA_SHUTDOWN;
    LogCriticalEvent(EVENT_FATAL_INIT_FAILURE, "EA failed to initialize — aborting");
    return INIT_FAILED;
  }
  
  return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) {
  EADeinit();
}

void OnTick() {
  if(eaState == EA_READY || eaState == EA_RUNNING) {
    EAUpdate();
  }
}

// ============================================================================
// DIAGNOSTIC ACCESSORS
// ============================================================================

EAState GetEATState() { return eaState; }
int GetUpdateCount() { return updateCount; }
bool IsEARunning() { return eaState == EA_RUNNING || eaState == EA_READY; }
bool IsEAInitialized() { return eaState != EA_UNINITIALIZED && eaState != EA_SHUTDOWN; }
