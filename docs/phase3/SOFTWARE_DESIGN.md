# Phase 3 — Software Design (No Code)
Decision: Modular single-responsibility; interface-based communication; failure isolation.

## Modules
1. Market Analyzer — inputs: tick/price; outputs: swings/structure; depends: none.
2. Trend Engine — inputs: H4 price; outputs: EMA50/200 + trend state; depends: none.
3. Price Action Engine — inputs: H1 candles + swings; outputs: pattern + score; depends: Market Analyzer.
4. Fibonacci Engine — inputs: swings; outputs: zones + invalid flag; depends: Market Analyzer.
5. Risk Manager — inputs: score, ATR, spread; outputs: approve/reject + SL/TP; depends: Trend, PA, Fib.
6. Trade Manager — inputs: risk decision; outputs: orders + state; depends: Risk, Execution.
7. Execution Engine — inputs: order request; outputs: execution report; depends: none (MT5 API).
8. Logger — inputs: all events; outputs: structured log; depends: none.
9. Config System — inputs: file; outputs: parameters; depends: none.
10. Testing Framework — isolated units + integration harness.
11. Future AI Interface — data export + feature store; depends: Logger.

## Data Flow
Market Analyzer → Parallel (Trend + PA + Fib) → Risk Manager → Trade Manager → Execution → Logger + AI Interface.

## Failure Cases
Per module: missing data = skip; invalid structure = reject; execution error = log + halt; risk breach = emergency shutdown.
