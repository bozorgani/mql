#include <mql5/include/PriceActionMath.mqh>
// SPR4-001 CandleClassifier Foundation
// TODO(SPR4-013): Move PatternType to shared CommonTypes; remove local declaration after shared types available
bool candleClassifierInitialized = false;
bool candleClassifierConfigured = false;
bool candleClassifierReadyState = false;
PatternType candleClassifierCurrentPattern = PATTERN_NONE;
double candleClassifierDojiBodyRatio = 0.10;
bool CandleClassifierInit(){ candleClassifierInitialized = true; return true; }
void CandleClassifierShutdown(){ candleClassifierInitialized = false; candleClassifierConfigured = false; candleClassifierReadyState = false; candleClassifierCurrentPattern = PATTERN_NONE; }
bool CandleClassifierStatus(){ return candleClassifierInitialized; }
bool CandleClassifierConfigure(){ candleClassifierConfigured = true; return true; }
bool CandleClassifierConfigureRuntime(double dojiBodyRatio){
  if(!MathIsValidNumber(dojiBodyRatio) || dojiBodyRatio < 0.0 || dojiBodyRatio >= 1.0) return false;
  candleClassifierDojiBodyRatio = dojiBodyRatio; candleClassifierConfigured = true; return true;
}
bool CandleClassifierUpdate(){
  if(!candleClassifierInitialized || !candleClassifierConfigured) return false;
  MqlRates rates[];
  if(!LoadClosedRates(_Symbol, indicatorConfig.entryTimeframe, 1, rates)) return false;
  candleClassifierCurrentPattern = ClassifyCandle(rates[0], candleClassifierDojiBodyRatio);
  if(candleClassifierCurrentPattern == PATTERN_NONE) return false;
  candleClassifierReadyState = true;
  return true;
}
bool CandleClassifierReady(){ return candleClassifierInitialized && candleClassifierConfigured && candleClassifierReadyState; }
PatternType GetPattern(){ return candleClassifierCurrentPattern; }
