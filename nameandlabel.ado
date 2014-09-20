clear all

preserve
	u "C:\Users\mbode\Desktop\masterlist_namelabel.dta", clear
	replace varlabel="NO LABEL" if varlabel==""
	foreach X in varname varlabel varname_org
	levelsof `X', loc(`X')
restore
