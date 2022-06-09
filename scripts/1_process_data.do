************
* SCRIPT: 1_process_data.do
* PURPOSE: imports the raw datasets and converts them into a stata-readable format
************

// US states legality data
insheet using "$MyProject/data/us-states-legality.csv", comma clear
compress
save "$MyProject/processed/us_states_legality.dta", replace

// MA dispensaries data
insheet using "$MyProject/data/dispensaries.csv", comma clear
compress
save "$MyProject/processed/intermediate/dispensaries_uncleaned.dta", replace

// MA property assessments data
forvalues y = 2014/2021 {
	insheet using "$MyProject/data/property_assessment/property-assessment-fy`y'.csv", comma clear
	compress
	save "$MyProject/processed/intermediate/property_assessments_ma_`y'_uncleaned.dta", replace
}

// Zillow home value data
insheet using "$MyProject/data/zhvi_sa_35_65.csv", comma clear
compress
save "$MyProject/processed/intermediate/zillow_home_values_uncleaned.dta", replace

// Zip code centroids data
insheet using "$MyProject/data/ZIP_Code_Population_Weighted_Centroids.csv", comma clear
compress
save "$MyProject/processed/intermediate/zip_code_centroids_uncleaned.dta", replace

// Census income data
forvalues y = 2011/2020 {
	insheet using "$MyProject/data/census-income/ACSST5Y`y'.csv", comma clear
	compress
	save "$MyProject/processed/intermediate/census_income_`y'_uncleaned.dta", replace
}

// Census age/sex data
forvalues y = 2011/2020 {
	foreach race in "white" "black" "asian" "amind" "pacif" {
		insheet using "$MyProject/data/census-age-by-sex/ACSDT5Y`y'-`race'.csv", comma clear
		compress
		save "$MyProject/processed/intermediate/census_age_sex_`race'_`y'_uncleaned.dta", replace
	}
}

** EOF
