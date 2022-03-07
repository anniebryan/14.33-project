************
* SCRIPT: 4a_process_dui_data.do
* PURPOSE: imports the raw dui data and converts it into a stata-readable format
************

insheet using "$MyProject/data/boston_duis.csv", comma clear

compress
save "$MyProject/processed/intermediate/boston_duis_uncleaned.dta", replace

** EOF
