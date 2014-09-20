

cap: program drop uniquelocal

program  uniquelocal 
	syntax varlist
	

	foreach X in `varlist' {
		levelsof `X', loc(`X'_levels)
		loc allvalues = "``X'_levels'" "`allvalues'"
	}
	stop
	loc count : word count loc `allvalues'
	loc N_before "`count'"
	nois di "`N_before'"
	
	loc allvalues2 : copy loc allvalues
	forval i = 1/`count' {
		gettoken var allvalues2 : allvalues2
		if strpos(`"`allvalues2'"',`"`var'"')>1 loc remove `remove' `var'
	}
	loc allvalues : list allvalues - remove
	loc count : word count loc `allvalues'
	loc N_after "`count'"

	loc N_removed = `N_before'-`N_after'

	di as result "Removed `N_removed'/`N_before' values from local"

end 
