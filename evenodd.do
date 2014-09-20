

loc i		0
loc oldr	0

foreach X in a a b b c c d d e e {
	loc ++i
	
	loc r = round(`i'/2)
	cap: loc dr = `r'-`oldr'

	*di as result "`X' - `i' - `r' - `dr'"
	
	if `dr'==1 {
		di as error "`X'"
	}
	
	loc oldr = `r'
}






STOP

			loc i		0
			loc oldr	0
			
			foreach dep1st in `depvar1st_fso' { 
				loc dep1stshort	`dep1st'
				loc dep1st 		``dep1st''
				loc dep1stname : subinstr loc dep1stshort "_" "", all	
				loc dep1stlabel = `"`: var label `dep1st''"'
				
				di as result "`dep1stlabel'"
				
				*** Creating locals for esttab ***	
				*------------------------------------
				loc ++i

				loc r = round(`i'/2)
				loc dr = `r'-`oldr'	

				di "`dr'"
				
				if `dr'==1 & `sample'==1 {
					di as error "`dep1stlabel'"
					loc eqlabels `"`eqlabels' "`dep1stlabel'""'
				}	
				
				loc oldr = `r'
