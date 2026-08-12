// SPR2-005 ATR Engine Foundation — skeleton only; no analysis
bool initialized = false;
bool configured = false;
int period = 14;
double currentATR = 0.0;
bool ATRInit(){ initialized = true; return true; }
void ATRShutdown(){ initialized = false; configured = false; currentATR = 0.0; }
bool ATRStatus(){ return initialized; }
bool ATRConfigure(int p){ period = p; configured = true; return true; }
bool ATRUpdate(){ 
  double closePrice = SymbolInfoDouble(_Symbol, SYMBOL_BID); // TODO(SPR3+): Replace placeholder with candle OHLC from MarketData
  double highPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID); // placeholder high
  double lowPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  double tr = MathMax(highPrice - lowPrice, MathMax(MathAbs(highPrice - closePrice), MathAbs(lowPrice - closePrice)));
  if(lastATRcalc == 0.0) lastATRcalc = tr;
  else lastATRcalc = lastATRcalc * (period - 1.0) / period + tr / period;
  lastTR = tr;
  currentATR = lastATRcalc;
  return true;
}
double ATRValue(){ return currentATR; }
bool ATRReady(){ return initialized && configured; }
// SPR2-006 ATR Calculation Core — internal only
double lastTR = 0.0;
double lastATRcalc = 0.0;
