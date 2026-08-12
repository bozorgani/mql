#include <mql5/modules/StructureManager.mq5>
void RunStructureBacktestHarness(void) {
  if(!StructureManagerInit()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  if(!StructureManagerStatus()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  if(!StructureManagerUpdate()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  if(!StructureManagerStatus()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  StructureManagerShutdown();
  if(StructureManagerStatus()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
}
