#include <mql5/include/CommonTypes.mqh>
// SPR4-004 InsideBarDetector Foundation — skeleton only; no pattern logic
// TODO(SPR4-013): Replace local PatternType with shared CommonTypes when available
bool insideBarInitialized = false;
bool insideBarConfigured = false;
bool insideBarReadyState = false;
PatternType insideBarDetectedPattern = PATTERN_NONE;
bool InsideBarInit(){ insideBarInitialized = true; return true; }
void InsideBarShutdown(){ insideBarInitialized = false; insideBarConfigured = false; insideBarReadyState = false; insideBarDetectedPattern = PATTERN_NONE; }
bool InsideBarStatus(){ return insideBarInitialized; }
bool InsideBarConfigure(){ insideBarConfigured = true; return true; }
bool InsideBarUpdate(){
  /* TODO(SPR4-005): Implement inside-bar detection using closed candles from CandleClassifier */
  return true;
}
bool InsideBarReady(){ return insideBarInitialized && insideBarConfigured && insideBarReadyState; }
