#include <mql5/modules/EMAEngine.mq5>
void RunEMAEngineTests(){
  if(!EMAInit()) { /* TODO(SPR7): replace with Logger.CreateLogEvent() */ }
  if(!EMAStatus()) { /* TODO(SPR7): replace with Logger.CreateLogEvent() */ }
  if(!EMAConfigure(50,0)) { /* TODO(SPR7): replace with Logger.CreateLogEvent() */ }
  if(!EMAReady()) { /* TODO(SPR7): replace with Logger.CreateLogEvent() */ }
  if(!EMAUpdate()) { /* TODO(SPR7): replace with Logger.CreateLogEvent() */ }
  double v = EMAValue(); if(v < 0 || v != v) { /* TODO(SPR7): replace with Logger.CreateLogEvent() */ }
  if(!EMAReady()) { /* TODO(SPR7): replace with Logger.CreateLogEvent() */ }
  EMAShutdown();
  if(EMAStatus()) { /* TODO(SPR7): replace with Logger.CreateLogEvent() */ }
}
