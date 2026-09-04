# SPR6-018 - Confirmed-Swing Fibonacci and Retracement

## Outcome

`FibonacciEngine` and `RetracementDetector` now operate on confirmed H1 swing history. The implementation separates pure anchor/level mathematics from runtime data access and exposes stable results for the later confluence layer.

## Anchor contract

- The newest confirmed swing is the candidate endpoint; the engine searches backward for the latest opposite-type origin.
- Consecutive same-type endpoints keep the earlier endpoint unless a later high/low extends it by more than the configured 0.5% invalidation threshold.
- Origin and endpoint must be chronological, opposite types, directionally consistent, and separated by strictly more than 3% of origin price.
- The origin must be within 40 closed H1 bars. Stale or insufficient history produces `Ready=false` without treating normal warm-up as a runtime error.
- A newer qualified endpoint causes deterministic redraw; no stale valid object survives a failed replacement.

## Level and zone contract

- Bullish impulse: levels are measured downward from the swing high.
- Bearish impulse: levels are measured upward from the swing low.
- Implemented levels are 38.2%, 50%, and 61.8%.
- Retracement depth is measured from impulse end toward origin and must remain within 0..100%.
- A closed H1 price enters a zone when its normalized distance to the nearest level is at most 0.15%; the nearest level is retained for scoring.
- A valid evaluation outside all zones remains ready with `FIB_NONE`, distinguishing “no zone” from missing/invalid data.

All thresholds and the maximum age are owned and validated by the typed configuration system. The documented 3% minimum is intentionally preserved even though it is restrictive for H1 FX; optimization belongs to later backtesting rather than detector code.

## Runtime integration

`PriceActionManager` applies Fibonacci and retracement configuration. Fibonacci reads `SwingStorage` without mutating structure state. Retracement consumes the current Fibonacci result and only the latest closed entry-timeframe price.

## Verification

Fresh isolated MetaEditor compilation completed with zero errors and zero warnings for `EAMain` plus Fibonacci, Price Action, Trend, CHOCH, BOS, Swing, Indicator Math, and Lifecycle runners.

Fixtures cover both impulse directions, exact 38.2/50/61.8 values, latest-opposite anchor selection, qualified and sub-threshold endpoint replacement, below/equal 3% rejection, nearest-zone selection, non-zone price, extension outside the impulse, invalid anchor chronology, and same-type rejection.
