# Enterprise Regression & Verification Framework
No code. Mandatory before merge.

Policies: Any change -> regression suite; no merge without pass.
Unit: Each module isolated; boundary + failure injection; expected outputs verified.
Integration: Module pairs + full chain (Data->EMA->Structure->BOS->Score->Risk->Exec->Log).
Smoke: Startup, config load, feed connect, basic calc.
Acceptance: All strategy rules executed; no violation; score consistent.
Boundary: Min/max ATR, spread threshold, score edge 50/75/90, position limit 2.
Failure injection: Missing feed, bad config, execution reject, emergency shutdown trigger.
Performance: Execution time <= baseline +10%; memory stable.
Memory: No growth over 1000 ticks; no leaks.
Logging: All required events present; format valid; levels correct.
Config: All params load; no hardcode changes undetected.
Risk: 0.5% max; 2 positions max; emergency stop works.
Trade validation: All conditions met; rejection correct.
Events: Every event ID emitted when expected.
State: Idle->Scan->Analyze->Score->Validate->Exec->Manage->Log.
Errors: Handled gracefully; logged ERROR/CRITICAL; recovery possible.
Backtest: Replay same data; results within 2% of baseline.
Forward: Paper/live split; no undisclosed changes.
Release checklist: All tests pass; docs updated; audit sign-off; no hidden changes.
Per module: Mandatory tests listed; failure conditions; regression risks; verification checklist.
