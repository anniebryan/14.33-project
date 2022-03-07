************
* SCRIPT: 1a_process_ma_zoning_laws_data.do
* PURPOSE: imports the raw massachusetts zoning data and converts it into a stata-readable format
************

insheet using "$MyProject/data/ma-zoning-laws/ma-zoning-laws.csv", comma clear

compress
save "$MyProject/processed/intermediate/ma_zoning_laws_uncleaned.dta", replace

** EOF
