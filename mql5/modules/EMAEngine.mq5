// SPR2-002A Frozen EMA Engine — single implementation only; no strategy logic
bool initialized = false;
bool configured = false;
double currentValue = 0.0;
int period = 50;
int appliedPrice = 0;
double lastCalculatedPrice = 0.0;
bool EMAInit(){ initialized = true; return true; }
void EMAShutdown(){ initialized = false; configured = false; currentValue = 0.0; }
bool EMAStatus(){ return initialized; }
bool EMAConfigure(int p,int ap){ period = p; appliedPrice = ap; configured = true; return true; }
bool EMAUpdate(){ 
  lastCalculatedPrice = SymbolInfoDouble(_Symbol,SYMBOL_BID);
  double k = 2.0 / (period + 1.0);
  if(currentValue == 0.0) currentValue = lastCalculatedPrice;
  else currentValue = lastCalculatedPrice * k + currentValue * (1.0 - k);
  return true; 
}
double EMAValue(){ return currentValue; }
bool EMAReady(){ return initialized && configured; }
