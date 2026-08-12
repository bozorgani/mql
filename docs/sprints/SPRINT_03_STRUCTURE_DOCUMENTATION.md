# Structure Layer Documentation — Sprint 3
=== SPR3-014 ===
Status: FROZEN / DOCUMENTED
No source changes. Only documentation.

## 1. Layer Overview
Market Structure Layer provides infrastructure for swing detection, storage, BOS, CHOCH, Trend, and orchestration.
No strategy, trading, risk, AI included.

## 2. Implemented Modules
- SwingDetector (mql5/modules/SwingDetector.mq5)
- SwingStorage (mql5/modules/SwingStorage.mq5)
- BOSDetector (mql5/modules/BOSDetector.mq5)
- CHOCHDetector (mql5/modules/CHOCHDetector.mq5)
- TrendEngine (mql5/modules/TrendEngine.mq5)
- StructureManager (mql5/modules/StructureManager.mq5)

## 3. Public Interfaces (verified)

SwingDetector:
- bool SwingInit()
- void SwingShutdown()
- bool SwingStatus()
- bool SwingConfigure(int lookback)
- bool SwingUpdate()
- bool SwingReady()
- double GetLastSwingPrice()
- datetime GetLastSwingTime()

SwingStorage:
- bool SwingStorageInit()
- void SwingStorageShutdown()
- bool SwingStorageStatus()
- bool SaveSwing(double price, datetime time)
- double GetStoredSwingPrice()
- datetime GetStoredSwingTime()
- bool SwingStorageReady()

BOSDetector:
- bool BOSInit()
- void BOSShutdown()
- bool BOSStatus()
- bool BOSConfigure()
- bool BOSUpdate()
- bool BOSReady()
- double GetLastBOSPrice()
- datetime GetLastBOSTime()

CHOCHDetector:
- bool CHOCHInit()
- void CHOCHShutdown()
- bool CHOCHStatus()
- bool CHOCHConfigure()
- bool CHOCHUpdate()
- bool CHOCHReady()
- double GetLastCHOCHPrice()
- datetime GetLastCHOCHTime()

TrendEngine:
- bool TrendInit()
- void TrendShutdown()
- bool TrendStatus()
- bool TrendConfigure()
- bool TrendUpdate()
- bool TrendReady()
- TrendDirection GetTrendDirection()
- TrendStrength GetTrendStrength()

StructureManager:
- bool StructureManagerInit()
- void StructureManagerShutdown()
- bool StructureManagerStatus()
- bool StructureManagerUpdate()

## 4. Dependency Chain
SwingDetector → SwingStorage → BOSDetector → CHOCHDetector → TrendEngine → StructureManager

## 5. Initialization Order
SwingInit → SwingStorageInit → BOSInit → CHOCHInit → TrendInit → StructureManagerInit

## 6. Shutdown Order
StructureManagerShutdown → TrendShutdown → CHOCHShutdown → BOSShutdown → SwingStorageShutdown → SwingShutdown

## 7. Update Sequence
StructureManagerUpdate calls SwingUpdate(); SaveSwing/GetLastSwing; BOSUpdate(); CHOCHUpdate(); TrendUpdate();

## 8. Frozen Interfaces
No interface changes permitted after SPR3-000 contracts frozen.

## 9. Known TODOs
- SPR3-004: SwingDetector algorithm complete; placeholder price source noted.
- SPR3-005: BOS confirmation algorithm placeholder.
- SPR3-006: Trend engine uses temporary state; real trend logic deferred.
- SPR3-009: StructureManager integration complete.

## 10. Out of Scope
No Strategy, Trading, Entry, Exit, Risk, AI, Fibonacci, Position, Order, Logger events, persistence.
