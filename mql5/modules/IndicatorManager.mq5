// SPR2-008 Indicator Manager Integration — EMA + ATR only; no strategy
bool indicatorInitialized = false;
bool IndicatorManagerInit(){
  if(!EMAInit()) return false;
  if(!ATRInit()) return false;
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
