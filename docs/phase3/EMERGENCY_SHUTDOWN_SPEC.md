# Emergency Shutdown Specification
- Consecutive losses: 4 -> stop trading; alert.
- Daily drawdown: 2% -> halt new trades; recover if back to 1.5% same day.
- Weekly drawdown: 5% -> full stop until Monday review.
- Kill Switch: Floating loss >3% OR margin <30% -> close all, disable EA.
- Recovery Mode: After halt, require manual confirmation + score >=70 + trend strong + ATR normal + no news within 30 min; then resume with 0.25% risk first trade.
- Deactivation of shutdown: Only after manual reset + verification of conditions; never automatic.
