# Structure Contracts — Sprint 3 Freeze (SPR3-000)

## 1. Purpose
Scope of Structure Layer: Swing, BOS, CHoCH, Trend, Structure Manager, tests, docs. No strategy/trading.

## 2. Public Components
- SwingDetector
- SwingValidator
- SwingStorage
- BOSDetector
- CHOCHDetector
- TrendEngine
- StructureManager

## 3. Public Interfaces (signatures only)
SwingInit(); SwingShutdown(); SwingStatus(); SwingConfigure(); SwingUpdate(); SwingReady();
BOSInit(); BOSShutdown(); BOSStatus(); BOSUpdate(); BOSReady();
CHOCHInit(); CHOCHShutdown(); CHOCHStatus(); CHOCHUpdate(); CHOCHReady();
TrendInit(); TrendShutdown(); TrendStatus(); TrendUpdate(); TrendReady();
StructureManagerInit(); StructureManagerShutdown(); StructureManagerStatus();

## 4. Shared Types (reserved, no implementation)
SwingPoint, SwingDirection, SwingStrength, StructureState, TrendState, BOSResult, CHOCHResult

## 5. Reserved Event IDs
SWING_, BOS_, CHOCH_, TREND_, STRUCTURE_

## 6. Reserved Error Codes
1100–1149 Swing; 1150–1199 BOS; 1200–1249 CHOCH; 1250–1299 Trend; 1300–1349 Structure

## 7. Dependency Rules
Swing -> BOS, Swing -> CHOCH, Swing -> Trend
BOS -> StructureManager; CHOCH -> StructureManager; Trend -> StructureManager
StructureManager -> Logger, StructureManager -> EventIDs
No circular dependency allowed.

## 8. Freeze Rules
No public interface changes after SPR3-001. New functions require architecture review. Changing signatures requires PATCH task.

## 9. Out of Scope
No Strategy, Orders, Risk, AI, Fibonacci, Entry, Exit, Position, Money Management.

## 10. Final Architecture Review — SPR3-016

Dependency chain verified (no circular):
SwingDetector -> SwingStorage (stores results) -> BOSDetector -> CHOCHDetector -> TrendEngine -> StructureManager

Clarification: SwingStorage is infrastructure storage for SwingDetector results; it does not depend on SwingDetector logic beyond interface consumption (SaveSwing / GetStoredSwingPrice). No hidden coupling.

Initialization Order: SwingInit → SwingStorageInit → BOSInit → CHOCHInit → TrendInit → StructureManagerInit
Shutdown Order: StructureManagerShutdown → TrendShutdown → CHOCHShutdown → BOSShutdown → SwingStorageShutdown → SwingShutdown
Update Order: SwingUpdate → SaveSwing → BOSUpdate → CHOCHUpdate → TrendUpdate (via StructureManagerUpdate)

Deferred items (low technical debt):
- SPR3-004: Swing confirmation algorithm (placeholder 3-bar)
- SPR3-005: BOS confirmation algorithm (temporary copy)
- SPR3-006: Trend algorithm (temporary state)
- SPR3-009: Logger integration (TODO comments present)
- SPR3-010: Structure Event IDs (registry complete)

Freeze affirmed: No interface changes permitted. All modules compile. Regression tests execute without failure. Architecture APPROVED.
