// SPR4-009 PriceActionManager — infrastructure orchestration (patched)
bool initialized = false;
bool PriceActionManagerInit(){
  if(!CandleClassifierInit()) return false;
  if(!EngulfingInit()) return false;
  if(!PinBarInit()) return false;
  if(!InsideBarInit()) return false;
  if(!OutsideBarInit()) return false;
  if(!FibonacciInit()) return false;
  if(!RetracementInit()) return false;
  if(!ConfluenceInit()) return false;
  initialized = true;
  return true;
}
void PriceActionManagerShutdown(){
  ConfluenceShutdown();
  RetracementShutdown();
  FibonacciShutdown();
  OutsideBarShutdown();
  InsideBarShutdown();
  PinBarShutdown();
  EngulfingShutdown();
  CandleClassifierShutdown();
  initialized = false;
}
bool PriceActionManagerStatus(){ return initialized; }
bool PriceActionManagerUpdate(){
  CandleClassifierUpdate();
  EngulfingUpdate();
  PinBarUpdate();
  InsideBarUpdate();
  OutsideBarUpdate();
  FibonacciUpdate();
  RetracementUpdate();
  ConfluenceUpdate();
  return true;
}
