*! version 1.0.2 MCHBode 15mar2013, stackivregress2
*! version 1.0.3 MCHBode 08apr2013, changed name to stackivreg
*! version 1.0.4 MCHBode 08apr2013, added model

/* Potential improvements:
(1) Take all options from fe-to-sample and combine them into one option using gettoken and tokenize
(2) Transform everything into tempnames 
*/

cap: program drop olsreg

program olsreg, eclass
#delimit ;
	syntax, dep1(string) dep2(string) insts(string)
			fe(string) 
			radius(string)
			controls(string)
			commission(string)
			migration(string)
			years(string)
			vcetype(string)
			sample(string)
			model(string)
			Finst(string)
			;
#delimit cr


* Preamble
**************************************************************************
version 10.1

* Get variable names and saved estimate names into locals
************************************************************************

* First-stage dependent / instrumented variable
loc depvar1 "f_`dep1'" /* first stage dep */

* Second-stage dependents
foreach X in `dep2' {
	loc XX = `XX' + 1
	loc dep2_`XX' = "`X'"
	loc depvar2_`XX' = "s_`X'"
}

* Define 1st and 2nd Stage Equation Names
************************************************************************

* First Stage
*-----------------------------------------

* Count instruments
loc insts_count : word count `insts'
*di "Instruments: `insts' - Count: `insts_count'"
/*
* Count instrumented variables
loc dep1_count : word count `dep1'
qui di `dep1_count'
*/
* Open First Stage and define first equation name 
est restore `depvar1'
loc instrumentedvar = e(depvar)
loc 1stStage = subinstr(`"First Stage~-~`: var label `e(depvar)''"'," ","~",.)
*di "`1stStage'"

* First stage N (for rows) and F
loc Nfirst = e(N)
loc Ffirst = e(F)

* Split up b and V matrix into matrices per instrument
mat b_i=e(b)
mat V_i=e(V)
forval X = 1/`insts_count' {
	gettoken ivvar insts : insts
	mat b`X'=b_i[1,"`ivvar'"]
	mat V`X'=V_i["`ivvar'","`ivvar'"]
	mat coleq b`X'= `ivvar'
	mat coleq V`X' = `ivvar'	

	mat v`X'=vecdiag(V`X')
	mat colnames b`X'  = `1stStage':
	mat colnames v`X'  = `1stStage':
	
	*** mean of instrument
	qui su `ivvar',  meanonly
	mat MEAN`X'=r(mean)   
	mat coleq MEAN`X' = `dep1'
	mat colnames MEAN`X' = `1stStage':`="`ivvar'"'
	*matrix list MEAN`X'
}

foreach Y in MEAN {
	forval X = 1/`insts_count' {
		loc Y`Y' `Y`Y'' `Y'`X', 
		if `insts_count'==1 loc Y`Y' `Y'`X'
	}
	loc Y`Y' : subinstr local Y`Y' " " "", all
	loc Y`Y' : subinstr local Y`Y' "`Y'`insts_count'," "`Y'`insts_count'", all
	*di "mat `Y' = `Y`Y''"
	mat `Y' = `Y`Y''
	mat rown `Y' = "`Y'"
}

* Mean of instrumented variable
*-----------------------------------------
qui su  `instrumentedvar', meanonly
loc MEAN_instd=r(mean)   

* 1st and 2nd stage coefficients and variance
************************************************************************
* Create b and V matrix
foreach Y in b v {
	forval i = 1/`XX' {
		loc matlist`Y' `matlist`Y'' `Y'`i', 
	}
	loc matlist`Y' : subinstr local matlist`Y' " " "", all
	loc matlist`Y' : subinstr local matlist`Y' "`XX'," "`XX'", all
	mat `Y' = `matlist`Y''
	* = mat define b = b1,b2,b3
	* = mat define v = v1,v2,v3
}


* Construct the fake "variance matrix" (only the diagonal matters to calculate t-statistics)
mat V=diag(v)

* Take apart Finst
************************************************************************

loc finst = substr("`finst'",1,4)

* Create Table
************************************************************************
ereturn post b V

ereturn mat MEAN = MEAN

ereturn local N="`Nfirst'"
ereturn scalar F=`Ffirst'
ereturn scalar MEAN_instd=`MEAN_instd'
ereturn local FE ="`fe'"
ereturn local Radius = "`radius'"
ereturn local Controls = "`controls'"
ereturn local Commission = "`commission'"
ereturn local Migration = "`migration'"
ereturn local Years = "`years'"
ereturn local VCEtype = "`vcetype'"
ereturn local Sample = "`sample'"
ereturn local Model = "`model'"
ereturn local cmd = "stackivreg"
ereturn local Finst ="`finst'"

************************************************************************

end
