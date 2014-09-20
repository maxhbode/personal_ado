*! tablewraplong, MaxBode, 4June2013
* Produces top and bottom file for tables, to  be used in combination with esttab

cap: program drop tablewraplong

program tablewraplong, rclass
#delimit ;
	syntax, 
		DIRectory(string) 
		[
			caption(string) // Caption of table
			suffix(string) // Suffix in filename
			ccount(string) // Column count
			notes(string) // addnotes to bottom of table
			extracolsep(string) // extra column separator (useful if you don't want clines to touch)
			toprow(string)
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
	loc beginlongtable \begin{longtable}{l*{`ccount'}{c}}
}
else if "`extracolsep'"!="" {
	loc beginlongtable \begin{longtable}{@{\extracolsep{`extracolsep'}}l*{`ccount'}{c}@{}}
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
`"\begin{ThreePartTable}"' _n
`"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' _n
`"\begin{TableNotes}[flushleft]"' _n
`"\item \footnotesize `notes'"' _n
`"\end{TableNotes}"' _n
`"`beginlongtable'"' _n
`"\caption{`caption'}\\"' _n
`"\toprule"' _n
`"`toprow' "' _n
`"\endfirsthead"' _n
`"\multicolumn{`ccount'}{l}{\emph{... table \thetable{} continued}} \\"' _n
`"\toprule"' _n
`"`toprow' \\"' _n
`"\midrule"' _n
`"\endhead"' _n
`"\multicolumn{`ccount'}{r}{\emph{Continued on next page...}}\\"' _n
`"\endfoot"' _n
`"\bottomrule"' _n
`"\insertTableNotes\\"' _n
`"\endlastfoot"' _n
;
#delimit cr
cap: file close topfile

* Bottomfile
cap: file close bottomfile	
file open bottomfile using "`directory'/bottomfile`suffix'.tex", write replace
#delimit ; 
file write bottomfile	
`"\end{longtable}"' _n
`"\end{ThreePartTable}"' _n
;
#delimit cr
cap: file close bottomfile			
* `"\addlinespace[1mm] `hlines'"' _n
end
