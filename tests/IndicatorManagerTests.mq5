#include <mql5/modules/IndicatorManager.mq5>
void RunIndicatorManagerTests(){
  if(!IndicatorManagerInit()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  if(!IndicatorManagerStatus()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  if(!VerifyEMAReady()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  if(!VerifyATRReady()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
  IndicatorManagerShutdown();
  if(IndicatorManagerStatus()) { /* TODO(SPR7): Replace with Logger.CreateLogEvent() */ }
}
