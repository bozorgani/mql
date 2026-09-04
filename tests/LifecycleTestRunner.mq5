#property script_show_inputs

// Deterministic contract/lifecycle suite.
// It intentionally excludes candle-dependent calculations and unfinished
// strategy, risk, and execution behavior.

#include <mql5/modules/ConfigSystem.mq5>
#include <mql5/modules/ConfigValidator.mq5>
#include <mql5/modules/LoggerCore.mq5>
#include <mql5/modules/LoggerFile.mq5>
#include <mql5/modules/TimeService.mq5>
#include <mql5/modules/MarketData.mq5>
#include <mql5/modules/SymbolInfoService.mq5>
#include <mql5/modules/EMAEngine.mq5>
#include <mql5/modules/ATREngine.mq5>
#include <mql5/modules/IndicatorManager.mq5>
#include <mql5/modules/SwingDetector.mq5>
#include <mql5/modules/SwingStorage.mq5>
#include <mql5/modules/BOSDetector.mq5>
#include <mql5/modules/CHOCHDetector.mq5>
#include <mql5/modules/TrendEngine.mq5>
#include <mql5/modules/StructureManager.mq5>
#include <mql5/modules/CandleClassifier.mq5>
#include <mql5/modules/EngulfingDetector.mq5>
#include <mql5/modules/PinBarDetector.mq5>
#include <mql5/modules/InsideBarDetector.mq5>
#include <mql5/modules/OutsideBarDetector.mq5>
#include <mql5/modules/FibonacciEngine.mq5>
#include <mql5/modules/RetracementDetector.mq5>
#include <mql5/modules/ConfluenceManager.mq5>
#include <mql5/modules/PriceActionManager.mq5>
#include "TestFramework.mqh"

void TestConfigurationContract() {
  TestAssertInt(INIT_SUCCEEDED, ConfigInit(), "ConfigInit returns INIT_SUCCEEDED");
  TestAssertTrue(ConfigLoad(), "ConfigLoad succeeds for frozen constants");
  TestAssertTrue(ConfigStatus(), "Authorized configuration validates");
  TestAssertInt(50, indicatorConfig.emaPeriod, "EMA period is 50");
  TestAssertInt(200, indicatorConfig.emaSlowPeriod, "Slow EMA period is 200");
  TestAssertInt(0, indicatorConfig.emaAppliedPrice, "EMA applied price is PRICE_CLOSE");
  TestAssertInt(14, indicatorConfig.atrPeriod, "ATR period is 14");
  TestAssertInt((int)PERIOD_H4, (int)indicatorConfig.trendTimeframe,
                "Trend timeframe is H4");
  TestAssertInt((int)PERIOD_H1, (int)indicatorConfig.entryTimeframe,
                "Entry timeframe is H1");
  TestAssertInt((int)PERIOD_H1, (int)indicatorConfig.atrTimeframe,
                "ATR timeframe is H1");
  TestAssertInt(10, indicatorConfig.historyMultiplier,
                "History warm-up multiplier is 10");
  TestAssertDouble(0.005, indicatorConfig.trendNormalDistanceRatio, 0.0,
                   "Normal trend-distance threshold is 0.5 percent");
  TestAssertDouble(0.015, indicatorConfig.trendStrongDistanceRatio, 0.0,
                   "Strong trend-distance threshold is 1.5 percent");
  TestAssertDouble(0.10, priceActionConfig.dojiBodyRatio, 0.0,
                   "Doji body threshold is configured");
  TestAssertDouble(0.30, priceActionConfig.pinMaximumBodyRatio, 0.0,
                   "Pin-bar body threshold is configured");
  TestAssertDouble(2.0, priceActionConfig.pinMinimumWickToBody, 0.0,
                   "Pin-bar wick multiple is configured");
  TestAssertDouble(0.25, priceActionConfig.extremeCloseRatio, 0.0,
                   "Extreme-close threshold is configured");

  indicatorConfig.emaPeriod = 0;
  TestAssertFalse(ConfigStatus(), "Zero EMA period is rejected");
  ConfigInit();

  indicatorConfig.atrPeriod = -1;
  TestAssertFalse(ConfigStatus(), "Negative ATR period is rejected");
  ConfigInit();

  indicatorConfig.emaAppliedPrice = 7;
  TestAssertFalse(ConfigStatus(), "Out-of-range applied price is rejected");
  ConfigInit();

  indicatorConfig.emaSlowPeriod = indicatorConfig.emaPeriod;
  TestAssertFalse(ConfigStatus(), "Slow EMA must be greater than fast EMA");
  ConfigInit();

  indicatorConfig.historyMultiplier = 0;
  TestAssertFalse(ConfigStatus(), "Zero history multiplier is rejected");
  ConfigInit();

  indicatorConfig.trendNormalDistanceRatio = -0.001;
  TestAssertFalse(ConfigStatus(), "Negative normal trend threshold is rejected");
  ConfigInit();

  indicatorConfig.trendStrongDistanceRatio = indicatorConfig.trendNormalDistanceRatio;
  TestAssertFalse(ConfigStatus(), "Strong trend threshold must exceed normal threshold");
  ConfigInit();

  priceActionConfig.extremeCloseRatio = 0.5;
  TestAssertFalse(ConfigStatus(), "Extreme-close ratio must remain below half-range");
  ConfigInit();
}

void TestLoggerLifecycle() {
  LoggerShutdown();
  LoggerFileShutdown();
  TestAssertFalse(LoggerStatus(), "Logger starts stopped");
  TestAssertFalse(LogFileStatus(), "Log file starts closed");

  LoggerInit();
  TestAssertTrue(LoggerStatus(), "Logger initializes");
  SetLogLevel(LOG_WARNING);
  TestAssertInt(LOG_WARNING, GetLogLevel(), "Logger level round-trips");
  TestAssertTrue(LoggerFileInit(), "Log file initializes");
  TestAssertTrue(LogFileStatus(), "Log file reports open");

  LoggerFileShutdown();
  LoggerShutdown();
  TestAssertFalse(LogFileStatus(), "Log file shuts down");
  TestAssertFalse(LoggerStatus(), "Logger shuts down");
}

void TestIndicatorLifecycle() {
  ConfigInit();
  IndicatorManagerShutdown();
  TestAssertFalse(IndicatorManagerStatus(), "Indicator manager starts stopped");
  TestAssertTrue(IndicatorManagerInit(), "Indicator manager initializes children");
  TestAssertTrue(IndicatorManagerStatus(), "Indicator manager reports initialized");
  TestAssertTrue(EMAReady(), "EMA is configured and ready");
  TestAssertTrue(ATRReady(), "ATR is configured and ready");
  TestAssertInt(50, emaPeriod, "Indicator manager applies EMA50");
  TestAssertInt(200, emaSlowPeriod, "Indicator manager applies EMA200");
  TestAssertInt((int)PERIOD_H4, (int)emaTimeframe,
                "Indicator manager applies H4 to EMA");
  TestAssertInt((int)PERIOD_H1, (int)atrTimeframe,
                "Indicator manager applies H1 to ATR");
  IndicatorManagerShutdown();
  TestAssertFalse(IndicatorManagerStatus(), "Indicator manager shuts down");
  TestAssertFalse(EMAStatus(), "EMA shuts down");
  TestAssertFalse(ATRStatus(), "ATR shuts down");
}

void TestStructureLifecycle() {
  StructureManagerShutdown();
  TestAssertFalse(StructureManagerStatus(), "Structure manager starts stopped");
  TestAssertTrue(StructureManagerInit(), "Structure manager initializes children");
  TestAssertTrue(StructureManagerStatus(), "Structure manager reports initialized");
  TestAssertTrue(SwingStatus(), "Swing detector initializes");
  TestAssertTrue(SwingStorageStatus(), "Swing storage initializes");
  TestAssertTrue(BOSStatus(), "BOS detector initializes");
  TestAssertTrue(CHOCHStatus(), "CHOCH detector initializes");
  TestAssertTrue(TrendStatus(), "Trend engine initializes");
  StructureManagerShutdown();
  TestAssertFalse(StructureManagerStatus(), "Structure manager shuts down");
  TestAssertFalse(SwingStatus(), "Swing detector shuts down");
  TestAssertFalse(SwingStorageStatus(), "Swing storage shuts down");
  TestAssertFalse(BOSStatus(), "BOS detector shuts down");
  TestAssertFalse(CHOCHStatus(), "CHOCH detector shuts down");
  TestAssertFalse(TrendStatus(), "Trend engine shuts down");
}

void TestPriceActionLifecycle() {
  PriceActionManagerShutdown();
  TestAssertFalse(PriceActionManagerStatus(), "Price-action manager starts stopped");
  TestAssertTrue(PriceActionManagerInit(), "Price-action manager initializes children");
  TestAssertTrue(PriceActionManagerStatus(), "Price-action manager reports initialized");
  TestAssertTrue(CandleClassifierStatus(), "Candle classifier initializes");
  TestAssertTrue(EngulfingStatus(), "Engulfing detector initializes");
  TestAssertTrue(PinBarStatus(), "Pin-bar detector initializes");
  TestAssertTrue(InsideBarStatus(), "Inside-bar detector initializes");
  TestAssertTrue(OutsideBarStatus(), "Outside-bar detector initializes");
  TestAssertTrue(FibonacciStatus(), "Fibonacci engine initializes");
  TestAssertTrue(RetracementStatus(), "Retracement detector initializes");
  TestAssertTrue(ConfluenceStatus(), "Confluence manager initializes");
  TestAssertTrue(candleClassifierConfigured, "Candle classifier receives configuration");
  TestAssertTrue(engulfingConfigured, "Engulfing detector receives configuration");
  TestAssertTrue(pinBarConfigured, "Pin-bar detector receives configuration");
  TestAssertTrue(insideBarConfigured, "Inside-bar detector receives configuration");
  TestAssertTrue(outsideBarConfigured, "Outside-bar detector receives configuration");
  PriceActionManagerShutdown();
  TestAssertFalse(PriceActionManagerStatus(), "Price-action manager shuts down");
  TestAssertFalse(CandleClassifierStatus(), "Candle classifier shuts down");
  TestAssertFalse(EngulfingStatus(), "Engulfing detector shuts down");
  TestAssertFalse(PinBarStatus(), "Pin-bar detector shuts down");
  TestAssertFalse(InsideBarStatus(), "Inside-bar detector shuts down");
  TestAssertFalse(OutsideBarStatus(), "Outside-bar detector shuts down");
  TestAssertFalse(FibonacciStatus(), "Fibonacci engine shuts down");
  TestAssertFalse(RetracementStatus(), "Retracement detector shuts down");
  TestAssertFalse(ConfluenceStatus(), "Confluence manager shuts down");
}

void TestTimeUtilities() {
  datetime sample = StringToTime("2026.09.03 14:25:30");
  TestAssertTrue(IsValidTimestamp(sample), "Known timestamp is valid");
  TestAssertTrue(IsSameDay(sample, sample + 60), "Same-day comparison succeeds");
  TestAssertFalse(IsSameDay(sample, sample + 86400), "Different day is detected");
  TestAssertTrue(IsSameHour(sample, sample + 60), "Same-hour comparison succeeds");
  TestAssertFalse(IsSameHour(sample, sample + 3600), "Different hour is detected");
  TestAssertInt(60, (int)SecondsBetween(sample + 60, sample), "SecondsBetween is deterministic");
}

void OnStart() {
  TestReset();
  Print("[SUITE] LifecycleTestRunner started");
  TestConfigurationContract();
  TestLoggerLifecycle();
  TestIndicatorLifecycle();
  TestStructureLifecycle();
  TestPriceActionLifecycle();
  TestTimeUtilities();

  if(!TestSummary("LifecycleTestRunner"))
    Alert("LifecycleTestRunner FAILED. Review Experts log.");
}
