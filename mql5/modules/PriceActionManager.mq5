// SPR4-009 PriceActionManager — infrastructure orchestration (patched)
bool priceActionManagerInitialized = false;
bool PriceActionManagerInit(){
  if(!CandleClassifierInit()) return false;
  if(!CandleClassifierConfigureRuntime(priceActionConfig.dojiBodyRatio)) { CandleClassifierShutdown(); return false; }
  if(!EngulfingInit() || !EngulfingConfigure()) { EngulfingShutdown(); CandleClassifierShutdown(); return false; }
  if(!PinBarInit() || !PinBarConfigureRuntime(priceActionConfig.pinMaximumBodyRatio, priceActionConfig.pinMinimumWickToBody, priceActionConfig.extremeCloseRatio)) { PinBarShutdown(); EngulfingShutdown(); CandleClassifierShutdown(); return false; }
  if(!InsideBarInit() || !InsideBarConfigure()) { InsideBarShutdown(); PinBarShutdown(); EngulfingShutdown(); CandleClassifierShutdown(); return false; }
  if(!OutsideBarInit() || !OutsideBarConfigureRuntime(priceActionConfig.extremeCloseRatio)) { OutsideBarShutdown(); InsideBarShutdown(); PinBarShutdown(); EngulfingShutdown(); CandleClassifierShutdown(); return false; }
  if(!FibonacciInit() || !FibonacciConfigureRuntime(priceActionConfig.fibonacciMinimumImpulseRatio,priceActionConfig.fibonacciInvalidationRatio,priceActionConfig.fibonacciMaximumAgeBars)) { FibonacciShutdown(); OutsideBarShutdown(); InsideBarShutdown(); PinBarShutdown(); EngulfingShutdown(); CandleClassifierShutdown(); return false; }
  if(!RetracementInit() || !RetracementConfigureRuntime(priceActionConfig.fibonacciZoneToleranceRatio)) { RetracementShutdown(); FibonacciShutdown(); OutsideBarShutdown(); InsideBarShutdown(); PinBarShutdown(); EngulfingShutdown(); CandleClassifierShutdown(); return false; }
  if(!ConfluenceInit() || !ConfluenceConfigure()) { ConfluenceShutdown(); RetracementShutdown(); FibonacciShutdown(); OutsideBarShutdown(); InsideBarShutdown(); PinBarShutdown(); EngulfingShutdown(); CandleClassifierShutdown(); return false; }
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
  if(!priceActionManagerInitialized) return false;
  if(!CandleClassifierUpdate()) return false;
  if(!EngulfingUpdate()) return false;
  if(!PinBarUpdate()) return false;
  if(!InsideBarUpdate()) return false;
  if(!OutsideBarUpdate()) return false;
  if(!FibonacciUpdate()) return false;
  if(!RetracementUpdate()) return false;
  if(!ConfluenceUpdate()) return false;
  return true;
}
