# SPR6-012 — Runtime Indicator Contract

**Status:** COMPLETE AT SOURCE/COMPILE LEVEL — TERMINAL RUNTIME PENDING

## Canonical Runtime Decisions

- Fast trend EMA: 50 periods.
- Slow trend EMA: 200 periods.
- EMA timeframe: H4.
- EMA applied price: closed-candle close (`PRICE_CLOSE`).
- ATR: Wilder ATR(14).
- ATR timeframe: H1, matching the entry/structure context.
- Entry/structure timeframe: H1.
- Forming candle: always excluded; history starts at shift 1.
- Warm-up history: 10 times the longest configured period.

These defaults implement the Phase 2 strategy source while retaining validation
and centralized ownership in `ConfigSystem`.

## Runtime Data Safety

`MarketData.LoadClosedRates` now:

- rejects empty symbols, invalid timeframes, and non-positive counts;
- selects the requested symbol before copying history;
- requests only closed bars from shift 1;
- fails unless the full requested history is available;
- normalizes arrays to chronological order;
- rejects invalid timestamps, non-positive OHLC, high below low, and
  non-monotonic timestamps.

No partial-history calculation is accepted.

## EMA Runtime

`EMAEngine` now calculates independent EMA50 and EMA200 values from H4 closed
bars through the tested pure EMA core. It supports all standard
`ENUM_APPLIED_PRICE` mappings and exposes fast, slow, and value-availability
accessors. The legacy `EMAValue` and `EMAConfigure` interfaces remain available.

## ATR Runtime

`ATREngine` now calculates gap-aware Wilder ATR(14) from H1 closed OHLC history.
The former Bid/Ask spread placeholder has been removed. The legacy
`ATRConfigure` interface remains available.

## Verification

MetaEditor 5 compilation:

```text
EAMain.mq5:                  0 errors, 0 warnings
LifecycleTestRunner.mq5:     0 errors, 0 warnings
IndicatorMathTestRunner.mq5: 0 errors, 0 warnings
```

Fixture coverage includes every applied-price mapping, EMA seed/progression,
gap-aware True Range, Wilder smoothing, invalid OHLC, insufficient history,
misaligned arrays, and invalid periods.

## Remaining Runtime Gate

Actual terminal execution is still required to verify history synchronization,
symbol availability, broker-specific data, and first-start behavior. Until that
run occurs, the status is compile-verified rather than runtime-verified.

The next market-logic step is a corrected, fixture-driven H1 swing detector.
BOS, CHOCH, and Trend must remain blocked from strategy acceptance until that
foundation is complete.
