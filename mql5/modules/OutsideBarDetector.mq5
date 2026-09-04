#include <mql5/include/PriceActionMath.mqh>
// SPR4-005 OutsideBarDetector Foundation — skeleton only; no detection logic
// TODO(SPR4-013): Replace local PatternType with shared CommonTypes definition


bool outsideBarInitialized = false;
bool outsideBarConfigured = false;
bool outsideBarReadyState = false;
PatternType outsideBarDetectedPattern = PATTERN_NONE;
double outsideBarExtremeCloseRatio = 0.25;

bool OutsideBarInit(){ outsideBarInitialized = true; return true; }
void OutsideBarShutdown(){ outsideBarInitialized = false; outsideBarConfigured = false; outsideBarReadyState = false; outsideBarDetectedPattern = PATTERN_NONE; }
bool OutsideBarStatus(){ return outsideBarInitialized; }
bool OutsideBarConfigure(){ outsideBarConfigured = true; return true; }
bool OutsideBarConfigureRuntime(double extremeCloseRatio){
  if(!MathIsValidNumber(extremeCloseRatio) || extremeCloseRatio <= 0.0 || extremeCloseRatio >= 0.5) return false;
  outsideBarExtremeCloseRatio=extremeCloseRatio; outsideBarConfigured=true; return true;
}
bool OutsideBarUpdate(){
  if(!outsideBarInitialized || !outsideBarConfigured) return false;
  MqlRates rates[]; if(!LoadClosedRates(_Symbol, indicatorConfig.entryTimeframe, 2, rates)) return false;
  outsideBarDetectedPattern = DetectOutsideBarPattern(rates[0], rates[1], outsideBarExtremeCloseRatio);
  outsideBarReadyState = true;
  return true;
}
bool OutsideBarReady(){ return outsideBarInitialized && outsideBarConfigured && outsideBarReadyState; }
PatternType GetOutsideBarPattern(){ return outsideBarDetectedPattern; }
