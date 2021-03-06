*! outvarlist2 v1.0.2 MCHBode 18oct2012, v1.0.2 = outvarlist
*! outvarlist2 v1.0.3 MCHBode 01apr2013 - converting to matrix, new timestamp, rename outvarlist2

cap: program drop outvarlist2

* Define Program
**************************************************************************

program outvarlist2, rclass
	
	#delimit ;
	syntax varlist [if] [in], 
		[MATrixname(string)
		FILEDIRectory(string)
		SUmmarize(string)
		INspect(string) 		
		NOTES(string)		
		CSV
		TEX
		OUTTABLEoptions(string)
		TIMEstamp 
		DONTlist 
		remove(string)
		];
	#delimit cr
	
	* Preamble
	**************************************************************************
	loc linesize = `c(linesize)'
	set linesize 225
	version 10.1
	preserve

	* Set if-statement
	*------------------------------
	marksample touse, novarlist
	qui count if `touse'
	if `r(N)'==0 {
		error 2000
	}
	
	* Matrix name
	*------------------------------	
	if "`matrixname'"=="" {
		loc matrixname unnamed
	}	
	
	* Concert varlist into local
	*------------------------------
	qui findname `varlist', loc(string) type(string)
	if "`string'"!="" {
		di as error "The following string variables are not included:"
		di as error "`string'"
	}
	
	qui findname `varlist', type(numeric) loc(vars) v(30)
	
	if "`remove'"!="" {
		qui findname `remove', loc(removevars) type(numeric)
		loc vars : list vars - removevars
	}
	
	qui findname `vars', loc(varlist) v(30)
	
	* Change labels for tex
	*------------------------------	
	if "`tex'"=="tex" {
		foreach var in `varlist' {
			loc label `"`: var label `var''"'
			loc label_new : copy loc label
			foreach rs in # $ % ^ & _ ID_ { } ~ \ {
				loc label_new : subinstr loc label_new "`rs'" "\\`rs'", all
			}
			la var `var' "`label_new'"
		}
	}
	
	* Create Time Stamp
	*------------------------------
	if "`timestamp'"=="timestamp" {
		loc time_h = substr("`c(current_time)'",1,2)
		loc time_m = substr("`c(current_time)'",4,2)
		loc time_s = substr("`c(current_time)'",-2,.)
		loc date_y = substr("`c(current_date)'",-4,.)
		loc date_m = substr("`c(current_date)'",4,3)
		loc date_d = substr("`c(current_date)'",1,2)
		
		loc timestamp = `"_`date_y'`date_m'`date_d'_`time_h'h"'		
	}

	
	* Eror Messages
	**************************************************************************	
	if "`notes'"=="" & "`summarize'"=="" & "`inspect'"=="" {
		di as error "No summary statistics specified."
		error 42
	} 
	if "`matrixname'"!="" & "`filedirectory'"!="" {
		if "`matrixname'"!="" & "`filedirectory'"==""  {
			di as error "You cannot specify the matrixname option without the filedirectory option."
			error 42
		}
		
		if ("`matrixname'"=="" & "`filedirectory'"!="")  {
			di as error "You cannot specify the filedirectory option without the matrixname option."
			error 42
		}
	}
	
	* Parse suboptions
	**************************************************************************
	
	/*
	loc loop_su
	loc loop_in
	if "`summarize'"!="" {
		loc loop_su summarize
	}
	if "`inspect'"!="" 	{	
		loc loop_in inspect
	}
	
	if "`summarize'"!="" | "`inspect'"!=""   {
		foreach stats in `loop_su' `loop_in'  {	
			loc `stats' : subinstr local `stats' "]" "", all
			di "*** `stats' **************"
			tokenize `"``stats''"', parse(" ")
			local count : word count ``stats''
			if "`stats'"=="`loop_su'" 		loc su_count = `count'
			else if "`stats'"=="`loop_in'" 	loc in_count = `count'
			
			forval i = 1/`count' {
				loc stat`i' = "``i''"
				loc stat`i' : subinstr 		loc stat`i' "[" " "
				*di "stat`i' - `stat`i''"
			}
			
			forval i = 1/`count' {
				tokenize `"`stat`i''"', parse(" ") 
				if "`stats'"=="`loop_su'" {
					loc su_stat`i' = "`1'"
					loc su_round`i' = `2'
					di `"loc su_stat`i' = "`su_stat`i''""'
					di `"loc su_round`i' = `su_round`i''"'
				}
				else if "`stats'"=="`loop_in'" {
					loc in_stat`i' = "`1'"
					loc in_round`i' = `2'	
					di `"loc in_stat`i' = "`in_stat`i''""'
					di `"loc in_round`i' = `in_round`i''"'					
				}
			}	

		}
		
	}
	
	di "((((((((((((((((((((((("
	di "su count - `su_count'"
	di "su count - `in_count'"
	
	forval i = 1/`su_count' {
		di "stat`i' = `su_stat`i''; round`i' = `in_round`i''"
	}
	
	
	end
	sysuse auto, clear
	*set trace on
	outvarlist mpg rep78, su(mean[.1] N[99] test[3]) in(N[100]) 
	*set trace off
	*/

	* Create matrix
	**************************************************************************		
	
	* Make counts
	*------------------------------------------
	loc nrow : word count `varlist'
	
	loc ncol : word count `notes' `summarize' `inspect'
	
	loc nnot : word count `notes'
	loc nsum : word count `summarize' 
	loc nins : word count `inspect'
	
	* Create Matrix
	*------------------------------------------
	tempname rmat
	matrix `rmat'=J(`nrow',`ncol',.)
	
	* Fill in matrix
	*------------------------------------------	
	
	*** Notes statistics
	if "`notes'"!="" {
		loc irow 0
		foreach v of varlist `varlist' {
			loc ++irow
			
			loc icol = 0 
			foreach stat in `notes' {
				loc ++icol
				qui notes _fetch `v'n : `v'	`icol' /* 1 stands for not #1 */
				matrix `rmat'[`irow',`icol']=``v'n'
			}
		}	
	}
	
	*** Summarize statistics
	if "`summarize'"!="" {
		loc irow 0
		foreach v of varlist `varlist' {
			loc ++irow
			qui su `v' if `touse', detail
			
			loc icol = `nnot'
			foreach stat in `summarize' {
				loc ++icol
				matrix `rmat'[`irow',`icol']=r(`stat')
			}
		}
	}
	
	*** Inspect statistics
	if "`inspect'"!="" {
		loc irow 0
		foreach v of varlist `varlist' {
			loc ++irow
			qui inspect `v' if `touse'
			
			loc icol = `nnot' + `nsum'
			foreach stat in `inspect' {
				loc ++icol
				matrix `rmat'[`irow',`icol']=r(`stat')
			}
		}
	}
	
	*** Column and row names
	loc irow 0
	foreach v of varlist `varlist' {
		loc ++irow
		*loc varlabel `"`: var label `v''"'
		*loc varlabel : subinstr local varlabel " " "", all
		*loc varlabel : subinstr local varlabel "'" "", all
		*loc rowl `"`rowl' `varlabel'"'
		loc rown `"`rown' `v'"'
	}

	matrix colnames `rmat' = `notes' `summarize' `inspect'
	matrix rownames `rmat' = `rown'
 	*matrix roweq `rmat' = `rowl'

	*** Matrix name option
	if "`matrixname'"!="" {
		matrix `matrixname' = `rmat'
	}
		
	*** Save results
	**************************************************************************	
	return matrix rmat = `rmat'
	return local varname `varlist'
	return local cmd outvarlist2 
	
	* Outsheet
	**************************************************************************	
	
	* To TeX
	if "`matrixname'"!="" & "`filedirectory'"!="" & "`tex'"=="tex" {
		outtable2 using "`filedirectory'/`matrixname'`timestamp'", ///
		mat(`matrixname') replace `outtableoptions' overwrite(l*{20}{l})
	}	
	
	* To CSV
	if "`matrixname'"!="" & "`filedirectory'"!="" & "`csv'"=="csv" {
		mat2csv, saving("`filedirectory'/`matrixname'`timestamp'.csv") ///
		mat(`matrixname') replace 
	}	
	
	* l*{20}{c} = 1 left, 20 center
	
	
	* Display results
	**************************************************************************		
	if "`dontlist'"!="dontlist" {
		if "`matrixname'"!="" {
			matrix list `matrixname'
		}
		else if "`matrixname'"=="" {
			matrix list `r(rmat)'
		}
	}


	* Locals
	**************************************************************************		
	return loc varlist `varlist'
	
	
**************************************************************************	

restore
set linesize `linesize'
end  
