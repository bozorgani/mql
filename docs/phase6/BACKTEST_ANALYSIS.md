# Phase 6 — Backtest & Optimization (Robustness Focus)
Test: Multi-year, multi-condition (trend/sideways/volatility), EURUSD + USDJPY.
Metrics: Win rate, Profit Factor (>1.2 target), Max DD (<15%), Recovery Factor, Avg trade, Sharpe-like risk-adjusted, consecutive losses.
Anti-overfit: Out-of-sample holdout; parameter stability across years; no curve-fit to single year.
Evidence-based improvements only: If drawdown exceeds threshold → tighten risk or add filter; if win rate low in sideways → add structure validity check.
No optimization solely for max profit.
