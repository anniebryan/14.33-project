************
* SCRIPT: 3e_summarize_prop_assessments_data.do
* PURPOSE: summarizes the property assessments dataset
************

use "$MyProject/processed/property_assessments_ma.dta", clear

* Assign labels describing types of properties
gen lu_int = 0
replace lu_int = 1 if lu == "CD"
replace lu_int = 2 if lu == "E"
replace lu_int = 3 if lu == "R"

label define origin 0 "Apartment/dorm" 1 "Condominium" 2 "Essential" 3 "Residential"
label values lu_int origin
label variable lu_int "Type"
			
* Make a table summarizing by property type
est clear
eststo clear

estpost tabstat av_bldg ppsqft living_area num_floors, by(lu_int) stat(mean sd count) col(stat)

esttab using "$MyProject/results/tables/property-types.tex", replace ///
	cells("mean(fmt(%9.1fc)) sd(fmt(%9.1fc)) count(fmt(%9.0fc))") ///
	collabels("Mean" "SD" "Obs") ///
	coeflabel(av_bldg "Assessed value" ppsqft "Price per square foot" living_area "Living area" num_floors "Number of floors") ///
	label nonumber noobs booktabs compress


* Add zipcode data
merge m:1 zipcode using "$MyProject/processed/zip_code_centroids.dta"
drop if _merge!=3
drop _merge

* Only considering property values before any dispensaries
drop if year_assessed >= 2019

* Divide properties into "close" vs. "not close"
gen close = min_dist_disp < 1
sort close

* Generate table of summary statistics
est clear
eststo clear

estpost su av_bldg living_area ppsqft num_floors r_bdrms if close==1
est store a
estpost su av_bldg living_area ppsqft num_floors r_bdrms if close==0
est store b

esttab a b using "$MyProject/results/tables/property-assessments.tex", replace ///
	cells("mean(fmt(2)) sd(fmt(2)) count(fmt(0))") ///
	mtitles("\textbf{\underline{Properties within 1 mi.}}" "\textbf{\underline{Properties outside 1 mi.}}") ///
	collabels("Mean" "SD" "Obs") ///
	coeflabel(av_bldg "Assessed Value (\\$)" living_area "Living Area (sq.ft.)" ppsqft "Price per Square Foot" num_floors "Number of Floors" r_bdrms "Number of Bedrooms") ///
	label nonumber noobs booktabs compress

* Generate .csv to use in Tableau
collapse close av_bldg ppsqft living_area num_floors r_bdrms, by(zipcode)
outsheet using "$MyProject/processed/zipcode_dists.csv", comma replace

** EOF
