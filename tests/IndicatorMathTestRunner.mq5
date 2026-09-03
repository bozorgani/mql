#property script_show_inputs

#include <mql5/include/IndicatorMath.mqh>
#include "TestFramework.mqh"

void TestEMASeedAndProgression() {
  double rising[] = {1.0, 2.0, 3.0, 4.0, 5.0,
                     6.0, 7.0, 8.0, 9.0, 10.0};
  double result = 0.0;
  TestAssertTrue(CalculateEMA(rising, 3, result),
                 "EMA accepts a valid chronological series");
  TestAssertDouble(9.0, result, 0.00000001,
                   "EMA(3) uses an SMA seed and standard multiplier");

  double seedOnly[] = {10.0, 20.0, 30.0};
  TestAssertTrue(CalculateEMA(seedOnly, 3, result),
                 "EMA accepts exactly one seed window");
  TestAssertDouble(20.0, result, 0.00000001,
                   "EMA seed equals SMA of the first period");
}

void TestAppliedPriceMapping() {
  MqlRates rates[1];
  rates[0].open = 10.0;
  rates[0].high = 14.0;
  rates[0].low = 8.0;
  rates[0].close = 12.0;
  double prices[];

  TestAssertTrue(ExtractAppliedPrices(rates, PRICE_CLOSE, prices),
                 "Applied-price mapper accepts PRICE_CLOSE");
  TestAssertDouble(12.0, prices[0], 0.00000001, "PRICE_CLOSE maps to close");
  TestAssertTrue(ExtractAppliedPrices(rates, PRICE_OPEN, prices),
                 "Applied-price mapper accepts PRICE_OPEN");
  TestAssertDouble(10.0, prices[0], 0.00000001, "PRICE_OPEN maps to open");
  TestAssertTrue(ExtractAppliedPrices(rates, PRICE_HIGH, prices),
                 "Applied-price mapper accepts PRICE_HIGH");
  TestAssertDouble(14.0, prices[0], 0.00000001, "PRICE_HIGH maps to high");
  TestAssertTrue(ExtractAppliedPrices(rates, PRICE_LOW, prices),
                 "Applied-price mapper accepts PRICE_LOW");
  TestAssertDouble(8.0, prices[0], 0.00000001, "PRICE_LOW maps to low");
  TestAssertTrue(ExtractAppliedPrices(rates, PRICE_MEDIAN, prices),
                 "Applied-price mapper accepts PRICE_MEDIAN");
  TestAssertDouble(11.0, prices[0], 0.00000001, "PRICE_MEDIAN maps to HL/2");
  TestAssertTrue(ExtractAppliedPrices(rates, PRICE_TYPICAL, prices),
                 "Applied-price mapper accepts PRICE_TYPICAL");
  TestAssertDouble(11.3333333333, prices[0], 0.00000001,
                   "PRICE_TYPICAL maps to HLC/3");
  TestAssertTrue(ExtractAppliedPrices(rates, PRICE_WEIGHTED, prices),
                 "Applied-price mapper accepts PRICE_WEIGHTED");
  TestAssertDouble(11.5, prices[0], 0.00000001,
                   "PRICE_WEIGHTED maps to HLCC/4");
  TestAssertFalse(ExtractAppliedPrices(rates, (ENUM_APPLIED_PRICE)99, prices),
                  "Applied-price mapper rejects unknown values");
  TestAssertInt(0, ArraySize(prices),
                "Rejected applied price clears the output array");
}

void TestEMAValidation() {
  double shortSeries[] = {1.0, 2.0};
  double invalidPrice[] = {1.0, 0.0, 3.0};
  double result = 123.0;

  TestAssertFalse(CalculateEMA(shortSeries, 3, result),
                  "EMA rejects insufficient warm-up data");
  TestAssertDouble(0.0, result, 0.0,
                   "EMA clears output after validation failure");
  TestAssertFalse(CalculateEMA(invalidPrice, 3, result),
                  "EMA rejects non-positive prices");
  TestAssertFalse(CalculateEMA(invalidPrice, 0, result),
                  "EMA rejects a non-positive period");
}

void TestTrueRange() {
  double result = 0.0;
  TestAssertTrue(CalculateTrueRange(15.0, 13.0, 10.0, result),
                 "True Range accepts a valid gap-up bar");
  TestAssertDouble(5.0, result, 0.00000001,
                   "True Range includes the previous-close gap");
  TestAssertFalse(CalculateTrueRange(9.0, 10.0, 9.5, result),
                  "True Range rejects high below low");
}

void TestWilderATR() {
  double highs[] = {10.0, 11.0, 15.0, 16.0};
  double lows[] = {8.0, 9.0, 13.0, 14.0};
  double closes[] = {9.0, 10.0, 14.0, 15.0};
  double result = 0.0;

  TestAssertTrue(CalculateWilderATR(highs, lows, closes, 3, result),
                 "Wilder ATR accepts aligned OHLC fixtures");
  TestAssertDouble(2.6666666667, result, 0.00000001,
                   "Wilder ATR applies gap-aware smoothing");

  double flatHighs[] = {11.0, 11.0, 11.0};
  double flatLows[] = {9.0, 9.0, 9.0};
  double flatCloses[] = {10.0, 10.0, 10.0};
  TestAssertTrue(CalculateWilderATR(flatHighs, flatLows, flatCloses, 3, result),
                 "Wilder ATR accepts an exact warm-up window");
  TestAssertDouble(2.0, result, 0.00000001,
                   "Constant ranges produce a constant ATR");
}

void TestATRValidation() {
  double highs[] = {10.0, 11.0, 12.0};
  double lows[] = {8.0, 9.0};
  double closes[] = {9.0, 10.0, 11.0};
  double result = 123.0;

  TestAssertFalse(CalculateWilderATR(highs, lows, closes, 2, result),
                  "ATR rejects arrays with different lengths");
  TestAssertDouble(0.0, result, 0.0,
                   "ATR clears output after validation failure");

  double invalidHighs[] = {10.0, 8.0, 12.0};
  double invalidLows[] = {8.0, 9.0, 10.0};
  TestAssertFalse(CalculateWilderATR(invalidHighs, invalidLows, closes, 2, result),
                  "ATR rejects a high below its low");
  TestAssertFalse(CalculateWilderATR(highs, highs, closes, 0, result),
                  "ATR rejects a non-positive period");
}

void OnStart() {
  TestReset();
  Print("[SUITE] IndicatorMathTestRunner started");
  TestEMASeedAndProgression();
  TestAppliedPriceMapping();
  TestEMAValidation();
  TestTrueRange();
  TestWilderATR();
  TestATRValidation();

  if(!TestSummary("IndicatorMathTestRunner"))
    Alert("IndicatorMathTestRunner FAILED. Review Experts log.");
}
