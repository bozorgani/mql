# Sprint 1 — Infrastructure (Enterprise Grade)
No code. Only planning.
Goal: Bootstrap project, config, logger, types, utils, time, market interface.
Scope: No strategy/indicators/trade.

Tasks (SPR1-001 to SPR1-020):
SPR1-001 Project Bootstrap — folder/unit init; files: /mql5/modules/; contract: Config; tests: compile; size S; 4h.
SPR1-002 Common Types — structs/enums; files: CommonTypes.mqh; contract: interfaces; tests: unit; S; 3h.
SPR1-003 Constants Registry — fixed constants; files: Constants.mqh; tests: unit; XS; 2h.
SPR1-004 Utility Library — math/format helpers; files: Utils.mqh; tests: unit; S; 4h.
SPR1-005 Time Service — timestamp/session; files: TimeService.mq5; contract: Logger time; tests: unit; S; 3h.
SPR1-006 Config Loader — load inputs; files: ConfigSystem.mq5; contract: Config Manager; tests: unit+int; S; 4h.
SPR1-007 Config Validator — range checks; files: ConfigValidator.mq5; contract: Config; tests: failure; S; 3h.
SPR1-008 Logger Core — init/levels; files: LoggerCore.mq5; contract: Logging Spec; tests: unit; S; 4h.
SPR1-009 Logger File Writer — JSON lines; files: LoggerFile.mq5; contract: Logging; tests: integration; S; 3h.
SPR1-010 Event ID Generator — CFG/EMA/ATR etc; files: EventIDs.mqh; contract: Logging; tests: unit; XS; 2h.
SPR1-011 Error Code Registry — codes; files: ErrorCodes.mqh; tests: unit; XS; 2h.
SPR1-012 Market Data Interface — feed abstract; files: MarketData.mq5; contract: Data Provider; tests: interface; S; 4h.
SPR1-013 Symbol Info Service — pair specs; files: SymbolInfo.mq5; tests: unit; S; 3h.
SPR1-014 Initialization Manager — sequence; files: InitManager.mq5; contract: Init order; tests: int; S; 3h.
SPR1-015 Shutdown Manager — stop sequence; files: Shutdown.mq5; contract: Shutdown; tests: int; S; 3h.
SPR1-016 Dependency Graph — doc; files: docs/; tests: review; XS; 2h.
SPR1-017 Infrastructure Integration Tests — full chain; files: tests/; contract: Regression; tests: int; M; 6h.
SPR1-018 Logging Verification — events present; files: tests/; contract: Logging Spec; tests: int; S; 3h.
SPR1-019 Config Regression — change detection; files: tests/; contract: Regression; tests: reg; S; 3h.
SPR1-020 Sprint Exit Review — checklist; files: docs/; tests: audit; XS; 2h.

Dependency: 001->002/003->004/005/006->007->008->009->010->011->012/013->014/015->017->018/019->020.
Critical Path: 001 -> 006 -> 008 -> 012 -> 014 -> 017 -> 020.
Merge Order: 1-5 independently; 6-9 sequenced; 12-15 after 5; 17 after 15; 18-20 last.
DoD: All tests pass; contracts respected; logging spec followed; regression framework applied; no hidden changes; <=3 files/task; <=1 day/task.
Exit: Infrastructure stable; Strategy modules not started; audit sign-off.
