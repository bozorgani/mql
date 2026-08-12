#pragma once
// SPR1-004 Utility Library — generic helpers only; pure; no mutable state
/// Numeric: clamp value between min/max
double Clamp(double v,double mn,double mx){return v<mn?mn:(v>mx?mx:v);}
/// Numeric: near equality with epsilon
double MinValue(double a,double b){return a<b?a:b;}
double MaxValue(double a,double b){return a>b?a:b;}
bool IsNearlyEqual(double a,double b,double e=0.00001){return MathAbs(a-b)<=e;}
/// String: trim whitespace
string Trim(string s){return StringTrimLeft(StringTrimRight(s));}
string ToUpper(string s){return StringUpper(s);}
string ToLower(string s){return StringLower(s);}
/// Validation: check number valid
bool IsValidNumber(double v){return !MathIsNaN(v);}
bool IsFinite(double v){return !MathIsNaN(v) && v!=DBL_MAX;}
/// Array: safe size
int SafeArraySize(void &arr){return ArraySize(arr);}
bool IsArrayEmpty(void &arr){return ArraySize(arr)<=0;}
/// Formatting: price/percentage/timestamp generic
string FormatPrice(double p){return DoubleToString(p,5);}
string FormatPercentage(double p){return DoubleToString(p,2)+"%";}
string FormatTimestamp(datetime t){return TimeToString(t);}
