# SPR6-013 — Confirmed Swing Detector and History

**Status:** COMPLETE AT SOURCE/COMPILE LEVEL

## Contract

- Structure timeframe: H1 from the centralized configuration contract.
- Default pivot: one closed candle on each side (three-bar pivot).
- Arrays: chronological, oldest to newest.
- Candidate: the centered candle, never the forming candle.
- Confirmation: only after all right-side candles have closed.
- Comparison: strict high/low inequality; equal highs/lows do not create a pivot.
- Ambiguous outside candle: if the same candle qualifies as both pivot high and
  pivot low, no swing is emitted.
- Duplicate protection: the same timestamp/type is idempotent.

## Implementation

- `StructureMath.mqh` provides pure confirmed-pivot detection and HH/HL/LH/LL
  classification.
- `SwingDetector` loads only closed H1 bars through `MarketData`, applies the
  pure detector, and preserves the most recent confirmed typed swing.
- `SwingStorage` retains up to 100 typed swing points, supports newest-first
  lookup and latest-by-type lookup, and clears history on shutdown.
- `StructureManager` configures the pivot radius and stores typed swings.
- Existing compatibility accessors remain available.

## Verification

`SwingMathTestRunner` covers:

- centered confirmed high;
- centered confirmed low;
- monotonic no-pivot sequence;
- ambiguous outside-bar rejection;
- insufficient confirmation data;
- invalid radius;
- HH, LH, HL, and LL classification;
- typed history ordering, lookup, duplicate idempotence, invalid input, and
  shutdown cleanup.

MetaEditor 5 results:

```text
SwingMathTestRunner.mq5: 0 errors, 0 warnings
EAMain.mq5:              0 errors, 0 warnings
```

Runtime execution against broker history remains pending. BOS and CHOCH must use
the typed swing history in their next implementation stages; their current
placeholder behavior is not considered strategy-valid.
