*! version 1.0.2 MCHBode 15mar2013, stackivregress2
*! version 1.0.3 MCHBode 08apr2013, changed name to stackivreg
*! version 1.0.4 MCHBode 08apr2013, added model

/* Potential improvements:
(1) Take all options from fe-to-sample and combine them into one option using gettoken and tokenize
(2) Transform everything into tempnames 
*/

cap: program drop stackivreg

program stackivreg, eclass
#delimit ;
	syntax, dep1(string) dep2(string) insts(string)
			[fe(string) 
			radius(string)
			controls(string)
			commission(string)
			migration(string)
			years(string)
			vcetype(string)
			sample(string)
			model(string)
			Finst(string)]
			;
#delimit cr


* Preamble
**************************************************************************
version 10.1

* Extract Sample
************************************************************************
tempvar touse

loc vars `dep1' `dep2' `insts'

g `touse' = 1
foreach var in `vars' {
	replace `touse' = 0 if `var'>=.
} 

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

* Count instrumented variables
loc dep1_count : word count `dep1'

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
	
		*** mean of outcomes (1st stage and 2nd stage) *NEW* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  - extra column
		loc depvar : subinstr loc ivvar "inst1_" ""
		qui su `depvar' if `touse'==1,  meanonly
		mat mean`X'= nullmat(`mean'), r(mean)
		mat coleq mean`X'= `ivvar'
		mat colnames mean`X' = `1stStage':`="`ivvar'"'
	
		*** N of outcomes (1st stage and 2nd stage) *NEW* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  - extra column
		qui su `depvar' if `touse'==1
		mat num`X'= nullmat(`num'), `Nfirst'
		mat coleq num`X'= `ivvar'
		mat colnames num`X' = `1stStage':`="`ivvar'"'	
	
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
	
	*loc label `"`: var label `e(depvar)''"'
	*la var `e(instd)' "`label'"
	
	*loc 2ndStage_`X' = subinstr(`"Second Stage~-~`: var label `e(depvar)''"'," ","~",.)
	* loc 2ndStage_`X' = subinstr(`"`e(depvar)'"'," ","~",.)
	loc 2ndStage_`X' = "Second_Stage"
	mat b_`e(instd)'= e(b)
	mat b`XX' = b_`e(instd)'[1,"`e(instd)'"]
	mat coleq b`XX' = `dep2_`X''
	mat V_`e(instd)'= e(V)
	mat V`XX' = V_`e(instd)'[1,"`e(instd)'"]	
	*mat coleq V`XX' = `dep2_`X''
	mat coleq V`XX' = "Second_Stage"
	
	mat v`XX'=vecdiag(V`XX')
	
	loc newcolname "`e(depvar)'"
	*di as error  "test - `e(instd)'_`e(depvar)'"
	*di as error  "test - `e(instd)'"
	*di as error  "test - `e(depvar)'"
	*di as error  "test - `dep2_`X''"
	*loc newcolname : subinstr loc newcolname "_" "", all
	mat colnames b`XX' = `newcolname'
	mat colnames v`XX' = `newcolname'
	
	mat colnames b`XX' = `2ndStage_`X'': 
	mat colnames v`XX' = `2ndStage_`X'':

		*** N of outcomes (1st stage and 2nd stage) *NEW* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  - extra column
		*qui su `e(depvar)' if `touse'==1
		mat num`XX'= nullmat(`N'), e(N)
		*mat coleq num`XX'= `dep2_`X''
		mat coleq num`XX' = "Second_Stage"
		mat colnames num`XX' = `newcolname'
		mat colnames num`XX' = `2ndStage_`X'':	
	
		*** mean of outcomes (1st stage and 2nd stage) *NEW* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! - extra column
		qui su `e(depvar)' if `touse'==1,  meanonly
		di "`e(depvar)' - `r(mean)'"
		mat mean`XX'= nullmat(`mean'), r(mean)
		*mat coleq mean`XX'= `dep2_`X''
		mat coleq mean`XX'= "Second_Stage"
		mat colnames mean`XX' = `newcolname'
		mat colnames mean`XX' = `2ndStage_`X'':
		
}

* 1st and 2nd stage coefficients and variance
************************************************************************
* Create b and V matrix
foreach Y in b v mean num {
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

* Mean in extra column
ereturn mat mean = mean
ereturn mat num = num

ereturn local N="`Nfirst'"
ereturn scalar F=`Ffirst'
ereturn scalar MEAN_instd=`MEAN_instd'

* Options
ereturn local FE ="`fe'"
ereturn local Radius = "`radius'"
ereturn local Controls = "`controls'"
ereturn local Commission = "`commission'"
ereturn local Migration = "`migration'"
ereturn local Years = "`years'"
ereturn local VCEtype = "`vcetype'"
ereturn local Sample = "`sample'"
ereturn local Model = "`model'"
ereturn local Finst ="`finst'"

* Other ereturns
ereturn local cmd = "stackivreg"

************************************************************************

end
