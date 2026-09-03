#ifndef MQL5_TEST_FRAMEWORK_MQH
#define MQL5_TEST_FRAMEWORK_MQH

int testAssertions = 0;
int testPassed = 0;
int testFailed = 0;

void TestReset() {
  testAssertions = 0;
  testPassed = 0;
  testFailed = 0;
}

void TestRecord(bool condition, string testName) {
  testAssertions++;
  if(condition) {
    testPassed++;
    Print("[PASS] ", testName);
    return;
  }

  testFailed++;
  Print("[FAIL] ", testName);
}

void TestAssertTrue(bool actual, string testName) {
  TestRecord(actual, testName);
}

void TestAssertFalse(bool actual, string testName) {
  TestRecord(!actual, testName);
}

void TestAssertInt(int expected, int actual, string testName) {
  if(expected != actual)
    Print("       expected=", expected, " actual=", actual);
  TestRecord(expected == actual, testName);
}

void TestAssertDouble(double expected, double actual, double tolerance, string testName) {
  bool equal = MathAbs(expected - actual) <= tolerance;
  if(!equal)
    Print("       expected=", DoubleToString(expected, 8),
          " actual=", DoubleToString(actual, 8),
          " tolerance=", DoubleToString(tolerance, 8));
  TestRecord(equal, testName);
}

bool TestSummary(string suiteName) {
  Print("[SUMMARY] suite=", suiteName,
        " assertions=", testAssertions,
        " passed=", testPassed,
        " failed=", testFailed);
  return testFailed == 0;
}

#endif // MQL5_TEST_FRAMEWORK_MQH
