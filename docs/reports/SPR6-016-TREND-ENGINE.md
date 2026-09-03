# SPR6-016 - Deterministic Trend Engine

## Outcome

The Trend Engine now classifies closed-H4 market conditions from EMA50/EMA200 alignment plus confirmed H1 swing structure. It no longer waits for CHOCH readiness, which previously prevented normal trend evaluation until a reversal event occurred.

## Classification contract

- EMA distance is `abs(EMA50 - EMA200) / EMA200`.
- Price between the EMAs, or EMA distance at or below 0.5%, produces the weak sideways filter state.
- Bullish requires closed price above EMA50, EMA50 above EMA200, and an HH/HL pair.
- Bearish requires closed price below EMA50, EMA50 below EMA200, and an LH/LL pair.
- Strong requires distance above 1.5% and two consecutive aligned structure sequences.
- A directional EMA layout without matching structure remains unknown rather than producing a premature trend.
- Three ordered highs and three ordered lows are required, making strong-trend evidence explicit and preventing malformed history from being accepted.

The detailed section 4.2 threshold of 1.5% is used for strong classification. This resolves the earlier summary line that mentioned 1% but did not define the final classification rule.

## Configuration and runtime

The 0.5% and 1.5% thresholds are owned by the typed configuration record and validated centrally. `StructureManager` applies them to `TrendEngine`; it also now propagates Swing, storage, BOS, CHOCH, and Trend update failures instead of silently returning success.

Sideways based on 20 H4 candles, ATR floor, and recent EMA-cross history is intentionally not claimed by this stage because those historical inputs are not yet modeled. The current sideways value is specifically the documented weak/converged EMA filter state.

## Verification

Fresh isolated MetaEditor compilation completed with zero errors and zero warnings for:

- `EAMain.mq5`
- `TrendMathTestRunner.mq5`
- `CHOCHMathTestRunner.mq5`
- `BOSMathTestRunner.mq5`
- `SwingMathTestRunner.mq5`
- `IndicatorMathTestRunner.mq5`
- `LifecycleTestRunner.mq5`

Trend fixtures cover strong/normal bullish, strong bearish, converged EMAs, price between EMAs, mismatched structure, exact thresholds, invalid numeric inputs, invalid threshold ordering, and invalid swing chronology.
