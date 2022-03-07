************
* SCRIPT: 7a_process_us_crash_data.do
* PURPOSE: imports the raw us crash data and converts it into a stata-readable format
************

insheet using "$MyProject/data/TODO.csv", comma clear

compress
save "$MyProject/processed/intermediate/TODO_uncleaned.dta", replace

** EOF
