*! version 1.0.0 15dec2009 E. Leuven, B. Sianesi
*! adjusted by max bode

cap: program drop  pstest_tex
cap: program drop breduc_tex

program define pstest_tex
version 10.0
syntax varlist(min=1) [, extracaption(string) latex(string) Treated(varname) SUPport(varname) MWeight(varname) SUMmary QUIetly GRaph]

	
	capture confirm var _treated
	if _rc & "`treated'"=="" {
		di as error "Error: provide treatment indicator variable"
		exit 198
	}
	else if !_rc & "`treated'"=="" {
		tempvar treated
		qui g double `treated' = _treated
	}

	capture confirm var _weight
	if _rc & "`mweight'"=="" {
		di as error "Error: provide weight"
	}
	else if !_rc &  "`mweight'"=="" {
		local mweight _weight
	}
	
	if ("`support'"=="") {
		tempvar support
		capture confirm var _support
		if _rc {
			qui g byte `support' = 1
		}
		else qui g byte `support'= _support
	}

	capture confirm var _pscore
	if _rc & "`pscore'"=="" & "`hotel'"!="" {
		di as error "Error: provide propensity score"
		exit 198
	}
	else if !_rc & "`pscore'"=="" & "`hotel'"!=""  {
		tempvar pscore
		qui g double `pscore' = _pscore
	}

	breduc_tex `varlist' , extracaption(`extracaption') latex(`latex') mw(`mweight') tr(`treated') sup(`support') `summary' `quietly' `graph'
end

program define breduc_tex, rclass
syntax varlist(min=1) , extracaption(string) latex(string) MWeight(varname) TReated(varname) SUPport(varname) [summary quietly graph]

	tempvar sumbias sumbias0 _bias0 _biasm xvar
	
	qui g `_bias0' = .
	qui g `_biasm' = .
	qui g str12 `xvar' = ""
	qui g `sumbias' = .
	qui g `sumbias0' = .

	/* construct header */
	di as error `"`latex'.tex"'
	qui log using "`latex'.tex", replace t
	`quietly' di
	`quietly' di as text "\begin{ThreePartTable}"
	`quietly' di as text "\begin{longtable}{ll|ccccc|cc}"
	`quietly' di as text "\caption{PSM Balance`extracaption'} \\"
	`quietly' di as text "\toprule"  
	`quietly' di as text "& & \multicolumn{3}{c}{Weighted Mean} & & \%reduct  & \multicolumn{2}{c}{t-test}  \\"
	`quietly' di as text "Variable &    Sample & Treated	& Control & Difference  	& \%bias  	& |bias| 	&    t   &  p>|t| \\"
	`quietly' di as text "\midrule \midrule"
	
	qui log off
	
	/* calculate stats for varlist */
	tempname N1u N0u N1m N0m N0m_noweight m1u m0u v1u v0u m1m m0m bias biasm absreduc tbef taft pbef paft r2bef r2aft chibef chiaft pchibef pchiaft
	local i 0
	foreach v of varlist `varlist' {
		local i = `i' + 1
		qui sum `v' if `treated'==1
		scalar `N1u'  = r(N)
		scalar `m1u' = r(mean)
		scalar `v1u' = r(Var)

		qui sum `v' if `treated'==0
		scalar `N0u' = r(N)
		scalar `m0u' = r(mean)
		scalar `v0u' = r(Var)

		qui sum `v' if `treated'==1 & `support'==1
		scalar `N1m'  = r(N)
		scalar `m1m' = r(mean)

		qui sum `v' [iw=`mweight'] if `treated'==0 & `support'==1
		scalar `N0m'  = r(N)
		scalar `m0m' = r(mean) 
	
	
		ta `mweight', mi
		tempvar unweight
		g `unweight' =  0 
		replace `unweight' = 1 if `mweight'!=.
		qui sum `v' [iw=`unweight'] if `treated'==0 & `support'==1
		scalar `N0m_noweight'  = r(N)

		qui replace `xvar' = "`v'" in `i'
		
		/* standardised % bias before matching */
		scalar `bias' = 100*(`m1u' - `m0u')/sqrt((`v1u' + `v0u')/2)
		qui replace `_bias0' = `bias' in `i'
		qui replace `sumbias0' = abs(`bias') in `i'
		/* standardised % bias after matching */
		scalar `biasm' = 100*(`m1m' - `m0m')/sqrt((`v1u' + `v0u')/2)
		qui replace `_biasm' = `biasm' in `i'
		qui replace `sumbias' = abs(`biasm') in `i'
		/* % reduction in absolute bias */
		scalar `absreduc' = -100*(abs(`biasm') - abs(`bias'))/abs(`bias')

		/* t-tests before matching */
		qui regress `v' `treated' 
		scalar `tbef' = _b[`treated']/_se[`treated']
		scalar `pbef' = 2*ttail(e(df_r),abs(`tbef'))
		/* t-tests after matching */
		qui regress `v' `treated' [iw=`mweight'] if `support'==1
		scalar `taft' = _b[`treated']/_se[`treated']
		scalar `paft' = 2*ttail(e(df_r),abs(`taft'))
		
		loc vl = `"`: var label `v''"' 
		loc diff1 = `m1u' - `m0u'
		loc diff2 = `m1m' - `m0m'
		
		qui log on
if `i'==1 {
`quietly' di as text as result %7.0g "Observations & Unmatched &" `N1u' " & " as result %7.0g `N0u' "& & & &  & \\"
`quietly' di as text as result %7.0g " & Matched &" `N1m' " & " as result %7.0g `N0m' "(" `N0m_noweight' ")" "& & & &  & \\"
`quietly' di as text "\midrule"
}
		qui log off

		qui log on
		`quietly' di as text %12s "`vl'" " &  Unmatched & " as result %7.0g `m1u' " & " %7.0g `m0u' " & " %7.0g `diff1' " & " %7.1f `bias'   _s(8)         " & "  as text " & "  as res %7.2f `tbef'  _s(2) " & " as res	 %05.3f `pbef' " \\ "
		`quietly' di as text              _col(13) " &    Matched & " as result %7.0g `m1m' " & " %7.0g `m0m' " & " %7.0g `diff2' " & " %7.1f `biasm' " & " %8.1f `absreduc'  as text " & " as result %7.2f `taft'  _s(2) " & " as res  %05.3f `paft' " \\ "
		`quietly' di as text              _col(13) " & & & & & & &  & \\"
		qui log off
	}
	qui log on
	`quietly' di as text "\bottomrule"
	`quietly' di as text "\end{longtable}"
	`quietly' di as text "\end{ThreePartTable}""
	qui log close


	if "`summary'"!="" {
		di as text "{hline 61}"
		di as text _col(10) "Summary of the distribution of the abs(bias)"
		di as text "{hline 61}"
		label var `sumbias0' "BEFORE MATCHING"
		sum `sumbias0', detail
		return scalar meanbiasbef = r(mean)
		return scalar medbiasbef  = r(p50)		
		di as text "{hline 61}"
		label var `sumbias' "AFTER MATCHING"
		sum `sumbias', detail
		return scalar meanbiasaft = r(mean)
		return scalar medbiasaft  = r(p50)		
		di as text "{hline 61}"

		qui probit `treated' `varlist'
		scalar `r2bef' = e(r2_p)
		scalar `chibef' = e(chi2)
		scalar `pchibef' = chi2tail(e(df_m), e(chi2))
		return scalar r2bef = e(r2_p)
		return scalar chiprobbef = chi2tail(e(df_m), e(chi2))

		qui probit `treated' `varlist' [iw=`mweight'] if `support'==1
		scalar `r2aft' = e(r2_p)
		scalar `chiaft' = e(chi2)
		scalar `pchiaft' = chi2tail(e(df_m), e(chi2))
		return scalar r2aft = e(r2_p)
		return scalar chiprobaft = chi2tail(e(df_m), e(chi2)) 

		di
		di as text "{hline 12}{c TT}{hline 49}"
		di as text "     Sample {c |}    Pseudo R2      LR chi2        p>chi2"
		di as text "{hline 12}{c +}{hline 49}"
		di as text "  Unmatched {c |}"  _s(4) as res %9.3f `r2bef' _s(4) as res %9.2f `chibef' _s(5) as res %9.3f `pchibef'
		di as text "    Matched {c |}"  _s(4) as res %9.3f `r2aft' _s(4) as res %9.2f `chiaft' _s(5) as res %9.3f `pchiaft'
		di as text "{hline 62}"
	}
	
	*drop if `_bias0'==.

	levelsof `xvar', loc(xvarlevels)
	foreach level in `xvarlevels' {
		loc label `"`: var label `level''"'
		loc label : subinstr loc label "\" "", all
		replace `xvar'="`label'" if `xvar'=="`level'"
	}
	

	if "`graph'"!="" {
		#delimit ;
		graph dot `_bias0' `_biasm',
			over(`xvar', sort(1) descending) 
			legend(label(1 "Unmatched") label(2 "Matched")) 
			yline(0, lcolor(gs10)) 
			marker(1, mcolor(black) msymbol(O)) 
			marker(2, mcolor(black)  msymbol(X))
		;
		#delimit cr
	}
	
end
