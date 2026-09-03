// SPR3-007 Structure Manager Foundation — infrastructure orchestration only
bool structureManagerInitialized = false;
bool StructureManagerInit(){
  if(!SwingInit()) return false;
  if(!SwingConfigure(1)) { SwingShutdown(); return false; }
  if(!SwingStorageInit()) { SwingShutdown(); SwingStorageShutdown(); return false; }
  if(!BOSInit()) { SwingStorageShutdown(); SwingShutdown(); return false; }
  if(!BOSConfigureRuntime(0.0)) { BOSShutdown(); SwingStorageShutdown(); SwingShutdown(); return false; }
  if(!CHOCHInit()) { BOSShutdown(); SwingStorageShutdown(); SwingShutdown(); return false; }
  if(!CHOCHConfigureRuntime(0.0)) { CHOCHShutdown(); BOSShutdown(); SwingStorageShutdown(); SwingShutdown(); return false; }
  if(!TrendInit()) { CHOCHShutdown(); BOSShutdown(); SwingStorageShutdown(); SwingShutdown(); return false; }
  if(!TrendConfigureRuntime(indicatorConfig.trendNormalDistanceRatio,
                            indicatorConfig.trendStrongDistanceRatio)) { TrendShutdown(); CHOCHShutdown(); BOSShutdown(); SwingStorageShutdown(); SwingShutdown(); return false; }
  structureManagerInitialized = true;
  return true;
}
void StructureManagerShutdown(){
  TrendShutdown();
  CHOCHShutdown();
  BOSShutdown();
  SwingStorageShutdown();
  SwingShutdown();
  structureManagerInitialized = false;
}
bool StructureManagerStatus(){ return structureManagerInitialized; }
bool StructureManagerUpdate(){
  if(!SwingUpdate()) return false;
  if(SwingReady()){
    if(!SaveSwingPoint(GetLastSwingPrice(), GetLastSwingTime(), GetLastSwingType()))
      return false;
  }
  if(!BOSUpdate()) return false;
  if(!CHOCHUpdate()) return false;
  if(!TrendUpdate()) return false;
  return true;
}

// TODO(SPR7): Logger integration hook — future CreateLogEvent calls here
