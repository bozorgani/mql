#include <mql5/include/PriceActionMath.mqh>
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
  if(!insideBarInitialized || !insideBarConfigured) return false;
  MqlRates rates[]; if(!LoadClosedRates(_Symbol, indicatorConfig.entryTimeframe, 2, rates)) return false;
  insideBarDetectedPattern = DetectInsideBarPattern(rates[0], rates[1]);
  insideBarReadyState = true;
  return true;
}
bool InsideBarReady(){ return insideBarInitialized && insideBarConfigured && insideBarReadyState; }
PatternType GetInsideBarPattern(){ return insideBarDetectedPattern; }
