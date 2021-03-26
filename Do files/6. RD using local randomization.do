
											*REGRESSION DISCONTINUITY UNDER LOCAL RANDOMIZATION*
	*________________________________________________________________________________________________________________________________*

	*global final "C:\Users\wb495845\Downloads"

	**
	**
	*Selecting the window around the cutoffxa
	**
	*________________________________________________________________________________________________________________________________*
	
		**The command rdwinselect helps us to find a window near the cutoff in which we can assume that the treatment assignment
		**may be regarded as a known randomization mechanism near the cutoff. 
		**For the procedure to be useful, the distribution of the covariates for control and treatment units should be unaffected
		**by the treatment within Wo (selected window) but should be affected by the treatment outside the window. 
	*--------------------------------------------------------------------------------------------------------------------------------*
	use "$final/Child Labor Data.dta" if urban == 1 & male == 1 & year == 1999, clear
			
		**Testing two specifications. 
		rdwinselect zw $covariates1, obsmin(200) 		  seed(2198)						// obsmin() is the minimum number of observations below and above the cutoff. 
			**Selected windon -13, +12
			
		rdwinselect zw $covariates1, obsmin(200) wstep(2) seed(2948)						// wstep()  is the window increase in each step
			**Selected windon -10, +10												

			
	**		
	**
	*Estimate of ATE on short and long term outcomes
	**
	*________________________________________________________________________________________________________________________________*

	matrix results = (0,0,0,0,0,0) //store year, short-term variable, long-term variable, observed statistic, lower bound and upper bound. 
	
	use "$final/Child Labor Data.dta" if urban == 1 & male == 1, clear
	
	
		**
		*Short term outcomes
		**
	
			foreach year in 1998 1999 2001 2002 2003 2004 2005 2006  {
				preserve
					keep if year == `year' 
					
						if `year' < 2002 {
						rdwinselect zw $covariates1, obsmin(200) seed(2198)
						local wr = r(w_right)
						local wl = r(w_left)
						}
						
						if `year' > 2001  {
						rdwinselect zw $covariates2, obsmin(200) seed(2198)
						local wr = r(w_right)
						local wl = r(w_left)
						}	
							
						local variable = 1
						foreach var of varlist $shortterm_outcomes  {
							rdrandinf `var' zw, wl(`wl') wr(`wr') interfci(0.05) seed(94757)	
							matrix results = results \ (`year', `variable', 0, r(obs_stat), r(int_lb), r(int_ub))
							local variable = `variable' + 1
						}
				restore
			}
			
		**
		*Long term outcomes
		**
			foreach year in 2007 2008 2009 2011 2012 2013 2014      {
				preserve
					keep if year == `year'
						
						rdwinselect zw $covariates2, obsmin(200) seed(2198)
						local wr = r(w_right)
						local wl = r(w_left)

						local variable = 1
						foreach var of varlist $longterm_outcomes   {
							rdrandinf `var' zw,  wl(`wl') wr(`wr') interfci(0.05) seed(493734)	
							matrix results = results \ (`year', 0, `variable', r(obs_stat), r(int_lb), r(int_ub))
							local variable = `variable' + 1
						}
						
				restore		
			}
				
		**
		*Results
		**

			clear
			svmat results
					
			drop  in 1
			rename (results1-results6) (year shortterm_outcomes longterm_outcomes ATE lower upper)	
					
			label define shortterm_outcomes  1 "Paid work" 					2 "Formal paid work" 				3 "Informal paid work" 	4  "Unpaid work"    5 "School attendance" 				6  "Paid work and studying" ///
											 7 "Unpaid work and studying" 	8 "Only paid work" 					9 "Only unpaid work" 	10 "Only studying" 11 "Neither working or studying"		12 "Log-earnings" 

			label define longterm_outcomes   1 "Years of schooling" 		2 "At least High School degree" 	3 "College degree" 		///
											 4 "Employed" 					5 "Formal occupation" 				6 "Log-earnings" 
												
			label val shortterm_outcomes shortterm_outcomes
			label val longterm_outcomes  longterm_outcomes
			
			foreach var of varlist ATE lower upper {
			replace `var' = . if year < 2001 & shortterm_outcomes == 12
			}

			label var ATE    "ATE"
			label var lower  "Lower bound"
			label var upper  "Upper bound"
			format ATE lower upper %4.3fc

			gen	 	year_n1 = 0
			local 	ordem = 1
			foreach year in 1998 1999 2001 2002 2003 2004 2005 2006 {
				replace year_n1 = `ordem' if year == `year'
			local  ordem = `ordem' + 1 
			}
			gen 	year_n2 = 0
			local 	ordem = 1
			foreach year in 2007 2008 2009 2011 2012 2013 2014      {
				replace year_n2 = `ordem' if year == `year'
				local  ordem = `ordem' + 1 
			}
			save "$final/Regression Results using RD under local randomization.dta", replace
		
		**
		*Charts
		**
			
			use   "$final/Regression Results using RD under local randomization.dta" if shortterm_outcomes != 0, clear
			local figure = 1
			forvalues shortterm_outcomes = 1(1)12 {
				preserve
					keep if shortterm_outcomes == `shortterm_outcomes'
					
					su lower, detail
					local min = r(min) + r(min)/3
					su upper, detail
					local max = r(max) + r(max)/3
					
					twoway   scatter ATE year_n1,  color(cranberry) || rcap lower upper year_n1, lcolor(navy)																	///
					yline(0, lw(1) lp(shortdash) lcolor(cranberry))				 																								///
					xlabel(1 `" "1998" "' 2 `" "1999" "' 3 `" "2001" "' 4 `" "2002" "' 5 `" "2003" "' 6 `" "2004" "' 7 `" "2005" "' 8 `" "2006" "' , labsize(small) ) 			///
					xtitle("", size(medsmall)) 											  																						///
					yscale(r(`min' `max'))	 																																	///
					ytitle("ATE", size(small))					 																												///					
					title(`: label shortterm_outcomes `shortterm_outcomes'')																									///
					legend(off)  																																				///
					note("Source: PNAD.", color(black) fcolor(background) pos(7) size(small)) saving(short`figure'.gph, replace)
					local figure = `figure' + 1
				restore
			}
		
			use   "$final/Regression Results using RD under local randomization.dta" if longterm_outcomes != 0, clear
			local figure = 1
			forvalues longterm_outcomes = 1(1)6 {
				preserve
					keep if longterm_outcomes == `longterm_outcomes'
					
					su lower, detail
					local min = r(min) + r(min)/3
					su upper, detail
					local max = r(max) + r(max)/3

					twoway   scatter ATE year_n2,  color(cranberry) || rcap lower upper year_n2, lcolor(navy)																	///
					yline(0, lw(1) lp(shortdash) lcolor(cranberry))				 																								///
					xlabel(1 `" "2007" "' 2 `" "2008" "' 3 `" "2009" "' 4 `" "2011" "' 5 `" "2012" "' 6 `" "2013" "' 7 `" "2014" "' , labsize(small) ) 							///
					xtitle("", size(medsmall)) 											  																						///
					yscale(r(`min' `max')) 																																		///
					ytitle("ATE", size(small))					 																												///					
					title(`: label longterm_outcomes `longterm_outcomes'')																										///
					legend(off)  																																				///
					note("Source: PNAD.", color(black) fcolor(background) pos(7) size(small)) saving(long`figure'.gph, replace)
					local figure = `figure' + 1
				restore
			}
			
			graph combine short1.gph short2.gph short3.gph short4.gph short5.gph short6.gph short7.gph short8.gph short9.gph short10.gph short11.gph short12.gph, graphregion(fcolor(white)) ysize(5) xsize(10) title(, fcolor(white) size(medium) color(cranberry))
			graph export "$figures/Short-term outcomes.pdf", as(pdf) replace
			forvalues figure = 1(1)12 {
			erase short`figure'.gph
			}	
			graph combine long1.gph long2.gph long3.gph long4.gph long5.gph	long6.gph																			, graphregion(fcolor(white)) ysize(5) xsize(10) title(, fcolor(white) size(medium) color(cranberry))
			graph export "$figures/Long-term outcomes.pdf", as(pdf) replace
			forvalues figure = 1(1)6  {
			erase long`figure'.gph
			}	
	/*
	**
	**	
	*Robustness check 
	**
	*________________________________________________________________________________________________________________________________*
	
		use "$final/Child Labor Data.dta" if urban == 1 & male == 1, clear

		preserve
		
		keep if year == 1999
		
			**
			*Paid work
			**
			rdrandinf pwork 		zw, c(0) wl(-13) wr(12) interfci(0.05) seed(1029)

			rdsensitivity  	pwork 		zw, wlist(10(1)18) tlist(-0.17(0.01)0.03) verbose nodots saving("$inter/Robustness_pwork") 			seed(2048)

			**
			*School attendance
			**
			rdrandinf schoolatt 	zw, c(0) wl(-13) wr(12) interfci(0.05) seed(93757)
			
			rdsensitivity  	schoolatt   zw, wlist(10(1)18) tlist(-0.07(0.01)0.13) verbose nodots saving("$inter/Robustness_schoolatt") 		seed(29273)
		
		restore
		
		keep if year == 2003
		
			**
			*Formal paid work
			**
			rdrandinf pwork_formal 	zw, c(0) wl(-13) wr(12) interfci(0.05) seed(34958)

			rdsensitivity  	pwork 		zw, wlist(10(1)18) tlist(-0.15(0.01)0.05) verbose nodots saving("$inter/Robustness_pwork_formal") 	seed(93875)

			
			**
			*Charts
			**
			use "$inter/Robustness_pwork", clear
			twoway contour pvalue t w, ccuts(0(0.05)1) xlabel(10(1)18,labsize(small)) ylabel(-0.17(0.01)0.03, labsize(small) nogrid) ///
			xtitle("Weeks around the cutoff") ///
			ytitle("ATE under the null hyphothesis") ///
			title("{bf:Paid work, 1999}")
			graph export "$figures/Robustness_pwork.pdf", replace
		
			use "$inter/Robustness_schoolatt", clear
			twoway contour pvalue t w, ccuts(0(0.05)1) xlabel(10(1)18,labsize(small)) ylabel(-0.07(0.01)0.13, labsize(small) nogrid) ///
			xtitle("Weeks around the cutoff") ///
			ytitle("ATE under the null hyphothesis") ///
			title("{bf:School attendance, 1999}")
			graph export "$figures/Robustness_schoolatt.pdf", replace
			
			use "$inter/Robustness_pwork_formal", clear
			twoway contour pvalue t w, ccuts(0(0.05)1) xlabel(10(1)18,labsize(small)) ylabel(-0.15(0.01)0.05, labsize(small) nogrid) ///
			xtitle("Weeks around the cutoff") ///
			ytitle("ATE under the null hyphothesis") ///
			title("{bf:Formal paid work, 2003}")
			graph export "$figures/Robustness_pwork_formal.pdf", replace
