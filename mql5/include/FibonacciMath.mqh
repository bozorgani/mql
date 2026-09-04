#ifndef MQL5_FIBONACCI_MATH_MQH
#define MQL5_FIBONACCI_MATH_MQH

#include <mql5/include/StructureMath.mqh>

void ResetFibonacciResult(FibonacciResult &result) {
  result.valid=false; result.direction=TREND_UNKNOWN;
  result.origin.time=0; result.origin.price=0.0; result.origin.type=SWING_NONE;
  result.end=result.origin; result.level382=0.0; result.level500=0.0; result.level618=0.0;
}

bool BuildFibonacci(const SwingPoint &origin, const SwingPoint &end,
                    const double minimumImpulseRatio, FibonacciResult &result) {
  ResetFibonacciResult(result);
  if(!MathIsValidNumber(minimumImpulseRatio) || minimumImpulseRatio <= 0.0 ||
     (origin.type!=SWING_HIGH && origin.type!=SWING_LOW) ||
     (end.type!=SWING_HIGH && end.type!=SWING_LOW) ||
     !ValidateTypedSwing(origin, origin.type) || !ValidateTypedSwing(end, end.type) ||
     origin.type == end.type || origin.time >= end.time) return false;
  double range=MathAbs(end.price-origin.price);
  if(range/origin.price <= minimumImpulseRatio) return true;
  if(origin.type==SWING_LOW && end.type==SWING_HIGH && end.price>origin.price) {
    result.direction=TREND_BULLISH;
    result.level382=end.price-range*0.382; result.level500=end.price-range*0.500; result.level618=end.price-range*0.618;
  } else if(origin.type==SWING_HIGH && end.type==SWING_LOW && end.price<origin.price) {
    result.direction=TREND_BEARISH;
    result.level382=end.price+range*0.382; result.level500=end.price+range*0.500; result.level618=end.price+range*0.618;
  } else return false;
  result.origin=origin; result.end=end; result.valid=true; return true;
}

bool SelectFibonacciAnchors(const SwingPoint &points[], const double minimumImpulseRatio,
                            const double invalidationRatio,
                            FibonacciResult &result) {
  ResetFibonacciResult(result);
  if(!MathIsValidNumber(invalidationRatio) || invalidationRatio<0.0) return false;
  int count=ArraySize(points); if(count<2) return true;
  SwingPoint end=points[count-1]; int runStart=count-1;
  while(runStart>0 && points[runStart-1].type==end.type) runStart--;
  end=points[runStart];
  for(int index=runStart+1;index<count;index++) {
    if((end.type==SWING_HIGH && points[index].price>end.price*(1.0+invalidationRatio)) ||
       (end.type==SWING_LOW && points[index].price<end.price*(1.0-invalidationRatio))) end=points[index];
  }
  for(int index=runStart-1;index>=0;index--) if(points[index].type!=end.type)
    return BuildFibonacci(points[index],end,minimumImpulseRatio,result);
  return true;
}

bool EvaluateRetracement(const FibonacciResult &fib, const double price,
                         const double zoneToleranceRatio, RetracementResult &result) {
  result.valid=false; result.nearestLevel=FIB_NONE; result.retracementRatio=0.0;
  result.nearestLevelPrice=0.0; result.distanceRatio=0.0;
  if(!fib.valid || !MathIsValidNumber(price) || price<=0.0 ||
     !MathIsValidNumber(zoneToleranceRatio) || zoneToleranceRatio<0.0) return false;
  double range=MathAbs(fib.end.price-fib.origin.price); if(range<=0.0) return false;
  result.retracementRatio = fib.direction==TREND_BULLISH ?
                            (fib.end.price-price)/range : (price-fib.end.price)/range;
  if(result.retracementRatio<0.0 || result.retracementRatio>1.0) return true;
  double levels[3]={fib.level382,fib.level500,fib.level618};
  FibonacciLevel names[3]={FIB_382,FIB_500,FIB_618};
  double nearest=DBL_MAX; int nearestIndex=-1;
  for(int index=0;index<3;index++) {
    double distance=MathAbs(price-levels[index])/levels[index];
    if(distance<nearest) { nearest=distance; nearestIndex=index; }
  }
  result.distanceRatio=nearest;
  if(nearestIndex>=0 && nearest<=zoneToleranceRatio) {
    result.valid=true; result.nearestLevel=names[nearestIndex]; result.nearestLevelPrice=levels[nearestIndex];
  }
  return true;
}

#endif // MQL5_FIBONACCI_MATH_MQH
