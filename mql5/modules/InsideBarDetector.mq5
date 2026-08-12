#include <mql5/include/CommonTypes.mqh>
// SPR4-004 InsideBarDetector Foundation — skeleton only; no pattern logic
// TODO(SPR4-013): Replace local PatternType with shared CommonTypes when available
bool initialized = false;
bool configured = false;
bool ready = false;
PatternType detectedPattern = PATTERN_NONE;
bool InsideBarInit(){ initialized = true; return true; }
void InsideBarShutdown(){ initialized = false; configured = false; ready = false; detectedPattern = PATTERN_NONE; }
bool InsideBarStatus(){ return initialized; }
bool InsideBarConfigure(){ configured = true; return true; }
bool InsideBarUpdate(){
  /* TODO(SPR4-005): Implement inside-bar detection using closed candles from CandleClassifier */
  return true;
}
bool InsideBarReady(){ return initialized && configured && ready; }
