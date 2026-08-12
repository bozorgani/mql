SPR5-006 — Backtest Harness Architecture Design
================================================
Status: DESIGN ONLY — NO IMPLEMENTATION — READY FOR REVIEW

1. OBJECTIVE
Design a regression and validation harness to verify that the frozen
Structure (Swing/Storage/BOS/CHOCH/Trend/StructureManager) and Price Action
(CandleClassifier/Engulfing/PinBar/InsideBar/OutsideBar/Fibonacci/Confluence/
PriceActionManager) modules integrate without error under simulated feed
conditions.

2. SCOPE (Read-only / Observation only)
- Initialize Structure layer (StructureManager.Init)
- Initialize Price Action layer (PriceActionManager.Init)
- Execute StructureManager.Update()
- Execute PriceActionManager.Update()
- Capture outputs (GetPattern, GetTrendDirection, etc.)
- Shutdown reverse order
- Verify no exceptions / no hidden state corruption

3. FILES ADDED / MODIFIED
- docs/reports/SPR5-006-REPORT.md (this document)
- No frozen source files edited
- No new runtime dependencies added

4. ARCHITECTURE (Dependency Graph for Test)

Input (Synthetic / Mock Historical Price Series)
    |
    v
[CandleClassifier] --pattern--> [EngulfingDetector] --pattern--> ...
    |
    v
[SwingDetector] --> [SwingStorage] --> [BOSDetector] --> [CHOCHDetector]
    |
    v
[TrendEngine] --> [StructureManager] --> [PriceActionManager]
    |
    v
[Test Harness Log / Report]

Note: Harness reads from frozen modules only; does NOT inject mock
strategic logic, orders, or risk evaluation.

5. INTEGRATION SEQUENCE

Step 1: StructureManager.Init()
Step 2: PriceActionManager.Init()
Step 3: StructureManager.Update()
Step 4: PriceActionManager.Update()
Step 5: Capture GetPattern() / GetTrendDirection() / GetLastSwingPrice() etc.
Step 6: Verify ready flags true
Step 7: StructureManager.Shutdown()
Step 8: PriceActionManager.Shutdown()

6. DATA REQUIREMENTS
- Synthetic OHLC series (closed bars only, index 1..N) compatible with
  MQL5 Series/Indicator access patterns.
- No live market connection required for regression.
- No persistent database writes.

7. LIMITATIONS
- Does not validate pattern accuracy (requires domain expert review).
- Does not generate trading signals.
- Does not test execution, risk, or AI modules.
- Only validates interface contract adherence and lifecycle stability.

8. VALIDATION CHECKLIST
- [ ] All frozen interfaces respond correctly
- [ ] No circular dependency detected
- [ ] Init -> Update -> Shutdown completes without error
- [ ] Read-only dependency preserved (Structure -> Price Action)
- [ ] Compile remains PASS
- [ ] No hidden logic observed

9. TECHNICAL DEBT NOTE
Low. Deferred to future if full historical backtest runner required.

10. SELF-REVIEW
- Documentation only: Yes
- Frozen modules edited: No
- New hidden logic: None
- Compile impact: None
- Architecture preserved: Yes
