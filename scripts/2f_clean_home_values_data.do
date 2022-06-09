************
* SCRIPT: 2f_clean_home_values_data.do
* PURPOSE: processes the zillow home value dataset in preparation for analysis
************

use "$MyProject/processed/intermediate/zillow_home_values_uncleaned.dta", clear

* Select only desired columns
drop regionid sizerank regiontype statename city metro countyname

* Rename zipcode
rename regionname zipcode

* Rename v10-v274 to their label (month/year)
foreach v of varlist v* {
	local x: variable label `v'
	local year = substr("`x'", 1, 4)
	local month = substr("`x'", 6, 2)
	rename `v' hv_`month'_`year'
}

* Make zipcode type string
tostring zipcode, replace
replace zipcode = "0" + zipcode if strlen(zipcode)==4
replace zipcode = "00" + zipcode if strlen(zipcode)==3

* Add state legality
rename state abbreviation
merge m:1 abbreviation using "$MyProject/processed/us_states_legality.dta"
drop _merge

* Save dataset
compress
save "$MyProject/processed/zillow_home_values.dta", replace

** EOF
