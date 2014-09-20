capture program drop maskvars
program define maskvars
	//By: Jonathan Holmes
	//E-mail: jholmes.hks@gmail.com
	//Date: January 30, 2013
	//Version 0.1

	version 11
	
	/*   ----  PROGRAM DESCRIPTION --- 
	maskvars deletes PII without losing any information about missing values. 
	If a variable in the varlist is a numeric variable, it recodes all non-missing values to "MASKED PII"
	*/
	
	/*   ---  VERSION HISTORY ---
		Version 0.1		01/30/2013
			--> Created basic functionality
	
	
	*/
	
	
	syntax varlist, [MISsingvals(string asis) PIILAB(string) LABREPLACE] 
	
	/* 	---- SYNTAX DESCRIPTION ---
		varlist: The list of variables to be recoded (may be string or numeric)
		missingvals: A list of `tokens' of missing values to be recoded. 
			SYNTAX: missingvals(`"Number1 Code1 "Text1""' `"Number2 Code2 "Text2""'
				-Number1: The value entered in during data entry
				-Code1: The missing value code (after recode)
				-Text1: The Descriptive text or value label for the code (eg: "Missing")
				NOTE: If variables have already been recoded, then simply put a value for 
					number1, number2, etc. which does not exist in the data. 
		piilab: The label name for the numeric PII variables (default "PIILAB")
		labreplace: If set, the label "piilab" will be replaced if it exists with no prompts for the user. 
		
		Example syntax: 
			maskvars name ssn, missingvals(`"-999 .a "Not Applicable""' `"-998 .b "Missing""') labreplace
	*/
	
	//Default label for piilab is just "PIILAB"
	if "`piilab'" == "" {
		local piilab "PIILAB"
	}
	
	//Check too see if pii label already exists
	cap label list `piilab'
	if _rc == 0 {
		if "`labreplace'" != "" {
			label drop `piilab'
		}
		else{
			di as error "Label `piilab' already exists. Please specifiy different label name or LABREPLACE."
			exit 42
		}
	}
	//Define label
	label define `piilab' .m "MASKED PII"
	
	//Parse missing values command	
	local n = 1
	while `"`missingvals'"' != "" {
		//PARSE MISSING VALUES COMMAND
		gettoken mis`n' missingvals: missingvals
		gettoken misnum`n'  mis`n': mis`n'
		gettoken miscode`n' mis`n': mis`n'
		gettoken mistxt`n'  mis`n': mis`n'
		
		//CHECK TO BE SURE MISSING VALUES DO NOT CONFLICT WITH MASKED MISSING VALUE
		if "`miscode`n''" == ".m"{
			di as error "Missing value .m is reserved for masked PII. Please chose a different missing value code."
			exit 42
		}
		
		//CREATE MISSING VALUES DECODE COMMAND
		local mvdectxt "`mvdectxt'`misnum`n''=`miscode`n''"
		if `"`missingvals'"' != "" {
			local mvdectxt "`mvdectxt'\ "
		}
				
		//ADD PII INFORMATION TO VARIABLE LABEL
		label define `piilab' `miscode`n'' "`mistxt`n''", add
		
		local ++n
	}
	
	//MASK NUMERIC VARIABLES
	ds `varlist', has(type numeric)
	foreach var in `r(varlist)' {
		if `n' > 1 mvdecode `var', mv(`mvdectxt')
		replace `var' = .m if !missing(`var')
		label values `var' `piilab'
	}
	
	//MASK STRING VARIABLES
	ds `varlist', has(type string)
	foreach var in `r(varlist)' {
		forvalues x = 1/`=`n'-1'{
			replace `var' = "`mistxt`x''" if `var' == "`misnum`x''"
			local missingcodes `"`missingcodes', "`mistxt`x''""'
		}
		
		replace `var' = "MASKED PII" if !inlist(`var', "" `missingcodes')
	}
end
