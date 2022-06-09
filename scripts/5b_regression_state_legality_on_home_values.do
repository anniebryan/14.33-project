************
* SCRIPT: 5b_regression_state_legality_on_home_values.do
* PURPOSE: runs a regression of state legality on home values
************

use "$MyProject/processed/zillow_home_values.dta", clear

destring zipcode, replace
format zipcode %05.0f

forvalues y = 2000/2021 {
	gen avg_hv_`y' = (hv_01_`y' + hv_02_`y' + hv_03_`y' + hv_04_`y' + hv_05_`y' + hv_06_`y' + hv_07_`y' + hv_08_`y' + hv_09_`y' + hv_10_`y' + hv_11_`y' + hv_12_`y')/12
}
drop hv_*

* Create one row for each observation
expand 22
bysort zipcode: gen year = 1999 + _n
gen avg_hv = .
forvalues y = 2000/2021 {
	replace avg_hv = avg_hv_`y' if year == `y'
}
drop avg_hv_*
drop if missing(avg_hv)

* Create enum variable for state
encode abbreviation, gen(abbrev)

* Create treatment variable
gen legal_med = medical & real(year_legalized_med) <= year

* Add lags/leads
gen c_m8_med = medical & real(year_legalized_med) == year + 8
gen c_m7_med = medical & real(year_legalized_med) == year + 7
gen c_m6_med = medical & real(year_legalized_med) == year + 6
gen c_m5_med = medical & real(year_legalized_med) == year + 5
gen c_m4_med = medical & real(year_legalized_med) == year + 4
gen c_m3_med = medical & real(year_legalized_med) == year + 3
gen c_m2_med = medical & real(year_legalized_med) == year + 2
gen c_0_med = medical & real(year_legalized_med) == year
gen c_p1_med = medical & real(year_legalized_med) == year - 1
gen c_p2_med = medical & real(year_legalized_med) == year - 2
gen c_p3_med = medical & real(year_legalized_med) == year - 3
gen c_p4_med = medical & real(year_legalized_med) == year - 4
gen c_p5_med = medical & real(year_legalized_med) == year - 5
gen c_p6_med = medical & real(year_legalized_med) == year - 6
gen c_p7_med = medical & real(year_legalized_med) == year - 7
gen c_p8_med = medical & real(year_legalized_med) == year - 8

local treatment_med medical c_m8_med c_m7_med c_m6_med c_m5_med c_m4_med c_m3_med c_m2_med c_0_med c_p1_med c_p2_med c_p3_med c_p4_med c_p5_med c_p6_med c_p7_med c_p8_med

* Run regression for medical
reg avg_hv `treatment_med' i.year i.abbrev, vce(cluster abbrev)

* Plot coefficients from regression
matrix coefs_med = (_b[c_m8_med], _b[c_m7_med], _b[c_m6_med], _b[c_m5_med], _b[c_m4_med], _b[c_m3_med], _b[c_m2_med], 0, _b[c_0_med], _b[c_p1_med], _b[c_p2_med], _b[c_p3_med], _b[c_p4_med], _b[c_p5_med], _b[c_p6_med], _b[c_p7_med], _b[c_p8_med])'
svmat coefs_med

matrix stderrs_med = (_se[c_m8_med], _se[c_m7_med], _se[c_m6_med], _se[c_m5_med], _se[c_m4_med], _se[c_m3_med], _se[c_m2_med], 0, _se[c_0_med], _se[c_p1_med], _se[c_p2_med], _se[c_p3_med], _se[c_p4_med], _se[c_p5_med], _se[c_p6_med], _se[c_p7_med], _se[c_p8_med])'
svmat stderrs_med

matrix high_med = coefs_med + invttail(e(df_r),0.025)*stderrs_med
svmat high_med

matrix low_med = coefs_med - invttail(e(df_r),0.025)*stderrs_med
svmat low_med

matrix rel_time = (-8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8)'
svmat rel_time
	
graph twoway (rcap high_med low_med rel_time in 1/17) (scatter coefs_med rel_time), ///
	xtitle("Event year") ///
	xlabel(-8(1)8) ///
	ylabel(-40000 "-40,000" -20000 "-20,000" 0 "0" 20000 "20,000", angle(0)) ///
	legend(off) ///

graph export "$MyProject/results/figures/reg-state-legality-home-vals-med.png", replace

* Repeat for recreational
drop coefs_med1 stderrs_med1 high_med1 low_med1 rel_time1

* Create treatment variable
gen legal_rec = recreational & real(year_legalized_rec) <= year

* Add lags/leads
gen c_m8_rec = recreational & real(year_legalized_rec) == year + 8
gen c_m7_rec = recreational & real(year_legalized_rec) == year + 7
gen c_m6_rec = recreational & real(year_legalized_rec) == year + 6
gen c_m5_rec = recreational & real(year_legalized_rec) == year + 5
gen c_m4_rec = recreational & real(year_legalized_rec) == year + 4
gen c_m3_rec = recreational & real(year_legalized_rec) == year + 3
gen c_m2_rec = recreational & real(year_legalized_rec) == year + 2
gen c_0_rec = recreational & real(year_legalized_rec) == year
gen c_p1_rec = recreational & real(year_legalized_rec) == year - 1
gen c_p2_rec = recreational & real(year_legalized_rec) == year - 2
gen c_p3_rec = recreational & real(year_legalized_rec) == year - 3
gen c_p4_rec = recreational & real(year_legalized_rec) == year - 4
gen c_p5_rec = recreational & real(year_legalized_rec) == year - 5
gen c_p6_rec = recreational & real(year_legalized_rec) == year - 6
gen c_p7_rec = recreational & real(year_legalized_rec) == year - 7
gen c_p8_rec = recreational & real(year_legalized_rec) == year - 8

local treatment_rec recreational c_m8_rec c_m7_rec c_m6_rec c_m5_rec c_m4_rec c_m3_rec c_m2_rec c_0_rec c_p1_rec c_p2_rec c_p3_rec c_p4_rec c_p5_rec c_p6_rec c_p7_rec c_p8_rec

* Run regression for medical
reg avg_hv `treatment_rec' i.year i.abbrev, vce(cluster abbrev)

* Plot coefficients from regression
matrix coefs_rec = (_b[c_m8_rec], _b[c_m7_rec], _b[c_m6_rec], _b[c_m5_rec], _b[c_m4_rec], _b[c_m3_rec], _b[c_m2_rec], 0, _b[c_0_rec], _b[c_p1_rec], _b[c_p2_rec], _b[c_p3_rec], _b[c_p4_rec], _b[c_p5_rec], _b[c_p6_rec], _b[c_p7_rec], _b[c_p8_rec])'
svmat coefs_rec

matrix stderrs_rec = (_se[c_m8_rec], _se[c_m7_rec], _se[c_m6_rec], _se[c_m5_rec], _se[c_m4_rec], _se[c_m3_rec], _se[c_m2_rec], 0, _se[c_0_rec], _se[c_p1_rec], _se[c_p2_rec], _se[c_p3_rec], _se[c_p4_rec], _se[c_p5_rec], _se[c_p6_rec], _se[c_p7_rec], _se[c_p8_rec])'
svmat stderrs_rec

matrix high_rec = coefs_rec + invttail(e(df_r),0.025)*stderrs_rec
svmat high_rec

matrix low_rec = coefs_rec - invttail(e(df_r),0.025)*stderrs_rec
svmat low_rec

matrix rel_time = (-8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8)'
svmat rel_time
	
graph twoway (rcap high_rec low_rec rel_time in 1/17) (scatter coefs_rec rel_time), ///
	xtitle("Event year") ///
	xlabel(-8(1)8) ///
	ytitle("Average home value ($)") ///
	ylabel(-50000 "-50,000" 0 "0" 50000 "50,000" 100000 "100,000" 150000 "150,000" 200000 "200,000", angle(0)) ///
	legend(off) ///

graph export "$MyProject/results/figures/reg-state-legality-home-vals-rec.png", replace
