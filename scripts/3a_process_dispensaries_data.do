************
* SCRIPT: 3a_process_dispensaries_data.do
* PURPOSE: imports the raw dispensaries data and converts it into a stata-readable format
************

insheet using "$MyProject/data/dispensaries.csv", comma clear

compress
save "$MyProject/processed/intermediate/dispensaries_uncleaned.dta", replace

** EOF
