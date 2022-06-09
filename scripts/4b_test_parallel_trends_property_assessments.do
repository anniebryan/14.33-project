************
* SCRIPT: 4c_test_parallel_trends_property_assessments.do
* PURPOSE: plots assessed property values to test for parallel trends
************

* Format property dataset
use "$MyProject/processed/property_assessments_ma.dta", clear

sort zipcode
merge m:1 zipcode using "$MyProject/processed/zip_code_centroids.dta"
keep if _merge==3
drop _merge

* Create set of treatment variables treat_j_d for j = -5 to 2, d = 1 to 5
* treat_j_d = 1 if a dispensary opens between d-1 and d miles away at time t-j
* treat_d   = 1 if a dispensary opens between d-1 and d miles away at any time

forvalues d = 1/5 {
	gen treat_d`d' = 0
	forvalues j = -5/2 {
		local abs_j = cond(`j' < 0, -`j', `j')
		local j_str = cond(`j' == 0, "0", cond(`j' < 0, "m`abs_j'", "p`j'"))
		gen treat_j`j_str'_d`d' = 0
		
		forvalues y = 2019/2022 {
			replace treat_j`j_str'_d`d' = 1 if year_assessed - `j' == `y' & min_dist_`y' < `d' & min_dist_`y' >= `d'-1
		}
		
		replace treat_d`d' = treat_d`d' + treat_j`j_str'_d`d'
	}
	replace treat_d`d' = cond(treat_d`d' > 0, 1, 0)
}

save "$MyProject/processed/dispensaries_on_property_assessments.dta", replace

* EOF
