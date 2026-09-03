// SPR6-016 EMA and market-structure trend engine
#include <mql5/include/TrendMath.mqh>

bool trendInitialized = false;
bool trendConfigured = false;
bool trendReadyState = false;
TrendDirection trendCurrentDirection = TREND_UNKNOWN;
TrendStrength trendCurrentStrength = STRENGTH_UNKNOWN;
double trendEMADistanceRatio = 0.0;
double trendNormalDistanceRatio = 0.005;
double trendStrongDistanceRatio = 0.015;

bool TrendInit(){ trendInitialized = true; return true; }
void TrendShutdown(){
  trendInitialized = false;
  trendConfigured = false;
  trendReadyState = false;
  trendCurrentDirection = TREND_UNKNOWN;
  trendCurrentStrength = STRENGTH_UNKNOWN;
  trendEMADistanceRatio = 0.0;
  trendNormalDistanceRatio = 0.005;
  trendStrongDistanceRatio = 0.015;
}
bool TrendStatus(){ return trendInitialized; }
bool TrendConfigure(){ trendConfigured = true; return true; }
bool TrendConfigureRuntime(double normalDistanceRatio,
                           double strongDistanceRatio){
  if(!MathIsValidNumber(normalDistanceRatio) || normalDistanceRatio < 0.0 ||
     !MathIsValidNumber(strongDistanceRatio) ||
     strongDistanceRatio <= normalDistanceRatio)
    return false;
  trendNormalDistanceRatio = normalDistanceRatio;
  trendStrongDistanceRatio = strongDistanceRatio;
  trendConfigured = true;
  return true;
}
bool TrendUpdate(){
  if(!trendInitialized || !trendConfigured)
    return false;
  if(!EMAHasValues())
    return true;

  SwingPoint latestHigh, previousHigh, olderHigh;
  SwingPoint latestLow, previousLow, olderLow;
  if(!GetSwingByTypeOffset(SWING_HIGH, 0, latestHigh) ||
     !GetSwingByTypeOffset(SWING_HIGH, 1, previousHigh) ||
     !GetSwingByTypeOffset(SWING_HIGH, 2, olderHigh) ||
     !GetSwingByTypeOffset(SWING_LOW, 0, latestLow) ||
     !GetSwingByTypeOffset(SWING_LOW, 1, previousLow) ||
     !GetSwingByTypeOffset(SWING_LOW, 2, olderLow))
    return true;

  MqlRates rates[];
  if(!LoadClosedRates(_Symbol, indicatorConfig.trendTimeframe, 1, rates))
    return false;
  TrendResult result;
  if(!ClassifyTrend(rates[0].close, EMAFastValue(), EMASlowValue(),
                    latestHigh, previousHigh, olderHigh,
                    latestLow, previousLow, olderLow,
                    trendNormalDistanceRatio, trendStrongDistanceRatio, result))
    return false;
  trendCurrentDirection = result.direction;
  trendCurrentStrength = result.strength;
  trendEMADistanceRatio = result.emaDistanceRatio;
  trendReadyState = true;
  return true;
}
bool TrendReady(){ return trendInitialized && trendConfigured && trendReadyState; }
TrendDirection GetTrendDirection(){ return trendCurrentDirection; }
TrendStrength GetTrendStrength(){ return trendCurrentStrength; }
double GetTrendEMADistanceRatio(){ return trendEMADistanceRatio; }

// TODO(SPR7): Logger integration hook - future CreateLogEvent calls here
