#include <mql5/include/CommonTypes.mqh>
// SPR4-003 PinBarDetector Foundation — skeleton only; no pattern logic
// TODO(SPR4-013): Replace local PatternType with shared CommonTypes when available

bool pinBarInitialized = false;
bool pinBarConfigured = false;
bool pinBarReadyState = false;
PatternType pinBarDetectedPattern = PATTERN_NONE;

bool PinBarInit(){ pinBarInitialized = true; return true; }
void PinBarShutdown(){ pinBarInitialized = false; pinBarConfigured = false; pinBarReadyState = false; pinBarDetectedPattern = PATTERN_NONE; }
bool PinBarStatus(){ return pinBarInitialized; }
bool PinBarConfigure(){ pinBarConfigured = true; return true; }
bool PinBarUpdate(){
  /* TODO(SPR4-003): Implement PinBar detection using closed candles from CandleClassifier */
  return true;
}
bool PinBarReady(){ return pinBarInitialized && pinBarConfigured && pinBarReadyState; }
