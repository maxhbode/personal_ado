
cap: program drop master_describe_tool
program master_describe_tool, rclass

	qui describe, s
	c_local N`1' = `r(N)'
	c_local k`1' = `r(k)'
	c_local doname`1' = "`2'"

end
