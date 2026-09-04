// SPR1-006 Configuration Loader — platform config only
// SPR6-007 — Authorized frozen configuration contract (SPR6-006G decision).
// ConfigSystem is the sole configuration source/data owner for Sprint 6.

#include <mql5/include/CommonTypes.mqh>

// ---------------------------------------------------------------------------
// Authorized Sprint 6 indicator configuration values (SPR6-006G decision).
// These constants are the single auditable representation of the approved
// values: EMA period 50, EMA applied price PRICE_CLOSE (0), ATR period 14.
// Strategy documentation, test fixtures, and engine private initializers are
// NOT configuration sources (per SPR6-006C..006G).
// ---------------------------------------------------------------------------
const int CONFIG_EMA_PERIOD = 50;
const int CONFIG_EMA_SLOW_PERIOD = 200;
const int CONFIG_EMA_APPLIED_PRICE = 0; // PRICE_CLOSE (MQL ENUM_APPLIED_PRICE)
const int CONFIG_ATR_PERIOD = 14;
const ENUM_TIMEFRAMES CONFIG_TREND_TIMEFRAME = PERIOD_H4;
const ENUM_TIMEFRAMES CONFIG_ENTRY_TIMEFRAME = PERIOD_H1;
const ENUM_TIMEFRAMES CONFIG_ATR_TIMEFRAME = PERIOD_H1;
const int CONFIG_HISTORY_MULTIPLIER = 10;
const double CONFIG_TREND_NORMAL_DISTANCE_RATIO = 0.005;
const double CONFIG_TREND_STRONG_DISTANCE_RATIO = 0.015;
const double CONFIG_DOJI_BODY_RATIO = 0.10;
const double CONFIG_PIN_MAX_BODY_RATIO = 0.30;
const double CONFIG_PIN_MIN_WICK_TO_BODY = 2.0;
const double CONFIG_PATTERN_EXTREME_CLOSE_RATIO = 0.25;
const double CONFIG_FIB_MINIMUM_IMPULSE_RATIO = 0.03;
const double CONFIG_FIB_ZONE_TOLERANCE_RATIO = 0.0015;
const double CONFIG_FIB_INVALIDATION_RATIO = 0.005;
const int CONFIG_FIB_MAX_AGE_BARS = 40;

// ---------------------------------------------------------------------------
// Typed indicator configuration record — approved transport shape (Option A).
// Populated by ConfigInit(); validated by ConfigValidator; applied by
// IndicatorManager through the frozen EMAConfigure/ATRConfigure interfaces.
// ---------------------------------------------------------------------------
struct IndicatorConfig {
  int emaPeriod;
  int emaSlowPeriod;
  int emaAppliedPrice; // MQL ENUM_APPLIED_PRICE domain (0..6)
  int atrPeriod;
  ENUM_TIMEFRAMES trendTimeframe;
  ENUM_TIMEFRAMES entryTimeframe;
  ENUM_TIMEFRAMES atrTimeframe;
  int historyMultiplier;
  double trendNormalDistanceRatio;
  double trendStrongDistanceRatio;
};

IndicatorConfig indicatorConfig;

struct PriceActionConfig {
  double dojiBodyRatio;
  double pinMaximumBodyRatio;
  double pinMinimumWickToBody;
  double extremeCloseRatio;
  double fibonacciMinimumImpulseRatio;
  double fibonacciZoneToleranceRatio;
  double fibonacciInvalidationRatio;
  int fibonacciMaximumAgeBars;
};
PriceActionConfig priceActionConfig;

int ConfigInit() {
  indicatorConfig.emaPeriod = CONFIG_EMA_PERIOD;
  indicatorConfig.emaSlowPeriod = CONFIG_EMA_SLOW_PERIOD;
  indicatorConfig.emaAppliedPrice = CONFIG_EMA_APPLIED_PRICE;
  indicatorConfig.atrPeriod = CONFIG_ATR_PERIOD;
  indicatorConfig.trendTimeframe = CONFIG_TREND_TIMEFRAME;
  indicatorConfig.entryTimeframe = CONFIG_ENTRY_TIMEFRAME;
  indicatorConfig.atrTimeframe = CONFIG_ATR_TIMEFRAME;
  indicatorConfig.historyMultiplier = CONFIG_HISTORY_MULTIPLIER;
  indicatorConfig.trendNormalDistanceRatio = CONFIG_TREND_NORMAL_DISTANCE_RATIO;
  indicatorConfig.trendStrongDistanceRatio = CONFIG_TREND_STRONG_DISTANCE_RATIO;
  priceActionConfig.dojiBodyRatio = CONFIG_DOJI_BODY_RATIO;
  priceActionConfig.pinMaximumBodyRatio = CONFIG_PIN_MAX_BODY_RATIO;
  priceActionConfig.pinMinimumWickToBody = CONFIG_PIN_MIN_WICK_TO_BODY;
  priceActionConfig.extremeCloseRatio = CONFIG_PATTERN_EXTREME_CLOSE_RATIO;
  priceActionConfig.fibonacciMinimumImpulseRatio = CONFIG_FIB_MINIMUM_IMPULSE_RATIO;
  priceActionConfig.fibonacciZoneToleranceRatio = CONFIG_FIB_ZONE_TOLERANCE_RATIO;
  priceActionConfig.fibonacciInvalidationRatio = CONFIG_FIB_INVALIDATION_RATIO;
  priceActionConfig.fibonacciMaximumAgeBars = CONFIG_FIB_MAX_AGE_BARS;
  return INIT_SUCCEEDED;
}

bool ConfigLoad() { return true; } // authorized values are compile-time constants; no external payload exists

bool ConfigValidate() { return (ValidateConfiguration() == VAL_OK); }

bool ConfigStatus() { return ConfigValidate(); }
