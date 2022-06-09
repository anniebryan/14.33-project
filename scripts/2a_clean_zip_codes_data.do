************
* SCRIPT: 2a_clean_zip_codes_data.do
* PURPOSE: processes the zip code centroids dataset in preparation for analysis
************

use "$MyProject/processed/intermediate/zip_code_centroids_uncleaned.dta", clear

* Keep only zip codes in Massachusetts
keep if usps_zip_pref_state_1221=="MA"

* Select only desired columns
keep std_zip5 usps_zip_pref_city_1221 usps_zip_pref_state_1221 latitude longitude

* Rename columns
rename std_zip5 zipcode
rename usps_zip_pref_city_1221 city
rename usps_zip_pref_state_1221 state

* Make city name proper
replace city = proper(city)

* Make zipcode type string
tostring zipcode, replace
replace zipcode = "0" + zipcode

* Save dataset
compress
save "$MyProject/processed/zip_code_centroids.dta", replace

** EOF
