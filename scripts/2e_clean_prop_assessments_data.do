************
* SCRIPT: 2e_clean_prop_assessments_data.do
* PURPOSE: processes the massachusetts property assessments datasets in preparation for analysis
************

* Clean dataset for each year, one at a time
forvalues y = 2014/2021 {
	use "$MyProject/processed/intermediate/property_assessments_ma_`y'_uncleaned.dta", clear
	
	* Rename 2021 variables to have the same name as other years
	if `y' == 2021 {
		rename bldg_value av_bldg
		rename yr_remodel yr_remod
		rename res_floor num_floors
		rename bed_rms r_bdrms
		rename full_bth r_full_bth
		rename hlf_bth r_half_bth
		rename kitchen r_kitch
		rename heat_type r_heat_typ
	}
	
	* Select only desired columns
	keep zipcode lu av_bldg living_area yr_built yr_remod num_floors r_bdrms r_full_bth r_half_bth r_kitch r_heat_typ
	
	* Create variable for the year the building was assessed
	gen year_assessed = `y'
	
	* Change zipcode column to be of uniform format across years
	if `y' == 2018 | `y' == 2019 | `y' == 2020 | `y' == 2021 {
		tostring zipcode, replace
		replace zipcode = "0" + zipcode
	}
	else {
		replace zipcode = substr(zipcode, 1, 5)
	}
	
	* Convert dollar amount av_bldg to int (2021 only)
	if `y' == 2021 {
		split av_bldg, parse(".00") gen(dollars)
		destring dollars1, replace ignore("$,")
		drop av_bldg
		rename dollars1 av_bldg
	}

	* Drop entries with missing, 0-valued, or unreasonable data
	drop if av_bldg == 0 | missing(av_bldg)
	drop if living_area < 250 | missing(living_area)
	drop if yr_built == 0 | missing(yr_built)
	drop if num_floors == 0 | missing(num_floors)
	drop if r_bdrms == 0 | missing(r_bdrms)
	
	* Create variable for price per square foot
	gen ppsqft = av_bldg / living_area
	drop if ppsqft < 20
	
	* Create variable for years since built
	gen yrs_since_built = `y' - yr_built
	
	* Create variable for years since remodel
	replace yr_remod = 0 if missing(yr_remod)
	replace yr_remod = yr_built if yr_remod==0
	gen yrs_since_remodel = `y' - yr_remod
	drop yr_built yr_remod
	
	* Replace missing values with 0
	replace living_area = 0 if missing(living_area)
	replace r_full_bth = 0 if missing(r_full_bth)
	replace r_half_bth = 0 if missing(r_half_bth)
	
	* Replace string kitchen values with ints
	if `y' == 2020 {
		replace r_kitch = "0" if missing(r_kitch)
		replace r_kitch = substr(r_kitch, 1, 1)
		replace r_kitch = "0" if real(r_kitch)==. & r_kitch=="N"
		replace r_kitch = "1" if real(r_kitch)==. & r_kitch!="N"
		destring r_kitch, replace
	}
	else {
		replace r_kitch = 0 if missing(r_kitch)
	}
	
	* Create dummy variables for heat type
	gen heat_electric = r_heat_typ==`"E"' | r_heat_typ==`"E - Electric"'
	gen heat_forced_hot_air = r_heat_typ==`"F"' | r_heat_typ==`"F - Forced Hot Air"'
	gen heat_pump = r_heat_typ==`"P"' | r_heat_typ==`"P - Heat Pump"'
	gen heat_space = r_heat_typ==`"S"' | r_heat_typ==`"S - Space Heat"'
	gen heat_steam = r_heat_typ==`"W"' | r_heat_typ==`"W - Ht Water/Steam"'
	gen heat_other = r_heat_typ==`"O"' | r_heat_typ==`"O - Other"'
	drop r_heat_typ
	
	* Save dataset for year `y'
	compress
	save "$MyProject/processed/intermediate/property_assessments_ma_`y'.dta", replace
}

* Merge datasets from 2014-2021 into one dataset containing all years
use "$MyProject/processed/intermediate/property_assessments_ma_2014.dta", clear
forvalues y = 2015/2021 {
	append using "$MyProject/processed/intermediate/property_assessments_ma_`y'.dta"
}

* Only keep common building types
replace lu = "A" if lu == "R4"
replace lu = "CD" if lu == "CC"
replace lu = "E" if lu == "C"
replace lu = "R" if lu == "R1" | lu == "R2" | lu == "R3" | lu == "RC"
drop if lu == "EA" | lu == "XX"

* Save dataset containing all years
compress
save "$MyProject/processed/property_assessments_ma.dta", replace

** EOF
