// SPR1-014 Final Freeze — InitManager synchronized with architecture
bool initManagerInitialized = false;
void InitManagerStart(){ initManagerInitialized = true; }
void InitManagerShutdown(){ initManagerInitialized = false; }
bool InitManagerStatus(){ return initManagerInitialized; }
bool InitializeInfrastructure(){
  if(ConfigInit() != INIT_SUCCEEDED) return false;
  LoggerInit();
  if(!LoggerFileInit()) return false;
  if(!TimeServiceInit()) return false;
  if(!MarketDataInit()) return false;
  if(!SymbolInfoInit()) return false;
  return true;
}
bool ValidateInitialization(){ return initManagerInitialized; }
