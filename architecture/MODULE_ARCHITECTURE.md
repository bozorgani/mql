# Module Architecture
- Core: Trade manager, Risk manager, Connector
- Strategy: Pluggable (no logic in core)
- AI: Python bridge (future)
- Backtest: Isolated environment
- Forward: Live log only
Principles: Single responsibility; interfaces defined; no hidden state.
