*! edestring v1.0.0 MCHBode 09may2013
// This program is called extended destring or edestring.
// This program forcefully destrings variables and
// creates a string variable with the nonnumeric
// values of the variable in question.

cap: program drop edestring
program def edestring

	syntax varlist, [DIsplay]
	
	version 10.1
	loc linesize = `c(linesize)'
	set linesize 225
	
	
	foreach var in `varlist' {
		qui {
			clonevar nonnumeric_`var' =  `var'
			destring `var', replace force
			replace nonnumeric_`var'="" if `var'!=.
			la var nonnumeric_`var' `"Residual string from destringing "`var'""'
			
			nois  di as result "`var' replaced as numeric."
			
			if "`display'"=="display" {
				nois ta `var'
			}
			
			levelsof nonnumeric_`var', loc(nonnumeric_`var')
			foreach X in `nonnumeric_`var'' {
				loc temp_local `temp_local' `X' 
			}
		
			if "`temp_local'"!="" {
				nois di as result "nonnumeric_`var' created for nonnumeric values in `var'."
				
				if "`display'"=="display" {
					nois ta nonnumeric_`var'
				}
			}
			else if "`temp_local'"=="" {
				drop nonnumeric_`var'
			}
		}
	}
	
	set linesize `linesize'
	
end
