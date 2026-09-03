// SPR2-008 Indicator Manager Integration — EMA + ATR only; no strategy
// SPR6-007: IndicatorManager is the configuration-application and
// child-lifecycle owner (authorized ownership model). Configuration values
// are read only from the ConfigSystem-owned record — no local literals.
bool indicatorInitialized = false;

bool IndicatorManagerInit(){
  // Configuration validation precedes indicator initialization (authorized contract).
  if(ValidateConfiguration() != VAL_OK) return false;
  if(!EMAInit()) return false;
  if(!ATRInit()){ EMAShutdown(); return false; }
  // Apply authorized values from the ConfigSystem-owned record.
  if(!EMAConfigureRuntime(indicatorConfig.emaPeriod,
                          indicatorConfig.emaSlowPeriod,
                          indicatorConfig.emaAppliedPrice,
                          indicatorConfig.trendTimeframe,
                          indicatorConfig.historyMultiplier)){
    IndicatorManagerShutdown(); // reverse-order child rollback (ATR, then EMA)
    return false;
  }
  if(!ATRConfigureRuntime(indicatorConfig.atrPeriod,
                          indicatorConfig.atrTimeframe,
                          indicatorConfig.historyMultiplier)){
    IndicatorManagerShutdown(); // reverse-order child rollback (ATR, then EMA)
    return false;
  }
  indicatorInitialized = true;
  return true;
}

void IndicatorManagerShutdown(){
  ATRShutdown();
  EMAShutdown();
  indicatorInitialized = false;
}
bool IndicatorManagerStatus(){ return indicatorInitialized && EMAStatus() && ATRStatus(); }
bool VerifyEMAReady(){ return EMAReady(); }
bool VerifyATRReady(){ return ATRReady(); }
