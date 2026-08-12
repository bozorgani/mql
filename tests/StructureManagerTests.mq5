#include <mql5/modules/StructureManager.mq5>
void RunStructureManagerTests(){
  if(!StructureManagerInit()) { /* TODO(SPR7): Logger event */ }
  if(!StructureManagerStatus()) { /* TODO(SPR7): Logger event */ }
  if(!StructureManagerUpdate()) { /* TODO(SPR7): Logger event */ }
  if(!BOSStatus()) { /* TODO(SPR7): Logger event */ }
  if(!CHOCHStatus()) { /* TODO(SPR7): Logger event */ }
  if(!SwingStatus()) { /* TODO(SPR7): Logger event */ }
  if(!SwingStorageStatus()) { /* TODO(SPR7): Logger event */ }
  StructureManagerShutdown();
  if(StructureManagerStatus()) { /* TODO(SPR7): Logger event */ }
}
