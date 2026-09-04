# SPR6-017 - Deterministic Price Action Patterns

## Outcome

The candle-pattern placeholders now evaluate validated, closed H1 candles through pure deterministic functions. Candle classification, engulfing, pin bar, inside bar, and outside bar detection are implemented and integrated into `PriceActionManager`.

## Pattern contract

- Every candle must have a positive timestamp/prices, a non-zero range, a high at or above the body, and a low at or below the body.
- Candle classification uses body/range; a body at or below 10% is a doji.
- Engulfing requires opposite candle directions, a strictly larger current body, and complete body containment. Wick containment is not required.
- Pin bar requires a non-zero body below 30% of range, dominant wick at least 2x body, opposite wick no larger than body, and close in the nearest 25% extreme.
- Inside bar requires complete range containment and at least one strict inner boundary; identical ranges are rejected.
- Outside bar requires complete range containment, at least one strict outer boundary, and a close in the upper/lower 25% to assign direction.
- Two-candle patterns reject reversed or equal chronology.
- `PATTERN_NONE` means a valid evaluation found no pattern; runtime/data validation failure returns `false` from module update.

All thresholds are owned by the typed configuration system and validated centrally. Runtime modules consume only `indicatorConfig.entryTimeframe`, so chart timeframe cannot silently alter strategy behavior.

## Orchestration fixes

`PriceActionManager` now configures every child during initialization, performs reverse-order rollback on failure, and propagates every child update failure. This removes the prior state where initialized-but-unconfigured detectors silently did nothing.

## Verification

Fresh isolated MetaEditor compilation completed with zero errors and zero warnings for `EAMain` and seven deterministic/regression runners: Price Action, Trend, CHOCH, BOS, Swing, Indicator Math, and Lifecycle.

Price Action fixtures cover bullish/bearish/doji classification, invalid OHLC, both engulfing directions, partial overlap, both pin-bar directions, the 30% body boundary, inside/identical ranges, outside/extreme-close behavior, and candle chronology.

## Deferred scope

Pattern-to-structure confluence, Fibonacci context, scoring, false-breakout history, and trade-entry decisions remain downstream stages. This detector layer deliberately reports candle facts without creating orders or strategy decisions.
