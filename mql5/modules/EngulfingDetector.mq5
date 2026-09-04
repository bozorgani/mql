#include <mql5/include/PriceActionMath.mqh>
// TODO(SPR4-013): Replace local PatternType with shared CommonTypes definition

// SPR4-003 EngulfingDetector Foundation — skeleton only; no pattern logic
bool engulfingInitialized = false;
bool engulfingConfigured = false;
bool engulfingReadyState = false;
PatternType engulfingDetectedPattern = PATTERN_NONE;
bool EngulfingInit(){ engulfingInitialized = true; return true; }
void EngulfingShutdown(){ engulfingInitialized = false; engulfingConfigured = false; engulfingReadyState = false; engulfingDetectedPattern = PATTERN_NONE; }
bool EngulfingStatus(){ return engulfingInitialized; }
bool EngulfingConfigure(){ engulfingConfigured = true; return true; }
bool EngulfingUpdate(){
  if(!engulfingInitialized || !engulfingConfigured) return false;
  MqlRates rates[]; if(!LoadClosedRates(_Symbol, indicatorConfig.entryTimeframe, 2, rates)) return false;
  engulfingDetectedPattern = DetectEngulfingPattern(rates[0], rates[1]);
  engulfingReadyState = true;
  return true;
}
bool EngulfingReady(){ return engulfingInitialized && engulfingConfigured && engulfingReadyState; }
PatternType GetEngulfingPattern(){ return engulfingDetectedPattern; }
