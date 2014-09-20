*! version 1.0.1, Max Bode, 18oct2012

* Define Program
**********************************************************************************

cap: program drop runcopy
program def runcopy
#delimit ;
	syntax [anything], 
		FILEname(string) 
		LOCation(string) 
		BACKup(string) 
		[TIMEstamp 
		Suffix 
		norun 
		nocopy 
		replace 
		ARGuments(string) 
		nostop 
		do] ;
#delimit cr

* Error Message
**********************************************************************************

if "`timestamp'"=="" & "`suffix'"=="suffix" {
	di as error "Error: Suffix specified without timestamp."
}
		
* Create Time Stamp
**********************************************************************************

if "`timestamp'"=="timestamp" {
	loc time_h = substr("`c(current_time)'",1,2)
	loc time_m = substr("`c(current_time)'",4,2)
	loc date_y = substr("`c(current_date)'",-4,.)
	loc date_m = substr("`c(current_date)'",4,3)
	loc date_d = substr("`c(current_date)'",1,2)
	
	loc i = 1
	foreach X in `c(Mons)' {
		loc ++i
		if "`date_m'"=="`X'" {
			loc date_m_n = "`i'" 
			if `i'<10 {
				loc date_m_n = "0`i'" 
			}
		}
	}
	if `date_d'<10 {
		loc date_d = "0`date_d'" 
	}
	
	loc DH = "`date_y'`date_m_n'`date_d'_`time_h'h"	
	loc T = "`time_h'_`time_m'"
}

* Run
**********************************************************************************	
* Setting on/off option: Nostop
if "`nostop'"=="nostop" local X nostop

* Setting on/off option: Do
if "`do'"=="do" local Y do
if "`do'"!="do" local Y run

* quietly 
if "`run'"=="" {
	`Y' "`location'/`filename'.do" `arguments', `X' 
	di as result "Ran `filename'."
}

* Create folder
**********************************************************************************	
if "`copy'"=="" {
	cap: mkdir "`backup'/`DH'"
}
* Copy
**********************************************************************************		

* Setting on/off option:  Replace
if "`replace'"=="replace" local X replace

if "`copy'"=="" & "`suffix'"=="suffix" {
	quietly copy "`location'/`filename'.do" "`backup'/`DH'/`filename'_`T'.do", `X'
	di as result  "Backed up `filename' as `filename'_`DH' in `backup'/`DH'."
}

if "`copy'"=="" & "`suffix'"!=="" {
	quietly copy "`location'/`filename'.do" "`backup'/`DH'/`T'_`filename'.do", `X'
	di as result  "Backed up `filename' as `DH'_`filename' in `backup'/`DH'."
}
	
* End
**********************************************************************************		
end  

