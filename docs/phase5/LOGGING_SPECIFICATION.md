# Enterprise Logging & Observability Specification
No code. Mandatory for all modules.

Levels: DEBUG (dev details), INFO (normal), WARNING (issues), ERROR (failures), CRITICAL (shutdown/kill).
Categories: System, Market, Indicators, PA, Risk, Orders, Execution, AI, Performance, Config, Security.
Standard format: Timestamp|Module|EventID|Severity|Pair|Timeframe|TradeID|Message|Meta(JSON)
Event IDs: CFG-001/EMA-101/ATR-201/BOS-301/RISK-401/EXEC-501/AI-601 etc.
Mandatory events per module: Config load/init/shutdown, calc, validation, execution/rejection, risk reject, errors, exceptions, recovery.
Performance: Exec time, memory, tick latency, freq.
Files: /logs/YYYY/MM/DD/module_level.json; rotation daily; retain 90d; archive yearly.
Backtest extra: Tester period, spread at entry, slippage, execution delay, model vs tick.
Live extra: Broker connection status, margin level, float P/L, pending orders, server time sync.
AI dataset fields: All trade features (pair, timestamp, trend, structure, pattern, fib, atr, score, result, duration, drawdown) + explanation + feature importance.
Security: No passwords in logs; mask account numbers; validate file permissions; tamper detection via checksum/hashing.
Compatible with interface contracts; no module uses private format.
