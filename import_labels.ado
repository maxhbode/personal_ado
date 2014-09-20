capture program drop import_labels
program define import_labels
	//By: Jonathan Holmes
	//E-mail: jholmes.hks@gmail.com
	//Date: January 17, 2013
	//Version: 0.1
	
	version 11

	/*   ----  PROGRAM DESCRIPTION --- 
	
	import_labels allows users to store variable names and labels in a text file instead of embedded in code. 
	It currently supports tabbed delimited files layed out as follows: 
	
	OLD-VARNAME		NEW VARNAME		VARIABLE LABEL
					VALUE 1			VALUE LABEL 1
					VALUE 2			VALUE LABEL 2
					
	OLD VARNAME 2	NEW VARNAME	2	VARIABLE LABEL 2
					VALUE 1			VALUE LABEL 1
					VALUE 2			VALUE LABEL 2
					VALUE 3			VALUE LABEL 3
					
	The program also supports recoding missing variables. It supports only one mapping of numbers onto missing 
	values (eg: -999 = .a, -997 = .b, etc), but can support multiple value labels for the mapping. 
	
	WARNING: This function will automatically recode all variables with values which equal to the missing values. 
	*/
		
	syntax using/, [MISsingfile(string)]
	
	/* 	---- SYNTAX DESCRIPTION ---
		using: The file with the variable labels. 
		missingfile: file which includes the rule for recoding missing values. If blank,
			do not recode missing values. 
		
		STILL TO DO: 
		-preservelist: List of variables to not recode to missing.  
		
		
		Example syntax: *import_labels using "C:\Users\jholmes\Desktop\tmp/Book1.csv", ///
							mis("C:\Users\jholmes\Desktop\tmp/Missing_Values.csv")

	*/
	
	
	// CHECK FOR POSSIBLE ERRORS
	tempname mis_file lab_file 
	
	
	// TO ADD: Checks to make sure that silly mistakes are not made in coding
	// -Confirm that all files exist
	
		
	//LOAD MISSING VALUES FILE
	if "`missingfile'" != "" {
		file open `mis_file' using "`missingfile'", read
		file read `mis_file' line //FIRST LINE IS THE COLUMN LABELS, DROP THIS LINE
		file read `mis_file' line //SECOND LINE IS THE FIRST MISSING VALUE
		local n = 0
		
		while r(eof) == 0 {
			local ++n
			tokenize "`line'", parse(",")
			local mvinitial`n' `1'
			local mvfinal`n' `3'
			local mvmsg`n' `5'
						
			local mvdectxt "`mvdectxt'`mvinitial`n''=`mvfinal`n''"
			*local misvals `"`misvals'`mvfinal' "`mvmsg'" "'
			file read `mis_file' line
			if r(eof) == 0 & "`line'" != "" local mvdectxt "`mvdectxt'\ "
		}		
		file close `mis_file'
	}
	
	
	file open `lab_file' using "`using'", read
	file read `lab_file' line //FIRST LINE IS THE COLUMN LABELS, DROP THIS LINE
	file read `lab_file' line

	while r(eof) == 0 {
		tokenize `"`line'"', parse(",")
		
		if "`1'" != ","{
			//RENAME/LABEL VARIABLE IF ROW HAS VARIABLE INFORMATION
			//`1' is a variable name if `1' is not ","
			local originalvar `1'
			local newvar `3'
			local varlab `5'
			
			if "`originalvar'" != "`newvar'" rename `originalvar' `newvar'
			if "`varlab'" != "" label variable `newvar' "`varlab'"
			mvdecode `newvar', mv(`mvdectxt')
			local varlabtext ""
			
			forvalues x = 1/`n' {
				local varlabtext`"`varlabtext'`mvfinal`x'' "`mvmsg`x''""'
			}
				
		}
		else if "`2'" != "," {
			//APPEND VALUE LABELS IF ROW HAS VALUE LABEL INFORMATION
			//`1' is a comma if first column is blank. Then `2' is second column
			local valnum `2'
			local valtxt `4'
			
			forvalues x = 1/`n' {
				if `valnum' == `mvinitial`x'' {
					local valnum `mvfinal`x''
				}	
			}
			local varlabtext `"`varlabtext'`valnum' "`valtxt'""'
		}
		else{
			//DEFINE LABELS IF ROW IS BLANK
			//[If `1' and `2' are both commas if the entire row is blank]
			if substr("`:type `newvar''", 1, 3) != "str" {
				label define `newvar'lab `varlabtext'
				label values `newvar' `newvar'lab
			}
		}		
		file read `lab_file' line
	
	}		
	
	//DEFINE VALUE LABELS IF EOF
	if substr("`:type `newvar''", 1, 3) != "str" {
		label define `newvar'lab `varlabtext'
		label values `newvar' `newvar'lab
	}
	
	file close `lab_file'
	
end

