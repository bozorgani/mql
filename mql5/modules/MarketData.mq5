// SPR1-012 Final Freeze — MarketData patched
bool initialized = false;
void MarketInit(){ initialized = true; }
void MarketShutdown(){ initialized = false; }
bool MarketStatus(){ return initialized; }
string GetCurrentSymbol(){ return _Symbol; }
string GetCurrentTimeframe(){ return Period(); }
double GetBid(){ return SymbolInfoDouble(_Symbol,SYMBOL_BID); }
double GetAsk(){ return SymbolInfoDouble(_Symbol,SYMBOL_ASK); }
double GetSpread(){ return MathAbs(GetAsk()-GetBid()); }
bool IsMarketAvailable(){ return initialized; /* TODO: full session validation deferred to later Sprint */ }
void RefreshMarketData(){ }
bool MarketDataInit(){ initialized = true; return true; }
void MarketDataShutdown(){ initialized = false; }
