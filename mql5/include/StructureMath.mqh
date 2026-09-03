#ifndef MQL5_STRUCTURE_MATH_MQH
#define MQL5_STRUCTURE_MATH_MQH

#include <mql5/include/CommonTypes.mqh>

bool DetectConfirmedPivot(const double &highs[], const double &lows[],
                          const datetime &times[], const int leftBars,
                          const int rightBars, SwingPoint &result,
                          int &pivotIndex) {
  result.time = 0;
  result.price = 0.0;
  result.type = SWING_NONE;
  pivotIndex = -1;
  int count = ArraySize(highs);
  if(leftBars <= 0 || rightBars <= 0 || count != ArraySize(lows) ||
     count != ArraySize(times) || count < leftBars + rightBars + 1)
    return false;
  int candidate = count - rightBars - 1;
  if(candidate < leftBars)
    return false;
  double candidateHigh = highs[candidate];
  double candidateLow = lows[candidate];
  if(!MathIsValidNumber(candidateHigh) || !MathIsValidNumber(candidateLow) ||
     candidateHigh <= 0.0 || candidateLow <= 0.0 ||
     candidateHigh < candidateLow || times[candidate] <= 0)
    return false;
  bool isHigh = true;
  bool isLow = true;
  for(int index = candidate - leftBars; index <= candidate + rightBars; index++) {
    if(index == candidate)
      continue;
    if(!MathIsValidNumber(highs[index]) || !MathIsValidNumber(lows[index]) ||
       highs[index] <= 0.0 || lows[index] <= 0.0 || highs[index] < lows[index] ||
       times[index] <= 0)
      return false;
    if(candidateHigh <= highs[index]) isHigh = false;
    if(candidateLow >= lows[index]) isLow = false;
  }
  if(isHigh == isLow)
    return true;
  result.time = times[candidate];
  result.price = isHigh ? candidateHigh : candidateLow;
  result.type = isHigh ? SWING_HIGH : SWING_LOW;
  pivotIndex = candidate;
  return true;
}

SwingRelation ClassifySwingRelation(const SwingPoint &current,
                                    const SwingPoint &previous) {
  if(current.type == SWING_HIGH && previous.type == SWING_HIGH)
    return current.price > previous.price ? SWING_HH :
           current.price < previous.price ? SWING_LH : SWING_RELATION_NONE;
  if(current.type == SWING_LOW && previous.type == SWING_LOW)
    return current.price > previous.price ? SWING_HL :
           current.price < previous.price ? SWING_LL : SWING_RELATION_NONE;
  return SWING_RELATION_NONE;
}

MarketStructureBias InferStructureBias(const SwingPoint &latestHigh,
                                       const SwingPoint &previousHigh,
                                       const SwingPoint &latestLow,
                                       const SwingPoint &previousLow) {
  SwingRelation highRelation = ClassifySwingRelation(latestHigh, previousHigh);
  SwingRelation lowRelation = ClassifySwingRelation(latestLow, previousLow);
  if(highRelation == SWING_HH && lowRelation == SWING_HL)
    return STRUCTURE_BIAS_BULLISH;
  if(highRelation == SWING_LH && lowRelation == SWING_LL)
    return STRUCTURE_BIAS_BEARISH;
  return STRUCTURE_BIAS_UNKNOWN;
}

bool DetectBreakOfStructure(const double closePrice,
                            const datetime closeTime,
                            const bool hasSwingHigh,
                            const SwingPoint &swingHigh,
                            const bool hasSwingLow,
                            const SwingPoint &swingLow,
                            const double minimumBreak,
                            BOSResult &result) {
  result.direction = BOS_NONE;
  result.level = 0.0;
  result.closePrice = 0.0;
  result.closeTime = 0;
  result.sourceSwingTime = 0;
  if(!MathIsValidNumber(closePrice) || closePrice <= 0.0 || closeTime <= 0 ||
     !MathIsValidNumber(minimumBreak) || minimumBreak < 0.0)
    return false;
  if(hasSwingHigh && (swingHigh.type != SWING_HIGH || swingHigh.price <= 0.0 ||
                      swingHigh.time <= 0))
    return false;
  if(hasSwingLow && (swingLow.type != SWING_LOW || swingLow.price <= 0.0 ||
                     swingLow.time <= 0))
    return false;

  if(hasSwingHigh && closePrice > swingHigh.price + minimumBreak) {
    result.direction = BOS_BULLISH;
    result.level = swingHigh.price;
    result.closePrice = closePrice;
    result.closeTime = closeTime;
    result.sourceSwingTime = swingHigh.time;
    return true;
  }
  if(hasSwingLow && closePrice < swingLow.price - minimumBreak) {
    result.direction = BOS_BEARISH;
    result.level = swingLow.price;
    result.closePrice = closePrice;
    result.closeTime = closeTime;
    result.sourceSwingTime = swingLow.time;
  }
  return true;
}

bool ConfirmBreakOfStructure(const double closePrice,
                             const datetime closeTime,
                             const MarketStructureBias bias,
                             const SwingPoint &swingHigh,
                             const SwingPoint &swingLow,
                             const double minimumBreak,
                             BOSResult &result) {
  if(bias == STRUCTURE_BIAS_UNKNOWN) {
    result.direction = BOS_NONE;
    result.level = 0.0;
    result.closePrice = 0.0;
    result.closeTime = 0;
    result.sourceSwingTime = 0;
    return true;
  }
  bool valid = DetectBreakOfStructure(closePrice, closeTime, true, swingHigh,
                                      true, swingLow, minimumBreak, result);
  if(!valid)
    return false;
  if((bias == STRUCTURE_BIAS_BULLISH && result.direction != BOS_BULLISH) ||
     (bias == STRUCTURE_BIAS_BEARISH && result.direction != BOS_BEARISH)) {
    result.direction = BOS_NONE;
    result.level = 0.0;
    result.closePrice = 0.0;
    result.closeTime = 0;
    result.sourceSwingTime = 0;
  }
  return true;
}

#endif // MQL5_STRUCTURE_MATH_MQH
