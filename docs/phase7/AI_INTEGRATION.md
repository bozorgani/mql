# Phase 7 — AI Decision-Support (Not Control)
Principle: EA is final authority; AI suggests only.

Python Module: Feature extraction from MT5 export; model evaluation with SHAP/explainability.
Data Pipeline: Logger → CSV/DB → Python; structured features (trend, PA, Fib, ATR, score, execution time).
Responsibilities: Trade quality scoring (align with 0-100), pattern recognition, market condition classification, risk filtering suggestions.
Communication: Python writes recommendation file; EA reads and logs; EA decides.
No black box: Every AI output includes feature importance + explanation string.
