*! version 1.0.1, Max Bode, 17mar2013

* master ado
* -----------------------------------------------------------
cap: program drop master
program master
	syntax anything	
	
	set linesize 225	
	cap: log close _all	
	
	* Put directory into loc
	loc dir	`anything'

	* Create master name
	loc m = lower("`dir'")
	loc m  `m'_02 master

	* Get dofiles of folder in loc
	loc dofilenames : dir "$DO/$`dir'" files "*.do", respectcase
	loc master `" "`m'.do" "`m'_body.do" "'
	loc dofilenames : list dofilenames - master

	* Display all file names and open the files
	/*
	foreach X in `dofilenames' {
		di "`X'"
		doedit2 $DO/$`dir'/`X'
	}
	*/

	di as error `""'
	di `"------------------------------------------------------- "'
	di `"INSTRUCTION: COPY/PASTE the following from the results  "'
	di `"window into this dofile after "02. master". "'
	di `"------------------------------------------------------- "'
	di `""'
	di as result `"*Setting counter for -master_describe-"'
	di `"loc i = 0"' 
	di `""'
	di `"* 01. intro"'
	di `"runcopy, file("01 intro") loc("\$DO") back("\$DO_B/\$`dir'") \`onlycopy' "'
	di `""'
	di `"* 02. master"'
	di `"runcopy, file("`m'") loc("\$DO/\$`dir'") back("\$DO_B/\$`dir'") \`onlycopy'"'
	di `""'

	* Create "m_02b master_body.do" for body (below)
	loc master  : subinstr loc master ".do" ""
	cap: erase "$DO/$`dir'/`m'_body.do"

	foreach X in `dofilenames' {
		loc XX  : subinstr loc X ".do" ""
		loc XXX  : subinstr loc XX " " ". "
		loc YY : subinstr loc XX " " "", all
		
		* Exception for summary stats (dofiles ending in - ss)
		loc ssindicator = substr("`XX'",-4,.)
		loc dropindicator = substr("`XX'",-1,.)
		loc summarystats ""
		if "`ssindicator'"=="- ss" 	loc summarystats `"if \$RUNSTATS==1 "'
		*di `"`summarystats'"'
		
		*qui log using "$DO/$`dir'/`m'_body.do", append text
		di `"* `XXX'"'
		if "`ssindicator'"!="- ss" & "`dropindicator'"!="-" {
			di `"loc ++i"'
			di `"runcopy, file("`XX'") loc("\$DO/\$`dir'") back("\$DO_B/\$`dir'") \`runcopy'"'
			di `"master_describe_tool \`i' `YY'"'
		}
		else if "`dropindicator'"=="-" {
			di `"runcopy, file("`m'") loc("\$DO/\$`dir'") back("\$DO_B/\$`dir'") \`onlycopy'"'
		}
		else if "`ssindicator'"=="- ss" {
			di `"if \`RUNSTATS'==1 runcopy, file("`XX'") loc("\$DO/$`dir'") back("\$DO_B/\$`dir'") \`runcopy'"'
		}
		di `""'
	}	
	
	di "* Number of observations and variables after execution of dofile"
	di "foreach X in N k doname {"
	di "	loc \`X'"
	di "	forval ii = 1/\`i' {"
	di "		loc \`X' \`\`X'' \`\`X'\`ii'' "
	di "	}"
	di "}"
	di ""
	di "master_describe, obs(\`N') var(\`k')  rown(\`doname')"
	di ""
	*qui log close 
		
end
