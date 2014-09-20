* ----------- for testing
clear all
set trace off
*! a good example of this is in reg_cs_06_varselection

* Test macros
global DESKTOP "C:/Users/mbode/Desktop"
loc test "This one"
loc aaa "bloed"
local another "one"
global OLD "kaka"
#delimit ;
loc test "a00_address2 a07_visit1_sprv1 a07_visit3_sprv1 a00_address3 a07_visit1_sprv2
                a07_visit3_sprv2 a00_address4 a07_visit1_stat_oth a07_visit3_stat_oth a00_feedback
                a07_visit2_fw a10_prev_add_1 a04_address1_1 a07_visit2_sprv1 a10_prev_add_2
                a04_address1_2 a07_visit2_sprv2 a10_prev_add_3 a04_address1_3 a07_visit2_stat_oth
                a10_prev_add_4 a07_visit1_fw a07_visit3_fw b04_name_mem" ;
loc test2 "a00_address2 a07_visit1_sprv1 a07_visit3_sprv1 a00_address3 a07_visit1_sprv2
                a07_visit3_sprv2 a00_address4 a07_visit1_stat_oth a07_visit3_stat_oth a00_feedback
                a07_visit2_fw a10_prev_add_1 a04_address1_1 a07_visit2_sprv1 a10_prev_add_2
                a04_address1_2 a07_visit2_sprv2 a10_prev_add_3 a04_address1_3 a07_visit2_stat_oth
                a10_prev_add_4 a07_visit1_fw a07_visit3_fw b04_name_mem" ;				
#delimit cr

* Get macro list into tempfile
cap: log close
qui log using tempfile.txt, text replace
macro list 
qui log close

file open logfile using tempfile.txt, read
	
file read logfile line

while r(eof)==0 {
	local localname : piece 1 2 of `"`line'"', nobreak 
	
	if strpos(`"`localname'"',"_")==1 {
		local localname		: subinstr local localname "_" ""
		local localname		: subinstr local localname ":" ""	
		di `"`localname'"'
		
		loc localnamelist `localnamelist' `localname'
	}
	
	file read logfile line
}

di `"locals: `localnamelist'"'

  
file close _all


file open temp_mylocals using "$DESKTOP/temp_mylocals.do", text replace write	

foreach local in `localnamelist' {
	file write temp_mylocals `"local `local' - ``local''"' _n
}

file close _all

file open temp_mylocals using "$DESKTOP/temp_mylocals.do", text read
file open mylocals using "$DESKTOP/mylocals.do", text write replace
file read temp_mylocals line
while r(eof)==0 {
	local line_new : subinstr loc line "  " " ", all
	local line_new : subinstr loc line "	" " ", all
	file write mylocals `"`line_new'"' _n
	file read temp_mylocals line
}

file close _all

erase tempfile.txt
erase "$DESKTOP/temp_mylocals.do"


