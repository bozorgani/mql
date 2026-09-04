// SPR6-018 Fibonacci retracement-zone detector
#include <mql5/include/FibonacciMath.mqh>

bool retracementInitialized=false, retracementConfigured=false, retracementReadyState=false;
double retracementCurrentValue=0.0, retracementNearestPrice=0.0, retracementDistanceRatio=0.0;
double retracementZoneToleranceRatio=0.0015;
FibonacciLevel retracementCurrentLevel=FIB_NONE;

bool RetracementInit(){ retracementInitialized=true; return true; }
void RetracementShutdown(){ retracementInitialized=false; retracementConfigured=false; retracementReadyState=false; retracementCurrentValue=0.0; retracementNearestPrice=0.0; retracementDistanceRatio=0.0; retracementZoneToleranceRatio=0.0015; retracementCurrentLevel=FIB_NONE; }
bool RetracementStatus(){ return retracementInitialized; }
bool RetracementConfigure(){ retracementConfigured=true; return true; }
bool RetracementConfigureRuntime(double zoneToleranceRatio){
  if(!MathIsValidNumber(zoneToleranceRatio) || zoneToleranceRatio<0.0 || zoneToleranceRatio>=0.5) return false;
  retracementZoneToleranceRatio=zoneToleranceRatio; retracementConfigured=true; return true;
}
bool RetracementUpdate(){
  if(!retracementInitialized || !retracementConfigured) return false;
  retracementReadyState=false; retracementCurrentLevel=FIB_NONE; retracementCurrentValue=0.0; retracementNearestPrice=0.0; retracementDistanceRatio=0.0;
  if(!FibonacciReady()) return true;
  MqlRates rates[]; if(!LoadClosedRates(_Symbol,indicatorConfig.entryTimeframe,1,rates)) return false;
  RetracementResult result;
  if(!EvaluateRetracement(fibonacciCurrentResult,rates[0].close,retracementZoneToleranceRatio,result)) return false;
  retracementCurrentValue=result.retracementRatio; retracementNearestPrice=result.nearestLevelPrice; retracementDistanceRatio=result.distanceRatio;
  retracementCurrentLevel=result.nearestLevel; retracementReadyState=true; return true;
}
bool RetracementReady(){ return retracementInitialized && retracementConfigured && retracementReadyState; }
double GetRetracementValue(){ return retracementCurrentValue; }
FibonacciLevel GetRetracementLevel(){ return retracementCurrentLevel; }
double GetRetracementNearestPrice(){ return retracementNearestPrice; }
double GetRetracementDistanceRatio(){ return retracementDistanceRatio; }
bool RetracementInZone(){ return RetracementReady() && retracementCurrentLevel!=FIB_NONE; }
