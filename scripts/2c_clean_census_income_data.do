************
* SCRIPT: 2c_clean_census_income_data.do
* PURPOSE: processes the census income datasets in preparation for analysis
************

* Clean dataset for each year, one at a time
forvalues y = 2011/2020 {
	use "$MyProject/processed/intermediate/census_income_`y'_uncleaned.dta", clear
	
	* Keep only desired columns
	keep v2 v3 v25 v27
	
	* Rename variable names
	rename v2 zipcode
	rename v3 num_hh_`y'
	rename v25 est_hh_med_inc_`y'
	rename v27 est_hh_mean_inc_`y'
	
	* Keep only desired rows
	drop if _n<=2
	drop if missing(est_hh_med_inc_`y') | real(est_hh_med_inc_`y')==.
	drop if missing(est_hh_mean_inc_`y') | real(est_hh_mean_inc_`y')==.
	
	* Split zip code column
	split zipcode, parse(" ")
	drop zipcode zipcode1
	rename zipcode2 zipcode
	order zipcode
	
	* Turn numeric values to ints
	destring num_hh_`y', replace
	destring est_hh_med_inc_`y', replace
	destring est_hh_mean_inc_`y', replace
	
	* Create variable for total income (mean income per household * # households)
	gen total_inc_`y' = num_hh_`y' * est_hh_mean_inc_`y'
	
	* Save dataset for year y
	compress
	save "$MyProject/processed/intermediate/census_income_`y'.dta", replace
}

* Merge datasets from 2011-2020 into one dataset containing all years
use "$MyProject/processed/intermediate/census_income_2011.dta", clear
forvalues y = 2012/2020 {
	merge 1:1 zipcode using "$MyProject/processed/intermediate/census_income_`y'.dta"
	drop _merge
}

* Add city name
merge 1:1 zipcode using "$MyProject/processed/zip_code_centroids.dta"
drop if _merge!=3
drop _merge latitude longitude min_dist_* state

* Save dataset containing all years
compress
save "$MyProject/processed/census_income.dta", replace

** EOF
