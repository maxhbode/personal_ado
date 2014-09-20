*! savelocals

*------------- save locals ------------------

cap: program drop savelocals
program savelocals, rclass

	version 12
	syntax using

	loc iso : subinstr loc using "using " ""
	cap: erase `iso'
	
	file open logfile using tempfile.txt, read
	file open mylocals `using', replace write
	file read logfile line

	while r(eof)==0 {
		local localname : piece 1 2 of "`line'", nobreak 
		loc ++i
		di "`i' - `localname'"
		}
		stop
		if strpos(`"`localname'"',"_")==1 {
		
			nois di as result `"`localname'"'
			nois di as error `"`line'"'
		
			local localvalue 	: subinstr local line "`localname'" ""
			local localname		: subinstr local localname "_" ""
			local localname		: subinstr local localname ":" ""
			
					* next line should have embedded quotes for last token
			if "`localname'"!="using" {
				loc lnamelist `lnamelist' `localname'
				*file write mylocals `"local `lname' `lval'"' _n
			}
		}
		file read logfile line
	}
	
	return local lnamelist "`lnamelist'"
	
	file close logfile
	file close mylocals

	* Erase tempfile
	erase tempfile.txt

end

*----------- done --------------------------

