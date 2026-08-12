# Project Dependency Graph — Sprint 3 Refresh (SPR3-015)
Status: DOCUMENTATION ONLY — Zero source changes

Layers (bottom-up):
Infrastructure (Sprint 1): ConfigSystem, ConfigValidator, LoggerCore, LoggerFile, TimeService, MarketData, SymbolInfoService, InitManager, ShutdownManager, Utils, CommonTypes, Constants, EventIDs, ErrorCodes
Indicator (Sprint 2): EMAEngine, ATREngine, IndicatorManager
Structure (Sprint 3): SwingDetector → SwingStorage → BOSDetector → CHOCHDetector → TrendEngine → StructureManager

Initialization Order:
ConfigSystem → LoggerCore → LoggerFile → TimeService → MarketData → SymbolInfoService → SwingInit → SwingStorageInit → BOSInit → CHOCHInit → TrendInit → StructureManagerInit

Shutdown Order:
StructureManagerShutdown → TrendShutdown → CHOCHShutdown → BOSShutdown → SwingStorageShutdown → SwingShutdown → LoggerFileShutdown → LoggerShutdown → Config (documented TODO)

Update Sequence:
StructureManagerUpdate: SwingUpdate → SaveSwing → BOSUpdate → CHOCHUpdate → TrendUpdate

Allowed Dependencies (downstream only):
- StructureManager → Logger, EventIDs, SwingStorage, BOS, CHOCH, Trend
- TrendEngine → BOS, CHOCH (not direct Swing)
- BOSDetector → SwingStorage (via interface, not direct module include)
- SwingStorage → SwingDetector (storage of swing results)
- IndicatorManager → EMAEngine, ATREngine
- All infrastructure → CommonTypes, Constants, Utils, TimeService, MarketData

Forbidden / No circular:
- No Strategy → Indicator
- No Indicator → Strategy
- No Structure → Strategy
- No Strategy → Risk/Execution/AI
- No Logger → Trading
- No direct SwingStorage → SwingDetector circular (storage writes; detector reads via interface)

No cycles found. Contracts preserved. Frozen interfaces intact.
