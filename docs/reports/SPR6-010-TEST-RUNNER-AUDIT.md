# SPR6-010 — Test Runner Prerequisite Audit

**Status:** LIFECYCLE RUNNER READY; MARKET/STRATEGY SUITES BLOCKED BY UNIMPLEMENTED OR AMBIGUOUS CONTRACTS

## Result

`tests/LifecycleTestRunner.mq5` and `tests/TestFramework.mqh` provide the first
executable, deterministic MQL5 test suite. The complete runner translation unit
compiles in MetaEditor 5 with:

```text
Result: 0 errors, 0 warnings
```

The suite covers configuration validation, logger lifecycle, indicator-manager
lifecycle, structure-manager lifecycle, price-action-manager lifecycle, shutdown
state, and deterministic time helpers. Every assertion prints an explicit PASS
or FAIL and the suite prints aggregate totals.

## Test Boundaries

The runner deliberately does not claim correctness for calculations that need
historical candles, a broker feed, Strategy Tester, or modules that are still
placeholders. Compile success is not treated as runtime or strategy success.

Planned suite separation:

1. Contract/lifecycle — deterministic and independent of market history.
2. Market-data calculations — fixed historical fixture and Strategy Tester.
3. Strategy acceptance — scoring, risk, execution, and no-trade rules after
   their contracts and implementations exist.

## Critical Logic Findings Before Market Tests

1. `ATREngine` uses Bid/Ask placeholders as high/low/close. Its current value is
   primarily spread-derived, not a valid ATR(14) over closed candles.
2. `EMAEngine` consumes the current Bid and ignores the configured applied-price
   value. The strategy requires H4 close data.
3. The strategy requires EMA50 and EMA200, while the current indicator contract
   and engine represent only one EMA instance (EMA50).
4. `SwingDetector` compares bar 1 with bars 2 and 3. This is not the documented
   centered three-bar pivot and does not provide the documented confirmation
   delay.
5. BOS copies the stored swing; CHOCH copies BOS; Trend does not classify actual
   structure. These are placeholders and cannot receive meaningful strategy
   assertions yet.
6. Engulfing, Pin Bar, Inside Bar, Outside Bar, Fibonacci, Retracement, and
   Confluence updates do not yet implement their documented calculations.
7. Several `Ready()` states require configuration and/or calculated data, while
   manager startup currently initializes children without configuring the
   Structure and Price Action layers. `Status()` and `Ready()` must not be
   treated as interchangeable.

## Specification Decisions Required Before Strategy Acceptance Tests

1. Entry score threshold conflicts: the compact specification accepts at 50,
   while the expanded BUY/SELL requirements specify 60.
2. The roadmap labels Sprint 6 as Risk/Validation, while the current Sprint 6
   plan labels it First Runnable Integration. One roadmap must become canonical.
3. Spread limits are written as 20/30 pips. For EURUSD/USDJPY this may mean
   points rather than pips and must be confirmed before coding.
4. The stop-loss rule uses `min` without an unambiguous price-coordinate versus
   distance definition for BUY and SELL.
5. ATR min/max thresholds, session hours, news-source behavior, timezone, and
   missing-calendar fallback need symbol-specific executable definitions.

## Next Implementation Gate

Before market-dependent tests are enabled:

- approve canonical strategy values and units;
- introduce deterministic candle/price access instead of direct terminal calls;
- implement EMA50/EMA200 and true ATR over closed bars;
- correct swing confirmation semantics;
- then add fixture-driven indicator and structure suites.

Runtime execution of the lifecycle script inside an MT5 terminal remains to be
performed after deploying the repository layout under the terminal's MQL5 data
directory. No runtime PASS is claimed in this report.
