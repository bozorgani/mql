#property script_show_inputs

#include <mql5/include/StructureMath.mqh>
#include <mql5/modules/SwingStorage.mq5>
#include "TestFramework.mqh"

void TestConfirmedHighPivot() {
  double highs[] = {10.0, 15.0, 11.0};
  double lows[] = {8.0, 9.0, 8.5};
  datetime times[] = {100, 200, 300};
  SwingPoint point;
  int index = -1;
  TestAssertTrue(DetectConfirmedPivot(highs, lows, times, 1, 1, point, index),
                 "Three-bar high fixture is valid");
  TestAssertInt(1, index, "High pivot uses the centered closed candle");
  TestAssertInt((int)SWING_HIGH, (int)point.type, "High pivot type is detected");
  TestAssertDouble(15.0, point.price, 0.0, "High pivot price is exact");
  TestAssertInt(200, (int)point.time, "High pivot time belongs to center candle");
}

void TestConfirmedLowPivot() {
  double highs[] = {12.0, 11.0, 13.0};
  double lows[] = {9.0, 5.0, 8.0};
  datetime times[] = {100, 200, 300};
  SwingPoint point;
  int index = -1;
  TestAssertTrue(DetectConfirmedPivot(highs, lows, times, 1, 1, point, index),
                 "Three-bar low fixture is valid");
  TestAssertInt((int)SWING_LOW, (int)point.type, "Low pivot type is detected");
  TestAssertDouble(5.0, point.price, 0.0, "Low pivot price is exact");
}

void TestNoPivotAndAmbiguity() {
  double trendHighs[] = {10.0, 11.0, 12.0};
  double trendLows[] = {8.0, 9.0, 10.0};
  datetime times[] = {100, 200, 300};
  SwingPoint point;
  int index = -1;
  TestAssertTrue(DetectConfirmedPivot(trendHighs, trendLows, times, 1, 1,
                                      point, index),
                 "Non-pivot fixture is structurally valid");
  TestAssertInt((int)SWING_NONE, (int)point.type,
                "Monotonic candles do not create a pivot");

  double outsideHighs[] = {10.0, 15.0, 11.0};
  double outsideLows[] = {8.0, 5.0, 7.0};
  TestAssertTrue(DetectConfirmedPivot(outsideHighs, outsideLows, times, 1, 1,
                                      point, index),
                 "Outside-bar fixture is structurally valid");
  TestAssertInt((int)SWING_NONE, (int)point.type,
                "Ambiguous high-and-low pivot is rejected");
}

void TestPivotValidation() {
  double highs[] = {10.0, 11.0};
  double lows[] = {8.0, 9.0};
  datetime times[] = {100, 200};
  SwingPoint point;
  int index = -1;
  TestAssertFalse(DetectConfirmedPivot(highs, lows, times, 1, 1, point, index),
                  "Pivot rejects insufficient confirmation bars");
  TestAssertFalse(DetectConfirmedPivot(highs, lows, times, 0, 1, point, index),
                  "Pivot rejects zero left radius");
}

void TestSwingClassification() {
  SwingPoint previous;
  SwingPoint current;
  previous.type = SWING_HIGH;
  previous.price = 10.0;
  current.type = SWING_HIGH;
  current.price = 12.0;
  TestAssertInt((int)SWING_HH, (int)ClassifySwingRelation(current, previous),
                "Higher high is classified");
  current.price = 9.0;
  TestAssertInt((int)SWING_LH, (int)ClassifySwingRelation(current, previous),
                "Lower high is classified");
  previous.type = SWING_LOW;
  previous.price = 8.0;
  current.type = SWING_LOW;
  current.price = 9.0;
  TestAssertInt((int)SWING_HL, (int)ClassifySwingRelation(current, previous),
                "Higher low is classified");
  current.price = 7.0;
  TestAssertInt((int)SWING_LL, (int)ClassifySwingRelation(current, previous),
                "Lower low is classified");
}

void TestSwingStorageHistory() {
  SwingStorageShutdown();
  TestAssertTrue(SwingStorageInit(), "Swing storage initializes");
  TestAssertTrue(SaveSwingPoint(10.0, 100, SWING_HIGH), "First swing is stored");
  TestAssertTrue(SaveSwingPoint(8.0, 200, SWING_LOW), "Second swing is stored");
  TestAssertTrue(SaveSwingPoint(12.0, 300, SWING_HIGH), "Third swing is stored");
  TestAssertTrue(SaveSwingPoint(12.0, 300, SWING_HIGH), "Duplicate swing is idempotent");
  TestAssertInt(3, GetStoredSwingCount(), "Duplicate does not grow history");
  SwingPoint point;
  TestAssertTrue(GetStoredSwingFromNewest(0, point), "Newest swing is readable");
  TestAssertDouble(12.0, point.price, 0.0, "Newest swing has expected price");
  TestAssertTrue(GetLatestSwingByType(SWING_LOW, point), "Latest low is readable");
  TestAssertDouble(8.0, point.price, 0.0, "Latest low has expected price");
  TestAssertFalse(SaveSwingPoint(0.0, 400, SWING_HIGH), "Invalid swing is rejected");
  SwingStorageShutdown();
  TestAssertInt(0, GetStoredSwingCount(), "Shutdown clears swing history");
}

void OnStart() {
  TestReset();
  Print("[SUITE] SwingMathTestRunner started");
  TestConfirmedHighPivot();
  TestConfirmedLowPivot();
  TestNoPivotAndAmbiguity();
  TestPivotValidation();
  TestSwingClassification();
  TestSwingStorageHistory();
  if(!TestSummary("SwingMathTestRunner"))
    Alert("SwingMathTestRunner FAILED. Review Experts log.");
}
