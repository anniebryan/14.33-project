************
* SCRIPT: 1c_dispensaries_summary.do
* PURPOSE: TODO
************

use "$MyProject/processed/dispensaries.dta", clear

levelsof establishment_county, local(counties)

sort commence_date
cumul commence_date, gen(ecd) freq

local ecd_vars
foreach county in `counties' {
	di "`county'"
	cumul commence_date if establishment_county=="`county'", gen(ecd_`county') freq
	local ecd_vars `ecd_vars' ecd_`county'
}

line ecd `ecd_vars' commence_date, sort

** EOF
