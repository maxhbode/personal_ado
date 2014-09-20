/*
cap: program drop dround
program define dround
	syntax , name(string)
	
	*Parse suboptions
	local name : subinstr local name "]" "", all
	tokenize `"`name'"', parse(" ")
	di `"`name'"'
	local count : word count `name'
	di "`count'"
	
	forval i = 1/`count' {
		loc var`i' = "``i''"
		local var`i' : subinstr local var`i' "[" " "
		di "var`i' - `var`i''"
	}
	
	
	forval i = 1/`count' {
		tokenize `"`var`i''"', parse(" ") 
		loc var`i' = "`1'"
		loc round`i' = `2'
			di "var`i' = `var`i''"
			di "round`i' = `round`i''"
	}
	
	forval i = 1/`count' {
		replace `var`i'' = round(`var`i'',`round`i'')
	}
end


sysuse auto, clear
dround , name(gear_ratio[.1] price[10])
*/
