#property script_show_inputs
#include <mql5/include/FibonacciMath.mqh>
#include "TestFramework.mqh"

void FibSwing(SwingPoint &point,SwingType type,double price,datetime time){ point.type=type; point.price=price; point.time=time; }

void TestBullishAndBearishLevels(){
  SwingPoint origin,end; FibonacciResult result;
  FibSwing(origin,SWING_LOW,100.0,100); FibSwing(end,SWING_HIGH,110.0,200);
  TestAssertTrue(BuildFibonacci(origin,end,0.03,result),"Bullish impulse valid");
  TestAssertTrue(result.valid,"Bullish impulse passes minimum movement");
  TestAssertInt((int)TREND_BULLISH,(int)result.direction,"Low to high is bullish impulse");
  TestAssertDouble(106.18,result.level382,0.00000001,"Bullish 38.2 level measured from end");
  TestAssertDouble(105.0,result.level500,0.00000001,"Bullish 50 level calculated");
  TestAssertDouble(103.82,result.level618,0.00000001,"Bullish 61.8 level calculated");
  FibSwing(origin,SWING_HIGH,110.0,100); FibSwing(end,SWING_LOW,100.0,200);
  TestAssertTrue(BuildFibonacci(origin,end,0.03,result),"Bearish impulse valid");
  TestAssertInt((int)TREND_BEARISH,(int)result.direction,"High to low is bearish impulse");
  TestAssertDouble(103.82,result.level382,0.00000001,"Bearish 38.2 level measured from end");
  TestAssertDouble(105.0,result.level500,0.00000001,"Bearish 50 level calculated");
  TestAssertDouble(106.18,result.level618,0.00000001,"Bearish 61.8 level calculated");
}

void TestAnchorSelectionAndThreshold(){
  SwingPoint points[]; ArrayResize(points,4); FibonacciResult result;
  FibSwing(points[0],SWING_LOW,100.0,100); FibSwing(points[1],SWING_HIGH,108.0,200);
  FibSwing(points[2],SWING_HIGH,109.0,300); FibSwing(points[3],SWING_HIGH,110.0,400);
  TestAssertTrue(SelectFibonacciAnchors(points,0.03,0.005,result),"Anchor selection valid");
  TestAssertInt(100,(int)result.origin.time,"Latest endpoint searches backward to latest opposite swing");
  TestAssertInt(400,(int)result.end.time,"Extension beyond invalidation threshold becomes endpoint");
  FibSwing(points[1],SWING_HIGH,108.0,200); FibSwing(points[2],SWING_HIGH,108.2,300); FibSwing(points[3],SWING_HIGH,108.4,400);
  TestAssertTrue(SelectFibonacciAnchors(points,0.03,0.005,result),"Sub-threshold extension input valid");
  TestAssertInt(200,(int)result.end.time,"Sub-threshold same-type swings retain confirmed endpoint");
  FibSwing(points[0],SWING_LOW,100.0,100); FibSwing(points[1],SWING_HIGH,102.0,200);
  ArrayResize(points,2);
  TestAssertTrue(SelectFibonacciAnchors(points,0.03,0.005,result),"Small impulse input valid");
  TestAssertFalse(result.valid,"Impulse below three percent rejected without stale fallback");
  FibSwing(points[1],SWING_HIGH,103.0,200);
  TestAssertTrue(SelectFibonacciAnchors(points,0.03,0.005,result),"Exact threshold input valid");
  TestAssertFalse(result.valid,"Impulse exactly at three percent is rejected");
}

void TestRetracementZones(){
  SwingPoint origin,end; FibonacciResult fib; RetracementResult result;
  FibSwing(origin,SWING_LOW,100.0,100); FibSwing(end,SWING_HIGH,110.0,200); BuildFibonacci(origin,end,0.03,fib);
  TestAssertTrue(EvaluateRetracement(fib,105.02,0.0015,result),"Retracement evaluation valid");
  TestAssertTrue(result.valid,"Price within tolerance enters Fibonacci zone");
  TestAssertInt((int)FIB_500,(int)result.nearestLevel,"Nearest level selected for scoring");
  TestAssertDouble(0.498,result.retracementRatio,0.00000001,"Retracement ratio measured from impulse end");
  TestAssertTrue(EvaluateRetracement(fib,107.0,0.0015,result),"Non-zone evaluation valid");
  TestAssertFalse(result.valid,"Price away from configured levels is not in zone");
  TestAssertInt((int)FIB_NONE,(int)result.nearestLevel,"Non-zone result has no level");
  TestAssertTrue(EvaluateRetracement(fib,111.0,0.0015,result),"Extension input valid");
  TestAssertFalse(result.valid,"Price beyond impulse end is not retracement zone");
}

void TestValidation(){
  SwingPoint origin,end; FibonacciResult fib; RetracementResult result;
  FibSwing(origin,SWING_LOW,100.0,200); FibSwing(end,SWING_HIGH,110.0,100);
  TestAssertFalse(BuildFibonacci(origin,end,0.03,fib),"Reversed anchor chronology rejected");
  end.time=300; end.type=SWING_LOW;
  TestAssertFalse(BuildFibonacci(origin,end,0.03,fib),"Same-type anchors rejected");
  TestAssertFalse(EvaluateRetracement(fib,105.0,0.0015,result),"Invalid Fibonacci object rejected");
}

void OnStart(){ TestReset(); Print("[SUITE] FibonacciMathTestRunner started"); TestBullishAndBearishLevels(); TestAnchorSelectionAndThreshold(); TestRetracementZones(); TestValidation(); if(!TestSummary("FibonacciMathTestRunner")) Alert("FibonacciMathTestRunner FAILED. Review Experts log."); }
