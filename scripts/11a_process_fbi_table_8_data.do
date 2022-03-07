************
* SCRIPT: 11a_process_fbi_table_8_data.do
* PURPOSE: imports the raw fbi table 8 data and converts it into a stata-readable format
************

insheet using "$MyProject/data/TODO.csv", comma clear

compress
save "$MyProject/processed/intermediate/TODO_uncleaned.dta", replace

** EOF
