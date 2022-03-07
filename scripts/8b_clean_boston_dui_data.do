************
* SCRIPT: 8b_clean_boston_dui_data.do
* PURPOSE: processes the boston dui dataset in preparation for analysis
************

use "$MyProject/processed/intermediate/boston_duis_uncleaned.dta", clear

* Delete first 6 rows
drop if _n<=6

* Delete last column
drop v152

* Delete bottom columns
drop if _n>=325

* Rename variable names to be values from the first row
local prev_x = ""
foreach var of varlist * {
	local x = strtoname(`var'[1])
	if "`x'"!="`prev_x'" {
		rename `var' `x'
	}
	else {
		drop `var'
	}
	local prev_x = "`x'"
}
drop in 1
rename Jurisdiction_by_Geography Arrest_Date
drop in 1

* Parse month/year into separate variables
local first_col = "Jurisdiction_by_Geography"
split Arrest_Date, parse(" ")
rename Arrest_Date1 arrest_month
destring Arrest_Date2, gen(arrest_year)
drop Arrest_Date Arrest_Date2
order arrest_month arrest_year

* Convert values to ints and replace empty values with 0
foreach var of varlist * {
	if "`var'"!="arrest_month" & "`var'"!="arrest_year" {
		destring `var', replace
		replace `var' = 0 if missing(`var')
	}
}

* Delete columns with no observations
// TODO


// compress
// save "$MyProject/processed/boston_duis.dta", replace

** EOF
