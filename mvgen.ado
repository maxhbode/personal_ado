*! mvgen v1.0.0 MCHBode 09apr2013

* PURPOSE: Create missing value tag

cap: program drop mvgen
program define mvgen

	syntax varlist(max=1) [if], [inspect prefix(string)] 

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
		g 				`prefix'`varlist'_mv 	=0
		replace			`prefix'`varlist'_mv	=1 	if `touse'
		la var 			`prefix'`varlist'_mv 	"`prefix'`varlist' missing"	
		la val 			`prefix'`varlist'_mv yesnol
		
		* Display execution
		*------------------------------
		nois di as text "`prefix'`varlist'_mv generated"	
		if "`inspect'"=="inspect" {
			nois ta 	 `prefix'`varlist'_mv 
		}
		
		
	}
	
	ta `prefix'`varlist'_mv
end	
