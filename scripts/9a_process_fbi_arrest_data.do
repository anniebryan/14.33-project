************
* SCRIPT: 9a_process_fbi_arrest_data.do
* PURPOSE: imports the raw fbi arrest data and converts it into a stata-readable format
************

insheet using "$MyProject/data/TODO.csv", comma clear

compress
save "$MyProject/processed/intermediate/TODO_uncleaned.dta", replace

** EOF
