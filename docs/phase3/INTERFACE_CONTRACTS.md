# Enterprise Interface Contracts (Task 010 — Approved Phase 2)
No code. Mandatory for all implementations.

## Module Contracts (Summary — Full spec in doc)
Configuration Manager: Input file; Output params; Preconditions file exists; Postconds loaded; Errors parse; Deps none; State load only.
Logger: Input event; Output record; Preconditions event valid; Postconds persisted; Errors disk; Deps none.
Market Data Provider: Input tick; Output price; Preconds feed active; Postconds updated; Deps none.
EMA Engine: Input H4 closes; Output EMA50/200; Preconds 200 bars; Postconds calculated; Deps Market Data.
ATR Engine: Input H1 closes; Output ATR14; Preconds data; Postconds within range; Deps Data.
Swing Detector: Input prices; Output swings; Preconds data; Postconds sorted; Deps Data.
Market Structure: Input swings; Output state; Preconds swings; Postconds valid; Deps Swing/EMA.
BOS Detector: Input swings+price; Output boolean; Preconds confirmed; Postconds true/false; Deps Structure.
CHoCH Detector: Input swings; Output boolean; Preconds trend; Postconds true/false; Deps Structure.
Fibonacci Engine: Input swings; Output zones; Preconds 2 swings; Postconds zones/invalid; Deps Swing.
Price Action Engine: Input candles+swing; Output pattern+score; Preconds structure; Postconds 0-100; Deps Swing/Structure.
Trend Filter: Input EMA+price; Output trend; Preconds EMA; Postconds classified; Deps EMA.
Trade Scoring: Input all factors; Output 0-100; Preconds inputs; Postconds score; Deps PA/Fib/ATR/Trend.
Risk Manager: Input score/ATR/spread; Output approve/reject/SL/TP; Preconds score known; Postconds risk<=0.5%; Deps Trend/Scoring.
Position Sizing: Input equity/risk/SL; Output lots; Preconds approval; Postconds <=2 positions; Deps Risk.
Trade Validator: Input decision; Output yes/no; Preconds all filters; Postconds consistent; Deps Risk/Trend/PA/Fib/ATR/Spread/News.
Trade Executor: Input order; Output report; Preconds valid; Postconds executed; Deps MT5.
Trade Journal: Input event; Output log; Preconds event; Postconds stored; Deps Logger.
Statistics Engine: Input results; Output metrics; Preconds data; Postconds computed; Deps Journal.
AI Interface: Input features; Output recommendation; Preconds data; Postconds explainable; Deps Logger/Journal.

## System Documents
Dependency Graph: Config->Data->EMA/ATR/Swing->Structure->BOS/CHoCH->Fib/PA->Trend/Score->Risk->Sizing/Validator->Executor->Logger/Journal->AI.
No circular dependencies; single direction.
Execution Sequence: Config load -> Data feed -> EMA/ATR/Swing -> Structure -> BOS/CHoCH -> Fib/PA -> Trend -> Score -> Risk -> Validator -> Sizing -> Execute -> Log.
Init Order: Config, Data, Logger, EMA, ATR, Swing, Structure, BOS/CHoCH, Fib, PA, Trend, Score, Risk, Validator, Executor, Journal, Stats, AI.
Shutdown Order: Stop new trades -> Close open -> Log -> Shutdown AI/Stats/Log last.
Error Propagation: Module error -> Log -> Risk guard -> Halt if critical -> No hidden changes.
State Transitions: Idle -> Scan -> Analyze -> Score -> Validate -> Execute -> Manage -> Log -> Idle.

Validation complete: No ambiguity; no circular; no duplicates; all inputs/outputs defined; contracts mandatory.
