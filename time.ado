// Author: Johannes F. Schmieder
// Version: June 2007
// Department of Economics, Columbia University
// Comments and suggestions welcome: jfs2106 {at} columbia.edu

capture program drop time
program define time
	if "$timercount"=="" {
		global timercount 1
		timer clear
	}
	else global timercount = $timercount+1
	timer on $timercount
	`0'
	timer off $timercount
end

