

set more off
sysuse census, clear
regress death medage i.region [aw=pop]

/*
set obs 200
g A = _n
g B = _n + 200
g C = _n - 200
g AA = _n - 200
g BB = _n + 33
g CC = 66 - _n

la var A "LaLaLa"
la var B "AAA"
la var C "LLL"

foreach Y in `dependent' {
	if "`Y'" == "A" 		local i = 55
	else if "`Y'" == "B" 	local i = 62
	else if "`Y'" == "C" 	local i = 69

	
	di "`dep_varlabel'"
	
	}

local A "A B C"
local AA "AA BB CC"
*/
ren death A
ren marriage B
ren divorce C

ren pop65p AA
ren popurban BB
ren medage CC

drop state state2 region pop poplt5 pop5_17 pop18p

local dep "A B C"
local ind "AA BB CC"


quietly reg A AA
quietly outreg2 using "C:\Users\mbode\Desktop/texreg/prefix_A", tex(frag)
erase "C:\Users\mbode\Desktop/texreg/prefix_A.txt"


texreg, filename(C:/Users/mbode/Desktop/texreg/filename) prefix(prefix)  ///
	dep(death) ind(medage)  replace ///
	maketitle listoftables author(Max C Bode) title(First Stage)
