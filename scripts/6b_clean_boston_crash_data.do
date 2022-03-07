************
* SCRIPT: 6b_clean_boston_crash_data.do
* PURPOSE: processes the boston crash dataset in preparation for analysis
************

use "$MyProject/processed/intermediate/boston_crashes_uncleaned.dta", clear

* Delete first 2 rows
drop if _n==1 | _n==2
compress

* Rename variable names to be values from the first row
foreach var of varlist * {
	local x = strtoname(`var'[1])
	rename `var' `x'
}
drop in 1

* Select only desired columns
local keep Crash_Number Crash_Date Crash_Time Number_of_Vehicles Total_Nonfatal_Injuries Total_Fatal_Injuries Road_Surface_Condition Ambient_Light Weather_Condition Distance_From_Nearest_Roadway_In
ds
local vars `r(varlist)'
local tokeep : list vars & keep
keep `tokeep'

compress
save "$MyProject/processed/boston_crashes.dta", replace

** EOF
