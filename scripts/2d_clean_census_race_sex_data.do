************
* SCRIPT: 2d_clean_census_race_sex_data.do
* PURPOSE: processes the census race by sex datasets in preparation for analysis
************

* Clean dataset for each year and each race, one at a time
forvalues y = 2011/2020 {
	foreach race in "white" "black" "asian" "amind" "pacif" {
		use "$MyProject/processed/intermediate/census_age_sex_`race'_`y'_uncleaned.dta", clear
		
		* Keep only desired columns
		keep v3 v5 v7 v9 v11 v13 v15 v17 v19 v21 v23 v25 v27 v29 v31 v33 v35 v37 v39 v41 v43 v45 v47 v49 v51 v53 v55 v57 v59 v61 v64
		order v64
		
		* Rename variable names
		rename v64 zipcode
		
		rename v3 tot_`race'_male_`y'
		rename v5 num_under_5_`race'_male_`y'
		rename v7 num_5_to_9_`race'_male_`y'
		rename v9 num_10_to_14_`race'_male_`y'
		rename v11 num_15_to_17_`race'_male_`y'
		rename v13 num_18_to_19_`race'_male_`y'
		rename v15 num_20_to_24_`race'_male_`y'
		rename v17 num_25_to_29_`race'_male_`y'
		rename v19 num_30_to_34_`race'_male_`y'
		rename v21 num_35_to_44_`race'_male_`y'
		rename v23 num_45_to_54_`race'_male_`y'
		rename v25 num_55_to_64_`race'_male_`y'
		rename v27 num_65_to_74_`race'_male_`y'
		rename v29 num_75_to_84_`race'_male_`y'
		rename v31 num_over_85_`race'_male_`y'
		
		rename v33 tot_`race'_female_`y'
		rename v35 num_under_5_`race'_female_`y'
		rename v37 num_5_to_9_`race'_female_`y'
		rename v39 num_10_to_14_`race'_female_`y'
		rename v41 num_15_to_17_`race'_female_`y'
		rename v43 num_18_to_19_`race'_female_`y'
		rename v45 num_20_to_24_`race'_female_`y'
		rename v47 num_25_to_29_`race'_female_`y'
		rename v49 num_30_to_34_`race'_female_`y'
		rename v51 num_35_to_44_`race'_female_`y'
		rename v53 num_45_to_54_`race'_female_`y'
		rename v55 num_55_to_64_`race'_female_`y'
		rename v57 num_65_to_74_`race'_female_`y'
		rename v59 num_75_to_84_`race'_female_`y'
		rename v61 num_over_85_`race'_female_`y'
		
		* Keep only desired rows
		keep if _n>2
		
		* Split zip code column
		split zipcode, parse(" ")
		drop zipcode zipcode1
		rename zipcode2 zipcode
		order zipcode
		
		* Turn numeric values to ints
		foreach sex in "male" "female" {
			destring tot_`race'_`sex'_`y', replace
			foreach age in "under_5" "5_to_9" "10_to_14" "15_to_17" "18_to_19" "20_to_24" "25_to_29" "30_to_34" "35_to_44" "45_to_54" "55_to_64" "65_to_74" "75_to_84" "over_85" {
				destring num_`age'_`race'_`sex'_`y', replace
			}
		}

		compress
		save "$MyProject/processed/intermediate/census_age_sex_`race'_`y'.dta", replace
	}
	
	* Merge datasets from each race into one dataset containing all races
	use "$MyProject/processed/intermediate/census_age_sex_white_`y'.dta", clear
	foreach race in "black" "asian" "amind" "pacif" {
		merge 1:1 zipcode using "$MyProject/processed/intermediate/census_age_sex_`race'_`y'.dta"
		drop _merge
	}
	
	* Add columns for aggregate values across races
	foreach sex in "male" "female" {
		gen total_`sex'_`y' = 0
	}
	
	foreach age in "under_5" "5_to_9" "10_to_14" "15_to_17" "18_to_19" "20_to_24" "25_to_29" "30_to_34" "35_to_44" "45_to_54" "55_to_64" "65_to_74" "75_to_84" "over_85" {
		gen total_`age'_`y' = 0
	}
	
	foreach race in "white" "black" "asian" "amind" "pacif" {
		gen total_`race'_`y' = 0
		foreach sex in "male" "female" {
			replace total_`sex'_`y' = total_`sex'_`y' + tot_`race'_`sex'_`y'
			replace total_`race'_`y' = total_`race'_`y' + tot_`race'_`sex'_`y'
			foreach age in "under_5" "5_to_9" "10_to_14" "15_to_17" "18_to_19" "20_to_24" "25_to_29" "30_to_34" "35_to_44" "45_to_54" "55_to_64" "65_to_74" "75_to_84" "over_85" {
				replace total_`age'_`y' = total_`age'_`y' + num_`age'_`race'_`sex'_`y'
			}
		}
	}
	
	gen total_`y' = total_male_`y' + total_female_`y'
	
	foreach sex in "male" "female" {
		gen prop_`sex'_`y' = total_`sex'_`y' / total_`y'
	}
	
	foreach race in "white" "black" "asian" "amind" "pacif" {
		gen prop_`race'_`y' = total_`race'_`y' / total_`y'
	}
	
	gen total_under_9_`y' = total_under_5_`y' + total_5_to_9_`y'
	gen total_under_14_`y' = total_under_9_`y' + total_10_to_14_`y'
	gen total_under_18_`y' = total_under_14_`y' + total_15_to_17_`y'
	gen total_under_20_`y' = total_under_18_`y' + total_18_to_19_`y'
	gen total_under_25_`y' = total_under_20_`y' + total_20_to_24_`y'
	gen total_under_30_`y' = total_under_25_`y' + total_25_to_29_`y'
	gen total_under_35_`y' = total_under_30_`y' + total_30_to_34_`y'
	gen total_under_45_`y' = total_under_35_`y' + total_35_to_44_`y'
	gen total_under_55_`y' = total_under_45_`y' + total_45_to_54_`y'
	gen total_under_65_`y' = total_under_55_`y' + total_55_to_64_`y'
	gen total_under_75_`y' = total_under_65_`y' + total_65_to_74_`y'
	gen total_under_85_`y' = total_under_75_`y' + total_75_to_84_`y'
	
	gen half_total = total_`y'/2
	gen median_age_`y' = cond(half_total < total_under_9_`y', 5+(9-5)*(half_total-total_under_5_`y')/(total_under_9_`y'-total_under_5_`y'), ///
		cond(half_total < total_under_14_`y', 9+(14-9)*(half_total-total_under_9_`y')/(total_under_14_`y'-total_under_9_`y'), ///
		cond(half_total < total_under_18_`y', 14+(18-14)*(half_total-total_under_14_`y')/(total_under_18_`y'-total_under_14_`y'), ///
		cond(half_total < total_under_20_`y', 18+(20-18)*(half_total-total_under_18_`y')/(total_under_20_`y'-total_under_18_`y'), ///
		cond(half_total < total_under_25_`y', 20+(25-20)*(half_total-total_under_20_`y')/(total_under_25_`y'-total_under_20_`y'), ///
		cond(half_total < total_under_30_`y', 25+(30-25)*(half_total-total_under_25_`y')/(total_under_30_`y'-total_under_25_`y'), ///
		cond(half_total < total_under_35_`y', 30+(35-30)*(half_total-total_under_30_`y')/(total_under_35_`y'-total_under_30_`y'), ///
		cond(half_total < total_under_45_`y', 35+(45-35)*(half_total-total_under_35_`y')/(total_under_45_`y'-total_under_35_`y'), ///
		cond(half_total < total_under_55_`y', 45+(55-45)*(half_total-total_under_45_`y')/(total_under_55_`y'-total_under_45_`y'), ///
		cond(half_total < total_under_65_`y', 55+(65-55)*(half_total-total_under_55_`y')/(total_under_65_`y'-total_under_55_`y'), ///
		cond(half_total < total_under_75_`y', 65+(75-65)*(half_total-total_under_65_`y')/(total_under_75_`y'-total_under_65_`y'), ///
		cond(half_total < total_under_85_`y', 75+(85-75)*(half_total-total_under_75_`y')/(total_under_85_`y'-total_under_75_`y'), 85))))))))))))
		
	gen prop_under_18_`y' = total_under_18_`y' / total_`y'
	gen prop_under_35_`y' = total_under_35_`y' / total_`y'
	gen prop_under_65_`y' = total_under_65_`y' / total_`y'
	
	keep zipcode total_`y' prop_male_`y' prop_white_`y' prop_black_`y' prop_asian_`y' prop_amind_`y' prop_under_18_`y' prop_under_35_`y' prop_under_65_`y' median_age
	order zipcode total_`y'
	
	* Save dataset containing all races
	compress
	save "$MyProject/processed/intermediate/census_age_sex_`y'.dta", replace
}

* Merge datasets from 2011-2020 into one dataset containing all years
use "$MyProject/processed/intermediate/census_age_sex_2011.dta", clear
forvalues y = 2012/2020 {
	merge 1:1 zipcode using "$MyProject/processed/intermediate/census_age_sex_`y'.dta"
	drop _merge
}

* Save dataset containing all years
compress
save "$MyProject/processed/census_age_sex.dta", replace

** EOF
