*! outvarlist v1.0.2 MCHBode 18oct2012

cap: program drop outvarlist

* Define Program
**************************************************************************

program outvarlist, rclass
	
	#delimit ;
	syntax varlist [if] [in], 
		[FILEname(string) 
		TIMEstamp 
		SUmmarize(string) 
		INspect(string) 
		DONTlist 
		REport(string)
		remove(string)
		type(string)
		tex
		LONGtable
		csv
		excel
		input(string)
		notesmax(string) // number of notes
		]
	;
	#delimit cr
	
	* Preamble
	**************************************************************************
	version 10.1
	
	* Temporarily change linesize
	*------------------------------	
	loc linesize = `c(linesize)' 
	set linesize 225
	
	* Set if-statement
	*------------------------------
	marksample touse, novarlist
	qui count if `touse'
	if `r(N)'==0 {
		error 2000
	}
	
	* Set number of notes reported 
	*------------------------------
	if "`notesmax'"=="" loc notesmax 1 
	forval j = 1/`notesmax' {
			loc notes `notes' note`j'
	}

	* Set default report
	*------------------------------
	loc report_all name varlabel vallabel vallabeldef `notes' type 
	if "`report'"=="" loc report name varlabel vallabel vallabeldef `notes' type
	*else if "`report'"!="" loc report `report'
	else if "`report'"!="" loc report : subinstr loc report "notes" "`notes'"
	
	* Concert varlist into local
	*------------------------------
	if "`type'"=="" { 
		loc typeoption 
	}
	else if "`type'"!="" {
		loc typeoption type(`type')
	}
	
	if "`remove'"=="" {
		qui findname `varlist', loc(variables) `typeoption'
	}
	else if "`remove'"!="" {
		qui findname `varlist', loc(vars) `typeoption'
		qui findname `remove', loc(removevars) `typeoption'
		loc vars : list vars - removevars
		qui findname `vars', loc(variables)
	}
	
	* Error message for no observations
	*------------------------------
	if "`variables'"=="" {
		di as error "No variables"
		error 42
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
	
	* Create tables
	**************************************************************************	

	*tempvar name varlabel vallabel vallabeldef notes type
	
	preserve
	qui {
		foreach Y in `report_all' {
			g `Y' = ""
			format `Y' %-5s
			
		}
		foreach Y in `summarize' `inspect' {
			g `Y' = .
		}
		
		local vars `report' `summarize' `inspect' 
		
		local i = 1

		foreach X in `variables' {
		loc string = substr(`"`: type `X''"',1,3)
		
			replace name		= "`X'" in `i'
			replace varlabel 	= `"`: var label `X''"' in `i'
			replace vallabel 	= `"`: val label `X''"' in `i'
			
			
			labellist, rc0
			loc labels `"`r(`X'_labels)'"'
			foreach Z in `r(`X'_values)' {
				gettoken i_label	labels : labels
				loc vallabeldef  `vallabeldef' `Z' `i_label' 
			}
			format %-20s name varlabel vallabel vallabeldef
			
			cap: replace vallabeldef = "`vallabeldef'" in `i'
			
			forval j = 1/`notesmax' {
				notes _fetch `X'n : `X'	`j' /* j stands for not #j */
				replace note`j'	=  "``X'n'" in `i'	
			}
			replace type = `"`: type `X''"' in `i'	
			
			if "`summarize'"!="" {
					if  "`string'"!="str"  {
						su `X' if `touse'
					}
					foreach Y in `summarize' {
						di "`string'"
						if  "`string'"!="str"  		replace `Y' = r(`Y') in `i'
						if  "`string'"!="str"  		format `Y'  %9.1g
						else if  "`string'"=="str"  replace `Y' =. in `i'
					}
			}
			
			if "`inspect'"!=""  {	
					if  "`string'"!="str"  {
						inspect `X' if `touse'
					}
					foreach Y in `inspect' {
						if  "`string'"!="str"  		replace `Y' = r(`Y') in `i'
						if  "`string'"!="str"  		format `Y'  %9.1g
						else if  "`string'"=="str"  replace `Y' =. in `i'
					}
			}

		
		local ++i
		}
		
		drop if name == ""
		

		* Outsheet tables
		**************************************************************************

		* Outsheet to EXCEL
		*--------------------------------------------
		if "`excel'"=="excel" & "`filename'"!="" {
			export excel `vars' using "`filename'`timestamp'", sheetreplace ///
				  sheet("variable_names")
		}
		
		* Outsheet to CSV
		*--------------------------------------------
		if "`csv'"=="csv" & "`filename'"!="" {
			outsheet `vars' using "`filename'`timestamp'.csv", c replace
		}
		
		* Outsheet to TEX
		*--------------------------------------------		
		if "`tex'"=="tex" & "`filename'"!="" {
			
			* Remove TEX reserved characters	
			foreach stat in `report' {
				ren `stat' `stat'_old
				g `stat' = ""
				*loc vars : subinstr loc vars "`stat'" "`stat'", all
	
				levelsof `stat'_old, loc(`stat'_values)
				foreach val in ``stat'_values' {
					loc val_new : copy loc val
					foreach rs in # $ % ^ & _ { } ~ \ {
						loc val_new : subinstr loc val_new "`rs'" "\\`rs'", all
					}
					replace `stat'="`val_new'" if `stat'_old=="`val'"
				}
			}
			
			* Count variables
			loc varcount : word count `vars'
			
			loc i = 0
			foreach var in `vars' {
				loc ++i
				loc var_name : subinstr loc var "var" "variable "
				loc var_name : subinstr loc var_name "val" "value "
				loc var_name : subinstr loc var_name "def" ""
				loc var_name = proper("`var_name'")
				if `i'<`varcount' {
					loc var_names  `var_names' {`var_name'} &  	
				}
				if `i'==`varcount' {
					loc var_names  `var_names' {`var_name'} \\	
				}
			}
			
			if "`input'"=="" {
				loc input l*{`varcount'}{l}
			}
			else if "`input'"!="" {
				loc input `input'
			}
			
			* Outsheet tex table
			if "`longtable'"!="longtable" {
				#delimit ;
				listtex `vars'
					using "`filename'`timestamp'.tex",
					rstyle(tabular) 
					head(
						"\begin{table}[h]"
						"\centering"
						"\begin{tabular}{`input'}"
						"\hline \hline"
						"`var_names'"
						"\hline"
						)
					foot(
						"\hline \hline"
						"\end{tabular}"
						"\end{table}"
						)
					replace
				;
				#delimit cr
			}
			
			* Outsheet tex longtable
			else if "`longtable'"=="longtable" {
				#delimit ;
				listtex `vars'
					using "`filename'`timestamp'.tex",
					rstyle(tabular) 
					head(
						"\begin{center}"
						"\begin{longtable}{`input'}"
						"\hline"
						"\hline"
						" \multicolumn{1}{l}`var_names' "
						"\hline" 
						" \endfirsthead"
						"\multicolumn{3}{l}{\emph{... table \thetable{} continued}} \\"
						"\hline \hline" 
						" \multicolumn{1}{l}`var_names' "
						"\hline"
						"\endhead"
						"\hline"
						"\multicolumn{3}{r}{\emph{Continued on next page...}} \\"
						"\endfoot"
						"\endlastfoot"
						)
					foot(
						"\hline \hline"
						"\end{longtable}"
						"\end{center}"
						)
					replace
				;
				#delimit cr			
			}
			
			* Restore old names
			foreach stat in `report' {
				drop `stat'
				ren `stat'_old `stat'
			}
		}
		
		* List variabes
		*--------------------------------------------
		if "`dontlist'"!="dontlist" {
			nois list `vars', notrim clean noobs
		}
		
	}
	


	restore	


	
	* Return
	**************************************************************************		
	return loc varlist `variables'

	
**************************************************************************	

set linesize `linesize'
end  
