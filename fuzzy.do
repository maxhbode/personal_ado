* Command Written by Francis Smart
cap program drop fuzzy
program define fuzzy

syntax varlist(min=2 max=2 string)     ///
       [, Gen_match(string) Free_letters(integer 0) ///
  Blanks Words_unordered Letters_unordered    ///
  Missed_letter_count(string) ///
  Reuse_letters Exclude(string) ///
  Case ]

local var1 = "`1'"
local var2 = subinstr("`2'",",","",.)

if "`gen_match'"=="" local gen_match = "matched"
if "`missed_letter_count'"=="" local missed_letter_count = "missed_count"
if "`free_letters'"=="" local free_letters = "0"

di _newline as text "Fuzzy matching (`var1' `var2')"
di as text "Generating match indicator variable (`gen_match')"
di as text "Number of free letters is (`free_letters')"

if "`words_unordered'"!="" {
  di as text "Word order does not matter (up to two words)"
  local blanks = "blanks"

}

if "`exclude'" != "" di "Characters `exclude' ignored"
if "`blanks'" != "" di as text "Blanks dropped"
if "`lunordered'" != "" di as text "Letter order does not matter when searching for match"
if "`reuse_letters'" != "" di as text "Letters may be resused when searching for matches"
if "`case'" != "" di "Case does not matter"
if (0 < `free_letters' | "`letters_unordered'" != "") di "Missed letter count variable created will be (`missed_letter_count')"

cap drop `gen_match'
 if _rc==0 noi di _newline "Matched indicator var: <`gen_match'> replaced"


gen `gen_match'=0 if `var1' != "" & `var2' != ""
  label var `gen_match' "Match indicator variable"

* Create a list of temporary variables
tempvar t_var1 t_var2 longest_word word_length

* Generate temporary variables for holding var1 and var2
qui gen `t_var1' = `var1' if length(`var1')>length(`var2')
qui gen `t_var2' = `var2' if length(`var1')>length(`var2')

* Whichever is the longest word will be the first variable
qui replace `t_var1' = `var2' if length(`var2')>length(`var1')
qui replace `t_var2' = `var1' if length(`var2')>length(`var1')

* di `longest_word_length'

if "`words_unordered'"=="" local loop_over_words = 1
if "`words_unordered'"!="" local loop_over_words = 2


* Generate a variable to indicate how many unmatched letters are in the variable comparison.
  if (0 < `free_letters' | "`letters_unordered'" != "") {
* Calculate how long the longest word is of the entire set of two strings being compared
    gen `word_length' = max(length(`t_var1'),length(`t_var2'))
    egen `longest_word' = max(`word_length')
    local longest_word_length = `longest_word'[1]
 
* Drop the variable if it already exists
    cap drop `missed_letter_count'
 if _rc==0 noi di "`missed_letter_count' replaced"

    * Create a variable to store the number of missed letters in the variable matchup.
    gen `missed_letter_count'=0
     label var `missed_letter_count' "Number of letters missed in matchup"
  }

    * Remove any blanks from the variables before trying a match.
  if "`blanks'" != "" {
    replace `t_var1' = subinstr(`t_var1', " " , "", .)
    replace `t_var2' = subinstr(`t_var2', " " , "", .)
  }

  if "`case'" != "" {
    replace `t_var1' = lower(`t_var1')
    replace `t_var2' = lower(`t_var2')
cap gen t_var2 = `t_var2'
 replace t_var2 = `t_var2'

  }

* This will loop either once or twice (once if word order matters, twice if not)
if  "`letters_unordered'" == "" qui forv i=1(1)`loop_over_words' {
  ************    Begin Word Match             ************

  * If words unordered is set then on the second loop reverse the word order.
  if `i'==2 replace `t_var2' =  word(`t_var2',2)+word(`t_var2',1)

  * Remove any excluded characters from the variables before trying a match
  * Loop through the list of user supplied excluded characters.
  foreach v in `exclude' {
    noi di "`v'"
    replace `t_var1' = subinstr(`t_var1', "`v'" , "", .)
    replace `t_var2' = subinstr(`t_var2', "`v'" , "", .)
  }
  cap gen t_var2 = `t_var2'

  replace `gen_match'=1 if `t_var1' ==`t_var2' & `gen_match'==0

  ************    End Word Match               ************

  * If there are free letters (# of letters that are allowed to be different)
 
  ************    Begin Ordered Letters Match  ************
  if "`letters_unordered'" == "" & 0 < real("`free_letters'") {

  * Start the missed letter count at 0
  replace `missed_letter_count' = 0 if `gen_match'==0

  * Loop through all of the lettered places for a number of loops equal to the longest word in either variable.
  forv v = 1(1)`longest_word_length' {
 
    * Add 1 to the missed letter count if the `v'th letter of both words does not match up
    replace `missed_letter_count' = `missed_letter_count'+1 ///
          if `gen_match'==0  & substr(`t_var1',`v',1) != substr(`t_var2',`v',1)
}
  replace `gen_match' = 1 if `missed_letter_count' <= `free_letters'
  }
  ************    End Ordered Letters Match    ************
}

  ************    Begin Unordered Letters Match  ************
  qui if "`letters_unordered'" != "" {
    replace `missed_letter_count' = 0 if `gen_match'==0
    forv v = 1(1)`longest_word_length' {
      gen tempvar_var2_`v' = substr(`t_var2',`v',1)
    }
   
    forv v = 1(1)`longest_word_length' {
     
    gen tempvar_match`v' = 0
    * This generates a variable that indicates if letter `v' in var1 is matched with a letter in var2

    gen tempvar_var1_`v' = substr(`t_var1',`v',1)
* This specifies letter `v' position of var1

    gen tempvar_match_place`v' = .
    * This specfies at what place (in terms of var2 letters) var1 letter `v' got matched with var2 letters

    forv vv = 1(1)`longest_word_length' {
      * This checks if any of the unused letters of var1 match var2
      replace tempvar_match`v' = 1 if tempvar_var2_`vv'==tempvar_var1_`v' & tempvar_match_place`v'==.
      replace tempvar_match_place`v' = `vv' if tempvar_var2_`vv'==tempvar_var1_`v' & tempvar_match_place`v'==.
       
      * If any of them match they are eleminated by replacing them with the value "ZZ" which cannot be equal to any of the individual letters of using_text.
      replace tempvar_var2_`vv'="ZZ" if tempvar_match`v' == 1 & "`reuse_letters'"=="" & tempvar_match_place`v'==`vv'
    }
     
    * Add a counter to mismatched letters if none of the letters in the using match with the current mismatch
replace `missed_letter_count' = `missed_letter_count'+1 if `gen_match'==0 & tempvar_match`v'==0
     
    * Drop tempvar of match and using
     
    }
cap drop tempvar*

  replace `gen_match' = 1 if `missed_letter_count' <= `free_letters'
  }
  ************    End Unordered Letters Match  ************


 tab `gen_match'
 cap confirm variable `missed_letter_count'
   if !_rc tab `missed_letter_count'

end
