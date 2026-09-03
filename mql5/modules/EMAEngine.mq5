// SPR2-002A Frozen EMA Engine — single implementation only; no strategy logic
#include <mql5/include/IndicatorMath.mqh>

bool emaInitialized = false;
bool emaConfigured = false;
double emaCurrentValue = 0.0;
double emaSlowCurrentValue = 0.0;
int emaPeriod = 50;
int emaSlowPeriod = 200;
int emaAppliedPrice = 0;
ENUM_TIMEFRAMES emaTimeframe = PERIOD_H4;
int emaHistoryMultiplier = 10;
bool EMAInit(){ emaInitialized = true; return true; }
void EMAShutdown(){ emaInitialized = false; emaConfigured = false; emaCurrentValue = 0.0; emaSlowCurrentValue = 0.0; }
bool EMAStatus(){ return emaInitialized; }
bool EMAConfigure(int p,int ap){ emaPeriod = p; emaAppliedPrice = ap; emaConfigured = true; return true; }
bool EMAConfigureRuntime(int fastPeriod, int slowPeriod, int ap,
                         ENUM_TIMEFRAMES timeframe, int historyMultiplier){
  if(fastPeriod <= 0 || slowPeriod <= fastPeriod || ap < 0 || ap > 6 ||
     PeriodSeconds(timeframe) <= 0 || historyMultiplier <= 0)
    return false;
  emaPeriod = fastPeriod;
  emaSlowPeriod = slowPeriod;
  emaAppliedPrice = ap;
  emaTimeframe = timeframe;
  emaHistoryMultiplier = historyMultiplier;
  emaConfigured = true;
  return true;
}
bool EMAUpdate(){
  if(!emaInitialized || !emaConfigured)
    return false;
  int requiredBars = MathMax(emaSlowPeriod, emaSlowPeriod * emaHistoryMultiplier);
  MqlRates rates[];
  if(!LoadClosedRates(_Symbol, emaTimeframe, requiredBars, rates))
    return false;
  double prices[];
  if(!ExtractAppliedPrices(rates, (ENUM_APPLIED_PRICE)emaAppliedPrice, prices))
    return false;
  double fastValue = 0.0;
  double slowValue = 0.0;
  if(!CalculateEMA(prices, emaPeriod, fastValue) ||
     !CalculateEMA(prices, emaSlowPeriod, slowValue))
    return false;
  emaCurrentValue = fastValue;
  emaSlowCurrentValue = slowValue;
  return true;
}
double EMAValue(){ return emaCurrentValue; }
double EMAFastValue(){ return emaCurrentValue; }
double EMASlowValue(){ return emaSlowCurrentValue; }
bool EMAHasValues(){ return emaCurrentValue > 0.0 && emaSlowCurrentValue > 0.0; }
bool EMAReady(){ return emaInitialized && emaConfigured; }
