# AI Dataset Specification (Per Trade)
Stored fields:
- Pair, Timestamp, Session, Spread
- Trend: EMA50, EMA200, TrendState, StrengthScore
- Structure: LastSwingHigh, LastSwingLow, BOS boolean, CHoCH boolean
- Pattern: Type, Strength, Rank, ConfirmationScore
- Fibonacci: Zone (38.2/50/61.8), Valid boolean, DistanceToZone
- ATR14, ATRQuality, VolatilityState
- ScoreComponents: Trend20, Structure20, PA15, Fib15, ATR10, Spread10, SR10
- TradeScore, Decision (Buy/Sell/No), Risk%, SL_pips, TP_pips
- Result (Win/Loss), ProfitPips, DurationHours
- ConsecutiveLosses, DailyDrawdownAtEntry, WeeklyDrawdownAtEntry
- ExecutionTime, MagicNumber, LogFilePath
- AI_Recommendation (future): SuggestedScore, ExplanationString, FeatureImportance
Format: CSV per month + JSON feature store; time-series indexed by Timestamp.
