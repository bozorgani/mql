#ifndef MQL5_PRICE_ACTION_MATH_MQH
#define MQL5_PRICE_ACTION_MATH_MQH

#include <mql5/include/CommonTypes.mqh>

bool ValidateCandle(const MqlRates &bar) {
  return bar.time > 0 && MathIsValidNumber(bar.open) && bar.open > 0.0 &&
         MathIsValidNumber(bar.high) && MathIsValidNumber(bar.low) &&
         MathIsValidNumber(bar.close) && bar.close > 0.0 &&
         bar.high >= MathMax(bar.open, bar.close) &&
         bar.low <= MathMin(bar.open, bar.close) && bar.high > bar.low;
}

PatternType ClassifyCandle(const MqlRates &bar, const double dojiBodyRatio) {
  if(!ValidateCandle(bar) || !MathIsValidNumber(dojiBodyRatio) ||
     dojiBodyRatio < 0.0 || dojiBodyRatio >= 1.0)
    return PATTERN_NONE;
  double body = MathAbs(bar.close - bar.open);
  if(body / (bar.high - bar.low) <= dojiBodyRatio) return PATTERN_DOJI;
  return bar.close > bar.open ? PATTERN_BULLISH : PATTERN_BEARISH;
}

PatternType DetectEngulfingPattern(const MqlRates &previous,
                                   const MqlRates &current) {
  if(!ValidateCandle(previous) || !ValidateCandle(current) ||
     current.time <= previous.time) return PATTERN_NONE;
  double previousBody = MathAbs(previous.close - previous.open);
  double currentBody = MathAbs(current.close - current.open);
  if(previousBody <= 0.0 || currentBody <= previousBody) return PATTERN_NONE;
  if(previous.close < previous.open && current.close > current.open &&
     current.open <= previous.close && current.close >= previous.open)
    return PATTERN_BULLISH;
  if(previous.close > previous.open && current.close < current.open &&
     current.open >= previous.close && current.close <= previous.open)
    return PATTERN_BEARISH;
  return PATTERN_NONE;
}

PatternType DetectPinBarPattern(const MqlRates &bar,
                                const double maximumBodyRatio,
                                const double minimumWickToBody,
                                const double extremeCloseRatio) {
  if(!ValidateCandle(bar) || maximumBodyRatio <= 0.0 || maximumBodyRatio >= 1.0 ||
     minimumWickToBody <= 0.0 || extremeCloseRatio <= 0.0 ||
     extremeCloseRatio >= 0.5) return PATTERN_NONE;
  double range = bar.high - bar.low;
  double body = MathAbs(bar.close - bar.open);
  if(body <= 0.0 || body / range >= maximumBodyRatio) return PATTERN_NONE;
  double upperWick = bar.high - MathMax(bar.open, bar.close);
  double lowerWick = MathMin(bar.open, bar.close) - bar.low;
  if(lowerWick >= minimumWickToBody * body && upperWick <= body &&
     bar.close >= bar.high - extremeCloseRatio * range) return PATTERN_BULLISH;
  if(upperWick >= minimumWickToBody * body && lowerWick <= body &&
     bar.close <= bar.low + extremeCloseRatio * range) return PATTERN_BEARISH;
  return PATTERN_NONE;
}

PatternType DetectInsideBarPattern(const MqlRates &previous,
                                   const MqlRates &current) {
  if(!ValidateCandle(previous) || !ValidateCandle(current) ||
     current.time <= previous.time) return PATTERN_NONE;
  bool contained = current.high <= previous.high && current.low >= previous.low;
  bool strict = current.high < previous.high || current.low > previous.low;
  if(!contained || !strict) return PATTERN_NONE;
  return current.close > current.open ? PATTERN_BULLISH :
         current.close < current.open ? PATTERN_BEARISH : PATTERN_DOJI;
}

PatternType DetectOutsideBarPattern(const MqlRates &previous,
                                    const MqlRates &current,
                                    const double extremeCloseRatio) {
  if(!ValidateCandle(previous) || !ValidateCandle(current) ||
     current.time <= previous.time || extremeCloseRatio <= 0.0 ||
     extremeCloseRatio >= 0.5) return PATTERN_NONE;
  bool contains = current.high >= previous.high && current.low <= previous.low;
  bool strict = current.high > previous.high || current.low < previous.low;
  if(!contains || !strict) return PATTERN_NONE;
  double range = current.high - current.low;
  if(current.close >= current.high - extremeCloseRatio * range) return PATTERN_BULLISH;
  if(current.close <= current.low + extremeCloseRatio * range) return PATTERN_BEARISH;
  return PATTERN_NONE;
}

#endif // MQL5_PRICE_ACTION_MATH_MQH
