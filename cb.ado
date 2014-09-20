*! version 1.0.0 MCHBode 17apr2013

* Description: This is a simple wrapper for -findname-
* I am tried of typing this long command name + specify the -v(30)- option

cap: program drop cb
program define cb

syntax varlist

	set linesize 77
	codebook `varlist', t(1000) 


end
