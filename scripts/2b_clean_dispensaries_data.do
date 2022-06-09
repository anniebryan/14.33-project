************
* SCRIPT: 2b_clean_dispensaries_data.do
* PURPOSE: processes the dispensaries dataset in preparation for analysis
************

use "$MyProject/processed/intermediate/dispensaries_uncleaned.dta", clear

* Select only desired columns
keep business_name dba_name license_type establishment_address_1 establishment_city establishment_zip_code establishment_county commence_operations_date latitude longitude

* Keep only entries that have certain license types
keep if license_type=="Marijuana Retailer"
drop license_type

* Keep only entries that have commenced operations
keep if commence_operations_date!=""

* Create variables for commencement operations month, day, and year
split commence_operations_date, parse("/")
destring commence_operations_date1, gen(commence_month)
destring commence_operations_date2, gen(commence_day)
destring commence_operations_date3, gen(commence_year)
drop commence_operations_date commence_operations_date1 commence_operations_date2 commence_operations_date3

* Change format of zip code to be 5 digits
format establishment_zip_code %05.0f

* Rename address variable
rename establishment_address_1 establishment_address

* Manually update lat/lon coordinates of HVV Massachusetts, Inc.
replace lat = 42.387990 if establishment_address=="220 William McClellan Hwy"
replace lon = -71.017820 if establishment_address=="220 William McClellan Hwy"

* Save dataset
compress
save "$MyProject/processed/dispensaries.dta", replace
outsheet using "$MyProject/processed/dispensaries.csv", comma replace

* Create dataset with only dispensaries in the Boston area
keep if establishment_city=="Boston" | establishment_city=="Brookline"
gen id = _n
order id
compress
save "$MyProject/processed/dispensaries_boston.dta", replace
outsheet using "$MyProject/processed/dispensaries_boston.csv", comma replace

* Update zip codes data to include distance to dispensaries
* Get distance to dispensaries
forvalues i = 1/11 {
	use "$MyProject/processed/dispensaries_boston.dta", clear
	sort id
	local disp_lat = latitude[`i']
	local disp_lon = longitude[`i']
	
	use "$MyProject/processed/zip_code_centroids.dta", clear
	geodist `disp_lat' `disp_lon' latitude longitude, gen(dist_`i') mile
	save "$MyProject/processed/zip_code_centroids.dta", replace
}

* Get minimum distance to a dispensary
egen min_dist_disp = rowmin(dist_1 dist_2 dist_3 dist_4 dist_5 dist_6 dist_7 dist_8 dist_9 dist_10 dist_11)

* Get minimum distance to a dispensary
gen min_dist_2019 = dist_8
gen min_dist_2020 = min(dist_7, dist_8, dist_10, dist_11)
gen min_dist_2021 = min(dist_1, dist_2, dist_3, dist_4, dist_5, dist_7, dist_8, dist_9, dist_10, dist_11)
gen min_dist_2022 = min(dist_1, dist_2, dist_3, dist_4, dist_5, dist_6, dist_7, dist_8, dist_9, dist_10, dist_11)

drop dist_1 dist_2 dist_3 dist_4 dist_5 dist_6 dist_7 dist_8 dist_9 dist_10 dist_11

compress
save "$MyProject/processed/zip_code_centroids.dta", replace

* Create file containing only Boston zipcodes
destring zipcode, replace
format zipcode %05.0f

local boston_zipcodes 02108 02109 02110 02111 02113 02114 02115 02116 02118 02119 02120 02121 02122 02124 02125 02126 02127 02128 02129 02130 02131 02132 02133 02134 02135 02136 02163 02199 02203 02210 02215 02222
gen boston = 0
foreach z in `boston_zipcodes' {
	replace boston = 1 if zipcode==`z'
}
drop if boston == 0
drop boston

save "$MyProject/processed/boston_zip_code_centroids.dta", replace

** EOF
