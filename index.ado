*! version 1.0.1, Max Bode, 28mar2013

cap: program drop index
program define index
	syntax varlist, [name(string) varlabel(string)]
	
	qui {
		nois findname `varlist', loc(varlist)

		* Normalize variables
		foreach var in `varlist' {
			tempvar norm_`var'
			su `var'
			g `norm_`var'' = (`var'-`r(mean)')/`r(sd)'
			la var `norm_`var'' `"`: var label `var'', normalized"'
			loc normalized `normalized' `norm_`var''
			loc K = `K' + 1
		}
		
		* Sum normalized values
		if "`name'"=="" {
			loc name index
		}
		if "`varlabel'"=="" {
			loc varlabel "Index: `varlist'"
		}
		
		egen `name' = rowtotal(`normalized')
		cap: drop rowmiss
		egen rowmiss = rowmiss(`normalized')
		replace `name' = . if rowmiss>0
		replace `name' = `name'/`K'
		la var `name' "`varlabel'"
	}
	
	outvarlist `name' `normalized' `varlist', re(varlabel) su(mean sd N)
	di `"Note: The "normalized" variables are only temporary variables."'
	
end

/*
sysuse auto, clear
index mpg gear_ratio weight trunk length, name(index) 

twoway (kdensity norm_mpg) (kdensity norm_gear_ratio) (kdensity index)
*/
