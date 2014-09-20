*! version 1.0.1, Max Bode, 17mar2013
*! version 1.0.2, Max Bode, 16apr2013 made universal

* master ado
* -----------------------------------------------------------
/*OVERVIEW

I WRITING MASTER
(1) PREAMBLE
(2) BODY - INCL. ALL DOFILES IN FOLDER
(3) SUMMARY STATS ABOUT DATASETS FROM END OF EACH DOFILE */

cap: program drop master2
program master2
	syntax anything, [NAME(string) INTRO(string)]	

	*************************************************************************
	* Create Time Stamp
	*************************************************************************

	loc time_h = substr("`c(current_time)'",1,2)
	loc time_m = substr("`c(current_time)'",4,2)
	loc date_y = substr("`c(current_date)'",-4,.)
	loc date_m = substr("`c(current_date)'",4,3)
	loc date_d = substr("`c(current_date)'",1,2)
	
	if `date_d'<10 {
		loc date_d = "0`date_d'" 
	}
	
	loc DMY = "`date_d' `date_m' `date_y'"	

	*************************************************************************
	* Generate master .do file
	*************************************************************************
	
	* Put directory into loc
	loc dir	`anything'

	* Create master name
	loc m = lower("`dir'")

	* Get dofiles of folder in loc (remove intro and master)
	if "`name'"!="" {
		loc mastername `name'
	}
	else {
		loc mastername master
	}

	loc masternamedo "`mastername'.do"
	loc do ".do"
	loc dofilenames : dir "$DO/`dir'" files "*.do", respectcase
	loc dofilenames : list dofilenames - masternamedo
	loc dofilenames : list dofilenames - do // correcting for weird error where ".do" gets into the master list
	
	* Generate master
	cap: file close master
	qui file open master using "$DO/`dir'/`mastername'.do", write replace
	nois di as result `"\$DO/`dir'/`mastername'.do written."'

	*************************************************************************
	* (I.1) PREAMBLE
	*************************************************************************
	#delimit ;
	qui file write master
		`"/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"' _n
		`"PROJECT: 	SEWA Bank"' _n
		`"PURPOSE: 	Do-file Directory"' _n
		`"PROGRAMMER:	Max Bode (EPoD, CID, HU)"' _n
		`"DATE:		`DMY'"' _n
		`"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/"' _n
		`""' _n
		`"set more off"' _n
		`"set linesize 225"' _n
		`"set graphics off"' _n
		`""' _n
		`"*************************************************************************"' _n
		`"* Command Bridge"' _n
		`"*************************************************************************"' _n
		`""' _n
		`"* Truecrypt mounting on/off"' _n
		`"*------------------------------------------------------"' _n
		`""' _n
		`"loc dir "`dir'""' _n
		`""' _n
		`"local TRUECRYPT 0"' _n
		`"* Truecrypt volumes get mounted trough running the "01 intro.do" file."' _n
		`"* IF TRUECRYPT==0 then volumes are not mounted in "01 intro.do"."' _n
		`"if "`1'" != "" local TRUECRYPT "`1'""' _n
		`"	* this argument is being passed on from the master files if they are run."' _n
		`""' _n
		`"* runcopy option controls"' _n
		`"*------------------------------------------------------"' _n
		`"local RUN		0"' _n
		`"local COPY		1"' _n
		`"local OUTSHEET	0"' _n
		`"local RUNSTATS	0"' _n
		`""' _n
		`"if \`RUN' == 0 local norun norun"' _n
		`"else if \`RUN' == 1 local norun"' _n
		`""' _n
		`"if \`COPY' == 0 local nocopy nocopy"' _n
		`"else if \`COPY' == 1 local nocopy"' _n
		`""' _n
		`"* Select options for runcopy"' _n
		`"*------------------------------------------------------"' _n
		`"* The argument master_skiptruecryptmount sets the local "' _n
		`"* TRUECRYPT in the respective .do file to 0."' _n
		`"local runcopy "timestamp \`norun' \`nocopy' replace arg("master_skiptruecryptmount")""' _n
		`"local onlycopy "timestamp norun \`nocopy' replace arg("master_skiptruecryptmount")""' _n
		`""' _n
		`"*************************************************************************"' _n
		`"* Do-Files"' _n
		`"*************************************************************************"' _n
		`""' _n
		`"*Setting counter for -master_describe-"' _n
		`"loc i = 0"' _n 
		`""' _n		
				`"* 01. intro"' _n
		`"runcopy, file("01 intro") loc("\$DO/") back("\$DO_B/") \`onlycopy' "' _n
		`""' _n
		`"* 02. master"' _n
		`"runcopy, file("`mastername'") loc("\$DO/\`dir'") back("\$DO_B/\`dir'") \`onlycopy'"' _n
		`""' _n ;
		
	#delimit cr

		/*

		*/ 
			
	*************************************************************************
	* (I.2) WRITING MASTER: BODY - INCL. ALL DOFILES IN FOLDER
	*************************************************************************

	foreach X in `dofilenames' {
		loc XX  : subinstr loc X ".do" ""
		loc XXX  : subinstr loc XX " " ". "
		loc YY : subinstr loc XX " " "", all
		
		* Exception for summary stats (dofiles ending in - ss)
		loc ssindicator = substr("`XX'",-4,.)
		loc dropindicator = substr("`XX'",-1,.)
		loc summarystats ""
		if "`ssindicator'"=="- ss" 	loc summarystats `"if \$RUNSTATS==1"'
		*di `"`summarystats'"'
		
		*qui log using "$DO/`dir'/`m'_body.do", append text
		file write master `"* `XXX'"' _n
		if "`ssindicator'"!="- ss" & "`dropindicator'"!="-" {
			file write master `"loc ++i"' _n
			file write master `"runcopy, file("`XX'") loc("\$DO/\`dir'") back("\$DO_B/\`dir'") \`runcopy'"' _n
			file write master `"master_describe_tool \`i' `YY'"' _n
		}
		else if "`dropindicator'"=="-" {
			file write master `"runcopy, file("`XX'") loc("\$DO/\`dir'") back("\$DO_B/\`dir'") \`onlycopy'"' _n
		}
		else if "`ssindicator'"=="- ss" {
			file write master `"if \`RUNSTATS'==1 runcopy, file("`XX'") loc("\$DO/`dir'") back("\$DO_B/\`dir'") \`runcopy'"' _n
		}
		file write master `""' _n
	}	
	
	*************************************************************************
	* (I.3) WRITING MASTER: SUMMARY STATS ABOUT DATASETS FROM END OF EACH DOFILE
	*************************************************************************
	#delimit ;
	file write master
		`"* Number of observations and variables after execution of dofile"' _n
		`"if \`RUN'==1 {"' _n
		`"	foreach X in N k doname {"' _n
		`"		loc \`X'"' _n
		`"		forval ii = 1/\`i' {"' _n
		`"			loc \`X' \`\`X'' \`\`X'\`ii'' "' _n
		`"		}"' _n
		`"	}"' _n
		`""' _n
		`"	master_describe, obs(\`N') var(\`k')  rown(\`doname')"' _n
		`"}"' _n 
		`""' _n 
		`"* NOTE THAT THIS DOFILE WAS CREATED BY THE PROGRAM -master-."' _n
		`""' _n ;
	#delimit cr
	
	* Close Master
	file close master
	
end
