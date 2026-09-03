#ifndef MQL5_INDICATOR_MATH_MQH
#define MQL5_INDICATOR_MATH_MQH

// Pure indicator calculations for deterministic tests and runtime reuse.
// Input arrays MUST be chronological: index 0 is the oldest closed bar and
// the last index is the newest closed bar. The current forming bar is excluded.

bool IsFiniteNumber(const double value) {
  return MathIsValidNumber(value);
}

bool ValidatePriceSeries(const double &prices[], const int minimumCount) {
  int count = ArraySize(prices);
  if(minimumCount <= 0 || count < minimumCount)
    return false;

  for(int index = 0; index < count; index++) {
    if(!IsFiniteNumber(prices[index]) || prices[index] <= 0.0)
      return false;
  }
  return true;
}

bool ExtractAppliedPrices(const MqlRates &rates[],
                          const ENUM_APPLIED_PRICE appliedPrice,
                          double &prices[]) {
  int count = ArraySize(rates);
  if(count <= 0 || ArrayResize(prices, count) != count)
    return false;

  for(int index = 0; index < count; index++) {
    switch(appliedPrice) {
      case PRICE_CLOSE:
        prices[index] = rates[index].close;
        break;
      case PRICE_OPEN:
        prices[index] = rates[index].open;
        break;
      case PRICE_HIGH:
        prices[index] = rates[index].high;
        break;
      case PRICE_LOW:
        prices[index] = rates[index].low;
        break;
      case PRICE_MEDIAN:
        prices[index] = (rates[index].high + rates[index].low) / 2.0;
        break;
      case PRICE_TYPICAL:
        prices[index] = (rates[index].high + rates[index].low + rates[index].close) / 3.0;
        break;
      case PRICE_WEIGHTED:
        prices[index] = (rates[index].high + rates[index].low +
                         2.0 * rates[index].close) / 4.0;
        break;
      default:
        ArrayResize(prices, 0);
        return false;
    }

    if(!IsFiniteNumber(prices[index]) || prices[index] <= 0.0) {
      ArrayResize(prices, 0);
      return false;
    }
  }
  return true;
}

bool CalculateEMA(const double &prices[], const int period, double &result) {
  result = 0.0;
  if(period <= 0 || !ValidatePriceSeries(prices, period))
    return false;

  double seed = 0.0;
  for(int index = 0; index < period; index++)
    seed += prices[index];

  double ema = seed / period;
  double multiplier = 2.0 / (period + 1.0);
  int count = ArraySize(prices);
  for(int index = period; index < count; index++)
    ema = prices[index] * multiplier + ema * (1.0 - multiplier);

  result = ema;
  return IsFiniteNumber(result);
}

bool CalculateTrueRange(const double high,
                        const double low,
                        const double previousClose,
                        double &result) {
  result = 0.0;
  if(!IsFiniteNumber(high) || !IsFiniteNumber(low) ||
     !IsFiniteNumber(previousClose) || high <= 0.0 || low <= 0.0 ||
     previousClose <= 0.0 || high < low)
    return false;

  result = MathMax(high - low,
                   MathMax(MathAbs(high - previousClose),
                           MathAbs(low - previousClose)));
  return true;
}

bool CalculateWilderATR(const double &highs[],
                        const double &lows[],
                        const double &closes[],
                        const int period,
                        double &result) {
  result = 0.0;
  int count = ArraySize(highs);
  if(period <= 0 || count < period || ArraySize(lows) != count ||
     ArraySize(closes) != count)
    return false;

  double trueRanges[];
  if(ArrayResize(trueRanges, count) != count)
    return false;

  for(int index = 0; index < count; index++) {
    if(!IsFiniteNumber(highs[index]) || !IsFiniteNumber(lows[index]) ||
       !IsFiniteNumber(closes[index]) || highs[index] <= 0.0 ||
       lows[index] <= 0.0 || closes[index] <= 0.0 ||
       highs[index] < lows[index] || closes[index] > highs[index] ||
       closes[index] < lows[index])
      return false;

    if(index == 0) {
      trueRanges[index] = highs[index] - lows[index];
      continue;
    }

    if(!CalculateTrueRange(highs[index], lows[index], closes[index - 1],
                           trueRanges[index]))
      return false;
  }

  double seed = 0.0;
  for(int index = 0; index < period; index++)
    seed += trueRanges[index];

  double atr = seed / period;
  for(int index = period; index < count; index++)
    atr = ((atr * (period - 1)) + trueRanges[index]) / period;

  result = atr;
  return IsFiniteNumber(result);
}

#endif // MQL5_INDICATOR_MATH_MQH
