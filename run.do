**********************
* OVERVIEW
*   All raw data are stored in /data
*   All tables are outputted to /results/tables
*   All figures are outputted to /results/figures
*
* TO PERFORM A CLEAN RUN, DELETE THE FOLLOWING TWO FOLDERS:
*   /processed
*   /results
**********************

global MyProject "/Users/anniebryan/Documents/College/2021-22/14.33/Project"

* Initialize log
clear
set more off
cap mkdir "$MyProject/scripts/logs"
cap log close
local datetime : di %tcCCYY.NN.DD!-HH.MM.SS `=clock("$S_DATE $S_TIME", "DMYhms")'
local logfile "$MyProject/scripts/logs/`datetime'.log.txt"
log using "`logfile'", text

ssc install estout, replace
ssc install outreg2
ssc install geodist

* Stata version control
version 17

* Create directories for output files
cap mkdir "$MyProject/processed"
cap mkdir "$MyProject/processed/intermediate"
cap mkdir "$MyProject/results"
cap mkdir "$MyProject/results/figures"
cap mkdir "$MyProject/results/intermediate"
cap mkdir "$MyProject/results/tables"

* Run project analysis
do "$MyProject/scripts/1_process_data.do"

do "$MyProject/scripts/2a_clean_zip_codes_data.do"
do "$MyProject/scripts/2b_clean_dispensaries_data.do"
do "$MyProject/scripts/2c_clean_census_income_data.do"
do "$MyProject/scripts/2d_clean_census_race_sex_data.do"
do "$MyProject/scripts/2e_clean_prop_assessments_data.do"
do "$MyProject/scripts/2f_clean_home_values_data.do"

do "$MyProject/scripts/3a_summarize_us_states_legality_data.do"
do "$MyProject/scripts/3b_summarize_dispensaries_data.do"
do "$MyProject/scripts/3c_summarize_prop_assessments_data.do"

do "$MyProject/scripts/4a_test_demographic_balance_boston.do"
do "$MyProject/scripts/4b_test_parallel_trends_property_assessments.do"

do "$MyProject/scripts/5a_regression_dispensaries_on_property_assessments.do"
do "$MyProject/scripts/5b_regression_state_legality_on_home_values.do"

* End log
di "End date and time: $S_DATE $S_TIME"
log close

** EOF
