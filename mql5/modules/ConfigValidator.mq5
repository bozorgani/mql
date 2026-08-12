#pragma once
ValidationResult ValidateRequired(string v){ return v!="" ? VAL_OK : VAL_FAIL; }
ValidationResult ValidateRange(double v,double mn,double mx){ return (v>=mn && v<=mx) ? VAL_OK : VAL_FAIL; }
ValidationResult ValidatePositive(double v){ return v>0 ? VAL_OK : VAL_FAIL; }
ValidationResult ValidateNonNegative(double v){ return v>=0 ? VAL_OK : VAL_FAIL; }
ValidationResult ValidateStringLength(string s,int maxLen){ return StringLen(s)<=maxLen ? VAL_OK : VAL_FAIL; }
ValidationResult ValidateNotEmpty(string s){ return s!="" ? VAL_OK : VAL_FAIL; }
ValidationResult ValidateEnumValue(int v,int min,int max){ return (v>=min && v<=max) ? VAL_OK : VAL_FAIL; }
// TODO deferred to Sprint 5/6: real duplicate detection requires trade/module context
ValidationResult ValidateDuplicate(string s){ return VAL_PENDING; }
// TODO deferred to Sprint 3/4: consistency requires structure/Trend state
ValidationResult ValidateConsistency(string s){ return VAL_PENDING; }
// TODO deferred to Sprint 6+: full config requires Strategy parameters
ValidationResult ValidateConfiguration(){ return VAL_PENDING; }
