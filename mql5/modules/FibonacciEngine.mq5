// SPR6-018 Confirmed-swing Fibonacci engine
#include <mql5/include/FibonacciMath.mqh>

bool fibonacciInitialized=false, fibonacciConfigured=false, fibonacciReadyState=false;
double fibonacciAnchorHigh=0.0, fibonacciAnchorLow=0.0;
double fibonacciMinimumImpulseRatio=0.03;
double fibonacciInvalidationRatio=0.005;
int fibonacciMaximumAgeBars=40;
FibonacciResult fibonacciCurrentResult;

bool FibonacciInit(){ fibonacciInitialized=true; ResetFibonacciResult(fibonacciCurrentResult); return true; }
void FibonacciShutdown(){ fibonacciInitialized=false; fibonacciConfigured=false; fibonacciReadyState=false; fibonacciAnchorHigh=0.0; fibonacciAnchorLow=0.0; fibonacciMinimumImpulseRatio=0.03; fibonacciInvalidationRatio=0.005; fibonacciMaximumAgeBars=40; ResetFibonacciResult(fibonacciCurrentResult); }
bool FibonacciStatus(){ return fibonacciInitialized; }
bool FibonacciConfigure(){ fibonacciConfigured=true; return true; }
bool FibonacciConfigureRuntime(double minimumImpulseRatio,double invalidationRatio,int maximumAgeBars){
  if(!MathIsValidNumber(minimumImpulseRatio) || minimumImpulseRatio<=0.0 || !MathIsValidNumber(invalidationRatio) || invalidationRatio<0.0 || invalidationRatio>=0.5 || maximumAgeBars<=0) return false;
  fibonacciMinimumImpulseRatio=minimumImpulseRatio; fibonacciInvalidationRatio=invalidationRatio; fibonacciMaximumAgeBars=maximumAgeBars; fibonacciConfigured=true; return true;
}
bool FibonacciUpdate(){
  if(!fibonacciInitialized || !fibonacciConfigured) return false;
  int count=GetStoredSwingCount(); if(count<2){ fibonacciReadyState=false; ResetFibonacciResult(fibonacciCurrentResult); return true; }
  SwingPoint points[]; ArrayResize(points,count);
  for(int index=0;index<count;index++) if(!GetStoredSwingFromNewest(count-1-index,points[index])) return false;
  FibonacciResult result;
  if(!SelectFibonacciAnchors(points,fibonacciMinimumImpulseRatio,fibonacciInvalidationRatio,result)) return false;
  if(!result.valid){ fibonacciReadyState=false; ResetFibonacciResult(fibonacciCurrentResult); return true; }
  int originShift=iBarShift(_Symbol,indicatorConfig.entryTimeframe,result.origin.time,false);
  if(originShift<1 || originShift>fibonacciMaximumAgeBars){ fibonacciReadyState=false; ResetFibonacciResult(fibonacciCurrentResult); return true; }
  fibonacciCurrentResult=result;
  fibonacciAnchorHigh=MathMax(result.origin.price,result.end.price);
  fibonacciAnchorLow=MathMin(result.origin.price,result.end.price);
  fibonacciReadyState=true; return true;
}
bool FibonacciReady(){ return fibonacciInitialized && fibonacciConfigured && fibonacciReadyState; }
double GetRetracement(){ return fibonacciCurrentResult.level500; }
double GetFibonacciLevelPrice(FibonacciLevel level){
  if(!FibonacciReady()) return 0.0;
  if(level==FIB_382) return fibonacciCurrentResult.level382;
  if(level==FIB_500) return fibonacciCurrentResult.level500;
  if(level==FIB_618) return fibonacciCurrentResult.level618;
  return 0.0;
}
TrendDirection GetFibonacciDirection(){ return fibonacciCurrentResult.direction; }
datetime GetFibonacciOriginTime(){ return fibonacciCurrentResult.origin.time; }
datetime GetFibonacciEndTime(){ return fibonacciCurrentResult.end.time; }
