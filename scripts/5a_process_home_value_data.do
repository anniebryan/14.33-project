************
* SCRIPT: 5a_process_home_value_data.do
* PURPOSE: imports the raw zillow home value data and converts it into a stata-readable format
************

insheet using "$MyProject/data/TODO.csv", comma clear

compress
save "$MyProject/processed/intermediate/TODO.dta", replace

** EOF
