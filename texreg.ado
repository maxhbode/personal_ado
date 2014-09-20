/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PURPOSE: 	Runs dofile while creating backup in a possibly different location
PROGRAM:	texreg
PROGRAMMER:	Max Bode (EPoD, CID, HU)
DATE:		Oct 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

set more off
set linesize 120

local PROGRAM	0
local EXAMPLE	0

if `EXAMPLE'==1 {
clear
set obs 200
g A = _n
g B = _n + 200
g C = _n - 200
g AA = _n - 200
g BB = _n + 33
g CC = 66 - _n

la var A "LaLaLa"
la var B "AAA"
la var C "LLL"

foreach Y in A B C {
	if "`Y'" == "A" 		local i = 55
	else if "`Y'" == "B" 	local i = 62
	else if "`Y'" == "C" 	local i = 69

	quietly reg `Y' BB
	quietly outreg2 using "C:\Users\mbode\Desktop/texreg/prefix_`Y'", tex(frag)
}
	

drop AA BB CC A B C
}

**********************************************************************************
* Control panel
**********************************************************************************

if `PROGRAM'==0 {
* Option
local replace replace
local fraction ""
local loop_dep dependent
local loop_ind independent
/*
if loop_dep == loop_dep local loop1 dependent
if loop_dep != loop_dep local loop1 = 1
if loop_ind == loop_ind local loop2 independent
if loop_ind != loop_ind local loop2 = 1
*/
local preamble preamble
local title title
local listoftables listoftables
local sideways sideways
local tableintro tableintro

* Nonoptions
local end end
local table table

* Fill in
local filename C:\Users\mbode\Desktop/texreg/tex
local authorname "Max Bode"
local titlename "SEWA Bank Project"
local dependent "A B C D"
local independent "AA BB CC"
}

**********************************************************************************
* Define Program
**********************************************************************************
if `PROGRAM'==1 {
cap: program drop texreg
program def texreg
	syntax [anything], 	FILEname(string)  PREfix(string) ///
						DEPendent(string) INDependent(string)   ///
						[FRACtion SIDEways author(string) title(string) ///
						maketitle listoftables replace ] 

preserve
}

**********************************************************************************
* Define Options
**********************************************************************************

* Sidewaystable 
if "`sideways'"!="sideways" local table_orientation table
if "`sideways'"=="sideways" local table_orientation sidewaystable

/*
* Create numlist
forval X = 1(1)50 {

	local numlist `" `numlist' `X' "'

}

di "`numlist'"
gettoken X_numlist 	numlist 	: numlist
*/

**********************************************************************************
* Define LaTeX Sections
**********************************************************************************

#delimit ;
local tex_preamble `" 
	"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" 
	"% Title: `titlename'" 
	"% Author: `authorname'" 
	"% DATE: April 2012" 
	"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
	"" 
	"\documentclass[9pt]{article}" 
	"" 
	"% Load packages"
	"%************************************************************" 
	"\usepackage[T1]{fontenc}" 
	"\usepackage[latin9]{inputenc}" 
	"\usepackage{geometry}" 
	"\geometry{verbose,tmargin=1in,bmargin=1in,lmargin=0.5in,rmargin=0.5in}" 
	"\usepackage{textcomp}" 
	"\usepackage[english]{babel}" 
	"\usepackage{graphicx}"
	"\usepackage{subfig}" 
	"\usepackage{rotating}" 
	"\usepackage{datatool} % Allows importing tables" 
	"\usepackage{fancyhdr}" 
	"\usepackage[hhmmss]{datetime}" 
	"\pagestyle{fancy}" 
	"\rfoot{Compiled on \today\ at \currenttime}" 
	"\cfoot{}" 
	"\lfoot{Page \thepage}" 
	"\lhead{SEWA Bank Project}" 
	"\rhead{Regression Outputs}" 
	"\usepackage{booktabs}" 
	"\usepackage{tabularx}" 
	"\renewcommand{\tabcolsep}{2pt}" 
	"\DTLsetseparator{,} % sets comma for comma separated tables" 
	"" 
	"\begin{document}"
	"" 
	"' ;

local tex_title `" 
	"% Title & Table of Contents" 
	"%************************************************************" 
	"\title{`titlename'}" 
	"\author{`authorname'}"
	"\date{`date'}"
	"\maketitle"
	""
	"' ;	
	
local tex_listoftables 	`" 
	"\listoftables" 
	""
	"' ;	
	
local tex_tableintro  `" 
	"\clearpage"
	""
	"% Tables" 
	"%************************************************************" 
	""	
	"' ;
	
local tex_sideways `" 
	"\global\pdfpageattr\expandafter{\the\pdfpageattr/Rotate 90}" 
	""
	"' ;	

local tex_table	`"
	"%%% Table : "
	"\begin{`table_orientation'}"
	"	\centering"
	"	\caption{`caption'}"		
	"	\input{`prefix'_`Y'}"
	"\end{`table_orientation'}"	
	""		
	"' ;
	
local tex_end `"
	"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" 
	"\clearpage" 
	"\newpage" 
	"\end{document}"
	"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
	""
	"' ;
	
#delimit cr

**********************************************************************************
* Define section packages
**********************************************************************************

local section "preamble title listoftables tableintro sideways table end"

* Copy of section
local section2 : list section - 0

* Without table
local notable table
local section_notable : list section - notable

* Without body
local no_body table end
local section_preamble : list section - no_body

* Without preamble or body
local notpreamble preamble table end
local section_preambleshort : list section - notpreamble

di "`section'"
di "`section2'"
di "`section_preamble'"
di "`section_preambleshort'"
di "`section_notable'"

**********************************************************************************
* Count elements/rows in sections
**********************************************************************************
foreach X in `section' {
	local n_`X' : word count `tex_`X''
	di "`X' - `n_`X''"
	}

foreach X in `section'  {

if "``X''"!="`X'" {	
	local n_`X' = 0
}

di "`X' - `n_`X''"
}

**********************************************************************************
* Create Frame: Count and Text variable
**********************************************************************************

clear

* Count of variables

foreach X in "`loop_dep'" "`loop_ind'" {
	local n_`X' : word count ``X''
	di "`X': `n_`X''"
}

* Calculate rows required
foreach X in `section_notable'  {
gettoken i_section_notable section_notable : section_notable
	local obssum = `obssum' + `n_`i_section_notable''
	di "n_`i_section_notable'"
	di `n_`i_section_notable''
}
di "`obssum'"

if `n_`loop_ind'' ==0 	local `n_`loop_ind'' = 1
if `n_`loop_dep''==0 	local `n_`loop_dep'' = 1
local obs = `obssum' + `n_table'*`n_`loop_dep''*`n_`loop_ind''

di "`obs'"

* PROBLEM: CODE NOT GENEREAL FOR MANY DIFFERENT LOOP THROUGH OPTIONS! 
* PROBLEM IN SUMMATION: IT DOESN'T SEEM TO MATTER IF IND AND DEP HAVE DIFFERENT NUMBER OF VARIABLES AND IF THEY ARE REMOVED

* Set row
set obs `obs'

* Create Count and Text variables
quietly g count = _n
quietly g text=""
format %-100s text

**********************************************************************************
* Create Section Start and End Row-Numbers 
***********************************************************************************

* Preamble
**************
if "`fraction'"!="fraction" {
local n_preamble_s	= 1
local n_preamble_e	= `n_preamble'

foreach X in `section_preambleshort'  {
	gettoken i_section2	section2 : section2

	local n_`X'_s		= `n_`i_section2'_e' + 1
	local n_`X'_e		= `n_`i_section2'_e' + `n_`X''
}
}

* Body
**************
if "`fraction'"=="fraction" local n_sideways_e = 1

foreach X in dependent independent {
	local n_`X' : word count ``X''
	di `n_`X''
}

local n_table_2 = `n_table' + 1

local n_table_s = `n_sideways_e' + 1
local n_table_e = `n_sideways_e' + `n_table_2' * `n_dependent'

di "`n_table_s' `n_table_e'"

forval X = `n_table_s'(`n_table_2')`n_table_e' {
		local numlist `" `numlist' `X' "' 
}

di "`numlist'"

foreach X in `dependent' {
	gettoken i_numlist numlist : numlist
	
	local n_table_`X'_s = `i_numlist'
	local n_table_`X'_e = `i_numlist' + `n_table'
	di "`n_table_`X'_s' - `n_table_`X'_e'"	
	di "n_table_`X'_s"
}	


* End
**************
if "`fraction'"!="fraction" {
local n_end_s = `n_table_e' + 1
local n_end_e = `n_table_e' + `n_end'
}

* Display
**************
foreach X in `section' {
	di " `n_`X'_s' - `n_`X'_e': `X' " 
}
foreach X in `dependent' {
	di " `n_table_`X'_s' - `n_table_`X'_e': Table, `X' "	
}	

**********************************************************************************
* Create LaTeX code / Generate Text
**********************************************************************************	

* Preamble
if "`fraction'"!="fraction" {
foreach X in `section_preamble'  {
if "``X''"=="`X'" {	
	forvalues i=`n_`X'_s'/`n_`X'_e' {
		gettoken i_`X' 	tex_`X'	: tex_`X'
		quietly replace text = "`i_`X''" in `i'
	}
}
}
}

* Body
forval X = 1/7 {
gettoken i_table 	tex_table	: tex_table
di "`i_table'"
}


local tex_table_1	"`tex_table'"
forval X = 1/7 {
gettoken i_table_1 	tex_table_1	: tex_table_1
di "`i_table_1'"
}


di "`tex_table_1'"

forval X = 1/`n_dependent' {
	
	local tex_table_`X'	`tex_table'
	
	di "`tex_table_`X''"
	
	gettoken X_dep dependent : dependent
	*local caption `X_dep'
	
	di "`X_dep'"
	di "`n_table_`X_dep'_s'/`n_table_`X_dep'_e'"
	
	forvalues i=`n_table_`X_dep'_s'/`n_table_`X_dep'_e' {
		gettoken i_table_`X' 	tex_table_`X'	: tex_table_`X'
		quietly replace text = "`i_table_`X''" in `i'
		di "`i_table_`X''"
		* di "`i_table'"
	}
	
}

* End
if "`fraction'"!="fraction" {
forvalues i=`n_end_s'/`n_end_e' {
	gettoken i_end 	tex_end	: tex_end
	quietly replace text = "`i_end'" in `i'
}
}

* Drop obs out of range	
count
foreach X in `n_end_e'/`r(N)' {
	drop in `X'
}
* PROBLEM: NOTHING SHOULD BE DELTED HER BECAUSE WE CALCULATED OPTIMAL AMOUNT BEFORE.
stop
**********************************************************************************
**********************************************************************************
**********************************************************************************

* Option: quietly replace
**********************************************************************************	
if "`replace'"=="replace" local erase replace

drop count
sencode text, replace

outsheet using "`filename'.tex", delimiter("") nonames noquote  `erase'


if `PROGRAM'==1 { 
restore

* End
**********************************************************************************		
end  
}
