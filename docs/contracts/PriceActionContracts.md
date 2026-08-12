# Price Action Contracts — Sprint 4 Freeze (SPR4-000)

## 1. Purpose
Structure layer (completed Sprint 3) feeds Price Action layer. No strategy, no execution, no AI.

## 2. Public Components
- PriceActionManager
- CandleClassifier
- EngulfingDetector
- PinBarDetector
- InsideBarDetector
- OutsideBarDetector
- FibonacciEngine
- RetracementDetector
- ConfluenceManager

## 3. Public Interfaces (signatures only)
PriceActionManager: Init/Shutdown/Status/Update/Ready
CandleClassifier: Init/Shutdown/Status/Update/Ready/GetPattern
EngulfingDetector: Init/Shutdown/Status/Update/Ready
PinBarDetector: Init/Shutdown/Status/Update/Ready
InsideBarDetector: Init/Shutdown/Status/Update/Ready
OutsideBarDetector: Init/Shutdown/Status/Update/Ready
FibonacciEngine: Init/Shutdown/Status/Configure/Update/Ready
RetracementDetector: Init/Shutdown/Status/Update/Ready
ConfluenceManager: Init/Shutdown/Status/Update/Ready

## 4. Shared Types (reserved, no implementation)
PriceActionState, PatternType, PatternStrength, FibonacciLevel, RetracementZone, ConfluenceResult

## 5. Reserved Event IDs
PRICEACTION_, PATTERN_, FIB_, CONFLUENCE_

## 6. Reserved Error Codes
1400-1449 PriceAction; 1450-1499 Candle Patterns; 1500-1549 Fibonacci; 1550-1599 Confluence

## 7. Dependency Rules
Indicators (EMA/ATR) → Structure Layer (Sprint 3) → Price Action Layer (Sprint 4)
Price Action may READ EMA/ATR/Swing/BOS/CHOCH/Trend.
Price Action MUST NOT depend on Execution/Orders/Risk/Money/AI/Strategy.

## 8. Freeze Rules
No interface changes after SPR4-001 without architecture review / PATCH.

## 9. Out of Scope
No Orders, Execution, Risk, Position, Money Management, AI, Strategy, Entry, Exit, Fibonacci calculation logic (reserved for later), Trend algorithm (reserved).

## 10. Structure Integration — READ-ONLY Dependency (SPR4-010)

Price Action layer modules may consume Structure layer outputs only through public interfaces:
- SwingDetector (GetLastSwingPrice, GetLastSwingTime, SwingStatus)
- SwingStorage (GetStoredSwingPrice, GetStoredSwingTime, SwingStorageStatus)
- BOSDetector (GetLastBOSPrice, GetLastBOSTime, BOSStatus)
- CHOCHDetector (GetLastCHOCHPrice, GetLastCHOCHTime, CHOCHStatus)
- TrendEngine (GetTrendDirection, GetTrendStrength, TrendStatus)
- StructureManager (Status, Update, etc.)

Price Action MUST NOT modify, write to, or directly alter state inside any Structure module.
No hidden dependency changes occurred during SPR4-010.

Future integration points (SPR4-011+):
- CandleClassifier will read Structure outputs to confirm pattern context.
- EngulfingDetector / PinBarDetector / InsideBarDetector / OutsideBarDetector will read Structure outputs for validation.
- FibonacciEngine / RetracementDetector will read SwingStorage results for anchor selection.
- ConfluenceManager will read TrendEngine direction and Structure status.
