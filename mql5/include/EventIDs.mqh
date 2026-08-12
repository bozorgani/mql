#pragma once
// SPR1-010 Event ID Registry — infrastructure only; compile-time constants
const string CFG_INIT = "CFG-001";
const string CFG_LOAD = "CFG-002";
const string CFG_VALIDATE = "CFG-003";
const string LOG_INIT = "LOG-001";
const string LOG_SHUTDOWN = "LOG-002";
const string LOG_LEVEL_CHANGED = "LOG-003";
const string LOG_FILE_OPEN = "LOG-101";
const string LOG_FILE_CLOSE = "LOG-102";
const string SYSTEM_START = "SYS-001";
const string SYSTEM_STOP = "SYS-002";
const string MODULE_INIT = "MOD-001";
const string MODULE_SHUTDOWN = "MOD-002";
const string ERROR_GENERIC = "ERR-001";
const string WARNING_GENERIC = "WRN-001";
const string INFO_GENERIC = "INF-001";
// Reserved prefixes for future modules
// EMA_ ATR_ BOS_ CHOCH_ FIB_ RISK_ AI_ TRADE_
