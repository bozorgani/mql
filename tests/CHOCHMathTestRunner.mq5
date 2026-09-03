#property script_show_inputs

#include <mql5/include/StructureMath.mqh>
#include "TestFramework.mqh"

void SetCHOCHSwing(SwingPoint &point, SwingType type, double price, datetime time) {
  point.type = type; point.price = price; point.time = time;
}

void BearishFixture(SwingPoint &latestHigh, SwingPoint &previousHigh,
                    SwingPoint &olderHigh, SwingPoint &latestLow,
                    SwingPoint &previousLow, SwingPoint &olderLow) {
  SetCHOCHSwing(olderHigh, SWING_HIGH, 1.1000, 100);
  SetCHOCHSwing(olderLow, SWING_LOW, 1.0800, 200);
  SetCHOCHSwing(previousHigh, SWING_HIGH, 1.1100, 300);
  SetCHOCHSwing(previousLow, SWING_LOW, 1.0900, 400);
  SetCHOCHSwing(latestLow, SWING_LOW, 1.0950, 500);
  SetCHOCHSwing(latestHigh, SWING_HIGH, 1.1050, 600);
}

void BullishFixture(SwingPoint &latestHigh, SwingPoint &previousHigh,
                    SwingPoint &olderHigh, SwingPoint &latestLow,
                    SwingPoint &previousLow, SwingPoint &olderLow) {
  SetCHOCHSwing(olderHigh, SWING_HIGH, 1.1100, 100);
  SetCHOCHSwing(olderLow, SWING_LOW, 1.0900, 200);
  SetCHOCHSwing(previousHigh, SWING_HIGH, 1.1000, 300);
  SetCHOCHSwing(previousLow, SWING_LOW, 1.0800, 400);
  SetCHOCHSwing(latestHigh, SWING_HIGH, 1.0950, 500);
  SetCHOCHSwing(latestLow, SWING_LOW, 1.0850, 600);
}

void TestBearishCHOCH() {
  SwingPoint lh, ph, oh, ll, pl, ol; BearishFixture(lh, ph, oh, ll, pl, ol);
  CHOCHResult result;
  TestAssertTrue(DetectChangeOfCharacter(1.0940, 700, lh, ph, oh, ll, pl, ol, 0.0, result), "Bearish fixture valid");
  TestAssertInt((int)CHOCH_BEARISH, (int)result.direction, "Bullish structure plus lower high and low break confirms bearish CHOCH");
  TestAssertDouble(1.0950, result.level, 0.00000001, "Broken protected low retained");
  TestAssertDouble(1.0940, result.closePrice, 0.00000001, "Confirmation close retained");
  TestAssertInt(600, (int)result.transitionSwingTime, "Lower-high transition retained");
  TestAssertInt((int)STRUCTURE_BIAS_BULLISH, (int)result.previousBias, "Previous bullish bias retained");
}

void TestBullishCHOCH() {
  SwingPoint lh, ph, oh, ll, pl, ol; BullishFixture(lh, ph, oh, ll, pl, ol);
  CHOCHResult result;
  TestAssertTrue(DetectChangeOfCharacter(1.0960, 700, lh, ph, oh, ll, pl, ol, 0.0, result), "Bullish fixture valid");
  TestAssertInt((int)CHOCH_BULLISH, (int)result.direction, "Bearish structure plus higher low and high break confirms bullish CHOCH");
  TestAssertDouble(1.0950, result.level, 0.00000001, "Broken protected high retained");
  TestAssertInt((int)STRUCTURE_BIAS_BEARISH, (int)result.previousBias, "Previous bearish bias retained");
}

void TestBoundariesAndTransition() {
  SwingPoint lh, ph, oh, ll, pl, ol; BearishFixture(lh, ph, oh, ll, pl, ol);
  CHOCHResult result;
  TestAssertTrue(DetectChangeOfCharacter(1.0950, 700, lh, ph, oh, ll, pl, ol, 0.0, result), "Equality fixture valid");
  TestAssertInt((int)CHOCH_NONE, (int)result.direction, "Level equality is not CHOCH");
  TestAssertTrue(DetectChangeOfCharacter(1.0940, 700, lh, ph, oh, ll, pl, ol, 0.0020, result), "Buffer fixture valid");
  TestAssertInt((int)CHOCH_NONE, (int)result.direction, "Break inside buffer is not CHOCH");
  lh.price = ph.price;
  TestAssertTrue(DetectChangeOfCharacter(1.0920, 700, lh, ph, oh, ll, pl, ol, 0.0, result), "Transition fixture valid");
  TestAssertInt((int)CHOCH_NONE, (int)result.direction, "No lower high means no bearish CHOCH");
}

void TestChronologyAndValidation() {
  SwingPoint lh, ph, oh, ll, pl, ol; BullishFixture(lh, ph, oh, ll, pl, ol);
  CHOCHResult result;
  TestAssertTrue(DetectChangeOfCharacter(1.0960, 550, lh, ph, oh, ll, pl, ol, 0.0, result), "Chronology fixture valid");
  TestAssertInt((int)CHOCH_NONE, (int)result.direction, "Close before transition confirmation rejected");
  TestAssertFalse(DetectChangeOfCharacter(0.0, 700, lh, ph, oh, ll, pl, ol, 0.0, result), "Non-positive close rejected");
  TestAssertFalse(DetectChangeOfCharacter(1.0960, 700, lh, ph, oh, ll, pl, ol, -0.0001, result), "Negative buffer rejected");
  lh.type = SWING_LOW;
  TestAssertFalse(DetectChangeOfCharacter(1.0960, 700, lh, ph, oh, ll, pl, ol, 0.0, result), "Mismatched swing type rejected");
  BullishFixture(lh, ph, oh, ll, pl, ol);
  ph.time = 50;
  TestAssertFalse(DetectChangeOfCharacter(1.0960, 700, lh, ph, oh, ll, pl, ol, 0.0, result), "Out-of-order swing history rejected");
}

void OnStart() {
  TestReset(); Print("[SUITE] CHOCHMathTestRunner started");
  TestBearishCHOCH(); TestBullishCHOCH(); TestBoundariesAndTransition(); TestChronologyAndValidation();
  if(!TestSummary("CHOCHMathTestRunner")) Alert("CHOCHMathTestRunner FAILED. Review Experts log.");
}
