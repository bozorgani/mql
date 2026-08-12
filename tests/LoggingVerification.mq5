#include <mql5/modules/LoggerCore.mq5>
#include <mql5/modules/LoggerFile.mq5>
void VerifyLogger(){
  LoggerInit(); if(!LoggerStatus()) Print("FAIL LoggerStatus");
  SetLogLevel(2); if(GetLogLevel()!=2) Print("FAIL SetLogLevel");
  CreateLogEvent("TEST","EVT-001",1,"msg");
  string m=BuildLogMessage("TEST","EVT-001",1,"msg"); if(m=="") Print("FAIL BuildLogMessage");
  OpenLog(); if(!LogFileStatus()) Print("FAIL LogFileStatus after Open");
  FlushLog();
  CloseLog(); if(LogFileStatus()) Print("FAIL LogFileStatus after Close");
  LoggerShutdown(); if(LoggerStatus()) Print("FAIL LoggerStatus after Shutdown");
}
// TODO: Replace temporary Print() reporting with centralized Logger event reporting after Logger persistence layer becomes fully available.
