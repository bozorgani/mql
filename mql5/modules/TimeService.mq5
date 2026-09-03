// SPR1-005 Final Freeze — TimeService
string FormatDate(datetime v){ return TimeToString(v,TIME_DATE); }
string FormatTime(datetime v){ return TimeToString(v,TIME_SECONDS); }
string FormatDateTime(datetime v){ return TimeToString(v,TIME_DATE|TIME_SECONDS); }
int CompareDateTime(datetime a,datetime b){ if(a<b) return -1; if(a==b) return 0; return 1; }
/// Unchanged helpers from previous versions
datetime GetServerTime(){ return TimeCurrent(); }
datetime GetLocalTime(){ return TimeLocal(); }
bool IsValidTimestamp(datetime d){ return d>0; }
bool IsSameDay(datetime a,datetime b){
  MqlDateTime left;
  MqlDateTime right;
  TimeToStruct(a,left);
  TimeToStruct(b,right);
  return left.year==right.year && left.mon==right.mon && left.day==right.day;
}
bool IsSameHour(datetime a,datetime b){
  MqlDateTime left;
  MqlDateTime right;
  TimeToStruct(a,left);
  TimeToStruct(b,right);
  return left.year==right.year && left.mon==right.mon && left.day==right.day && left.hour==right.hour;
}
long SecondsBetween(datetime a,datetime b){ return (long)(a-b); }
long MinutesBetween(datetime a,datetime b){ return (long)((a-b)/60); }
long HoursBetween(datetime a,datetime b){ return (long)((a-b)/3600); }
bool TimeServiceInit(){ return true; }
void TimeServiceShutdown() { }
