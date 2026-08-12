// SPR1-013 Symbol Info Service — static symbol properties only
bool infoInitialized = false;
bool SymbolInfoStatus(){ return infoInitialized; }
int GetDigits(){ return (int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS); }
double GetPointSize(){ return SymbolInfoDouble(_Symbol,SYMBOL_POINT); }
double GetTickSize(){ return SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE); }
double GetTickValue(){ return SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE); }
double GetContractSize(){ return SymbolInfoDouble(_Symbol,SYMBOL_TRADE_CONTRACT_SIZE); }
double GetMinimumVolume(){ return SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN); }
double GetMaximumVolume(){ return SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX); }
double GetVolumeStep(){ return SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP); }
bool IsTradeAllowed(){ return SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE)==SYMBOL_TRADE_MODE_FULL; }
bool SymbolInfoInit(){ infoInitialized = true; return true; }
void SymbolInfoShutdown(){ infoInitialized = false; }
