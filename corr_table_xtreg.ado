*! Jonathan Holmes & Max Bode, max_bode@hks.harvard.edu
*! 3/15/2013

************************************************************************

cap: program drop corr_table_xtreg
program define corr_table_xtreg, eclass 
	/*	The following program is meant to provide the results from "reg <depvar> <variable>, <condlist>" for every <variable> in <varlist>.
		It then exports the results in e() as if it were a regression to be able to create a nice estout table. 	*/
	#delimit ;
	syntax varlist, 
		indvar(varname) 
		[
			condlist(string asis) 
			radius(string)
			controls(string)
			controllabel(string) 
			felabel(string)
			vcelabel(string)
			colequations
		];
	#delimit cr
	
************************************************************************


* Create fake regression output
*---------------------------------------------------

tempname est_b est_V b V se est_F F N mean

foreach var of local varlist {

	* HERE is the regression
	di as result "xtreg `var' `indvar' `controls', `condlist'"
	qui xtreg `var' `indvar' `controls', `condlist' 

	* Save results from regression
	mat `est_b' 	= e(b)
	mat `est_V' 	= e(V)
	mat `est_F'		= e(F)

	* Get mean and N from indvar
	qui su `var'

	* Construct the fake "regression matrixes" which look like the results from a normal reg function
	mat `b'  	  	= nullmat(`b')   , `est_b'[1,1]
	mat `se' 		= nullmat(`se')  , `=sqrt(`est_V'[1,1])'
	mat `N'  		= nullmat(`N'), r(N)	
	mat `mean'  	= nullmat(`mean'), r(mean)
	mat `F'		  	= nullmat(`F'), `est_F'
	
}

* Label the output matricies
foreach mat in b se F N mean {
	if "`colequations'"=="colequations" {
	mat coleq ``mat'' = `varlist'
	}
	mat coln ``mat'' = `varlist'
	mat rown ``mat'' = `indvar'
}

* Construct the fake "variance matrix" (only the diagonal matters to calculate t-statistics)
mat `V' = `se''*`se'

* Indicators
*---------------------------------------------------

* Control indicator
if "`controllabel'"!="" {
	loc controlyesno "`controllabel'"
}
else if "`controllabel'"=="" {
	loc controlyesno "no"
	if "`controls'"!="" {
		loc controlyesno "yes"
	}
}

* VCE indicator
if "`vcelabel'"!="" {
	loc vcelabel = "`vcelabel'"
}
else if "`vcelabel'"=="" {
	loc vcelabel "normal" 
}

* Return the results in e() to be read by eststo. 
ereturn post `b' `V', depname("`indvar'") 
ereturn local cmd "corr_table"
if "`felabel'"!="" {
	ereturn local felabel =	"`felabel'"
}
if "`controllabel'"!="" {
	ereturn local controllabel = "`controllabel'"
}
if "`radius'"!="" {
	ereturn local Radius = `radius'
}
ereturn local Controls `controlyesno'
ereturn local VCE `vcelabel' 
foreach mat in F N mean {
	ereturn mat `mat' = ``mat''
}


*matrix list e(b)

************************************************************************	 
	
end
