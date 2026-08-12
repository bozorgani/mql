#include <mql5/modules/SwingDetector.mq5>
#include <mql5/modules/SwingStorage.mq5>
#include <mql5/modules/BOSDetector.mq5>
#include <mql5/modules/CHOCHDetector.mq5>
#include <mql5/modules/TrendEngine.mq5>
#include <mql5/modules/StructureManager.mq5>
void RunStructureVerificationTests(){
  if(!SwingInit()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  if(!SwingConfigure(5)) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  if(!SwingStatus()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  if(!SwingReady()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  if(!SwingStorageInit()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  if(!SwingStorageStatus()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  if(!BOSInit()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  if(!BOSStatus()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  if(!BOSReady()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  if(!CHOCHInit()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  if(!CHOCHStatus()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  if(!CHOCHReady()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  if(!TrendInit()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  if(!TrendStatus()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  if(!TrendReady()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  if(!StructureManagerInit()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  if(!StructureManagerStatus()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  if(!StructureManagerUpdate()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  StructureManagerShutdown();
  if(StructureManagerStatus()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
}
