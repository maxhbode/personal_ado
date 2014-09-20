
 
set more off
set linesize 100

global REG_TEST "$OUTPUT/reg_test"
* "$REG_TEST/test1" 

*** ivreg2 results stacked togehter
sysuse auto, clear



ivreg2 price headroom trunk (mpg=rep78 foreign), savefirst first
est store _ivreg2_price
ivreg2out _ivreg2_mpg _ivreg2_price

outreg2 using myfile, replace long nor2 adds("r2 first", e(r2_1), "r2 second", e(r2_2))

stop
*** ivreg2 results not-so stacked togehter
sysuse auto, clear
ivreg2 price headroom trunk (mpg=rep78 foreign), savefirst first
est store _ivreg2_price
ivreg2out _ivreg2_mpg _ivreg2_price
outreg2 using myfile, replace nor2 adds(r2, e(r2_1)) eqkeep(mpg)
outreg2 using myfile, nor2 adds(r2, e(r2_2)) eqkeep(price)

 


*** these are for the future reference (non-stacked)
 
* from stored estimates
sysuse auto, clear
ivreg2 price headroom trunk (mpg=rep78 foreign), savefirst first
est store _ivreg2_price
outreg2 [*] using myfile, replace see
 
 

* cleaner column titles, can be used with ctitie( ) if so desired
sysuse auto, clear
ivreg2 price headroom trunk (mpg=rep78 foreign), savefirst first
est store _ivreg2_price
est restore _ivreg2_mpg
outreg2 using myfile, replace
est restore _ivreg2_price
outreg2 using myfile, see
 stop
* by hand
sysuse auto, clear
reg mpg headroom trunk rep78 foreign
gen esample=e(sample)
outreg2 using myfile, replace
ivreg2 price headroom trunk (mpg=rep78 foreign) if esample, savefirst first
est store _ivreg2_price
outreg2 using myfile, see

