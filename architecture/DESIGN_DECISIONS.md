# Design Decisions
- Modular: MQL5 EA, Python AI, Backtest, Forward Test isolated.
- Docs-as-code: Markdown in repo; AI context preserved via structured docs.
- VCS: Git, protected main, feature branches, PR required.
- Change mgmt: RFC -> Review -> Merge -> Log.
- No hidden changes: All config in versioned files, not env secrets.
- No trading code in architecture phase.
