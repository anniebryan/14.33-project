************
* SCRIPT: 3b_summarize_dispensaries_data.do
* PURPOSE: summarizes the dispensaries dataset
************

use "$MyProject/processed/dispensaries.dta", clear

* Generate month/year variable
gen month_str = cond(commence_month <= 4, "Jan-Apr", cond(commence_month <= 8, "May-Aug", "Sep-Dec"))
egen month_year_str = concat(month_str commence_year), punct(" ")

* Generate .csv to use in Tableau
outsheet using "$MyProject/processed/dispensaries_ma.csv", comma replace

** EOF
