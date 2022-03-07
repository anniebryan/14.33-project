************
* SCRIPT: 6a_process_boston_crash_data.do
* PURPOSE: imports the raw boston crash data and converts it into a stata-readable format
************

insheet using "$MyProject/data/boston_crashes.csv", comma clear

compress
save "$MyProject/processed/intermediate/boston_crashes_uncleaned.dta", replace

** EOF
