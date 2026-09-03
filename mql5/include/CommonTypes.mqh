#ifndef MQL5_COMMON_TYPES_MQH
#define MQL5_COMMON_TYPES_MQH
// SPR1-002 Final Freeze + SPR1-003 Prep — CommonTypes frozen

enum TrendDirection { TREND_UNKNOWN=0, TREND_BULLISH, TREND_BEARISH, TREND_SIDEWAYS };
enum TrendStrength { STRENGTH_UNKNOWN=0, STRENGTH_WEAK, STRENGTH_NORMAL, STRENGTH_STRONG };
enum SwingType { SWING_NONE=0, SWING_HIGH, SWING_LOW };
enum SwingRelation { SWING_RELATION_NONE=0, SWING_HH, SWING_HL, SWING_LH, SWING_LL };
enum StructureBreakDirection { BOS_NONE=0, BOS_BULLISH, BOS_BEARISH };
enum MarketStructureBias { STRUCTURE_BIAS_UNKNOWN=0, STRUCTURE_BIAS_BULLISH, STRUCTURE_BIAS_BEARISH };
enum StructureShiftDirection { CHOCH_NONE=0, CHOCH_BULLISH, CHOCH_BEARISH };
enum LogLevel { LOG_DEBUG=0, LOG_INFO, LOG_WARNING, LOG_ERROR, LOG_CRITICAL };
enum ModuleStatus { MODULE_IDLE=0, MODULE_ACTIVE, MODULE_ERROR };
enum ValidationResult { VAL_UNKNOWN=0, VAL_OK, VAL_FAIL, VAL_PENDING };


enum PatternType { PATTERN_NONE, PATTERN_BULLISH, PATTERN_BEARISH, PATTERN_DOJI };
enum PatternStrength { PATTERN_STRENGTH_UNKNOWN, PATTERN_STRENGTH_WEAK, PATTERN_STRENGTH_NORMAL, PATTERN_STRENGTH_STRONG };
enum FibonacciLevel { FIB_NONE, FIB_236, FIB_382, FIB_500, FIB_618, FIB_786 };

struct SwingPoint {
  datetime time;
  double price;
  SwingType type;
};

struct BOSResult {
  StructureBreakDirection direction;
  double level;
  double closePrice;
  datetime closeTime;
  datetime sourceSwingTime;
};

struct CHOCHResult {
  StructureShiftDirection direction;
  double level;
  double closePrice;
  datetime closeTime;
  datetime transitionSwingTime;
  MarketStructureBias previousBias;
};

struct TrendResult {
  TrendDirection direction;
  TrendStrength strength;
  double emaDistanceRatio;
};

#endif // MQL5_COMMON_TYPES_MQH
