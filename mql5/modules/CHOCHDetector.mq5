// SPR6-015 Confirmed Change of Character detector
#include <mql5/include/StructureMath.mqh>

bool chochInitialized = false;
bool chochConfigured = false;
bool chochReadyState = false;
double chochLastPrice = 0.0;
double chochLastClosePrice = 0.0;
datetime chochLastTime = 0;
datetime chochTransitionSwingTime = 0;
StructureShiftDirection chochLastDirection = CHOCH_NONE;
MarketStructureBias chochPreviousBias = STRUCTURE_BIAS_UNKNOWN;
double chochMinimumBreak = 0.0;

bool CHOCHInit(){ chochInitialized = true; return true; }
void CHOCHShutdown(){
  chochInitialized = false;
  chochConfigured = false;
  chochReadyState = false;
  chochLastPrice = 0.0;
  chochLastClosePrice = 0.0;
  chochLastTime = 0;
  chochTransitionSwingTime = 0;
  chochLastDirection = CHOCH_NONE;
  chochPreviousBias = STRUCTURE_BIAS_UNKNOWN;
  chochMinimumBreak = 0.0;
}
bool CHOCHStatus(){ return chochInitialized; }
bool CHOCHConfigure(){ chochConfigured = true; return true; }
bool CHOCHConfigureRuntime(double minimumBreak){
  if(!MathIsValidNumber(minimumBreak) || minimumBreak < 0.0)
    return false;
  chochMinimumBreak = minimumBreak;
  chochConfigured = true;
  return true;
}
bool CHOCHUpdate(){
  if(!chochInitialized || !chochConfigured)
    return false;
  MqlRates rates[];
  if(!LoadClosedRates(_Symbol, indicatorConfig.entryTimeframe, 1, rates))
    return false;

  SwingPoint latestHigh, previousHigh, olderHigh;
  SwingPoint latestLow, previousLow, olderLow;
  if(!GetSwingByTypeOffset(SWING_HIGH, 0, latestHigh) ||
     !GetSwingByTypeOffset(SWING_HIGH, 1, previousHigh) ||
     !GetSwingByTypeOffset(SWING_HIGH, 2, olderHigh) ||
     !GetSwingByTypeOffset(SWING_LOW, 0, latestLow) ||
     !GetSwingByTypeOffset(SWING_LOW, 1, previousLow) ||
     !GetSwingByTypeOffset(SWING_LOW, 2, olderLow))
    return true;

  CHOCHResult result;
  if(!DetectChangeOfCharacter(rates[0].close, rates[0].time,
                              latestHigh, previousHigh, olderHigh,
                              latestLow, previousLow, olderLow,
                              chochMinimumBreak, result))
    return false;
  if(result.direction == CHOCH_NONE)
    return true;
  if(result.direction == chochLastDirection &&
     result.transitionSwingTime == chochTransitionSwingTime)
    return true;

  chochLastDirection = result.direction;
  chochLastPrice = result.level;
  chochLastClosePrice = result.closePrice;
  chochLastTime = result.closeTime;
  chochTransitionSwingTime = result.transitionSwingTime;
  chochPreviousBias = result.previousBias;
  chochReadyState = true;
  return true;
}
bool CHOCHReady(){ return chochInitialized && chochConfigured && chochReadyState; }
double GetLastCHOCHPrice(){ return chochLastPrice; }
datetime GetLastCHOCHTime(){ return chochLastTime; }
double GetLastCHOCHClosePrice(){ return chochLastClosePrice; }
datetime GetLastCHOCHTransitionSwingTime(){ return chochTransitionSwingTime; }
StructureShiftDirection GetLastCHOCHDirection(){ return chochLastDirection; }
MarketStructureBias GetCHOCHPreviousBias(){ return chochPreviousBias; }

// TODO(SPR7): Logger integration hook - future CreateLogEvent calls here
