# PHASE 2 — Strategy Specification (Source of Truth)
Role: Senior Quant / Risk Manager / Architect. No code.

## 1. Trading Environment
- MT5 EA, Swing, EURUSD/USDJPY
- Trend: H4, Entry: H1, 24h
- Primary: Price Action (BOS, CHoCH, HH/HL/LH/LL defined precisely)
- Secondary: Fib 38.2/50/61.8 with invalidation rules
- Filter: EMA50/200 (Trend: Bull/Bear/Weak/Strong/Sideways — defined with thresholds)
- Volatility: ATR14 (min/max thresholds defined; too low/high = no trade)

## 2. Definitions (Programmatic)
- Market Structure: Swing High/Low confirmed by 3-bar pivot.
- BOS: Price breaks prior swing high/low + closes past.
- CHoCH: Internal shift (lower high after uptrend, etc.).
- Fib: Drawn from latest confirmed swing to prior opposite swing; invalid if new swing forms beyond origin.

## 3. Entry Decision Tree (BUY / SELL)
BUY: Trend=Bulish/Strong, Structure=BOS/CHoCH, Fib zone 38.2-61.8, ATR within range, Confirmation (Pin/Engulf/Break) ranked strongest to weakest, Score >= threshold.
SELL: Mirror.

## 4. Scoring (0-100)
Trend 20 | Structure 20 | PA 15 | Fib 15 | ATR 10 | Spread/Session 10 | S/R distance 10
Rejected <50 | Accepted 50-75 | High 76-89 | Excellent 90+

## 5. Risk Management
- Risk/trade 0.5%, Max 2 positions, No martingale/grid/avg down
- Daily loss cap, Weekly loss cap, Consecutive loss cap defined
- Emergency shutdown rules listed
- SL: ATR + Swing + Structure (advantages/disadvantages documented)
- TP V1: RR 1:2 fixed; weaknesses noted; future improvements listed

## 6. Trade Management
Break-even (defined %), Trailing stop (ATR-based), Partial close (defined %), Max duration, Weekend rules.

## 7. No-Trade Conditions (All Listed)
High spread, low liquidity, major news, invalid structure, weak trend, low ATR, too many open, daily limit, close conditions.

## 8. Logging / Config / AI Dataset
Every trade logs 14 fields (see spec). Config: all parameters external. AI dataset: features listed (trend, structure, PA pattern, Fib zone, ATR, EMA, score, result, execution time, session).

## 9. Validation
Contradictions checked; ambiguous logic flagged; duplicates removed; programming difficulties noted. No hidden assumptions.
