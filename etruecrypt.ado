/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PURPOSE: 	Makes - truecrypt compatible with mac and windows 
PROGRAM:	etruecrypt
PROGRAMMER:	Max Bode (EPoD, CID, HU)
DATE:		Dec 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

set more off

* Test
/*
loc drive 		q
loc mount		mount
loc replace 	repalce
loc off 		1
loc progdir		"C:/Program Files/TrueCrypt"
loc filename 	"$RAW/checklists.tc"
*/
* Drop Program
cap: program drop etruecrypt

* Define Program
**********************************************************************************

program def etruecrypt
	syntax [anything], DRive(string) [FILEname(string) Mount DISmount PROGdir(string) off(string) replace]

* Check options
if "`mount'"!="mount" & "`dismount'"!="dismount" {
		di as err "options mount and dismount are mutually exclusive"
	}
if "`mount'"=="mount" & "`dismount'"=="dismount" {
		di as err "specify mount or dismount option"
	}	
	
* Create macros
if c(os) == "Windows" {	
	di "TC_`drive'"
	c_local TC_`drive' = "`drive'" + ":"
	loc drive = "`drive'" + ":"
	
	
}

if c(os) == "MacOSX" {
	c_local TC_`drive' "/Users/`c(username)'/`drive'colon"
}

* -progdir- 
if c(os) == "Windows" {
	if "`progdir'" == "C:/Program Files/TrueCrypt" {
		loc progdir_e	
		}
	if "`progdir'" != "C:/Program Files/TrueCrypt" {
		loc progdir_e	progdir(`progdir')
		}		
	}

if c(os) == "MacOSX" {
	
	if "`progdir'" == "/Applications" {
		loc progdir_e	
		}
	if "`progdir'" != "/Applications" {
		loc progdir_e	progdir(`progdir')
		}
	}	

* loc off option
if "`off'"!="0" loc off 1 /* setting default to 1 */ 

if "`off'"=="1" 	{

	* Mounting
	if "`mount'"=="mount" {
		if "`replace'"=="replace" {
			cap: truecrypt, dismount drive(`drive')  `progdir_e'
		}
		truecrypt `filename', mount drive(`drive')  `progdir_e'
		
	}

	* Dismounting
	if "`dismount'"=="dismount" {
		truecrypt, dismount drive(`drive') `progdir_e'
	}

}

* End
**********************************************************************************		
end  
