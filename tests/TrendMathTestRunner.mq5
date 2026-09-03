#property script_show_inputs

#include <mql5/include/TrendMath.mqh>
#include "TestFramework.mqh"

void SetTrendSwing(SwingPoint &point, SwingType type, double price, datetime time) {
  point.type = type; point.price = price; point.time = time;
}

void BuildRisingTrend(SwingPoint &latestHigh, SwingPoint &previousHigh,
                      SwingPoint &olderHigh, SwingPoint &latestLow,
                      SwingPoint &previousLow, SwingPoint &olderLow) {
  SetTrendSwing(olderHigh, SWING_HIGH, 1.1000, 100);
  SetTrendSwing(olderLow, SWING_LOW, 1.0800, 200);
  SetTrendSwing(previousHigh, SWING_HIGH, 1.1100, 300);
  SetTrendSwing(previousLow, SWING_LOW, 1.0900, 400);
  SetTrendSwing(latestHigh, SWING_HIGH, 1.1200, 500);
  SetTrendSwing(latestLow, SWING_LOW, 1.1000, 600);
}

void BuildFallingTrend(SwingPoint &latestHigh, SwingPoint &previousHigh,
                       SwingPoint &olderHigh, SwingPoint &latestLow,
                       SwingPoint &previousLow, SwingPoint &olderLow) {
  SetTrendSwing(olderHigh, SWING_HIGH, 1.1200, 100);
  SetTrendSwing(olderLow, SWING_LOW, 1.1000, 200);
  SetTrendSwing(previousHigh, SWING_HIGH, 1.1100, 300);
  SetTrendSwing(previousLow, SWING_LOW, 1.0900, 400);
  SetTrendSwing(latestHigh, SWING_HIGH, 1.1000, 500);
  SetTrendSwing(latestLow, SWING_LOW, 1.0800, 600);
}

void TestDirectionalTrends() {
  SwingPoint lh, ph, oh, ll, pl, ol; BuildRisingTrend(lh, ph, oh, ll, pl, ol);
  TrendResult result;
  TestAssertTrue(ClassifyTrend(1.1300, 1.1200, 1.1000, lh, ph, oh, ll, pl, ol, 0.005, 0.015, result), "Strong bullish fixture valid");
  TestAssertInt((int)TREND_BULLISH, (int)result.direction, "Aligned price EMAs and HH HL classify bullish");
  TestAssertInt((int)STRENGTH_STRONG, (int)result.strength, "Two rising sequences and distance above 1.5 percent classify strong");
  TestAssertDouble(0.0181818182, result.emaDistanceRatio, 0.00000001, "EMA distance normalized by slow EMA");

  TestAssertTrue(ClassifyTrend(1.1150, 1.1100, 1.1000, lh, ph, oh, ll, pl, ol, 0.005, 0.015, result), "Normal bullish fixture valid");
  TestAssertInt((int)TREND_BULLISH, (int)result.direction, "Moderate aligned expansion stays bullish");
  TestAssertInt((int)STRENGTH_NORMAL, (int)result.strength, "Distance below strong threshold classifies normal");

  BuildFallingTrend(lh, ph, oh, ll, pl, ol);
  TestAssertTrue(ClassifyTrend(1.0700, 1.0800, 1.1000, lh, ph, oh, ll, pl, ol, 0.005, 0.015, result), "Strong bearish fixture valid");
  TestAssertInt((int)TREND_BEARISH, (int)result.direction, "Aligned price EMAs and LH LL classify bearish");
  TestAssertInt((int)STRENGTH_STRONG, (int)result.strength, "Two falling sequences can classify strong");
}

void TestWeakAndUnconfirmedStates() {
  SwingPoint lh, ph, oh, ll, pl, ol; BuildRisingTrend(lh, ph, oh, ll, pl, ol);
  TrendResult result;
  TestAssertTrue(ClassifyTrend(1.1020, 1.1040, 1.1000, lh, ph, oh, ll, pl, ol, 0.005, 0.015, result), "Converged fixture valid");
  TestAssertInt((int)TREND_SIDEWAYS, (int)result.direction, "Converged EMAs classify sideways filter state");
  TestAssertInt((int)STRENGTH_WEAK, (int)result.strength, "Converged EMAs classify weak");
  TestAssertTrue(ClassifyTrend(1.1050, 1.1100, 1.1000, lh, ph, oh, ll, pl, ol, 0.005, 0.015, result), "Between-EMA fixture valid");
  TestAssertInt((int)TREND_SIDEWAYS, (int)result.direction, "Price between EMAs classifies sideways filter state");

  ll.price = 1.0700;
  TestAssertTrue(ClassifyTrend(1.1300, 1.1200, 1.1000, lh, ph, oh, ll, pl, ol, 0.005, 0.015, result), "Mixed structure fixture valid");
  TestAssertInt((int)TREND_UNKNOWN, (int)result.direction, "EMA direction without matching structure stays unknown");
  TestAssertInt((int)STRENGTH_UNKNOWN, (int)result.strength, "Unconfirmed direction has unknown strength");
}

void TestThresholdsAndValidation() {
  SwingPoint lh, ph, oh, ll, pl, ol; BuildRisingTrend(lh, ph, oh, ll, pl, ol);
  TrendResult result;
  TestAssertTrue(ClassifyTrend(1.1060, 1.1055, 1.1000, lh, ph, oh, ll, pl, ol, 0.005, 0.015, result), "Exact normal threshold fixture valid");
  TestAssertInt((int)TREND_SIDEWAYS, (int)result.direction, "Exact 0.5 percent distance remains weak");
  TestAssertFalse(ClassifyTrend(0.0, 1.1200, 1.1000, lh, ph, oh, ll, pl, ol, 0.005, 0.015, result), "Non-positive close rejected");
  TestAssertFalse(ClassifyTrend(1.1300, 1.1200, 1.1000, lh, ph, oh, ll, pl, ol, -0.1, 0.015, result), "Negative normal threshold rejected");
  TestAssertFalse(ClassifyTrend(1.1300, 1.1200, 1.1000, lh, ph, oh, ll, pl, ol, 0.015, 0.015, result), "Non-increasing thresholds rejected");
  ph.time = 50;
  TestAssertFalse(ClassifyTrend(1.1300, 1.1200, 1.1000, lh, ph, oh, ll, pl, ol, 0.005, 0.015, result), "Out-of-order swings rejected");
}

void OnStart() {
  TestReset(); Print("[SUITE] TrendMathTestRunner started");
  TestDirectionalTrends(); TestWeakAndUnconfirmedStates(); TestThresholdsAndValidation();
  if(!TestSummary("TrendMathTestRunner")) Alert("TrendMathTestRunner FAILED. Review Experts log.");
}
