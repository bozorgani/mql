#ifndef MQL5_CONFIG_VALIDATOR_MQ5
#define MQL5_CONFIG_VALIDATOR_MQ5
#include <mql5/include/CommonTypes.mqh>

ValidationResult ValidateRequired(string v){ return v!="" ? VAL_OK : VAL_FAIL; }
ValidationResult ValidateRange(double v,double mn,double mx){ return (v>=mn && v<=mx) ? VAL_OK : VAL_FAIL; }
ValidationResult ValidatePositive(double v){ return v>0 ? VAL_OK : VAL_FAIL; }
ValidationResult ValidateNonNegative(double v){ return v>=0 ? VAL_OK : VAL_FAIL; }
ValidationResult ValidateStringLength(string s,int maxLen){ return StringLen(s)<=maxLen ? VAL_OK : VAL_FAIL; }
ValidationResult ValidateNotEmpty(string s){ return s!="" ? VAL_OK : VAL_FAIL; }
ValidationResult ValidateEnumValue(int v,int min,int max){ return (v>=min && v<=max) ? VAL_OK : VAL_FAIL; }
// TODO deferred to Sprint 5/6: real duplicate detection requires trade/module context
ValidationResult ValidateDuplicate(string s){ return VAL_PENDING; }
// TODO deferred to Sprint 3/4: consistency requires structure/Trend state
ValidationResult ValidateConsistency(string s){ return VAL_PENDING; }
// SPR6-007: Sprint 6 indicator configuration contract validation (authorized).
// Validates the ConfigSystem-owned record: EMA period > 0, ATR period > 0,
// EMA applied price within MQL ENUM_APPLIED_PRICE domain (0..6).
// Strategy parameters remain deferred to a future strategy configuration layer.
ValidationResult ValidateConfiguration(){
  if(ValidatePositive(indicatorConfig.emaPeriod) != VAL_OK) return VAL_FAIL;
  if(ValidatePositive(indicatorConfig.emaSlowPeriod) != VAL_OK) return VAL_FAIL;
  if(indicatorConfig.emaSlowPeriod <= indicatorConfig.emaPeriod) return VAL_FAIL;
  if(ValidatePositive(indicatorConfig.atrPeriod) != VAL_OK) return VAL_FAIL;
  if(ValidateEnumValue(indicatorConfig.emaAppliedPrice, 0, 6) != VAL_OK) return VAL_FAIL;
  if(PeriodSeconds(indicatorConfig.trendTimeframe) <= 0) return VAL_FAIL;
  if(PeriodSeconds(indicatorConfig.entryTimeframe) <= 0) return VAL_FAIL;
  if(PeriodSeconds(indicatorConfig.atrTimeframe) <= 0) return VAL_FAIL;
  if(ValidatePositive(indicatorConfig.historyMultiplier) != VAL_OK) return VAL_FAIL;
  if(!MathIsValidNumber(indicatorConfig.trendNormalDistanceRatio) ||
     indicatorConfig.trendNormalDistanceRatio < 0.0) return VAL_FAIL;
  if(!MathIsValidNumber(indicatorConfig.trendStrongDistanceRatio) ||
     indicatorConfig.trendStrongDistanceRatio <= indicatorConfig.trendNormalDistanceRatio) return VAL_FAIL;
  if(!MathIsValidNumber(priceActionConfig.dojiBodyRatio) ||
     priceActionConfig.dojiBodyRatio < 0.0 || priceActionConfig.dojiBodyRatio >= 1.0) return VAL_FAIL;
  if(!MathIsValidNumber(priceActionConfig.pinMaximumBodyRatio) ||
     priceActionConfig.pinMaximumBodyRatio <= 0.0 || priceActionConfig.pinMaximumBodyRatio >= 1.0) return VAL_FAIL;
  if(!MathIsValidNumber(priceActionConfig.pinMinimumWickToBody) ||
     priceActionConfig.pinMinimumWickToBody <= 0.0) return VAL_FAIL;
  if(!MathIsValidNumber(priceActionConfig.extremeCloseRatio) ||
     priceActionConfig.extremeCloseRatio <= 0.0 || priceActionConfig.extremeCloseRatio >= 0.5) return VAL_FAIL;
  if(!MathIsValidNumber(priceActionConfig.fibonacciMinimumImpulseRatio) ||
     priceActionConfig.fibonacciMinimumImpulseRatio <= 0.0) return VAL_FAIL;
  if(!MathIsValidNumber(priceActionConfig.fibonacciZoneToleranceRatio) ||
     priceActionConfig.fibonacciZoneToleranceRatio < 0.0 ||
     priceActionConfig.fibonacciZoneToleranceRatio >= 0.5) return VAL_FAIL;
  if(!MathIsValidNumber(priceActionConfig.fibonacciInvalidationRatio) ||
     priceActionConfig.fibonacciInvalidationRatio < 0.0 ||
     priceActionConfig.fibonacciInvalidationRatio >= 0.5) return VAL_FAIL;
  if(ValidatePositive(priceActionConfig.fibonacciMaximumAgeBars) != VAL_OK) return VAL_FAIL;
  return VAL_OK;
}

#endif // MQL5_CONFIG_VALIDATOR_MQ5
