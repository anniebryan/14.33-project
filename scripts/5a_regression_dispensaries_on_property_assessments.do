************
* SCRIPT: 5a_regression_dispensaries_on_property_assessments.do
* PURPOSE: runs a regression of dispensaries on property assessments
************

use "$MyProject/processed/dispensaries_on_property_assessments.dta", clear

destring zipcode, replace
format zipcode %05.0f

* Define covariates
local heat_type heat_electric heat_forced_hot_air heat_pump heat_space heat_steam
local covariates living_area num_floors r_bdrms r_full_bth r_half_bth r_kitch yrs_since_built yrs_since_remodel `heat_type'

* Run separate regression for each building type
set graphics off
est clear

encode lu, gen(lu_enc)

matrix rel_time = (-5, -4, -3, -2, -1, 0, 1, 2)'
svmat rel_time
	
forvalues d = 1/5 {
	local treatment treat_d`d' treat_jm5_d`d' treat_jm4_d`d' treat_jm3_d`d' treat_jm2_d`d' treat_j0_d`d' treat_jp1_d`d' treat_jp2_d`d'
	
	local dm1 = `d'-1
	qui reg ppsqft `treatment' i.year_assessed i.zipcode i.lu_enc `covariates', vce(cluster year_assessed zipcode)
	eststo model_`d', title("`dm1'-`d' mi.")

	* Plot coefficients from regression
	matrix coefs_`d' = (_b[treat_jm5_d`d'], _b[treat_jm4_d`d'], _b[treat_jm3_d`d'], _b[treat_jm2_d`d'], 0, _b[treat_j0_d`d'], _b[treat_jp1_d`d'], _b[treat_jp2_d`d'])'
	svmat coefs_`d'

	matrix se_`d' = (_se[treat_jm5_d`d'], _se[treat_jm4_d`d'], _se[treat_jm3_d`d'], _se[treat_jm2_d`d'], 0, _se[treat_j0_d`d'], _se[treat_jp1_d`d'], _se[treat_jp2_d`d'])'
	
	matrix high_`d' = coefs_`d' + invttail(e(df_r),0.025)*se_`d'
	svmat high_`d'

	matrix low_`d' = coefs_`d' - invttail(e(df_r),0.025)*se_`d'
	svmat low_`d'
}

matrix d1_rel_time = rel_time - 0.2*(1, 1, 1, 1, 1, 1, 1, 1)'
svmat d1_rel_time

matrix d2_rel_time = rel_time - 0.1*(1, 1, 1, 1, 1, 1, 1, 1)'
svmat d2_rel_time

matrix d4_rel_time = rel_time + 0.1*(1, 1, 1, 1, 1, 1, 1, 1)'
svmat d4_rel_time

matrix d5_rel_time = rel_time + 0.2*(1, 1, 1, 1, 1, 1, 1, 1)'
svmat d5_rel_time

graph twoway (rcap high_1 low_1 d1_rel_time in 1/8, color("12 69 118")) ///
	(rcap high_2 low_2 d2_rel_time in 1/8, color("7 90 152")) ///
	(rcap high_3 low_3 rel_time in 1/8, color("1 111 185")) ///
	(rcap high_4 low_4 d4_rel_time in 1/8, color("108 175 220")) ///
	(rcap high_5 low_5 d5_rel_time in 1/8, color("161 207 238")) ///
	(scatter coefs_1 d1_rel_time, color("12 69 118")) ///
	(scatter coefs_2 d2_rel_time, color("7 90 152")) ///
	(scatter coefs_3 rel_time, color("1 111 185")) ///
	(scatter coefs_4 d4_rel_time, color("108 175 220")) ///
	(scatter coefs_5 d5_rel_time, color("161 207 238")), ///
	xtitle("Event year") ///
	xlabel(-5(1)2) ///
	ylabel(, angle(0)) ///
	ytitle("Price ($) per square foot") ///
	legend(order(6 "{&beta}{sub:j,1}" 7 "{&beta}{sub:j,2}" 8 "{&beta}{sub:j,3}" 9 "{&beta}{sub:j,4}" 10 "{&beta}{sub:j,5}") rows(1)) ///

graph export "$MyProject/results/figures/reg-property-vals.png", replace

esttab model* using "$MyProject/results/tables/reg-property-vals.tex", replace ///
	rename(treat_d1 treatment_d treat_d2 treatment_d treat_d3 treatment_d treat_d4 treatment_d treat_d5 treatment_d treat_jm5_d1 treatment_-5_d treat_jm5_d2 treatment_-5_d treat_jm5_d3 treatment_-5_d treat_jm5_d4 treatment_-5_d treat_jm5_d5 treatment_-5_d treat_jm4_d1 treatment_-4_d treat_jm4_d2 treatment_-4_d treat_jm4_d3 treatment_-4_d treat_jm4_d4 treatment_-4_d treat_jm4_d5 treatment_-4_d treat_jm3_d1 treatment_-3_d treat_jm3_d2 treatment_-3_d treat_jm3_d3 treatment_-3_d treat_jm3_d4 treatment_-3_d treat_jm3_d5 treatment_-3_d treat_jm2_d1 treatment_-2_d treat_jm2_d2 treatment_-2_d treat_jm2_d3 treatment_-2_d treat_jm2_d4 treatment_-2_d treat_jm2_d5 treatment_-2_d treat_j0_d1 treatment_0_d treat_j0_d2 treatment_0_d treat_j0_d3 treatment_0_d treat_j0_d4 treatment_0_d treat_j0_d5 treatment_0_d treat_jp1_d1 treatment_1_d treat_jp1_d2 treatment_1_d treat_jp1_d3 treatment_1_d treat_jp1_d4 treatment_1_d treat_jp1_d5 treatment_1_d treat_jp2_d1 treatment_2_d treat_jp2_d2 treatment_2_d treat_jp2_d3 treatment_2_d treat_jp2_d4 treatment_2_d treat_jp2_d5 treatment_2_d) ///
	keep(treatment_*) ///
	cells(b(star fmt(3)) se(par fmt(2))) ///
	mtitles("0-1 mi." "1-2 mi." "2-3 mi." "3-4 mi.") ///
	legend label ///

* EOF
