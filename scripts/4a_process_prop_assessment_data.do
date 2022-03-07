************
* SCRIPT: 4a_process_prop_assessment_data.do
* PURPOSE: imports the raw massachusetts property assessment data and converts it into a stata-readable format
************

insheet using "$MyProject/data/TODO.csv", comma clear

compress
save "$MyProject/processed/intermediate/TODO.dta", replace

** EOF
