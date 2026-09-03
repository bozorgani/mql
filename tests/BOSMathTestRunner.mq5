#property script_show_inputs

#include <mql5/include/StructureMath.mqh>
#include "TestFramework.mqh"

void BuildSwingFixtures(SwingPoint &highPoint, SwingPoint &lowPoint) {
  highPoint.type = SWING_HIGH;
  highPoint.price = 1.1000;
  highPoint.time = 100;
  lowPoint.type = SWING_LOW;
  lowPoint.price = 1.0900;
  lowPoint.time = 200;
}

void TestBullishBOS() {
  SwingPoint highPoint;
  SwingPoint lowPoint;
  BuildSwingFixtures(highPoint, lowPoint);
  BOSResult result;
  TestAssertTrue(ConfirmBreakOfStructure(1.1010, 300, STRUCTURE_BIAS_BULLISH,
                                         highPoint, lowPoint, 0.0, result),
                 "Bullish BOS fixture is valid");
  TestAssertInt((int)BOS_BULLISH, (int)result.direction,
                "Close above swing high confirms bullish BOS");
  TestAssertDouble(1.1000, result.level, 0.00000001,
                   "Bullish BOS retains broken swing level");
  TestAssertDouble(1.1010, result.closePrice, 0.00000001,
                   "Bullish BOS retains confirmation close");
  TestAssertInt(100, (int)result.sourceSwingTime,
                "Bullish BOS references source swing");
}

void TestBearishBOS() {
  SwingPoint highPoint;
  SwingPoint lowPoint;
  BuildSwingFixtures(highPoint, lowPoint);
  BOSResult result;
  TestAssertTrue(ConfirmBreakOfStructure(1.0890, 300, STRUCTURE_BIAS_BEARISH,
                                         highPoint, lowPoint, 0.0, result),
                 "Bearish BOS fixture is valid");
  TestAssertInt((int)BOS_BEARISH, (int)result.direction,
                "Close below swing low confirms bearish BOS");
  TestAssertDouble(1.0900, result.level, 0.00000001,
                   "Bearish BOS retains broken swing level");
}

void TestCloseAndBufferRules() {
  SwingPoint highPoint;
  SwingPoint lowPoint;
  BuildSwingFixtures(highPoint, lowPoint);
  BOSResult result;
  TestAssertTrue(DetectBreakOfStructure(1.1000, 300, true, highPoint,
                                        true, lowPoint, 0.0, result),
                 "Equality fixture is valid");
  TestAssertInt((int)BOS_NONE, (int)result.direction,
                "Close equal to swing level is not a BOS");
  TestAssertTrue(DetectBreakOfStructure(1.1010, 300, true, highPoint,
                                        true, lowPoint, 0.0020, result),
                 "Buffered fixture is valid");
  TestAssertInt((int)BOS_NONE, (int)result.direction,
                "Close inside configured buffer is not a BOS");
  TestAssertTrue(DetectBreakOfStructure(1.1030, 300, true, highPoint,
                                        true, lowPoint, 0.0020, result),
                 "Close beyond buffer fixture is valid");
  TestAssertInt((int)BOS_BULLISH, (int)result.direction,
                "Close beyond configured buffer confirms BOS");
}

void TestOneSidedHistory() {
  SwingPoint highPoint;
  SwingPoint lowPoint;
  BuildSwingFixtures(highPoint, lowPoint);
  BOSResult result;
  TestAssertTrue(DetectBreakOfStructure(1.1010, 300, true, highPoint,
                                        false, lowPoint, 0.0, result),
                 "BOS accepts history containing only a swing high");
  TestAssertInt((int)BOS_BULLISH, (int)result.direction,
                "One-sided high history can confirm bullish BOS");
  TestAssertTrue(DetectBreakOfStructure(1.0890, 300, false, highPoint,
                                        true, lowPoint, 0.0, result),
                 "BOS accepts history containing only a swing low");
  TestAssertInt((int)BOS_BEARISH, (int)result.direction,
                "One-sided low history can confirm bearish BOS");
}

void TestStructureBiasAndDirectionGate() {
  SwingPoint previousHigh;
  SwingPoint latestHigh;
  SwingPoint previousLow;
  SwingPoint latestLow;
  previousHigh.type = SWING_HIGH; previousHigh.price = 1.1000; previousHigh.time = 100;
  latestHigh.type = SWING_HIGH; latestHigh.price = 1.1100; latestHigh.time = 300;
  previousLow.type = SWING_LOW; previousLow.price = 1.0900; previousLow.time = 200;
  latestLow.type = SWING_LOW; latestLow.price = 1.0950; latestLow.time = 400;
  TestAssertInt((int)STRUCTURE_BIAS_BULLISH,
                (int)InferStructureBias(latestHigh, previousHigh, latestLow, previousLow),
                "HH plus HL establishes bullish structure");
  BOSResult result;
  TestAssertTrue(ConfirmBreakOfStructure(1.0940, 500, STRUCTURE_BIAS_BULLISH,
                                         latestHigh, latestLow, 0.0, result),
                 "Opposite-break fixture is valid");
  TestAssertInt((int)BOS_NONE, (int)result.direction,
                "Break against bullish structure is not mislabeled BOS");

  latestHigh.price = 1.0900;
  latestLow.price = 1.0800;
  TestAssertInt((int)STRUCTURE_BIAS_BEARISH,
                (int)InferStructureBias(latestHigh, previousHigh, latestLow, previousLow),
                "LH plus LL establishes bearish structure");
  TestAssertTrue(ConfirmBreakOfStructure(1.0910, 500, STRUCTURE_BIAS_BEARISH,
                                         latestHigh, latestLow, 0.0, result),
                 "Opposite bullish-break fixture is valid");
  TestAssertInt((int)BOS_NONE, (int)result.direction,
                "Break against bearish structure is not mislabeled BOS");
}

void TestBOSValidation() {
  SwingPoint highPoint;
  SwingPoint lowPoint;
  BuildSwingFixtures(highPoint, lowPoint);
  BOSResult result;
  TestAssertFalse(DetectBreakOfStructure(0.0, 300, true, highPoint,
                                         true, lowPoint, 0.0, result),
                  "BOS rejects non-positive close");
  TestAssertFalse(DetectBreakOfStructure(1.1010, 0, true, highPoint,
                                         true, lowPoint, 0.0, result),
                  "BOS rejects invalid close time");
  TestAssertFalse(DetectBreakOfStructure(1.1010, 300, true, highPoint,
                                         true, lowPoint, -0.0001, result),
                  "BOS rejects negative break buffer");
  highPoint.type = SWING_LOW;
  TestAssertFalse(DetectBreakOfStructure(1.1010, 300, true, highPoint,
                                         true, lowPoint, 0.0, result),
                  "BOS rejects mismatched swing-high type");
}

void OnStart() {
  TestReset();
  Print("[SUITE] BOSMathTestRunner started");
  TestBullishBOS();
  TestBearishBOS();
  TestCloseAndBufferRules();
  TestOneSidedHistory();
  TestStructureBiasAndDirectionGate();
  TestBOSValidation();
  if(!TestSummary("BOSMathTestRunner"))
    Alert("BOSMathTestRunner FAILED. Review Experts log.");
}
