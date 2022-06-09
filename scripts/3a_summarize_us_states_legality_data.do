************
* SCRIPT: 3a_summarize_us_states_legality_data.do
* PURPOSE: summarizes the us states legality dataset
************

use "$MyProject/processed/us_states_legality.dta", clear

* Generate .csv to use in Tableau
gen status = cond(recreational==1, 2, medical)
keep state status
outsheet using "$MyProject/processed/us_states_legality.csv", comma replace

expand 2
sort state
gen type_legal = mod(_n, 2)
gen legal = (status == 1 | status == 2) if type_legal == 0 // medical
replace legal = status == 2 if type_legal == 1 // recreational
gen illegal = 1 - legal
gen t = 1

* Summarize legal status by state
est clear
estpost tabstat legal illegal t, by(type_legal) stat(sum)
esttab using "$MyProject/results/tables/us-states-legality.tex", replace ///
	cells("legal illegal t") ///
	collabels("Legal" "Illegal" "Total") ///
	coeflabel(0 "Medical" 1 "Recreational") ///
	nonumber nomtitle nonote noobs label ///
	drop("Total")

** EOF
