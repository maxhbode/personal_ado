*! version 1.0.2 15mar2013

cap: program drop stackivregress2

program stackivregress2, eclass
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
									;
#delimit cr


* Get variable names and saved estimate names into locals
************************************************************************

* First-stage dependent / instrumented variable
loc depvar1 "first_`dep1'" /* first stage dep */

* Second-stage dependents
foreach X in `dep2' {
	loc XX = `XX' + 1
	loc dep2_`XX' = "`X'"
	loc depvar2_`XX' = "second_`X'"
}

* Define 1st and 2nd Stage Equation Names
************************************************************************

* First Stage
*-----------------------------------------

* Count instruments
loc insts_count : word count `insts'
*di "Instruments: `insts' - Count: `insts_count'"

* Open First Stage and define first equation name 
est restore `depvar1'
loc instrumentedvar = e(depvar)
loc 1stStage = subinstr(`"First Stage~-~`: var label `e(depvar)''"'," ","~",.)
*di "`1stStage'"

* First stage N (for rows) and F
loc Nfirst = e(N)
loc Ffirst = e(F)

* Split up b and V matrix into matrixes per instrument
mat b_i=e(b)
mat V_i=e(V)
forval X = 1/`insts_count' {
	mat b`X'=b_i[1,"instrument`X'"]
	mat V`X'=V_i["instrument`X'","instrument`X'"]
	mat coleq b`X'= instrument`X'
	mat coleq V`X' = instrument`X'	

	mat v`X'=vecdiag(V`X')
	mat colnames b`X'  = `1stStage':
	mat colnames v`X'  = `1stStage':
	
	*** mean of instrument
	qui su instrument`X',  meanonly
	mat MEAN`X'=r(mean)   
	mat coleq MEAN`X' = `dep1'
	mat colnames MEAN`X' = `1stStage':`="instrument`X'"'
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

* Second Stage
*-----------------------------------------

* Count dependent variables
loc dep2_count : word count `dep2'
qui di `dep2_count'

* Loop over dependent variables
forval X = 1/`dep2_count' {
	loc XX = `X' + `insts_count'
	*di "`XX' = `X' + `insts_count'"

	* Second Stage Results
	est restore `depvar2_`X''
	loc 2ndStage_`X' = subinstr(`"Second Stage~-~`: var label `e(depvar)''"'," ","~",.)
	mat b_`e(instd)'=e(b)
	mat b`XX' = b_`e(instd)'[1,"`e(instd)'"]
	mat coleq b`XX' = `dep2_`X''
	mat V_`e(instd)'=e(V)
	mat V`XX' = V_`e(instd)'[1,"`e(instd)'"]	
	mat coleq V`XX' = `dep2_`X''
	
	mat v`XX'=vecdiag(V`XX')
	
	mat colnames b`XX' = `2ndStage_`X'': 
	mat colnames v`XX' = `2ndStage_`X'':
}

* 1st and 2nd stage coefficients and variance
************************************************************************
* Create b, v and F matrix
foreach Y in b v {
* F N {
	forval X = 1/`XX' {
		loc Y`Y' `Y`Y'' `Y'`X', 
	}
	loc Y`Y' : subinstr local Y`Y' " " "", all
	loc Y`Y' : subinstr local Y`Y' "`XX'," "`XX'", all
	qui di "mat `YY' = `Y`Y''"
	mat `Y' = `Y`Y''
	*di "mat `Y' = `Y`Y''"
	*mat list `Y'
}


* Construct the fake "variance matrix" (only the diagonal matters to calculate t-statistics)
mat V=diag(v)

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

* Equation and Depvariable names (???)
************************************************************************
*eret loc eqnames= "`dep1' `dep2' `dep3'"
*eret loc depvar= "`dep1' `dep2' `dep3'"

************************************************************************

end
