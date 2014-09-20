*! version 1.0.0 MCHBode 17apr2013

* Description: This is a simple wrapper for -findname-\
* The -v(30)- option is a default
* Findname options other than -type- and -local- have to go into the -Options- option
* The -remove- option allows you to remove a certain group of variables from findname

cap: program drop fn
program define fn

syntax varlist, [Options(string) remove(string) type(string) LOCal(string)]

	if "`local'"=="" { 
		loc localoption 
	}
	else if "`local'"!="" {
		loc localoption local(temp_local)
	}	

	if "`type'"=="" { 
		loc typeoption 
	}
	else if "`type'"!="" {
		loc typeoption type(`type')
	}	

	if "`remove'"=="" {
		findname `varlist', v(30) `typeoption' `localoption' `options' 
	}
	else if "`remove'"!="" {
		qui findname `varlist', loc(vars) `typeoption'
		qui findname `remove', loc(removevars) `typeoption'
		loc vars : list vars - removevars
		findname `vars', `localoption' `options' v(30)
	}

	if "`local'"!="" {
		c_local `local' `temp_local'
	}
	
end
