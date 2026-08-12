#include <mql5/modules/ATREngine.mq5>
void RunATREngineTests(){
  if(!ATRInit()) { /* TODO(SPR7): Logger event */ }
  if(!ATRStatus()) { /* TODO(SPR7): Logger event */ }
  if(!ATRConfigure(14)) { /* TODO(SPR7): Logger event */ }
  if(!ATRReady()) { /* TODO(SPR7): Logger event */ }
  if(!ATRUpdate()) { /* TODO(SPR7): Logger event */ }
  double v = ATRValue(); if(v < 0 || v != v) { /* TODO(SPR7): Logger event */ }
  ATRShutdown();
  if(ATRStatus()) { /* TODO(SPR7): Logger event */ }
}
