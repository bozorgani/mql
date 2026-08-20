#include <mql5/include/CommonTypes.mqh>
// SPR4-003 PinBarDetector Foundation — skeleton only; no pattern logic
// TODO(SPR4-013): Replace local PatternType with shared CommonTypes when available

bool initialized = false;
bool configured = false;
bool ready = false;
PatternType detectedPattern = PATTERN_NONE;

bool PinBarInit(){ initialized = true; return true; }
void PinBarShutdown(){ initialized = false; configured = false; ready = false; detectedPattern = PATTERN_NONE; }
bool PinBarStatus(){ return initialized; }
bool PinBarConfigure(){ configured = true; return true; }
bool PinBarUpdate(){
  /* TODO(SPR4-003): Implement PinBar detection using closed candles from CandleClassifier */
  return true;
}
bool PinBarReady(){ return initialized && configured && ready; }
