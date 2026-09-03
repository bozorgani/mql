#include <mql5/include/CommonTypes.mqh>
// SPR4-005 OutsideBarDetector Foundation — skeleton only; no detection logic
// TODO(SPR4-013): Replace local PatternType with shared CommonTypes definition


bool outsideBarInitialized = false;
bool outsideBarConfigured = false;
bool outsideBarReadyState = false;
PatternType outsideBarDetectedPattern = PATTERN_NONE;

bool OutsideBarInit(){ outsideBarInitialized = true; return true; }
void OutsideBarShutdown(){ outsideBarInitialized = false; outsideBarConfigured = false; outsideBarReadyState = false; outsideBarDetectedPattern = PATTERN_NONE; }
bool OutsideBarStatus(){ return outsideBarInitialized; }
bool OutsideBarConfigure(){ outsideBarConfigured = true; return true; }
bool OutsideBarUpdate(){
  /* TODO(SPR4-006): Implement Outside Bar detection using closed candles from CandleClassifier */
  return true;
}
bool OutsideBarReady(){ return outsideBarInitialized && outsideBarConfigured && outsideBarReadyState; }
