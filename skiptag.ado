/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PURPOSE: 	
PROGRAM:	
PROGRAMMER:	Max Bode (EPoD, CID, HU)
DATE:		22 Jan 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

/*
set more off
set trace on
u "$DESKTOP/temp2.dta", clear

* String example
skiptag i02_member_name, ind(i01_cdip_member) skipvalue(0) suffix(1,3,.,.) report

* Numeric example
foreach X in a02_nextboro  a03_lastboro {
	skiptag `X', ind(a01_current_farmer) skipvalue(0) suffix(1,3,.,.) report
}

*/
/*
set more off
*set trace on
u "$DESKTOP/temp2.dta", clear
local string 0

if `string'==1 { 
	local varlist 			i02_member_name
	local indicator			i01_cdip_member
}
if `string'==0 { 
	local varlist			a02_nextboro a03_lastboro
	local indicator	 		a01_current_farmer
}

local suffix "1,3,.,."
local report report

local skipvalue = 0
*/

* Define Program
***************************************************************
cap: program drop skiptag
program def skiptag 

	syntax varlist, INDicator(string) SKIPvalue(string) ///
					 [Report SUFfix(string) ///
					 PREfix(string) NOTfixvalues]

* Preamble
***************************************************************

* Define locals
local pfmissing			mi 
local pfskip			skip
if "`prefix'"=="" {
	local pferror			ee
}
else if "`prefix'"!="" {
	local pferror			`prefix'
}

* Create suffix
if "`suffix'"=="" {
	local suffix
}
else if "`suffix'"!="" {		
		local suffix = trim(itrim("`suffix'"))
		tokenize `"`suffix'"', p(,)
		local s1 = `1'
		local s2 = `3'
		local s3 = `5'
		local s4 = `7'
	local indicator_short1 = substr("`indicator'",`s1',`s2')
	local indicator_short2 = substr("`indicator'",`s3',`s4')
	local suffix = "_" + "`indicator_short1'" + "`indicator_short2'"
}

* Create skipvalues
local skipvalue : subinstr local skipvalue  " " "", all
local skipvalue : subinstr local skipvalue  "," ",", all count(local elements_n1)
local elements = `elements_n1' + 1 
tokenize `"`skipvalue'"', p(,)

forval X = 0/`elements_n1' {
	local XX = `X'+1
	local XXX = `XX'+`X'
			
	local skipvalue`XX' = `" ``XXX'' "'
	*di "skipvalue`XX' - `skipvalue`XX''"
}

***************************************************************
* Start Variable Loop
***************************************************************

foreach X in `varlist' {
qui {
* Find out whether variable is string
local typ : type `X'
local typ = substr("`typ'",1,3)

* (1) Indicate when observation is missing
***************************************************************
la de missingtagl 0 "OK (0)" 1 "MISSING (1)", replace

g 		`pfmissing'_`X' = 0
if "`typ'"!="str" replace `pfmissing'_`X' = 1 if `X'==.
else if "`typ'"=="str" replace `pfmissing'_`X' = 1 if `X'==""
la val 	`pfmissing'_`X' missingtagl	

* (2) Indicate whether observation should be skipped
***************************************************************
la de skipl 0 "DON'T SKIP (0)" 1 "SKIP (1)", replace

g 		`pfskip'_`X' = 0
*di "replace	`pfskip'_`X' = 1 if `indicator'==`skipvalue'"
forval Y = 1/`elements' {
	replace	`pfskip'_`X' = 1 if `indicator'==`skipvalue`Y''
}
la val	`pfskip'_`X' skipl

* (3) Create variabe indicating when variable should be 
*skipped but isn't and vice-vera
***************************************************************

g `pferror'_`X'`suffix' = 0
la de enumeratorerrorl 	0 "no error" 1 "type I error (value not skipped)" ///
						2 "type II error (missing value)", replace
la val `pferror'_`X'`suffix' enumeratorerrorl
la var `pferror'_`X'`suffix' "enumerator error, variable: `X', indicator: `indicator'"

* Type I error: If supposed to skip (skip, 1) but observation exists (ok, 0)
replace `pferror'_`X'`suffix' = 1 if `pfmissing'_`X' == 0 & `pfskip'_`X' == 1 

* Type II error: If NOT supposed to skip (skip, 0) but observation missing (ok, 1)
replace `pferror'_`X'`suffix' = 2 if `pfmissing'_`X' == 1 & `pfskip'_`X' == 0	

* (4) Fixing values
***************************************************************

if "`notfixvalues'"!="notfixvalues" {
*  If supposed to skip observation and observation was skipped
if "`typ'"!="str" 		local missingvalue1 = .b
else if "`typ'"=="str" 	local missingvalue1 = "Not applicable (skip)"

if "`typ'"!="str" 		replace `X' = `missingvalue1' 	///
	if `pfmissing'_`X'==1 & `pfskip'_`X'==1 & `X'==.
else if "`typ'"=="str" 	replace `X' = "`missingvalue1'" 	///
	if `pfmissing'_`X'==1 & `pfskip'_`X'==1 & `X'==""

* Type II error: If NOT supposed to skip (skip, 0) but observation missing (ok, 1)
if "`typ'"!="str" 		local missingvalue2 = .e
else if "`typ'"=="str" 	local missingvalue2 = "enumerator/deo error, missing value"

if "`typ'"!="str" 		replace `X' = `missingvalue2' 	///
	if `pfmissing'_`X' == 1 & `pfskip'_`X' == 0
else if "`typ'"=="str" 	replace `X' = "`missingvalue2'" 	///
	if `pfmissing'_`X' == 1 & `pfskip'_`X' == 0
}

* Drop variables
***************************************************************
drop mi_`X' skip_`X'

} /*ending quite loop */

* Display Result
***************************************************************
if "`report'"=="report" {
	codebook `pferror'_`X'`suffix' 
}
di "`pferror'_`X'`suffix' has been created."

***************************************************************
* End Variable Loop
***************************************************************
}

* End
***************************************************************
end 	


 
