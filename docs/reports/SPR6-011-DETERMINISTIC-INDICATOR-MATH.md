# SPR6-011 — Deterministic Indicator Math Foundation

**Status:** COMPLETE — PURE EMA/ATR CORE AND FIXTURE RUNNER COMPILE CLEAN

## Purpose

Create a broker-independent calculation seam before replacing the placeholder
runtime calculations. This separates formula correctness from MT5 history,
symbol synchronization, array orientation, and broker-feed behavior.

## Data Contract

- All input arrays are chronological: index 0 is the oldest closed bar.
- The last element is the newest closed bar.
- The current forming candle is excluded.
- Prices must be finite and positive.
- OHLC arrays used by ATR must have equal lengths.
- Every close must be inside its candle's low/high range.
- A calculation with insufficient warm-up data returns `false` and clears its
  output to zero.

## EMA Contract

- Initial value: SMA of the first `period` samples.
- Multiplier: `2 / (period + 1)`.
- Remaining samples: standard recursive EMA update.
- At least `period` closed prices are required.

## ATR Contract

- True Range includes the previous-close gap.
- First True Range uses the first candle's high-low range.
- Initial ATR: arithmetic mean of the first `period` True Ranges.
- Remaining samples: Wilder smoothing.
- At least `period` closed candles are required.

## Files

- `mql5/include/IndicatorMath.mqh` — pure validation, EMA, True Range, and
  Wilder ATR calculations.
- `tests/IndicatorMathTestRunner.mq5` — known-answer and invalid-input fixtures.
- `tests/TestFramework.mqh` — shared assertion and summary reporting.

## Fixture Coverage

- EMA known-answer rising series.
- EMA exact seed window.
- EMA insufficient history, invalid price, and invalid period.
- Gap-aware True Range known answer.
- Constant-range ATR known answer.
- Wilder-smoothed ATR known answer.
- Misaligned arrays, invalid candle, and invalid ATR period.

## Compile Verification

MetaEditor 5 result:

```text
IndicatorMathTestRunner.mq5: 0 errors, 0 warnings
```

## Runtime Integration Gate

The pure core is intentionally not yet wired into `EMAEngine` or `ATREngine`.
Before that change, the runtime configuration contract must explicitly define:

1. Trend timeframe (strategy source currently says H4).
2. Entry/structure timeframe (strategy source currently says H1).
3. EMA50 and EMA200 ownership; the current engine models one EMA only.
4. Applied-price mapping for every supported `ENUM_APPLIED_PRICE` value.
5. Required history and behavior while data are not synchronized.
6. Whether ATR is calculated on H4, H1, or separately on both.

No runtime or Strategy Tester PASS is claimed until these decisions are encoded
and the compiled script is executed inside MT5.
