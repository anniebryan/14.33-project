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

* Configure Stata's library environment and record system parameters
run "$MyProject/scripts/programs/_config.do"

* Stata version control
version 15

* Create directories for output files
cap mkdir "$MyProject/processed"
cap mkdir "$MyProject/processed/intermediate"
cap mkdir "$MyProject/results"
cap mkdir "$MyProject/results/figures"
cap mkdir "$MyProject/results/intermediate"
cap mkdir "$MyProject/results/tables"

* Run project analysis
do "$MyProject/scripts/1a_process_dispensaries_data.do"
do "$MyProject/scripts/1b_clean_dispensaries_data.do"
do "$MyProject/scripts/1c_dispensaries_summary.do"
// do "$MyProject/scripts/2a_process_crash_data.do"
// do "$MyProject/scripts/2b_clean_crash_data.do"
// do "$MyProject/scripts/3a_process_shootings_data.do"
// do "$MyProject/scripts/3b_clean_shootings_data.do"

* End log
di "End date and time: $S_DATE $S_TIME"
log close

** EOF
