#include <mql5/include/CommonTypes.mqh>
// SPR4-001 CandleClassifier Foundation
// TODO(SPR4-013): Move PatternType to shared CommonTypes; remove local declaration after shared types available
bool initialized = false;
bool configured = false;
bool ready = false;
PatternType currentPattern = PATTERN_NONE;
bool CandleClassifierInit(){ initialized = true; return true; }
void CandleClassifierShutdown(){ initialized = false; configured = false; ready = false; currentPattern = PATTERN_NONE; }
bool CandleClassifierStatus(){ return initialized; }
bool CandleClassifierConfigure(){ configured = true; return true; }
bool CandleClassifierUpdate(){
  double open = iOpen(_Symbol, PERIOD_CURRENT, 1);
  double high = iHigh(_Symbol, PERIOD_CURRENT, 1);
  double low = iLow(_Symbol, PERIOD_CURRENT, 1);
  double close = iClose(_Symbol, PERIOD_CURRENT, 1);
  if(close > open) currentPattern = PATTERN_BULLISH;
  else if(close < open) currentPattern = PATTERN_BEARISH;
  else currentPattern = PATTERN_DOJI;
  ready = true;
  return true;
}
bool CandleClassifierReady(){ return initialized && configured && ready; }
PatternType GetPattern(){ return currentPattern; }
