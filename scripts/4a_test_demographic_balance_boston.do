************
* SCRIPT: 4a_test_demographic_balance_boston.do
* PURPOSE: runs a 2-sample t-test to check that the demographics in treatment/control groups are similar
************

* Format property dataset
use "$MyProject/processed/property_assessments_ma.dta", clear

sort zipcode
merge m:1 zipcode using "$MyProject/processed/zip_code_centroids.dta"
keep if _merge==3
drop _merge

* Divide properties into "close" vs. "not close"
gen close = min_dist_disp < 1
sort close

* Run t-test
global controls av_bldg ppsqft living_area num_floors r_bdrms

est clear
estpost ttest $controls , by(close)

esttab using "$MyProject/results/tables/ttest-properties.tex", replace ///
	cells("mu_1 mu_2 b se count") ///
	collabels("Treated" "Untreated" "Diff." "S.E." "Obs." ) ///
	coeflabel(av_bldg "Building value" ppsqft "Price per square foot" living_area "Living area" num_floors "Number of floors" r_bdrms "Number of bedrooms") ///
	label booktabs nonum compress

* EOF
