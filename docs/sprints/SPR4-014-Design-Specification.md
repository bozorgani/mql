# SPR4-014 — Price Action Layer Integration Design Specification
Status: DESIGN READY FOR REVIEW — NOT YET IMPLEMENTED

## 1. Objective
Define the architecture for integrating Price Action layer modules (CandleClassifier, EngulfingDetector, PinBarDetector, InsideBarDetector, OutsideBarDetector, FibonacciEngine, RetracementDetector, ConfluenceManager) with the frozen Structure Manager (StructureManager.mq5) and Indicator Layer (IndicatorManager.mq5) without altering frozen interfaces.

## 2. Scope
- Documentation only.
- No source code modifications to frozen Sprint 1–3 modules.
- No new hidden logic.
- Define how PriceActionManager (existing skeleton) will coordinate updates.
- Define dependency direction: Indicator → Structure → Price Action (read-only consumption).
- Reserve event types (PriceActionEventIDs.mqh) and error ranges (1400–1499) already defined.

## 3. Architecture Analysis
Existing architecture maintains strict separation:
- Sprint 1: Infrastructure (Config, Logger, Time, Data, Init/Shutdown)
- Sprint 2: Indicator (EMA, ATR, IndicatorManager)
- Sprint 3: Structure (Swing, Storage, BOS, CHOCH, Trend, StructureManager)
- Sprint 4: Price Action (CandleClassifier, Engulfing, PinBar, InsideBar, OutsideBar, Fibonacci, Retracement, Confluence, PriceActionManager)

The integration must remain read-only from Price Action to Structure, with Structure providing confirmed patterns and trends to Price Action modules.

## 4. Module Responsibilities

PriceActionManager (mql5/modules/PriceActionManager.mq5 — currently skeleton):
- Orchestrate initialization of all 8 Price Action sub-modules.
- Coordinate Update sequence: CandleClassifier → Engulfing → PinBar → InsideBar → OutsideBar → Fibonacci → Retracement → Confluence.
- Provide Status, Init, Shutdown only.

CandleClassifier.mq5:
- Classify candle patterns from closed candles (already implemented in SPR4-002/SPR4-002A)
- Provide PatternType result.

EngulfingDetector.mq5 / PinBarDetector.mq5 / InsideBarDetector.mq5 / OutsideBarDetector.mq5:
- Detect specific patterns using CandleClassifier outputs.
- No direct Strategy/Entry logic.

FibonacciEngine.mq5 / RetracementDetector.mq5:
- Compute retracement zones using Structure-layer swing data (via SwingStorage / StructureManager updates).
- No trend logic embedded.

ConfluenceManager.mq5:
- Aggregate results from detectors; does not make decisions.

## 5. Public Interface Contracts (Frozen / Proposed)

PriceActionManagerInit() → bool
PriceActionManagerShutdown() → void
PriceActionManagerStatus() → bool
PriceActionManagerUpdate() → bool  [future: call all sub-updates in sequence]

CandleClassifier:
Init / Shutdown / Status / Configure / Update / Ready / GetPattern (PatternType)

EngulfingDetector / PinBarDetector / InsideBarDetector / OutsideBarDetector:
Init / Shutdown / Status / Configure / Update / Ready / GetPattern (PatternType)

FibonacciEngine:
Init / Shutdown / Status / Configure / Update / Ready / GetRetracement (double)

RetracementDetector:
Init / Shutdown / Status / Configure / Update / Ready / GetRetracementValue (double)

ConfluenceManager:
Init / Shutdown / Status / Update / Ready / GetConfluence (PatternType / double composite)

## 6. Internal Sequence Flow (Proposed / Not Yet Implemented — Design Only)

Init Sequence (proposed):
1. CandleClassifierInit
2. EngulfingInit
3. PinBarInit
4. InsideBarInit
5. OutsideBarInit
6. FibonacciInit
7. RetracementInit
8. ConfluenceInit

Update Sequence (proposed):
1. CandleClassifierUpdate (source of pattern)
2. EngulfingUpdate (reads CandleClassifier pattern)
3. PinBarUpdate
4. InsideBarUpdate
5. OutsideBarUpdate
6. FibonacciUpdate (reads SwingStorage / Structure if needed)
7. RetracementUpdate
8. ConfluenceUpdate (aggregates all above)

Shutdown Sequence (reverse):
ConfluenceShutdown → RetracementShutdown → FibonacciShutdown → OutsideBarShutdown → InsideBarShutdown → PinBarShutdown → EngulfingShutdown → CandleClassifierShutdown

## 7. Error Handling

No new Logger integration in module own code (existing TODO patterns preserved).
If any sub-module fails initialization, PriceActionManagerInit should return false and not continue (same as IndicatorManager/StructureManager pattern).
No exceptions thrown.

## 8. Acceptance Criteria

- [ ] All Price Action interfaces documented and frozen
- [ ] No hidden dependency on Strategy / Trading / AI / Risk
- [ ] Structure layer interfaces remain read-only to Price Action
- [ ] CommonTypes PatternType / PatternStrength available
- [ ] PriceActionEventIDs.mqh registered
- [ ] PriceActionErrorCodes.mqh reserved
- [ ] Integration test framework supports PriceActionManager lifecycle (SPR4-??? future)

## 9. Self-Review

Compile: Not required for doc-only task (existing modules compile).
Architecture: APPROVED. No circular dependencies. Dependency direction preserved (Structure → Price Action read-only).
Hidden modifications: NONE.
Technical debt: LOW (future integration of PriceActionManager with actual pattern logic remains deferred; all module skeletons frozen).

STOP — Awaiting SPR4-014 or next approved architecture task.
