# SPR6-015 - Confirmed CHOCH Detector

## Outcome

The placeholder CHOCH module now detects a confirmed counter-trend market-structure shift from closed H1 data. BOS remains continuation-only; counter-bias breaks are owned exclusively by CHOCH.

## Detection contract

- Requires three valid, chronologically ordered swing highs and three swing lows.
- Bearish CHOCH requires a previously bullish HH/HL structure, a subsequent lower high, and a closed candle below the protected low.
- Bullish CHOCH requires a previously bearish LH/LL structure, a subsequent higher low, and a closed candle above the protected high.
- Equality with the protected level is not a break.
- An optional non-negative price buffer must be fully exceeded.
- Confirmation must occur after the transition swing.
- Repeated updates for the same direction and transition swing are deduplicated.

## Runtime integration

`StructureManager` initializes CHOCH with an explicit runtime buffer. The detector loads only the latest closed entry-timeframe candle and stores direction, broken level, confirmation close/time, transition swing time, and previous bias.

## Verification

Isolated MetaEditor compilation completed with zero errors and zero warnings for:

- `EAMain.mq5`
- `CHOCHMathTestRunner.mq5`
- `BOSMathTestRunner.mq5`
- `SwingMathTestRunner.mq5`
- `LifecycleTestRunner.mq5`

The CHOCH fixture suite covers bullish and bearish confirmation, exact-level rejection, break buffer, missing transition, close chronology, invalid prices, invalid buffer, incorrect swing types, and out-of-order history.

## Deferred scope

Volume, session, volatility, and confluence filters remain downstream concerns. The next structure stage can consume BOS and CHOCH events to implement the trend-state engine without redefining break semantics.
