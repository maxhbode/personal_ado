// Author: Johannes F. Schmieder
// Version: June 2007
// Department of Economics, Columbia University
// Comments and suggestions welcome: jfs2106 {at} columbia.edu

capture program drop mat2tex
program define mat2tex
	version 9
	syntax using/ , Matrix(name) [ REPlace APPend Title(str) /// 
		SUBTitle(str) NOTEs(str)  ///
		COLumnnames(string asis) ROWlabels(string asis) ///
		PAGE FRAGment BOOKTabs NOMIDrule PLACEment(str) ///
		STARs(name) TMAT(name) SIDEways LANDScape size(str)]		
		
	if "`replace'"=="" & "`append'"=="" local replace replace

	local nrows=rowsof(`matrix')
	local ncols=colsof(`matrix')
	
	if "`stars'"!="" {
		local nrowsstar=rowsof(`stars')
		local ncolsstar=colsof(`stars')
		assert `nrows'==`nrowsstar'
		assert `ncols'==`ncolsstar'
	}
	
	if "`tmat'"!="" {
		local nrowsstar=rowsof(`tmat')
		local ncolsstar=colsof(`tmat')
		assert `nrows'==`nrowsstar'
		assert `ncols'==`ncolsstar'
	}
	
	Mat2csvQuotedFullnames `matrix' row
	Mat2csvQuotedFullnames `matrix' col
	if `"`columnnames'"'!="" {
		local colnames "`columnnames'"
	}	
	if `"`rowlabels'"'!="" {
		local rownames "`rowlabels'"
	}
	
	local align "r"
	if "`center'" == "center" local align "c"
	forvalues i=1/`ncols' {
		local l "`l'`align'"
	}
	local l "l`l'"
	
	if "`booktabs'"=="booktabs" {
		local toprule \toprule
		local bottomrule \bottomrule \addlinespace
		if "`nomidrule'"=="" local midrule \midrule
		else local midrule \addlinespace
	} 
	else {
		local toprule \hline\hline
		local bottomrule \hline\hline \addlinespace
		if "`nomidrule'"=="" local midrule \hline
	}
	if "`placement'"=="" local placement htbp
	if "`sideways'"!="" {
		local sidewaysbegin \begin{sideways}
		local sidewaysend \end{sideways}
	}
	if "`rotate'"!="" {
		confirm number `rotate'
		local rotbegin \begin{rotate}{`rotate'}	
		local rotend \end{rotate}	
	}
	if "`size'"=="footnotesize" {
		local footnotesize "\footnotesize"
		local size "\footnotesize"
	}
	else if "`size'"=="scriptsize" {
		local footnotesize "\scriptsize"
		local size "\scriptsize"
	}
	else if "`size'"=="tiny" {
		local footnotesize "\tiny"
		local size "\tiny"
	}
	else if "`size'" == "" {
		local footnotesize "\footnotesize"
		local size ""
	}
	else {
		di in red "Size must be footnotesize, scriptsize or tiny"
		exit 101
	}		
	
	local using: subinstr local using "." ".", count(local ext)
	if !`ext' local using "`using'.tex"	
	tempname fh
	file open `fh' using `"`using'"', write text `append' `replace'

	// Write Document Header
	if "`page'"=="page" {
		file write `fh'  "%  `c(current_date)' `c(current_time)'" _n
		file write `fh'  "\documentclass{article}" _n
		file write `fh'  "\usepackage{geometry}" _n
		file write `fh'  "\usepackage{booktabs,rotating}" _n		
		file write `fh'  "\geometry{verbose,letterpaper,lmargin=1cm}" _n
		file write `fh'  "\begin{document}" _n
	}

	// Write Table Header
	if "`fragment'"=="" | "`page'"=="page" {
		if "`landscape'"!="" file write `fh' "\begin{landscape}" _n
		file write `fh' "\begin{table}[`placement']" _n
		if "`title'"!="" file write `fh' "\caption{\label{clabel} `title'}\centering\medskip" _n
		if "`size'"!="" file write `fh' "`size' " _n  
		file write `fh' "  \begin{tabular}{`l'} `toprule'" _n  
	}
	
	// Write Columnnames
	foreach colname of local colnames {
			local colname = subinstr(`"`colname'"',"_","\_",.)
			local rowname = subinstr(`"`rowname'"',"#","\#",.)			
			file write `fh' `"& `sidewaysbegin'`rotbegin' `colname' `rotend'`sidewaysend'"' 
	}

	//Write Cells
	file write `fh' " \" "\ `midrule'" _n
	forvalues r=1/`nrows' {
		local rowname: word `r' of `rownames'
		local rowname = subinstr(`"`rowname'"',"_","\_",.)
		local rowname = subinstr(`"`rowname'"',"#","\#",.)		
		file write `fh' `"    `rowname '"'
		forvalues c=1/`ncols' {
			*if `c'<=`formatn' local fmt: word `c' of `format'
			if "`stars'"!="" local starred = cond(`stars'[`r',`c']<.05,"*","")
			if "`tmat'"!="" local starred = cond(`tmat'[`r',`c']>1.96,"*","")			
			Mat2texSignificantDigits a3 `matrix'[`r',`c']
			file write `fh' `" & "'
			file write `fh' `fmt' (`matrix'[`r',`c']) 
			file write `fh' `"`starred' "'
		}
		file write `fh' " \" "\ " _n
	}
	file write `fh' "    `bottomrule'" _n	

	// Write Footnotes	
	if `"`notes'"'!="" {
		tokenize `notes', parse("|")
		while "`1'"!="" {
			if "`1'" !="|" file write `fh' ///
				"    \multicolumn{`=`ncols'+1'}{l}{`footnotesize' `1'}\\" _n
			mac shift
		}
	}
	
	// Write Table Footer
	if "`fragment'"=="" | "`page'"=="page" {
		file write `fh'  "  \end{tabular}" _n
		file write `fh'  "\end{table}" _n
		if "`landscape'"!="" file write `fh' "\end{landscape}" _n
	}
	
	// Write Document Footer
	if "`page'"=="page" {
		file write `fh'  "\end{document}" _n
	}	
	
	file close `fh'
end

program define Mat2csvQuotedFullnames
        args matrix type
        tempname extract
        local one 1
        local i one
        local j one
        if "`type'"=="row" local i k
        if "`type'"=="col" local j k
        local K = `type'sof(`matrix')
        forv k = 1/`K' {
                mat `extract' = `matrix'[``i''..``i'',``j''..``j'']
                local name: `type'names `extract'
                local eq: `type'eq `extract'
                if `"`eq'"'=="_" local eq
                else local eq `"`eq':"'
                local names `"`names'`"`eq'`name'"' "'
        }
        c_local `type'names `"`names'"'
end

program Mat2texSignificantDigits // idea stolen from outreg2.ado
	args fmt value
	local d = substr("`fmt'", 2, .)
	capt confirm integer number `d'
	if _rc {
		di as err `"`fmt' not allowed"'
		exit 198
	}
// missing: format does not matter
	if `value'>=. local fmt "%9.0g"
// integer: print no decimal places
	else if (`value'-int(`value'))==0 {
		local fmt "%12.0f"
	}
// value in (-1,1): display up to 9 decimal places with d significant
// digits, then switch to e-format with d-1 decimal places
	else if abs(`value')<1 {
		local right = -int(log10(abs(`value'-int(`value')))) // zeros after dp
		local dec = max(1,`d' + `right')
		if `dec'<=9 {
			local fmt "%12.`dec'f"
		}
		else {
			local fmt "%12.`=min(9,`d'-1)'e"
		}
	}
// |values|>=1: display d+1 significant digits or more with at least one
// decimal place and up to nine digits before the decimal point, then
// switch to e-format
	else {
		local left = int(log10(abs(`value'))+1) // digits before dp
		if `left'<=9 {
			local fmt "%12.`=max(1,`d' - `left' + 1)'f"
		}
		else {
			local fmt "%12.0e" // alternatively: "%12.`=min(9,`d'-1)'e"
		}
	}
	c_local fmt "`fmt'"
end
