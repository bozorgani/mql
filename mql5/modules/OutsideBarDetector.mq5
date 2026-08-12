#include <mql5/include/CommonTypes.mqh>
// SPR4-005 OutsideBarDetector Foundation — skeleton only; no detection logic
// TODO(SPR4-013): Replace local PatternType with shared CommonTypes definition


bool initialized = false;
bool configured = false;
bool ready = false;
PatternType detectedPattern = PATTERN_NONE;

bool OutsideBarInit(){ initialized = true; return true; }
void OutsideBarShutdown(){ initialized = false; configured = false; ready = false; detectedPattern = PATTERN_NONE; }
bool OutsideBarStatus(){ return initialized; }
bool OutsideBarConfigure(){ configured = true; return true; }
bool OutsideBarUpdate(){
  /* TODO(SPR4-006): Implement Outside Bar detection using closed candles from CandleClassifier */
  return true;
}
bool OutsideBarReady(){ return initialized && configured && ready; }
