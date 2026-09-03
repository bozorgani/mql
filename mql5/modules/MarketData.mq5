// SPR1-012 Final Freeze — MarketData patched
bool marketDataInitialized = false;
void MarketInit(){ marketDataInitialized = true; }
void MarketShutdown(){ marketDataInitialized = false; }
bool MarketStatus(){ return marketDataInitialized; }
string GetCurrentSymbol(){ return _Symbol; }
string GetCurrentTimeframe(){ return EnumToString((ENUM_TIMEFRAMES)Period()); }
double GetBid(){ return SymbolInfoDouble(_Symbol,SYMBOL_BID); }
double GetAsk(){ return SymbolInfoDouble(_Symbol,SYMBOL_ASK); }
double GetSpread(){ return MathAbs(GetAsk()-GetBid()); }
bool IsMarketAvailable(){ return marketDataInitialized; /* TODO: full session validation deferred to later Sprint */ }
void RefreshMarketData(){ }
bool LoadClosedRates(string symbol, ENUM_TIMEFRAMES timeframe, int count, MqlRates &rates[]){
  ArrayResize(rates, 0);
  if(symbol == "" || PeriodSeconds(timeframe) <= 0 || count <= 0)
    return false;
  if(!SymbolSelect(symbol, true))
    return false;

  int copied = CopyRates(symbol, timeframe, 1, count, rates);
  if(copied != count){
    ArrayResize(rates, 0);
    return false;
  }

  ArraySetAsSeries(rates, false);
  for(int index = 0; index < count; index++){
    if(rates[index].time <= 0 || rates[index].high < rates[index].low ||
       rates[index].open <= 0.0 || rates[index].high <= 0.0 ||
       rates[index].low <= 0.0 || rates[index].close <= 0.0)
      return false;
    if(index > 0 && rates[index].time <= rates[index - 1].time)
      return false;
  }
  return true;
}
bool MarketDataInit(){ marketDataInitialized = true; return true; }
void MarketDataShutdown(){ marketDataInitialized = false; }
