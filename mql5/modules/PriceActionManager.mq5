// SPR4-009 PriceActionManager — infrastructure orchestration (patched)
bool priceActionManagerInitialized = false;
bool PriceActionManagerInit(){
  if(!CandleClassifierInit()) return false;
  if(!EngulfingInit()) return false;
  if(!PinBarInit()) return false;
  if(!InsideBarInit()) return false;
  if(!OutsideBarInit()) return false;
  if(!FibonacciInit()) return false;
  if(!RetracementInit()) return false;
  if(!ConfluenceInit()) return false;
  priceActionManagerInitialized = true;
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
  priceActionManagerInitialized = false;
}
bool PriceActionManagerStatus(){ return priceActionManagerInitialized; }
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
