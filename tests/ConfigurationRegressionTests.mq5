#include <mql5/modules/ConfigSystem.mq5>
#include <mql5/modules/ConfigValidator.mq5>
void RunConfigRegression(){
  ConfigInit(); ConfigInit(); ConfigInit();
  bool s1=ConfigStatus(); bool s2=ConfigStatus(); if(s1!=s2) Print("FAIL ConfigStatus repeat");
  ValidateRequired("test"); ValidateRequired("test"); ValidateRequired("test");
  ValidateRange(5.0,0.0,10.0); ValidateRange(5.0,0.0,10.0);
  ValidatePositive(1.0); ValidatePositive(1.0);
  ValidateNonNegative(0.0); ValidateNonNegative(0.0);
  ValidateStringLength("abc",10); ValidateStringLength("abc",10);
  ValidateNotEmpty("x"); ValidateNotEmpty("x");
}
