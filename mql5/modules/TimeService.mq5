// SPR1-005 Final Freeze — TimeService
string FormatDate(datetime v){ return TimeToString(v,"yyyy.MM.dd"); }
string FormatTime(datetime v){ return TimeToString(v,"HH:mm:ss"); }
string FormatDateTime(datetime v){ return TimeToString(v,"yyyy.MM.dd HH:mm:ss"); }
int CompareDateTime(datetime a,datetime b){ if(a<b) return -1; if(a==b) return 0; return 1; }
/// Unchanged helpers from previous versions
datetime GetServerTime(){ return TimeCurrent(); }
datetime GetLocalTime(){ return TimeLocal(); }
bool IsValidTimestamp(datetime d){ return d>0; }
bool IsSameDay(datetime a,datetime b){ return TimeToString(a,"yyyy.MM.dd")==TimeToString(b,"yyyy.MM.dd"); }
bool IsSameHour(datetime a,datetime b){ return TimeToString(a,"yyyy.MM.dd HH")==TimeToString(b,"yyyy.MM.dd HH"); }
long SecondsBetween(datetime a,datetime b){ return (long)(a-b); }
long MinutesBetween(datetime a,datetime b){ return (long)((a-b)/60); }
long HoursBetween(datetime a,datetime b){ return (long)((a-b)/3600); }
bool TimeServiceInit(){ return true; }
void TimeServiceShutdown() { }
