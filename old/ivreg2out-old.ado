*! ivreg2out 0.9 roywada@hotmail.com
* Updated by Max Bode, 1 Nov 2012

prog define ivreg2out, eclass
version 8.0
qui {
args one two
local name1=subinstr("`one'","_ivreg2_","",1)
local name2=subinstr("`two'","_ivreg2_","",1)
est restore `one'
mat b1=e(b)
mat V1=e(V)
matrix coleq b1 = `name1'
matrix coleq V1 = `name1'
local r2_first=e(r2)
	local F2_first=e(F)
est restore `two'
mat b2=e(b)
mat V2=e(V)
matrix coleq b2 = `name2'
matrix coleq V2 = `name2'
mat b=b1,b2
mat v1=vecdiag(V1)
mat v2=vecdiag(V2)
mat v=v1,v2
mat V=diag(v)
local r2_second=e(r2)
	local F2_second=e(F)
local N=e(N)
eret post b V
eret scalar N=`N'
eret scalar r2_1=`r2_first'
eret scalar r2_2=`r2_second'
	eret scalar F2_1=`F2_first'
	eret scalar F2_2=`F2_second'
*eret loc eqnames= "`name1' `name2'"
	eret loc eqnames= "1st 2nd"
eret loc depvar= "`name1' `name2'"
}
end
