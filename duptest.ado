*! version 1.0.0 MCHBode 29May2014

* Description: This is a simple wrapper for a couple of duplicates commands.
* If duplicates are found duplicates' subcommands -report- -list- and -tag- are activated.
* If duplicates are found, the script is stopped due to the error
* If no duplicates are found, that is reported. 
* The command allows for testing in multiple variables

cap: program drop duptest

program define duptest

syntax varlist [if], [NOAssert]

foreach var in `varlist' {
	di ""
	di as result "Testing for duplicates in `var':"
	
	qui {
		duplicates report `var'
		if `r(unique_value)'!=`r(N)' {
			noisily di as error "Error: Found `r(unique_value)'/`r(N)' duplicates in `var'!"
			noisily duplicates report `var'
			noisily duplicates list `var'
			duplicates tag `var', generate(dup_`var')
			
			qui duplicates report `var'
			if "`noassert'"!="noassert" {
				assert `r(unique_value)'==`r(N)'
			}
		}
		else {
			noisily di as text "No duplicates in `varlist'"
			noisily duplicates report `var'
		}
	}
	di ""
}
	
end 
