// SPR1-014 Final Freeze — InitManager synchronized with architecture
bool initialized = false;
void InitManagerStart(){ initialized = true; }
void InitManagerShutdown(){ initialized = false; }
bool InitManagerStatus(){ return initialized; }
bool InitializeInfrastructure(){
  if(!ConfigInit()) return false;
  LoggerInit();
  if(!LoggerFileInit()) return false;
  if(!TimeServiceInit()) return false;
  if(!MarketDataInit()) return false;
  if(!SymbolInfoInit()) return false;
  return true;
}
bool ValidateInitialization(){ return initialized; }
