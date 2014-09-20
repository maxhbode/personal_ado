*!  master_describe v1.0.0 MCHBode 08apr2013

*! Using datasignature would be a great improvement of this command!


cap: program drop master_describe

program master_describe, rclass
	
	* Syntax
	*--------------------------------------		
	
	#delimit ;
	syntax, 
		OBServations(numlist) 
		VARiables(numlist) 
		ROWNames(string) ;
	#delimit cr
	
	* Preamble
	*--------------------------------------	
	version 10.1
	tempname masterlist	
	
	* Error Message
	*--------------------------------------	
	loc obs_count :		word count `observations'
	loc var_count : 	word count `variables'
	loc rown_count :  	word count `rownames'
	
	if "`obs_count'"!="`var_count'" | "`obs_count'"!="`rown_count'" {
			di as error "Number of objects in observations variables and rownames are unequal." 
			error 42 
	}
	
	* Create empty Matrix
	*--------------------------------------
	matrix `masterlist'=J(`rown_count',2,.)
	
	* Fill matrix with values
	*--------------------------------------
	loc i = 1
	foreach X in `observations' {
		matrix `masterlist'[`i',1]=`X'
		loc ++i
	}
	
	loc i = 1
	foreach X in `variables' {
		matrix `masterlist'[`i',2]=`X'
		loc ++i
	}
	
	* Label rows and Columns
	*--------------------------------------
	matrix colnames `masterlist' = "Observations" "Variables"
	matrix rownames `masterlist' = `rownames'
	
	nois di as text ""
	nois di as text "Number of observations and variables after execution of dofile"
	matrix list `masterlist',  noheader
	
	
end	

/*
* Example
*--------------------------------------------

sysuse auto, clear

loc i = 0

*1st dateset
loc ++i
di "`i'"


qui describe, s

loc N`i' = `r(N)'
loc k`i' = `r(k)'
loc doname`i' auto

*2nd dataset 
loc ++i

sysuse lifeexp, clear
 
qui describe, s

loc N`i' = `r(N)'
loc k`i' = `r(k)'
loc doname`i' lifeexp

* Loop
foreach X in N k doname {
	loc `X'
	forval ii = 1/`i' {
		loc `X' ``X'' ``X'`ii'' 
	}
}

di "`N'"
di "`k'"
di "`doname'"


master_describe, obs(`N') var(`k')  rown(`doname')
*/



	
	
