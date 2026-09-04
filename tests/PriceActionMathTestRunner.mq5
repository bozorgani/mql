#property script_show_inputs
#include <mql5/include/PriceActionMath.mqh>
#include "TestFramework.mqh"

void Bar(MqlRates &bar, datetime time, double open, double high, double low, double close) {
  bar.time=time; bar.open=open; bar.high=high; bar.low=low; bar.close=close;
}

void TestClassification() {
  MqlRates bar; Bar(bar,100,1.1000,1.1120,1.0980,1.1100);
  TestAssertInt((int)PATTERN_BULLISH,(int)ClassifyCandle(bar,0.10),"Directional bullish candle classified");
  Bar(bar,100,1.1000,1.1100,1.0900,1.1010);
  TestAssertInt((int)PATTERN_DOJI,(int)ClassifyCandle(bar,0.10),"Small body classified as doji");
  bar.high=1.0990;
  TestAssertInt((int)PATTERN_NONE,(int)ClassifyCandle(bar,0.10),"Invalid OHLC rejected");
}

void TestEngulfing() {
  MqlRates previous,current;
  Bar(previous,100,1.1050,1.1060,1.0990,1.1000);
  Bar(current,200,1.0990,1.1080,1.0980,1.1070);
  TestAssertInt((int)PATTERN_BULLISH,(int)DetectEngulfingPattern(previous,current),"Bullish body engulfing detected");
  Bar(previous,100,1.1000,1.1060,1.0990,1.1050);
  Bar(current,200,1.1060,1.1070,1.0970,1.0980);
  TestAssertInt((int)PATTERN_BEARISH,(int)DetectEngulfingPattern(previous,current),"Bearish body engulfing detected");
  current.close=1.1010;
  TestAssertInt((int)PATTERN_NONE,(int)DetectEngulfingPattern(previous,current),"Partial body overlap rejected");
}

void TestPinBars() {
  MqlRates bar;
  Bar(bar,100,1.1020,1.1040,1.0900,1.1030);
  TestAssertInt((int)PATTERN_BULLISH,(int)DetectPinBarPattern(bar,0.30,2.0,0.25),"Bullish pin bar detected");
  Bar(bar,100,1.1020,1.1140,1.1000,1.1010);
  TestAssertInt((int)PATTERN_BEARISH,(int)DetectPinBarPattern(bar,0.30,2.0,0.25),"Bearish pin bar detected");
  Bar(bar,100,1.1000,1.1100,1.0900,1.1060);
  TestAssertInt((int)PATTERN_NONE,(int)DetectPinBarPattern(bar,0.30,2.0,0.25),"Body at 30 percent boundary rejected");
}

void TestInsideOutside() {
  MqlRates previous,current;
  Bar(previous,100,1.1000,1.1100,1.0900,1.1050);
  Bar(current,200,1.1010,1.1080,1.0920,1.1060);
  TestAssertInt((int)PATTERN_BULLISH,(int)DetectInsideBarPattern(previous,current),"Inside bar detected with direction");
  current.high=previous.high; current.low=previous.low;
  TestAssertInt((int)PATTERN_NONE,(int)DetectInsideBarPattern(previous,current),"Identical range is not inside bar");
  Bar(current,200,1.0950,1.1150,1.0850,1.1100);
  TestAssertInt((int)PATTERN_BULLISH,(int)DetectOutsideBarPattern(previous,current,0.25),"Bullish outside bar closing near high detected");
  current.close=1.1000;
  TestAssertInt((int)PATTERN_NONE,(int)DetectOutsideBarPattern(previous,current,0.25),"Outside range without extreme close rejected");
  current.time=50;
  TestAssertInt((int)PATTERN_NONE,(int)DetectOutsideBarPattern(previous,current,0.25),"Reversed candle chronology rejected");
}

void OnStart(){
  TestReset(); Print("[SUITE] PriceActionMathTestRunner started");
  TestClassification(); TestEngulfing(); TestPinBars(); TestInsideOutside();
  if(!TestSummary("PriceActionMathTestRunner")) Alert("PriceActionMathTestRunner FAILED. Review Experts log.");
}
