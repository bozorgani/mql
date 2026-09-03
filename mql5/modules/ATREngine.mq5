// SPR2-005 ATR Engine Foundation — skeleton only; no analysis
#include <mql5/include/IndicatorMath.mqh>

bool atrInitialized = false;
bool atrConfigured = false;
int atrPeriod = 14;
ENUM_TIMEFRAMES atrTimeframe = PERIOD_H1;
int atrHistoryMultiplier = 10;
double atrCurrentValue = 0.0;
double atrLastTR = 0.0;
double atrLastCalculated = 0.0;
bool ATRInit(){ atrInitialized = true; return true; }
void ATRShutdown(){ atrInitialized = false; atrConfigured = false; atrCurrentValue = 0.0; atrLastTR = 0.0; atrLastCalculated = 0.0; }
bool ATRStatus(){ return atrInitialized; }
bool ATRConfigure(int p){ atrPeriod = p; atrConfigured = true; return true; }
bool ATRConfigureRuntime(int p, ENUM_TIMEFRAMES timeframe, int historyMultiplier){
  if(p <= 0 || PeriodSeconds(timeframe) <= 0 || historyMultiplier <= 0)
    return false;
  atrPeriod = p;
  atrTimeframe = timeframe;
  atrHistoryMultiplier = historyMultiplier;
  atrConfigured = true;
  return true;
}
bool ATRUpdate(){
  if(!atrInitialized || !atrConfigured)
    return false;
  int requiredBars = MathMax(atrPeriod, atrPeriod * atrHistoryMultiplier);
  MqlRates rates[];
  if(!LoadClosedRates(_Symbol, atrTimeframe, requiredBars, rates))
    return false;
  double highs[];
  double lows[];
  double closes[];
  if(ArrayResize(highs, requiredBars) != requiredBars ||
     ArrayResize(lows, requiredBars) != requiredBars ||
     ArrayResize(closes, requiredBars) != requiredBars)
    return false;
  for(int index = 0; index < requiredBars; index++){
    highs[index] = rates[index].high;
    lows[index] = rates[index].low;
    closes[index] = rates[index].close;
  }
  double value = 0.0;
  if(!CalculateWilderATR(highs, lows, closes, atrPeriod, value))
    return false;
  atrLastTR = MathMax(highs[requiredBars - 1] - lows[requiredBars - 1],
                      MathMax(MathAbs(highs[requiredBars - 1] - closes[requiredBars - 2]),
                              MathAbs(lows[requiredBars - 1] - closes[requiredBars - 2])));
  atrLastCalculated = value;
  atrCurrentValue = value;
  return true;
}
double ATRValue(){ return atrCurrentValue; }
bool ATRHasValue(){ return atrCurrentValue > 0.0; }
bool ATRReady(){ return atrInitialized && atrConfigured; }
// SPR2-006 ATR Calculation Core — internal only
