# SPR6-002A: Bootstrap Initialization Audit Report

**Date:** 2026-08-13  
**Audit ID:** SPR6-002A-BOOTSTRAP-AUDIT  
**Type:** Architecture Audit — Duplicate Initialization Detection  
**Constraint:** Audit Only — No Source Modifications

---

## 1. Exact Initialization Call Graph

### 1.1 Structure Manager Internal Initialization

**Source:** `mql5/modules/StructureManager.mq5`

```
StructureManagerInit()
│
├─→ SwingInit()
├─→ SwingStorageInit()
├─→ BOSInit()
├─→ CHOCHInit()
└─→ TrendInit()
```

**StructureManagerInit() internally initializes all 5 Structure modules.**

### 1.2 Price Action Manager Internal Initialization

**Source:** `mql5/modules/PriceActionManager.mq5`

```
PriceActionManagerInit()
│
├─→ CandleClassifierInit()
├─→ EngulfingInit()
├─→ PinBarInit()
├─→ InsideBarInit()
├─→ OutsideBarInit()
├─→ FibonacciInit()
├─→ RetracementInit()
└─→ ConfluenceInit()
```

**PriceActionManagerInit() internally initializes all 8 Price Action modules.**

### 1.3 Indicator Manager Internal Initialization

**Source:** `mql5/modules/IndicatorManager.mq5`

```
IndicatorManagerInit()
│
├─→ EMAInit()
└─→ ATRInit()
```

**IndicatorManagerInit() internally initializes both Indicator modules.**

### 1.4 EAMain Initialization Call Graph

**Source:** `mql5/modules/EAMain.mq5` — `EAStartup()`

```
EAStartup()
│
├─→ InitializeInfrastructureLayer()
│   ├─→ ConfigInit()
│   ├─→ LoggerInit()
│   ├─→ LoggerFileInit()
│   ├─→ TimeServiceInit()
│   ├─→ MarketDataInit()
│   └─→ SymbolInfoInit()
│
├─→ InitializeIndicatorLayer()
│   ├─→ EMAInit()              ← DUPLICATE (also called by IndicatorManagerInit)
│   ├─→ ATRInit()              ← DUPLICATE (also called by IndicatorManagerInit)
│   └─→ IndicatorManagerInit() ← ALSO calls EMAInit(), ATRInit()
│
├─→ InitializeStructureLayer()
│   ├─→ SwingInit()            ← DUPLICATE (also called by StructureManagerInit)
│   ├─→ SwingStorageInit()     ← DUPLICATE (also called by StructureManagerInit)
│   ├─→ BOSInit()              ← DUPLICATE (also called by StructureManagerInit)
│   ├─→ CHOCHInit()            ← DUPLICATE (also called by StructureManagerInit)
│   ├─→ TrendInit()            ← DUPLICATE (also called by StructureManagerInit)
│   └─→ StructureManagerInit() ← ALSO calls all 5 above
│
└─→ InitializePriceActionLayer()
    ├─→ CandleClassifierInit() ← DUPLICATE (also called by PriceActionManagerInit)
    ├─→ EngulfingInit()         ← DUPLICATE (also called by PriceActionManagerInit)
    ├─→ PinBarInit()            ← DUPLICATE (also called by PriceActionManagerInit)
    ├─→ InsideBarInit()         ← DUPLICATE (also called by PriceActionManagerInit)
    ├─→ OutsideBarInit()        ← DUPLICATE (also called by PriceActionManagerInit)
    ├─→ FibonacciInit()         ← DUPLICATE (also called by PriceActionManagerInit)
    ├─→ RetracementInit()       ← DUPLICATE (also called by PriceActionManagerInit)
    ├─→ ConfluenceInit()        ← DUPLICATE (also called by PriceActionManagerInit)
    └─→ PriceActionManagerInit() ← ALSO calls all 8 above
```

---

## 2. Exact Shutdown Call Graph

### 2.1 Structure Manager Internal Shutdown

**Source:** `mql5/modules/StructureManager.mq5`

```
StructureManagerShutdown()
│
├─→ TrendShutdown()
├─→ CHOCHShutdown()
├─→ BOSShutdown()
├─→ SwingStorageShutdown()
└─→ SwingShutdown()
```

### 2.2 Price Action Manager Internal Shutdown

**Source:** `mql5/modules/PriceActionManager.mq5`

```
PriceActionManagerShutdown()
│
├─→ ConfluenceShutdown()
├─→ RetracementShutdown()
├─→ FibonacciShutdown()
├─→ OutsideBarShutdown()
├─→ InsideBarShutdown()
├─→ PinBarShutdown()
├─→ EngulfingShutdown()
└─→ CandleClassifierShutdown()
```

### 2.3 Indicator Manager Internal Shutdown

**Source:** `mql5/modules/IndicatorManager.mq5`

```
IndicatorManagerShutdown()
│
├─→ ATRShutdown()
└─→ EMAShutdown()
```

### 2.4 EAMain Shutdown Call Graph

**Source:** `mql5/modules/EAMain.mq5` — `EADeinit()`

```
EADeinit()
│
├─→ PriceActionManagerShutdown()
│   └─→ (internally calls all 8 PA module shutdowns)
│
├─→ StructureManagerShutdown()
│   └─→ (internally calls all 5 Structure module shutdowns)
│
├─→ IndicatorManagerShutdown()
│   └─→ (internally calls ATRShutdown, EMAShutdown)
│
└─→ ShutdownManagerStop()
    └─→ SymbolInfoShutdown()
        MarketDataShutdown()
        TimeServiceShutdown()
        LoggerFileShutdown()
        LoggerShutdown()
```

**SHUTDOWN: NO DUPLICATION — EAMain delegates to managers correctly.**

---

## 3. Duplicate Initialization Table

### 3.1 Structure Layer Duplicates

| Module | Initialized by EAMain | Initialized by Manager | Duplicate? |
|--------|----------------------|----------------------|------------|
| SwingDetector | YES (line 139) | YES (StructureManagerInit line 4) | **YES** |
| SwingStorage | YES (line 140) | YES (StructureManagerInit line 5) | **YES** |
| BOSDetector | YES (line 142) | YES (StructureManagerInit line 6) | **YES** |
| CHOCHDetector | YES (line 143) | YES (StructureManagerInit line 7) | **YES** |
| TrendEngine | YES (line 144) | YES (StructureManagerInit line 8) | **YES** |
| StructureManager | YES (line 145) | NO (self) | NO |

**Structure Layer: 5 duplicate initializations detected.**

### 3.2 Price Action Layer Duplicates

| Module | Initialized by EAMain | Initialized by Manager | Duplicate? |
|--------|----------------------|----------------------|------------|
| CandleClassifier | YES (line 155) | YES (PriceActionManagerInit line 4) | **YES** |
| EngulfingDetector | YES (line 156) | YES (PriceActionManagerInit line 5) | **YES** |
| PinBarDetector | YES (line 157) | YES (PriceActionManagerInit line 6) | **YES** |
| InsideBarDetector | YES (line 158) | YES (PriceActionManagerInit line 7) | **YES** |
| OutsideBarDetector | YES (line 159) | YES (PriceActionManagerInit line 8) | **YES** |
| FibonacciEngine | YES (line 160) | YES (PriceActionManagerInit line 9) | **YES** |
| RetracementDetector | YES (line 161) | YES (PriceActionManagerInit line 10) | **YES** |
| ConfluenceManager | YES (line 162) | YES (PriceActionManagerInit line 11) | **YES** |
| PriceActionManager | YES (line 163) | NO (self) | NO |

**Price Action Layer: 8 duplicate initializations detected.**

### 3.3 Indicator Layer Duplicates

| Module | Initialized by EAMain | Initialized by Manager | Duplicate? |
|--------|----------------------|----------------------|------------|
| EMAEngine | YES (line 128) | YES (IndicatorManagerInit line 3) | **YES** |
| ATREngine | YES (line 129) | YES (IndicatorManagerInit line 4) | **YES** |
| IndicatorManager | YES (line 130) | NO (self) | NO |

**Indicator Layer: 2 duplicate initializations detected.**

### 3.4 Infrastructure Layer

| Module | Initialized by EAMain | Initialized by Manager | Duplicate? |
|--------|----------------------|----------------------|------------|
| ConfigSystem | YES (line 118) | NO (no manager) | NO |
| LoggerCore | YES (line 119) | NO (no manager) | NO |
| LoggerFile | YES (line 120) | NO (no manager) | NO |
| TimeService | YES (line 121) | NO (no manager) | NO |
| MarketData | YES (line 122) | NO (no manager) | NO |
| SymbolInfoService | YES (line 123) | NO (no manager) | NO |

**Infrastructure Layer: No duplicates (no manager modules for infrastructure).**

### 3.5 Summary: Total Duplicate Initializations

| Layer | Modules | Duplicates |
|-------|---------|------------|
| Infrastructure | 6 | 0 |
| Indicators | 3 | 2 (EMA, ATR) |
| Structure | 6 | 5 (Swing, SwingStorage, BOS, CHOCH, Trend) |
| Price Action | 9 | 8 (CandleClassifier, Engulfing, PinBar, InsideBar, OutsideBar, Fibonacci, Retracement, Confluence) |
| **TOTAL** | **24** | **15 duplicate initializations** |

---

## 4. Duplicate Shutdown Table

| Module | Shutdown by EAMain | Shutdown by Manager | Duplicate? |
|--------|-------------------|---------------------|------------|
| All Structure modules | YES (via StructureManagerShutdown) | YES (internally by StructureManagerShutdown) | NO — EAMain calls manager, manager cascades |
| All Price Action modules | YES (via PriceActionManagerShutdown) | YES (internally by PriceActionManagerShutdown) | NO — EAMain calls manager, manager cascades |
| EMA, ATR | YES (via IndicatorManagerShutdown) | YES (internally by IndicatorManagerShutdown) | NO — EAMain calls manager, manager cascades |
| Infrastructure modules | YES (via ShutdownManagerStop) | N/A (no manager) | NO |

**Shutdown: NO DUPLICATION — Correct delegation pattern.**

---

## 5. Rollback Audit

### 5.1 Rollback Functions in EAMain

| Rollback Function | What It Calls | Matches Init Order? |
|-------------------|---------------|---------------------|
| RollbackInfrastructureLayer() | LoggerFileShutdown(), LoggerShutdown() | YES (reverse of LoggerFileInit, LoggerInit) |
| RollbackIndicatorLayer() | IndicatorManagerShutdown() | YES (cascades to ATR, EMA — reverse of init) |
| RollbackStructureLayer() | StructureManagerShutdown() | YES (cascades to all 5 — reverse of init) |
| RollbackPriceActionLayer() | PriceActionManagerShutdown() | YES (cascades to all 8 — reverse of init) |

### 5.2 Rollback Order Verification

```
Init Order:        Infrastructure → Indicators → Structure → Price Action
Rollback Order:    Price Action → Structure → Indicators → Infrastructure
                                              ↑ Correct reverse
```

**Rollback order is correct — mirrors initialization in reverse.**

### 5.3 Rollback Completeness Issue

**Issue:** Due to duplicate initialization, rollback calls manager shutdown which cascades to all modules. This means:

1. EAMain's individual module Init() calls set module state to initialized
2. Manager Init() calls ALSO set module state to initialized (duplicate)
3. On rollback, Manager Shutdown() cascades and resets ALL module states
4. The individual module states that EAMain set are also reset by the cascade

**Impact:** Rollback works correctly despite duplicates because the cascade handles all modules. However, the duplicate initialization is still an architecture flaw.

---

## 6. Architecture Verdict

### 6.1 Finding

**DUPLICATE INITIALIZATION DETECTED — 15 instances across 3 layers.**

EAMain initializes each module individually AND then calls the manager Init() which also initializes the same modules. This violates the principle of single responsibility and creates redundant initialization.

### 6.2 Root Cause

EAMain was implemented with explicit knowledge of individual module interfaces, then also delegates to manager modules that have the same knowledge. This creates:

1. **Redundant initialization** — each module's Init() called twice
2. **Tight coupling** — EAMain knows about every individual module
3. **Maintenance burden** — adding a new module requires updating EAMain in two places

### 6.3 Architecture Principle Violation

| Principle | Violation |
|-----------|-----------|
| Manager delegation | EAMain should delegate to managers, not bypass them |
| Single initialization | Each module should be initialized once |
| Loose coupling | EAMain should not know individual module interfaces when managers exist |

### 6.4 What Works Despite Issue

- **Shutdown works correctly** — EAMain delegates to managers, no duplication
- **Rollback works** — manager shutdown cascades handle all modules
- **Update works correctly** — EAMain calls manager Update() functions
- **No functional failure** — duplicate Init() calls are idempotent (setting `initialized = true` twice has no adverse effect)

---

## 7. Required Fixes

### 7.1 Recommended Minimal Fix

**Remove individual module Init() calls from EAMain. Delegate to managers only.**

#### 7.1.1 Indicator Layer Fix

**Current (lines 128-130):**
```mql5
bool InitializeIndicatorLayer() {
  if(!EMAInit()) { LogErrorEvent("INIT_FAILED", "EMAInit failed"); return false; }
  if(!ATRInit()) { LogErrorEvent("INIT_FAILED", "ATRInit failed"); return false; }
  if(!IndicatorManagerInit()) { LogErrorEvent("INIT_FAILED", "IndicatorManagerInit failed"); return false; }
  ...
}
```

**Fixed:**
```mql5
bool InitializeIndicatorLayer() {
  if(!IndicatorManagerInit()) { LogErrorEvent("INIT_FAILED", "IndicatorManagerInit failed"); return false; }
  ...
}
```

**Remove:** EMAInit() and ATRInit() calls. IndicatorManagerInit() handles them.

#### 7.1.2 Structure Layer Fix

**Current (lines 139-145):**
```mql5
bool InitializeStructureLayer() {
  if(!SwingInit()) { LogErrorEvent("INIT_FAILED", "SwingInit failed"); return false; }
  if(!SwingStorageInit()) { LogErrorEvent("INIT_FAILED", "SwingStorageInit failed"); RollbackStructureLayer(); return false; }
  if(!BOSInit()) { LogErrorEvent("INIT_FAILED", "BOSInit failed"); RollbackStructureLayer(); return false; }
  if(!CHOCHInit()) { LogErrorEvent("INIT_FAILED", "CHOCHInit failed"); RollbackStructureLayer(); return false; }
  if(!TrendInit()) { LogErrorEvent("INIT_FAILED", "TrendInit failed"); RollbackStructureLayer(); return false; }
  if(!StructureManagerInit()) { LogErrorEvent("INIT_FAILED", "StructureManagerInit failed"); RollbackStructureLayer(); return false; }
  ...
}
```

**Fixed:**
```mql5
bool InitializeStructureLayer() {
  if(!StructureManagerInit()) { LogErrorEvent("INIT_FAILED", "StructureManagerInit failed"); return false; }
  ...
}
```

**Remove:** SwingInit(), SwingStorageInit(), BOSInit(), CHOCHInit(), TrendInit() calls. StructureManagerInit() handles them.

**Note:** Error handling changes — individual module failure detection is lost. StructureManagerInit() already handles rollback internally on failure.

#### 7.1.3 Price Action Layer Fix

**Current (lines 155-163):**
```mql5
bool InitializePriceActionLayer() {
  if(!CandleClassifierInit()) { LogErrorEvent("INIT_FAILED", "CandleClassifierInit failed"); return false; }
  if(!EngulfingInit()) { LogErrorEvent("INIT_FAILED", "EngulfingInit failed"); RollbackPriceActionLayer(); return false; }
  if(!PinBarInit()) { LogErrorEvent("INIT_FAILED", "PinBarInit failed"); RollbackPriceActionLayer(); return false; }
  if(!InsideBarInit()) { LogErrorEvent("INIT_FAILED", "InsideBarInit failed"); RollbackPriceActionLayer(); return false; }
  if(!OutsideBarInit()) { LogErrorEvent("INIT_FAILED", "OutsideBarInit failed"); RollbackPriceActionLayer(); return false; }
  if(!FibonacciInit()) { LogErrorEvent("INIT_FAILED", "FibonacciInit failed"); RollbackPriceActionLayer(); return false; }
  if(!RetracementInit()) { LogErrorEvent("INIT_FAILED", "RetracementInit failed"); RollbackPriceActionLayer(); return false; }
  if(!ConfluenceInit()) { LogErrorEvent("INIT_FAILED", "ConfluenceInit failed"); RollbackPriceActionLayer(); return false; }
  if(!PriceActionManagerInit()) { LogErrorEvent("INIT_FAILED", "PriceActionManagerInit failed"); RollbackPriceActionLayer(); return false; }
  ...
}
```

**Fixed:**
```mql5
bool InitializePriceActionLayer() {
  if(!PriceActionManagerInit()) { LogErrorEvent("INIT_FAILED", "PriceActionManagerInit failed"); return false; }
  ...
}
```

**Remove:** All 8 individual module Init() calls. PriceActionManagerInit() handles them.

### 7.2 Verification Functions Impact

**Current VerifyStructureReady() calls:**
```mql5
if(!SwingStatus()) { ... }
if(!SwingStorageStatus()) { ... }
if(!BOSStatus()) { ... }
if(!CHOCHStatus()) { ... }
if(!TrendStatus()) { ... }
```

**These should REMAIN** — they verify individual module status, which is useful for diagnostics even when initialization is delegated to the manager.

**Current VerifyPriceActionReady() calls:**
```mql5
if(!CandleClassifierStatus()) { ... }
if(!EngulfingStatus()) { ... }
// ... etc for all 8 modules
```

**These should REMAIN** — status verification is different from initialization.

### 7.3 What NOT to Change

| Item | Change? | Reason |
|------|---------|--------|
| Shutdown sequence | NO | Already correct (delegation to managers) |
| Update sequence | NO | Already correct (delegation to managers) |
| Rollback functions | NO | Already correct (delegation to managers) |
| Status verification functions | NO | Useful for diagnostics |
| Manager modules | NO | Freeze preserved |
| Individual module interfaces | NO | Freeze preserved |

---

## 8. Self Audit

### 8.1 Audit Completeness

| Check | Status |
|-------|--------|
| StructureManagerInit() inspected | ✓ |
| PriceActionManagerInit() inspected | ✓ |
| IndicatorManagerInit() inspected | ✓ |
| EAMain EAStartup() inspected | ✓ |
| All Init() calls listed in order | ✓ |
| Duplicate detection complete | ✓ (15 duplicates found) |
| Shutdown audit complete | ✓ (no duplicates) |
| Rollback audit complete | ✓ (order correct, completeness OK) |
| Architecture verdict reached | ✓ |

### 8.2 Accuracy Verification

| Claim | Evidence |
|-------|----------|
| StructureManagerInit calls 5 modules | Lines 4-8 of StructureManager.mq5 |
| PriceActionManagerInit calls 8 modules | Lines 4-11 of PriceActionManager.mq5 |
| IndicatorManagerInit calls 2 modules | Lines 3-4 of IndicatorManager.mq5 |
| EAMain calls all modules individually | Lines 118-163 of EAMain.mq5 |
| EAMain then calls managers | Lines 130, 145, 163 of EAMain.mq5 |
| Shutdown has no duplication | EADeinit() calls only manager shutdown functions |

### 8.3 Constraint Compliance

| Constraint | Status |
|------------|--------|
| No source code modified | ✓ (audit only) |
| No Sprint 6-003 implemented | ✓ |
| No features added | ✓ |
| No refactoring done | ✓ |
| Architecture audit only | ✓ |

---

## 9. Final Verdict

```
STATUS: SPR6-002 REQUIRES MINOR PATCH

BOOTSTRAP ARCHITECTURE HAS DUPLICATE INITIALIZATION

Summary:
- 15 duplicate Init() calls detected across 3 layers
- Indicators: 2 duplicates (EMA, ATR)
- Structure: 5 duplicates (Swing, SwingStorage, BOS, CHOCH, Trend)
- Price Action: 8 duplicates (all 8 PA modules)
- Shutdown: NO duplication (correct)
- Rollback: Works but redundant

Fix Required:
- EAMain must delegate initialization to managers ONLY
- Remove individual module Init() calls
- Keep status verification functions (diagnostic value)
- Keep shutdown sequence unchanged (already correct)

Impact:
- Minimal code change in EAMain.mq5
- No frozen interfaces modified
- No manager modules modified
- Architecture improves (proper delegation)

STOP.

DO NOT implement SPR6-003.

PATCH EAMain BEFORE proceeding.
```

---

**END OF SPR6-002A AUDIT REPORT**

*Audit complete. Duplicate initialization detected. EAMain requires minimal patch to delegate initialization to manager modules only. Shutdown and rollback architectures are correct.*
