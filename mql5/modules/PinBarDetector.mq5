#include <mql5/include/PriceActionMath.mqh>
// SPR4-003 PinBarDetector Foundation — skeleton only; no pattern logic
// TODO(SPR4-013): Replace local PatternType with shared CommonTypes when available

bool pinBarInitialized = false;
bool pinBarConfigured = false;
bool pinBarReadyState = false;
PatternType pinBarDetectedPattern = PATTERN_NONE;
double pinBarMaximumBodyRatio = 0.30;
double pinBarMinimumWickToBody = 2.0;
double pinBarExtremeCloseRatio = 0.25;

bool PinBarInit(){ pinBarInitialized = true; return true; }
void PinBarShutdown(){ pinBarInitialized = false; pinBarConfigured = false; pinBarReadyState = false; pinBarDetectedPattern = PATTERN_NONE; }
bool PinBarStatus(){ return pinBarInitialized; }
bool PinBarConfigure(){ pinBarConfigured = true; return true; }
bool PinBarConfigureRuntime(double maximumBodyRatio, double minimumWickToBody, double extremeCloseRatio){
  if(maximumBodyRatio <= 0.0 || maximumBodyRatio >= 1.0 || minimumWickToBody <= 0.0 || extremeCloseRatio <= 0.0 || extremeCloseRatio >= 0.5) return false;
  pinBarMaximumBodyRatio=maximumBodyRatio; pinBarMinimumWickToBody=minimumWickToBody; pinBarExtremeCloseRatio=extremeCloseRatio; pinBarConfigured=true; return true;
}
bool PinBarUpdate(){
  if(!pinBarInitialized || !pinBarConfigured) return false;
  MqlRates rates[]; if(!LoadClosedRates(_Symbol, indicatorConfig.entryTimeframe, 1, rates)) return false;
  pinBarDetectedPattern = DetectPinBarPattern(rates[0], pinBarMaximumBodyRatio, pinBarMinimumWickToBody, pinBarExtremeCloseRatio);
  pinBarReadyState = true;
  return true;
}
bool PinBarReady(){ return pinBarInitialized && pinBarConfigured && pinBarReadyState; }
PatternType GetPinBarPattern(){ return pinBarDetectedPattern; }
