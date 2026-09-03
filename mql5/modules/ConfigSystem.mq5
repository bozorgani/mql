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
const int CONFIG_EMA_APPLIED_PRICE = 0; // PRICE_CLOSE (MQL ENUM_APPLIED_PRICE)
const int CONFIG_ATR_PERIOD = 14;

// ---------------------------------------------------------------------------
// Typed indicator configuration record — approved transport shape (Option A).
// Populated by ConfigInit(); validated by ConfigValidator; applied by
// IndicatorManager through the frozen EMAConfigure/ATRConfigure interfaces.
// ---------------------------------------------------------------------------
struct IndicatorConfig {
  int emaPeriod;
  int emaAppliedPrice; // MQL ENUM_APPLIED_PRICE domain (0..6)
  int atrPeriod;
};

IndicatorConfig indicatorConfig;

int ConfigInit() {
  indicatorConfig.emaPeriod = CONFIG_EMA_PERIOD;
  indicatorConfig.emaAppliedPrice = CONFIG_EMA_APPLIED_PRICE;
  indicatorConfig.atrPeriod = CONFIG_ATR_PERIOD;
  return INIT_SUCCEEDED;
}

bool ConfigLoad() { return true; } // authorized values are compile-time constants; no external payload exists

bool ConfigValidate() { return (ValidateConfiguration() == VAL_OK); }

bool ConfigStatus() { return ConfigValidate(); }
