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

#endif // MQL5_STRUCTURE_MATH_MQH
