// SPR1-015 Final Freeze — Shutdown Manager
bool shutdownCompleted = false;
void ShutdownManagerStart(){ shutdownCompleted = false; }
void ShutdownManagerStop(){ 
  SymbolInfoShutdown();
  MarketDataShutdown();
  TimeServiceShutdown();
  LoggerFileShutdown();
  LoggerShutdown();
  // TODO: ConfigSystem currently has no explicit shutdown interface; deferred
  shutdownCompleted = true; 
}
bool ShutdownManagerStatus(){ return shutdownCompleted; }
void ShutdownInfrastructure(){ ShutdownManagerStop(); }
bool ValidateShutdown(){ return shutdownCompleted; }
