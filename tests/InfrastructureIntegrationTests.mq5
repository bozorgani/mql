#include <mql5/include/CommonTypes.mqh>
#include <mql5/include/Constants.mqh>
#include <mql5/include/EventIDs.mqh>
#include <mql5/include/ErrorCodes.mqh>
#include <mql5/modules/ConfigSystem.mq5>
#include <mql5/modules/ConfigValidator.mq5>
#include <mql5/modules/LoggerCore.mq5>
#include <mql5/modules/LoggerFile.mq5>
#include <mql5/modules/TimeService.mq5>
#include <mql5/modules/MarketData.mq5>
#include <mql5/modules/SymbolInfoService.mq5>
#include <mql5/modules/InitManager.mq5>
#include <mql5/modules/ShutdownManager.mq5>
#include <mql5/include/Utils.mqh>
void RunInfrastructureTests(){
  if(ConfigInit()!=INIT_SUCCEEDED) Print("FAIL ConfigInit");
  LoggerInit(); if(!LoggerStatus()) Print("FAIL LoggerStatus");
  SetLogLevel(1); if(GetLogLevel()!=1) Print("FAIL SetLogLevel");
  if(!InitializeInfrastructure()) Print("FAIL Init");
  if(!MarketStatus()) Print("FAIL MarketStatus");
  if(!SymbolInfoStatus()) Print("FAIL SymbolInfoStatus");
  double b=GetBid(); if(b<=0) Print("FAIL GetBid");
  int d=GetDigits(); if(d<=0) Print("FAIL GetDigits");
  if(Clamp(5.0,0.0,10.0)!=5.0) Print("FAIL Clamp");
  ShutdownInfrastructure();
  if(!ShutdownManagerStatus()) Print("FAIL ShutdownManagerStatus");
  if(!ValidateShutdown()) Print("FAIL ValidateShutdown");
}
// TODO: Replace temporary Print() reporting with centralized Logger event reporting after Logger persistence layer becomes fully available.
