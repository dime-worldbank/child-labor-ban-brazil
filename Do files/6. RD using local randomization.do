
											*REGRESSION DISCONTINUITY UNDER LOCAL RANDOMIZATION*
	*________________________________________________________________________________________________________________________________*


	
	*Selecting the window around the cutoff
	*--------------------------------------------------------------------------------------------------------------------------------*
		**The command rdwinselect helps us to find a window near the cutoff in which we can assume that the treatment assignment
		**may be regarded as a known randomization mechanism near the cutoff. 
		**For the procedure to be useful, the distribution of the covariates for control and treatment units should be unaffected
		**by the treatment within Wo (selected window) but should be affected by the treatment outside the window. 
	*--------------------------------------------------------------------------------------------------------------------------------*
	use "$final/Child Labor Data.dta" if urban == 1 & male == 1 & year == 1999, clear
			
		**Testing two specifications. 
		rdwinselect zw $covariates, obsmin(200) 		 seed(1039)						// obsmin() is the minimum number of observations below and above the cutoff. 
			**Selected windon -13, +12
			
		rdwinselect zw $covariates, obsmin(200) wstep(2) seed(2948)						// wstep()  is the window increase in each step
			**Selected windon -10, +10												

	
	*Estimate of ATE on short and long term outcomes
	*--------------------------------------------------------------------------------------------------------------------------------*
	matrix results = (0,0,0,0,0,0) //store year, short-term variable, long-term variable, observed statistic, lower bound and upper bound. 
	
	use "$final/Child Labor Data.dta" if urban == 1 & male == 1, clear
	
	
		**
		*Short term outcomes
		**
	
			foreach year in 1998 1999 2001 2002 2003 2004 2005 2006  {
				preserve
					keep if year == `year' 
					
						local variable = 1
						foreach var of varlist $shortterm_outcomes  {
							rdrandinf `var' zw, c(0) wl(-13) wr(12)  interfci(0.05)
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
					
						local variable = 1
						foreach var of varlist $longterm_outcomes   {
							rdrandinf `var' zw, c(0) wl(-13) wr(12) interfci(0.05)
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
			erase short`figure'.gph
			}	
		

	*Robustness check 
	*--------------------------------------------------------------------------------------------------------------------------------*
		use "$final/Child Labor Data.dta" if urban == 1 & male == 1, clear

		preserve
		
		keep if year == 1999
		
			**
			*Paid work
			**
			rdrandinf pwork zw, c(0) wl(-13) wr(12) interfci(0.05)

			rdsensitivity  	pwork 		zw, wlist(10(1)18) tlist(-0.17(0.01)0.03) verbose nodots saving(graphdata1)

			**
			*School attendance
			**
			rdrandinf schoolatt zw, c(0) wl(-13) wr(12) interfci(0.05)
			
			rdsensitivity  	schoolatt   zw, wlist(10(1)18) tlist(-0.07(0.01)0.13) verbose nodots saving(graphdata2)
		
		restore
		
		keep if year == 2003
		
			**
			*Formal paid work
			**
			rdrandinf pwork_formal zw, c(0) wl(-13) wr(12) interfci(0.05)

			rdsensitivity  	pwork 		zw, wlist(10(1)18) tlist(-0.15(0.01)0.05) verbose nodots saving(graphdata3)

			
			**
			*Charts
			**
			use graphdata1, clear
			twoway contour pvalue t w, ccuts(0(0.05)1) ccolors(gray*0.01 gray*0.05 gray*0.1 gray*0.15 gray*0.2 gray*0.25 gray*0.3 gray*0.35 gray*0.4 gray*0.5    ///
															   gray*0.6 gray*0.7 gray*0.8 gray*0.9 gray black*0.5 black*0.6 black*0.7 black*0.8 black*0.9 black) ///
									   xlabel(10(1)18) ylabel(-0.17(0.01)0.03, nogrid) graphregion(fcolor(none))
			
		
		
		
		use "$final/Child Labor Data.dta" if urban == 1 & male == 1 & year == 1999 & c_household == 3, clear
		
		rdrandinf mom_working zw if two_parent == 0, c(0) interfci(0.05) covariates($covariates) obsmin(200) wstep(2) seed(2948)
		rdrandinf mom_working zw if two_parent == 1, c(0) interfci(0.05) covariates($covariates) obsmin(200) wstep(2) seed(2948)
	

		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
			use "$final/Child Labor Data.dta" if urban == 1 & male == 1 & year == 1999, clear
			clonevar T = D

				rdrandinf 		pwork zw, c(0) wl(-13) wr(12)  interfci(0.05)
				rdsensitivity  	pwork zw, wlist(10(1)12) verbose nodots saving(graphdata)
		
						rdsensitivity  	pwork zw, wlist(10(1)15) tlist(-0.17(0.01)0.03) nodots saving(graphdata)

		
		
		use graphdata, clear 
		twoway contour pvalue t w, ccuts(0(0.05)1)
		
				rdrbounds pwork zw, expgamma(1.5 2 3) wlist(9 12 15) reps(1000)
		
		/*
										ysize(3) xsize(4) 	saving(`outcome'.gph, replace))		
							}
					
				}
			}
		**
		*Short term outcomes
		**
			foreach year in 1999 2001  {
				preserve
					if `year' != 2001 keep if year == `year'
					if `year' == 2001 keep if year == `year' | year == 1999
					
						local variable = 1
						foreach var of varlist $shortterm_outcomes  {
							rdrandinf `var' zw, c(0) wl(-13) wr(12)  interfci(0.05)
							matrix results = results \ (`year', `variable', r(obs_stat), r(int_lb), r(int_ub))
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
			rename (results1-results5) (year shortterm_outcomes ATE lower upper)	
					
			label define shortterm_outcomes  1 "Paid work" 					2 "Formal paid work" 				3 "Informal paid work" 	4  "Unpaid work"    5 "School attendance" 				6 "Paid work and studying" ///
											 7 "Unpaid work and studying" 	8 "Only paid work" 					9 "Only unpaid work" 	10 "Only studying" 11 "Neither working or studying"		
												
			label val shortterm_outcomes shortterm_outcomes

			label var ATE    "ATE"
			label var lower  "Lower bound"
			label var upper  "Upper bound"
			format ATE lower upper %4.3fc

			save "$final/Regression Results using RD under local randomization.dta", replace
	
					
		**
		*Charts
		**
			
			use   "$final/Regression Results using RD under local randomization.dta" if inlist(shortterm_outcomes, 1, 2, 3, 5), clear

				
					su lower, detail
					local min = r(min) + r(min)/3
					su upper, detail
					local max = r(max) + r(max)/3
					
					twoway   scatter ATE shortterm_outcomes if year == 1999,  color(cranberry) || rcap lower upper shortterm_outcomes if year == 1999, lcolor(navy)																	///
					yline(0, lw(1) lp(shortdash) lcolor(cranberry))				 																								///
					xlabel(1 `" "Paid Work" "' 2 `" "Formal" "' 3 `" "Informal" "' 4 `" "School attendance" "' , labsize(small) ) 			///
					xtitle("", size(medsmall)) 											  																						///
					yscale(r())	 																																	///
					ytitle("ITT", size(small))					 																												///					
					title(`: label shortterm_outcomes `shortterm_outcomes'')																									///
					legend(off)  																																				///
					note("Source: PNAD.", color(black) fcolor(background) pos(7) size(small)) 
					graph export "$figures/Figure_RD_short`figure'.pdf", as(pdf) replace
			
			
			
			
			
			
			
		
