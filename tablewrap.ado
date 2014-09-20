*! tablewrap, MaxBode, 3June2013
* Produces top and bottom file for tables, to  be used in combination with esttab

cap: program drop tablewrap

program tablewrap, rclass
#delimit ;
	syntax, 
		DIRectory(string) 
		[
			SIDEways // Latex Sideways table
			caption(string) // Caption of table
			suffix(string) // Suffix in filename
			ccount(string) // Column count
			hlines(string) // alternative horizontal lines in latex code, single \hline is default
			notes(string) // addnotes to bottom of table
			extracolsep(string) // extra column separator (useful if you don't want clines to touch)
		] ;
#delimit cr

* Options	
if "`suffix'"!="" {
	loc suffix _`suffix'
}
if "`ccount'"=="" {
	loc ccount 20
}
if "`extracolsep'"=="" {
	loc begintabular \begin{tabular}{l*{`ccount'}{c}}
}
else if "`extracolsep'"!="" {
	loc begintabular \begin{tabular}{@{\extracolsep{`extracolsep'}}l*{`ccount'}{c}@{}}
}
if "`hlines'"=="" {
	loc hlines \hline
}
loc tabletile = upper("`caption'")

* Remove TEX reserved characters from latex string
foreach string in caption notes {
	foreach rs in # $ % ^ & _ { } ~ \ {
		loc `string' : subinstr loc `string' "`rs'" "\\`rs'", all
	}
}

* Topfile
cap: file close topfile
file open topfile using "`directory'/topfile`suffix'.tex", write replace
#delimit ; 
file write topfile	

`"%%% Table: `tabletile' %%%"' _n
`"\begin{`sideways'table}[htbp]\centering"' _n
`"\begin{threeparttable}"' _n
`"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' _n
`"\caption{`caption'}"' _n
`"`begintabular'"' _n
`"\toprule"' _n
;
#delimit cr
* `"`hlines' \addlinespace[1mm]"' _n
cap: file close topfile

* Bottomfile
cap: file close bottomfile	
file open bottomfile using "`directory'/bottomfile`suffix'.tex", write replace
#delimit ; 
file write bottomfile	
`"\bottomrule"' _n
`"\end{tabular}"' _n
`"\begin{tablenotes}[flushleft]"' _n
`"\item \footnotesize `notes'"' _n
`"\end{tablenotes}"' _n
`"\end{threeparttable}"' _n
`"\end{`sideways'table}"' _n
;
#delimit cr
cap: file close bottomfile			
* `"\addlinespace[1mm] `hlines'"' _n
end
