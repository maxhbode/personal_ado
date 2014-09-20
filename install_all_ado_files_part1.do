* Author1: Matthew White, Innovations for Poverty Action, mwhite@poverty-action.org
* Author2: Max Bode, Harvard University, max_bode@hks.harvard.edu
* Purpose: Install a user-written ado-file.

qui {

*******************************MODIFY THESE!*******************************

* The directory that contains the ado-file
global ADO "`1'"
di "$ADO"

local dir "$ADO"

* The name of the ado command
local adofiles : dir "$ADO" files "*.ado", respectcase 
di `adofiles'
local adofiles: subinstr local adofiles ".ado" "", all
di `adofiles'

foreach ado in `adofiles' {
	run "$ADO/install_all_ado_files_part2.do" "`ado'" "`dir'"
}
}

foreach ado in `adofiles' {
	di "Installation of {cmd:`ado'} complete."
}
