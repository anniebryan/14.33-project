************
* SCRIPT: 10a_process_boston_crime_data.do
* PURPOSE: imports the raw boston crime data and converts it into a stata-readable format
************

insheet using "$MyProject/data/TODO.csv", comma clear

compress
save "$MyProject/processed/intermediate/TODO_uncleaned.dta", replace

** EOF
