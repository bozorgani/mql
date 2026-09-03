// SPR3-003 Swing Storage — infrastructure storage only
#include <mql5/include/CommonTypes.mqh>

bool swingStorageInitialized = false;
bool swingStorageReadyState = false;
double swingStorageLastPrice = 0.0;
datetime swingStorageLastTime = 0;
SwingType swingStorageLastType = SWING_NONE;
SwingPoint swingStoragePoints[];
const int SWING_STORAGE_CAPACITY = 100;
bool SwingStorageInit(){ swingStorageInitialized = true; swingStorageReadyState = true; return true; }
void SwingStorageShutdown(){ swingStorageInitialized = false; swingStorageReadyState = false; swingStorageLastPrice = 0.0; swingStorageLastTime = 0; swingStorageLastType = SWING_NONE; ArrayResize(swingStoragePoints, 0); }
bool SwingStorageStatus(){ return swingStorageInitialized; }
bool SaveSwing(double price, datetime time){ swingStorageLastPrice = price; swingStorageLastTime = time; return true; }
bool SaveSwingPoint(double price, datetime time, SwingType type){
  if(!swingStorageInitialized || price <= 0.0 || time <= 0 || type == SWING_NONE)
    return false;
  int count = ArraySize(swingStoragePoints);
  if(count > 0 && swingStoragePoints[count - 1].time == time &&
     swingStoragePoints[count - 1].type == type)
    return true;
  if(count >= SWING_STORAGE_CAPACITY){
    for(int index = 1; index < count; index++)
      swingStoragePoints[index - 1] = swingStoragePoints[index];
    count--;
    ArrayResize(swingStoragePoints, count);
  }
  if(ArrayResize(swingStoragePoints, count + 1) != count + 1)
    return false;
  swingStoragePoints[count].price = price;
  swingStoragePoints[count].time = time;
  swingStoragePoints[count].type = type;
  swingStorageLastPrice = price;
  swingStorageLastTime = time;
  swingStorageLastType = type;
  return true;
}
double GetStoredSwingPrice(){ return swingStorageLastPrice; }
datetime GetStoredSwingTime(){ return swingStorageLastTime; }
SwingType GetStoredSwingType(){ return swingStorageLastType; }
int GetStoredSwingCount(){ return ArraySize(swingStoragePoints); }
bool GetStoredSwingFromNewest(int offset, SwingPoint &point){
  int index = ArraySize(swingStoragePoints) - 1 - offset;
  if(offset < 0 || index < 0)
    return false;
  point = swingStoragePoints[index];
  return true;
}
bool GetLatestSwingByType(SwingType type, SwingPoint &point){
  if(type == SWING_NONE)
    return false;
  for(int index = ArraySize(swingStoragePoints) - 1; index >= 0; index--){
    if(swingStoragePoints[index].type == type){
      point = swingStoragePoints[index];
      return true;
    }
  }
  return false;
}
bool SwingStorageReady(){ return swingStorageInitialized && swingStorageReadyState; }

// TODO(SPR7): Logger integration hook — future CreateLogEvent calls here
