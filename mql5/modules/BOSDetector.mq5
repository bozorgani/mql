// SPR3-004 BOS Detector Foundation — temporary copy from SwingStorage; no breakout logic yet
#include <mql5/include/StructureMath.mqh>

bool bosInitialized = false;
bool bosConfigured = false;
bool bosReadyState = false;
double bosLastBreakPrice = 0.0;
datetime bosLastBreakTime = 0;
double bosLastClosePrice = 0.0;
datetime bosSourceSwingTime = 0;
StructureBreakDirection bosLastDirection = BOS_NONE;
double bosMinimumBreak = 0.0;
bool BOSInit(){ bosInitialized = true; return true; }
void BOSShutdown(){ bosInitialized = false; bosConfigured = false; bosReadyState = false; bosLastBreakPrice = 0.0; bosLastBreakTime = 0; bosLastClosePrice = 0.0; bosSourceSwingTime = 0; bosLastDirection = BOS_NONE; }
bool BOSStatus(){ return bosInitialized; }
bool BOSConfigure(){ bosConfigured = true; return true; }
bool BOSConfigureRuntime(double minimumBreak){
  if(!MathIsValidNumber(minimumBreak) || minimumBreak < 0.0)
    return false;
  bosMinimumBreak = minimumBreak;
  bosConfigured = true;
  return true;
}
bool BOSUpdate(){
  if(!bosInitialized || !bosConfigured)
    return false;
  MqlRates rates[];
  if(!LoadClosedRates(_Symbol, indicatorConfig.entryTimeframe, 1, rates))
    return false;
  SwingPoint swingHigh;
  SwingPoint swingLow;
  SwingPoint previousHigh;
  SwingPoint previousLow;
  bool hasHigh = GetLatestSwingByType(SWING_HIGH, swingHigh);
  bool hasLow = GetLatestSwingByType(SWING_LOW, swingLow);
  bool hasPreviousHigh = GetPreviousSwingByType(SWING_HIGH, previousHigh);
  bool hasPreviousLow = GetPreviousSwingByType(SWING_LOW, previousLow);
  if(!hasHigh || !hasLow || !hasPreviousHigh || !hasPreviousLow)
    return true;
  MarketStructureBias bias = InferStructureBias(swingHigh, previousHigh,
                                                swingLow, previousLow);
  BOSResult result;
  if(!ConfirmBreakOfStructure(rates[0].close, rates[0].time, bias,
                              swingHigh, swingLow, bosMinimumBreak, result))
    return false;
  if(result.direction == BOS_NONE)
    return true;
  if(result.direction == bosLastDirection &&
     result.sourceSwingTime == bosSourceSwingTime)
    return true;
  bosLastDirection = result.direction;
  bosLastBreakPrice = result.level;
  bosLastClosePrice = result.closePrice;
  bosLastBreakTime = result.closeTime;
  bosSourceSwingTime = result.sourceSwingTime;
  bosReadyState = true;
  return true;
}
bool BOSReady(){ return bosInitialized && bosConfigured && bosReadyState; }
double GetLastBOSPrice(){ return bosLastBreakPrice; }
datetime GetLastBOSTime(){ return bosLastBreakTime; }
double GetLastBOSClosePrice(){ return bosLastClosePrice; }
datetime GetLastBOSSourceSwingTime(){ return bosSourceSwingTime; }
StructureBreakDirection GetLastBOSDirection(){ return bosLastDirection; }

// TODO(SPR7): Logger integration hook — future CreateLogEvent calls here
