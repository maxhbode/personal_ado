*! mvgen v1.0.0 MCHBode 09apr2013

* PURPOSE: Create missing value tag

cap: program drop mvgen2
program define mvgen2

	syntax varlist(max=1) if, [inspect] 

	qui {
		* Set if-statement
		*------------------------------
		marksample touse, novarlist
		qui count if `touse'
		if `r(N)'==0 {
			error 2000
		}
		
		* Create missing value tag
		*------------------------------
		if "`inspect'"=="inspect" {
			nois ta  		`varlist' 		if `touse', mi
		}
		g				mv_`varlist' =  `touse'
		la var 			mv_`varlist' "mv_`varlist' is missing"	
		la val 			mv_`varlist' mvl
		
		* Display execution
		*------------------------------
		nois di as text "mv_`varlist' generated"	
		if "`inspect'"=="inspect" {
			nois ta 	 mv_`varlist' 
		}
	}
	
	ta mv_`varlist'
	
end	
