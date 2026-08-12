# Dependency Graph — Sprint 1 Infrastructure
No code.

Layers:
Infrastructure: Config, Logger, EventID, ErrorCode, Utils, CommonTypes, Constants, Time, Market, Symbol, Init, Shutdown
Core: ConfigValidator
Strategy: None yet (future)
Risk/Execution/AI: Future

Module Dependencies (Sprint 1):
ConfigSystem -> CommonTypes, Constants, Utils
LoggerCore -> CommonTypes, Constants, LogSpec
LoggerFile -> LoggerCore, CommonTypes
EventIDs -> none
ErrorCodes -> none
TimeService -> CommonTypes, Constants, Utils
MarketData -> CommonTypes, Constants, TimeService
SymbolInfoService -> CommonTypes, Constants, MarketData
InitManager -> Config, LoggerCore, LoggerFile, TimeService, MarketData, SymbolInfo
ShutdownManager -> LoggerCore, Config (TODO), reverse order
ConfigValidator -> CommonTypes, ValidationResult
Utils -> CommonTypes

Initialization Order: Config -> LoggerCore -> LoggerFile -> Time -> Market -> Symbol
Shutdown Order: Symbol -> Market -> Time -> LoggerFile -> LoggerCore -> Config

No circular dependencies verified.
