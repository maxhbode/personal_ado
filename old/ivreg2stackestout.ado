*! ivreg2stack 1.0.0, 15march2013
*! Max Bode, max_bode@hks.harvard.edu
/*
cap: program drop ivreg2stack

program ivreg2stack, eclass
	syntax, dep1(string) dep2(string)
*/
* Test
loc dep1 lamount_total_ln
loc dep2 income_h_ln income_i_ln

* Get variable names and saved estimate names into locals
************************************************************************

* First-stage dependent / instrumented variable
loc depvar1 "_ivreg2_`dep1'" /* first stage dep */

* Second-stage dependents
foreach X in `dep2' {
	loc XX = `XX' + 1
	loc dep2_`XX' = "`X'"
	loc depvar2_`XX' = "_ivreg2_`X'"
}

* Define 1st and 2nd Stage Equation Names
************************************************************************
	* First Stage results
	est restore `depvar1'
	loc 1stStage = subinstr(`"First Stage~-~`: var label `e(depvar)''"'," ","~",.)
	mat b1=e(b)
	mat V1=e(V)
	mat colequation b1 = `dep1'
	mat colequation V1 = `dep1'
	mat colnames b1 = `1stStage':
	loc r2_first=e(r2)
	loc F_first=e(F)
	
	* mean of instrument
	qui su `e(insts)'
	loc x_first=r(mean)        

loc dep2_count : word count `dep2'
qui di `dep2_count'
forval X = 1/`dep2_count' {
	loc XX = `X' + 1

	* Second Stage Results
	est restore `depvar2_`X''
	loc 2ndStage_`X' = subinstr(`"Second Stage~-~`: var label `e(depvar)''"'," ","~",.)
	mat b`XX'=e(b)
	mat V`XX'=e(V)
	mat colequation b`XX' = `dep2_`X''
	mat colequation V`XX' = `dep2_`X''
	mat colnames b`XX' = `2ndStage_`X'': 
	loc r2_second_`X'=e(r2)
	loc F_second_`X'=e(F)
	
	* mean of  instrumented variables
	qui su `e(instd)'
	loc x_second_`X'=r(mean)
}

* 1st and 2nd stage coefficients and variance
************************************************************************

* variance v - vecdiag
forval X = 1/`XX' {
	mat v`X'=vecdiag(V`X')
}

* colnames
mat colnames v1 = `1stStage':
forval X = 1/`dep2_count' {
loc XX = `X' + 1
	mat colnames v`XX' = `2ndStage_`X'':
	mat colnames v`XX' = `2ndStage_`X'':	
}

foreach Y in b v {
	forval X = 1/`XX' {
		loc Y`Y' `Y`Y'' `Y'`X', 
	}
	loc Y`Y' : subinstr local Y`Y' " " "", all
	loc Y`Y' : subinstr local Y`Y' "`XX'," "`XX'", all
	qui di "mat `YY' = `Y`Y''"
	mat `Y' = `Y`Y''
}

di "`Y'"


* Summary Stats
************************************************************************
*loc N=e(N)

* Construct the fake "regression matrixes" which look like the results from a normal reg function
************************************************************************
forval X = 1/`XX' {
	loc est_b `b`X''
	loc est_V `V`X''
	
	mat b 	  	= nullmat(b)   , `est_b'[1,1]
	mat se 		= nullmat(se)  , `=sqrt(`est_V'[1,1])'
}
	
mat V=diag(se)

 * Return the results in e() to be read by eststo. 
************************************************************************
eret post b V

/*
ereturn scalar N=`N'



ereturn scalar r2_first=`r2_first'
ereturn scalar F_first=`F_first'
ereturn scalar x_first=`x_first'

forval X = 1/`dep2_count' {
	ereturn scalar r2_second_`X'=`r2_second_`X''
	ereturn scalar F_second_`X'=`F_second_`X''
	ereturn scalar x_second_`X'=`x_second_`X''
}
*/	
	
* Equation and Depvariable names (???)
************************************************************************
*eret loc eqnames= "`dep1' `dep2' `dep3'"
*eret loc depvar= "`dep1' `dep2' `dep3'"

************************************************************************

end
