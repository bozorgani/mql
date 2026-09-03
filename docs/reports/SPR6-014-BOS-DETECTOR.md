# SPR6-014 — Directional BOS Detector

**Status:** COMPLETE AT SOURCE/COMPILE LEVEL

## Definition

A BOS is a continuation break confirmed by the close of a completed H1 candle:

- Bullish structure is established only by HH plus HL.
- Bearish structure is established only by LH plus LL.
- Bullish BOS requires a close strictly above the latest confirmed swing high.
- Bearish BOS requires a close strictly below the latest confirmed swing low.
- Equality with the level is not a break.
- A configurable non-negative price buffer may be required beyond the level.
- A break against the established bias is not labeled BOS; it is reserved for
  the CHOCH stage.
- At least two confirmed highs and two confirmed lows are required to establish
  directional structure.

Wicks are not used for confirmation. The runtime reads only the latest closed
H1 candle through `LoadClosedRates(..., shift=1)`.

## State and Deduplication

The detector retains direction, broken level, confirmation close/time, and the
source swing timestamp. Repeated closes beyond the same source swing in the same
direction do not emit a new event. A new confirmed swing level can produce a new
BOS.

## Tests

`BOSMathTestRunner.mq5` verifies bullish and bearish BOS, exact-level rejection,
buffer behavior, one-sided structural-break primitives, invalid inputs,
HH+HL/LH+LL bias inference, and rejection of counter-bias breaks as BOS.

Regression compilation:

```text
EAMain.mq5:              0 errors, 0 warnings
BOSMathTestRunner.mq5:    0 errors, 0 warnings
SwingMathTestRunner.mq5:  0 errors, 0 warnings
LifecycleTestRunner.mq5:  0 errors, 0 warnings
```

## Explicit Boundary

The strategy document mentions volume/filter conditions but does not define an
executable volume threshold or data contract. No arbitrary threshold was added.
This implementation produces a structural BOS; volume, session, spread, ATR,
and scoring remain downstream trade-validation concerns.

Runtime execution against broker history remains pending. The next structure
stage is CHOCH, which will consume counter-bias structural breaks without
relabeling continuation BOS events.
