#include <mql5/include/CommonTypes.mqh>
// SPR4-001 CandleClassifier Foundation
// TODO(SPR4-013): Move PatternType to shared CommonTypes; remove local declaration after shared types available
bool candleClassifierInitialized = false;
bool candleClassifierConfigured = false;
bool candleClassifierReadyState = false;
PatternType candleClassifierCurrentPattern = PATTERN_NONE;
bool CandleClassifierInit(){ candleClassifierInitialized = true; return true; }
void CandleClassifierShutdown(){ candleClassifierInitialized = false; candleClassifierConfigured = false; candleClassifierReadyState = false; candleClassifierCurrentPattern = PATTERN_NONE; }
bool CandleClassifierStatus(){ return candleClassifierInitialized; }
bool CandleClassifierConfigure(){ candleClassifierConfigured = true; return true; }
bool CandleClassifierUpdate(){
  double open = iOpen(_Symbol, PERIOD_CURRENT, 1);
  double high = iHigh(_Symbol, PERIOD_CURRENT, 1);
  double low = iLow(_Symbol, PERIOD_CURRENT, 1);
  double close = iClose(_Symbol, PERIOD_CURRENT, 1);
  if(close > open) candleClassifierCurrentPattern = PATTERN_BULLISH;
  else if(close < open) candleClassifierCurrentPattern = PATTERN_BEARISH;
  else candleClassifierCurrentPattern = PATTERN_DOJI;
  candleClassifierReadyState = true;
  return true;
}
bool CandleClassifierReady(){ return candleClassifierInitialized && candleClassifierConfigured && candleClassifierReadyState; }
PatternType GetPattern(){ return candleClassifierCurrentPattern; }
