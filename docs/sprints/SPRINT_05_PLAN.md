# Sprint 5 Plan — Integration, Testing & Validation (Architecture-First)

## 1. Sprint 5 Objectives
Build the integration, regression, and validation layer that connects Sprint 3 Structure with Sprint 4 Price Action without altering frozen interfaces. Confirm that the full pipeline from Swing detection through Price Action recognition to Confluence management operates with verified contracts.

## 2. Scope
- Integration test harness (Structure + Price Action together)
- Regression verification of all Sprint 3-4 modules
- Dependency validation (no hidden coupling introduced)
- Documentation of final architecture
- Technical debt reduction checklist
- No new trading logic, no strategy, no AI, no execution

## 3. Architecture Impact Analysis
- Frozen interfaces (S1-S4) must not change signatures.
- New integration module (optional): PriceActionStructureBridge.mq (read-only observer) may reference both SwingStorage and PriceActionManager to verify data flow.
- All new interfaces must follow existing contracts (PatternType, etc.).
- No removal or deprecation of existing modules.
- Dependency direction must remain: Structure → Price Action (read-only).

## 4. Module Breakdown
SPR5-001 — Integration Test Harness (Structure ↔ Price Action)
SPR5-002 — Regression Suite (full module verification)
SPR5-003 — Dependency Graph Refresh (post-integration)
SPR5-004 — Contract Compliance Audit (all interfaces)
SPR5-005 — Technical Debt Reduction (documented TODOs)
SPR5-006 — Backtest Harness Design (structure-only backtest)
SPR5-007 — Forward Test Design (structure-only)
SPR5-008 — Documentation Update (final architecture guide)

## 5. Public Interface Requirements
Any new integration interfaces must only expose status/check/configure/init/shutdown. No getters for private state. No new PatternType variants unless via shared CommonTypes.mqh.

## 6. Dependency Analysis
Structure (Swing -> Storage -> BOS -> CHOCH -> Trend -> StructureManager) feeds Price Action (CandleClassifier -> ... -> ConfluenceManager) via read-only observation. No circular dependency exists. No hidden dependency introduced.

## 7. Risks and Mitigations
- Risk: Integration introduces hidden coupling via direct module references.
  Mitigation: Use only existing public interfaces; no direct state access.
- Risk: New regression tests may reveal hidden interface drift.
  Mitigation: Compare all interfaces against SPR3-000 / SPR4-010 contracts.
- Risk: Sprint 5 scope creep into strategy or execution.
  Mitigation: Explicit exclusion list (no Entry/Exit/Risk/AI/Order).

## 8. Acceptance Criteria
- All frozen modules compile without modification.
- Integration tests pass (no failures from hidden coupling).
- Dependency graph confirms acyclic structure.
- All SPR3-XXX / SPR4-XXX interfaces remain identical.
- Documentation updated.
- Technical debt documented, not hidden.
