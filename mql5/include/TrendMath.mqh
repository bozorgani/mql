#ifndef MQL5_TREND_MATH_MQH
#define MQL5_TREND_MATH_MQH

#include <mql5/include/StructureMath.mqh>

bool ClassifyTrend(const double closePrice,
                   const double fastEMA,
                   const double slowEMA,
                   const SwingPoint &latestHigh,
                   const SwingPoint &previousHigh,
                   const SwingPoint &olderHigh,
                   const SwingPoint &latestLow,
                   const SwingPoint &previousLow,
                   const SwingPoint &olderLow,
                   const double normalDistanceRatio,
                   const double strongDistanceRatio,
                   TrendResult &result) {
  result.direction = TREND_UNKNOWN;
  result.strength = STRENGTH_UNKNOWN;
  result.emaDistanceRatio = 0.0;
  if(!MathIsValidNumber(closePrice) || closePrice <= 0.0 ||
     !MathIsValidNumber(fastEMA) || fastEMA <= 0.0 ||
     !MathIsValidNumber(slowEMA) || slowEMA <= 0.0 ||
     !MathIsValidNumber(normalDistanceRatio) || normalDistanceRatio < 0.0 ||
     !MathIsValidNumber(strongDistanceRatio) ||
     strongDistanceRatio <= normalDistanceRatio)
    return false;
  if(!ValidateTypedSwing(latestHigh, SWING_HIGH) ||
     !ValidateTypedSwing(previousHigh, SWING_HIGH) ||
     !ValidateTypedSwing(olderHigh, SWING_HIGH) ||
     !ValidateTypedSwing(latestLow, SWING_LOW) ||
     !ValidateTypedSwing(previousLow, SWING_LOW) ||
     !ValidateTypedSwing(olderLow, SWING_LOW))
    return false;
  if(!(latestHigh.time > previousHigh.time && previousHigh.time > olderHigh.time &&
       latestLow.time > previousLow.time && previousLow.time > olderLow.time))
    return false;

  result.emaDistanceRatio = MathAbs(fastEMA - slowEMA) / slowEMA;
  bool priceBetween = (closePrice >= MathMin(fastEMA, slowEMA) &&
                       closePrice <= MathMax(fastEMA, slowEMA));
  if(priceBetween || result.emaDistanceRatio <= normalDistanceRatio) {
    result.direction = TREND_SIDEWAYS;
    result.strength = STRENGTH_WEAK;
    return true;
  }

  bool bullishStructure = latestHigh.price > previousHigh.price &&
                          latestLow.price > previousLow.price;
  bool bearishStructure = latestHigh.price < previousHigh.price &&
                          latestLow.price < previousLow.price;
  bool twoBullishSequences = bullishStructure &&
                             previousHigh.price > olderHigh.price &&
                             previousLow.price > olderLow.price;
  bool twoBearishSequences = bearishStructure &&
                             previousHigh.price < olderHigh.price &&
                             previousLow.price < olderLow.price;

  if(closePrice > fastEMA && fastEMA > slowEMA && bullishStructure) {
    result.direction = TREND_BULLISH;
    result.strength = (result.emaDistanceRatio > strongDistanceRatio &&
                       twoBullishSequences) ? STRENGTH_STRONG : STRENGTH_NORMAL;
  } else if(closePrice < fastEMA && fastEMA < slowEMA && bearishStructure) {
    result.direction = TREND_BEARISH;
    result.strength = (result.emaDistanceRatio > strongDistanceRatio &&
                       twoBearishSequences) ? STRENGTH_STRONG : STRENGTH_NORMAL;
  }
  return true;
}

#endif // MQL5_TREND_MATH_MQH
