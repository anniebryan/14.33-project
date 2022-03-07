************
* SCRIPT: 2a_process_states_legality_data.do
* PURPOSE: imports the raw massachusetts zoning data and converts it into a stata-readable format
************

insheet using "$MyProject/data/TODO", comma clear

compress
save "$MyProject/processed/intermediate/TODO_uncleaned.dta", replace

** EOF
