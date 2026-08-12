# Sprint 3 — Market Structure Layer (Plan Only)
Status: PLANNED — NO CODE

Sprint Goal: Build Swing/BOS/CHoCH/Trend/Structure modules; freeze before Sprint 4.

Task List (SPR3-001 to SPR3-020):
SPR3-001 Swing Detector module (structure only)
SPR3-002 Swing Validation rules
SPR3-003 Swing Storage interface
SPR3-004 BOS Detector module
SPR3-005 CHoCH Detector module
SPR3-006 Trend State Engine
SPR3-007 Structure Manager init
SPR3-008 Structure Manager shutdown
SPR3-009 Structure Manager status
SPR3-010 Market Structure Events
SPR3-011 Structure Logger integration
SPR3-012 Structure Verification tests
SPR3-013 Structure Regression tests
SPR3-014 Structure Documentation
SPR3-015 Dependency Graph update
SPR3-016 Interface contracts (BOS/CHoCH/Trend)
SPR3-017 Backtest harness setup (structure only)
SPR3-018 Sprint Exit Review doc
SPR3-019 Dependency graph refresh
SPR3-020 Merge order / release readiness

Dependencies: All Sprint 2 frozen (EMA/ATR/IndicatorManager). No Sprint 1 changes.
Critical Path: Swing Detection -> Validation -> Storage -> BOS -> CHoCH -> Trend -> Structure Manager -> Tests -> Exit Review
Merge Order: Foundation -> Detection -> Validation -> Storage -> Manager -> Tests -> Docs -> Review
DoD: All modules compile; interfaces frozen; contracts respected; no hidden changes; regression passes; docs complete.
Exit: Structure layer frozen; ready for Sprint 4 (Price Action / Fibonacci / Entry Rules).
