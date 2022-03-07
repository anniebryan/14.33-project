************
* SCRIPT: 1b_clean_dispensaries_data.do
* PURPOSE: processes the dispensaries dataset in preparation for analysis
************

use "$MyProject/processed/intermediate/dispensaries_uncleaned.dta", clear

* Select only desired columns
local keep business_name license_type establishment_address_1 establishment_city establishment_zip_code establishment_county commence_operations_date
ds
local vars `r(varlist)'
local tokeep : list vars & keep
keep `tokeep'

* Keep only entries that have certain license types
keep if license_type=="Marijuana Retailer"
drop license_type

* Keep only entries that have commenced operations
keep if commence_operations_date!=""

* Create variables for commencement operations month, day, and year
split commence_operations_date, parse("/")
destring commence_operations_date1, gen(commence_month)
destring commence_operations_date2, gen(commence_day)
destring commence_operations_date3, gen(commence_year)
drop commence_operations_date commence_operations_date1 commence_operations_date2 commence_operations_date3

* Create combined date variable
gen commence_date = commence_year + (commence_month-1)/12 + commence_day/365
sort commence_date

* Change format of zip code to be 5 digits
format establishment_zip_code %05.0f

* Rename address variable
rename establishment_address_1 establishment_address

compress
save "$MyProject/processed/dispensaries.dta", replace

** EOF
