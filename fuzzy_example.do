
clear

set obs 1000

/*
syntax varlist(min=2 max=2 string)     ///
       [, Gen_match(string) Free_letters(integer 0) ///
  Blanks Words_unordered Letters_unordered    ///
  Missed_letter_count(string) ///
  Reuse_letters Exclude(string) ///
  Case ]
*/
* Without specifying
gen v0= "John Smith"
gen v1="Smith John"

* This simply creates a variable match=1 if v1=v2
fuzzy v0 v1



* This creates a variable match=1 if v1=v2 with or without word order swtiched.
fuzzy v0 v1, w

ta matched
stop

gen v2="Smith        John"

* This creates a variable match=1 if v1=v2 with or without word order swtiched.
fuzzy v1 v2, b

* Note, that turning on off word order tells fuzzy that blanks don't matter.

gen v3="Smi.th   ///     J.,.o,h...n ZZZZZZ"

* Make sure to seperate characters to exclude with spaces.
fuzzy v1 v3, b e(. , / Z)

gen obsid = _n

gen v4= v0 + string(obsid)

* This code will tell fuzzy match to check if the strings are similar with up to two letters wild
fuzzy v0 v4, f(2) b

fuzzy v0 v4, f(3) b

* L tells stata to ignore letter order when searching for a match
gen v5="Jist mhohn"
fuzzy v0 v5, f(0) l b

* This failed because Stata is case sensitive and the s in Jist does not match the S in Smith.
* But you can turn off case sensitivity with case (c)
fuzzy v0 v5, f(0) l b c

* Finally we might want to allow letters to be resused when attempting matching
gen v6="John Smith John"

fuzzy v0 v6 , f(1) r l 
