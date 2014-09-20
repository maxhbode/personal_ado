/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PURPOSE: 	
PROGRAM:	listerrors
PROGRAMMER:	Max Bode (EPoD, CID, HU)
DATE:		22 Jan 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

/*
listerrors ee_*, out($OUTPUT/errors/temp_sum_A.dta) sa($OUTPUT/errors/temp_sum_A.csv)

*/

/*
set more off

local varlist 	ee_*
local outsheet	$OUTPUT/errors/temp_sum_A.dta
local save		$OUTPUT/errors/temp_sum_A.csv
*/
* Define Program
***************************************************************
cap: program drop listerrors
program def listerrors 

	syntax varlist, [OUTsheet(string) SAve(string) SUPpresstable]

preserve

* Quite section
qui {
keep `varlist'
findname *
foreach X in `r(varlist)' {
	qui g 		e`X' = 0
	qui replace	e`X' = 1 if `X'>0
	}
drop ee_*
ren eee_* ee_*
qui findname *
collapse (sum) `r(varlist)' 
g id = 1
ren ee_* Nee_*
reshape long N , i(id) j(variable) string
ren N N_errors
drop id
}

* Not quite
if "`save'"!="" {
	sa "`save'", replace
}
if "`outsheet'"!="" {
	outsheet using "`outsheet'", replace c
}
if "`suppresstable'"!="suppresstable" {
	g variable2 = substr(variable,1,8)
	list variable N_errors, noobs divider sepby(variable2) header  
} 
restore

* End Program
***************************************************************
end 	
