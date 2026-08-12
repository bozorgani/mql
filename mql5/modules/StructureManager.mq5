// SPR3-007 Structure Manager Foundation — infrastructure orchestration only
bool initialized = false;
bool StructureManagerInit(){
  if(!SwingInit()) return false;
  if(!SwingStorageInit()) { SwingShutdown(); SwingStorageShutdown(); return false; }
  if(!BOSInit()) { SwingStorageShutdown(); SwingShutdown(); return false; }
  if(!CHOCHInit()) { BOSShutdown(); SwingStorageShutdown(); SwingShutdown(); return false; }
  if(!TrendInit()) { CHOCHShutdown(); BOSShutdown(); SwingStorageShutdown(); SwingShutdown(); return false; }
  initialized = true;
  return true;
}
void StructureManagerShutdown(){
  TrendShutdown();
  CHOCHShutdown();
  BOSShutdown();
  SwingStorageShutdown();
  SwingShutdown();
  initialized = false;
}
bool StructureManagerStatus(){ return initialized; }
bool StructureManagerUpdate(){
  SwingUpdate();
  if(SwingReady()){
    SaveSwing(GetLastSwingPrice(), GetLastSwingTime());
  }
  BOSUpdate();
  CHOCHUpdate();
  TrendUpdate();
  return true;
}

// TODO(SPR7): Logger integration hook — future CreateLogEvent calls here
