* Advanced: 0 to overwrite the ado-file if it already exists and 1
*	otherwise. Default is 0.
local replace 1
* Advanced: 0 to install in the PLUS system directory and 1 to install in
*	the PERSONAL system directory. Default is 0.
local personal 0

local ado "`1'"	
local dir "`2'"

********************************UNDER THE HOOD**********************************
********************************DON'T BOTHER!***********************************

foreach loc in ado dir {
	loc temp : subinstr loc `loc' `"""' "", count(loc dq)
	if `dq' {
		di as err `"`loc' cannot contain ""'
		ex 198
	}
}

foreach loc in replace personal {
	cap conf integer n ``loc''
	loc err = _rc
	if !`err' loc err = !inlist(``loc'', 0, 1)
	if `err' {
		di as err "`loc' must be 0 or 1"
		ex 198
	}
}

conf f "`dir'/`ado'.ado"
if !regexm(substr("`ado'", 1, 1), "^[a-zA-z_]") {
	di as err "invalid command name"
	ex 198
}		
if !`personal' loc outdir `c(sysdir_plus)'`=substr("`ado'", 1, 1)'/
else loc outdir `c(sysdir_personal)'
mata:
	outdir = st_local("outdir")
	el = els = ""
	while (outdir != "") {
		pathsplit(outdir, outdir, el)
		els = `"""' + el + `"" "' + els
	}
	st_local("els", els)
end		
foreach el of loc els {
	cap mkdir "`prevels'`el'"
	loc prevels `prevels'`el'/
}
if !`replace' conf new f "`outdir'`ado'.ado"

foreach ext in ado sthlp hlp {
	cap copy "`dir'/`ado'.`ext'" "`outdir'`ado'.`ext'", ///
		`=cond(`replace', "replace", "")'
}
di "{txt}Installation of {cmd:`ado'} complete."
