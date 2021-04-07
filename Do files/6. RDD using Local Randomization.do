
											*REGRESSION DISCONTINUITY UNDER LOCAL RANDOMIZATION*
	*________________________________________________________________________________________________________________________________*

	*global final "C:\Users\wb495845\Downloads"
	*global inter "C:\Users\wb495845\Downloads"
	
	
	*________________________________________________________________________________________________________________________________*
	**
	**
	*Selecting the window around the cutoff
	**
	*________________________________________________________________________________________________________________________________*
	
		**The command rdwinselect helps us to find a window near the cutoff in which we can assume that the treatment assignment
		**may be regarded as a known randomization mechanism near the cutoff. 
		**For the procedure to be useful, the distribution of the covariates for control and treatment units should be unaffected
		**by the treatment within Wo (selected window) but should be affected by the treatment outside the window. 
	*--------------------------------------------------------------------------------------------------------------------------------*
	use "$final/Child Labor Data.dta" if urban == 1 & male == 1 & year == 1999, clear
			
		**Testing two specifications. 
		rdwinselect zw $covariates, obsmin(200) 		 seed(2198)							// obsmin() is the minimum number of observations below and above the cutoff. 
			**Selected windon -13, +12
			
		rdwinselect zw $covariates, obsmin(200) wstep(2) seed(2948)							// wstep()  is the window increase in each step
			**Selected windon -10, +10												

			
		su pwork if xw >= -3 & xw < 0														//% of paid work for control group
			
	
	*________________________________________________________________________________________________________________________________*
	**
	**
	*Estimate of ATE on short and long term outcomes
	**
	*________________________________________________________________________________________________________________________________*

		**The command rdrandinf estimates ATE, lower and upper bounds for a specific window around the cutoff. 
	*--------------------------------------------------------------------------------------------------------------------------------*

	
	matrix results = (0,0,0,0,0,0) //store year, short-term variable, long-term variable, observed statistic, lower bound and upper bound. 
	
	use "$final/Child Labor Data.dta" if urban == 1 & male == 1, clear		//urban and male children 
	
	
		**
		*Short term outcomes
		**
	
			foreach year in 1998 1999 2001 2002 2003 2004 2005 2006  {												//pnad waves 
				preserve
					keep if year == `year' 
					
						local variable = 1
						foreach var of varlist $shortterm_outcomes  {												//short term outcomes
							rdrandinf `var' zw, wl(-13) wr(12) interfci(0.05) seed(94757)							//estimate of ATE
							matrix results = results \ (`year', `variable', 0, r(obs_stat), r(int_lb), r(int_ub))	//storing results
							local variable = `variable' + 1
						}
				restore
			}
			
		**
		*Long term outcomes
		**	
			foreach year in 2007 2008 2009 2011 2012 2013 2014      {												//pnad waves
				preserve
					keep if year == `year'

						local variable = 1
						foreach var of varlist $longterm_outcomes   {												//long term outcomes					
							rdrandinf `var' zw,  wl(-13) wr(12) interfci(0.05) seed(493734)	
							matrix results = results \ (`year', 0, `variable', r(obs_stat), r(int_lb), r(int_ub))
							local variable = `variable' + 1
						}
						
				restore		
			}
				
		**
		*Results
		**

			clear
			svmat results																								//storing the results of our estimates so we can present the estimates in charts
					
			drop  in 1
			rename (results1-results6) (year shortterm_outcomes longterm_outcomes ATE lower upper)	
					
			/*		
			label define shortterm_outcomes  1 "Paid work" 								2 "Formal paid work" 				3 "Informal paid work" 	4  "Unpaid work"    5 "School attendance" 				6  "Paid work and studying" ///
											 7 "Unpaid work and studying" 				8 "Only paid work" 					9 "Only unpaid work" 	10 "Only studying" 11 "Neither working or studying"		12 "Log-earnings" 
			*/
							
			label define shortterm_outcomes  1 "Economically Active Population" 		2 "Paid work" 						3 "Formal paid work" ///
											 4 "Unpaid work" 							5 "School attendance" 				6 "Ln wage per hour" 
											 
			label define longterm_outcomes   1 "At least High School degree" 						 ///
											 2 "Employed" 								3 "Formal occupation" 				4 "Ln wage per hour" 
												
			label val shortterm_outcomes shortterm_outcomes
			label val longterm_outcomes  longterm_outcomes
			
			foreach var of varlist ATE lower upper {
			replace `var' = . if year < 2001 & (shortterm_outcomes == 3 | shortterm_outcomes == 6)
			}

			label var ATE    "ATE"
			label var lower  "Lower bound"
			label var upper  "Upper bound"
			format ATE lower upper %4.3fc

			gen	 	year_n1 = 0
			gen 	year_n2 = 0
			
			local 	ordem = 1
			foreach year in 1998 1999 2001 2002 2003 2004 2005 2006 {		
				replace year_n1 = `ordem' if year == `year'					//I am just doing this to adjust the years in the graph, otherwise xaxis would show 1999, 2000 and 2001, and we do not have data for 2000. 
				local  ordem = `ordem' + 1 
			}
			local 	ordem = 1
			foreach year in 2007 2008 2009 2011 2012 2013 2014      {
				replace year_n2 = `ordem' if year == `year'
				local  ordem = `ordem' + 1 
			}
			save "$final/Regression Results using RD under local randomization.dta", replace
		
		**
		*Charts
		**
			**Shortterm outcomes
			use   "$final/Regression Results using RD under local randomization.dta" if shortterm_outcomes != 0, clear
			local figure = 1
			forvalues shortterm_outcomes = 1(1)6 {
				preserve
					keep if shortterm_outcomes == `shortterm_outcomes'
					
					quietly su lower, detail
					local min = r(min) + r(min)/3
					quietly su upper, detail
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
		
			*Longterm outcomes
			use   "$final/Regression Results using RD under local randomization.dta" if longterm_outcomes != 0, clear
			local figure = 1
			forvalues longterm_outcomes = 1(1)4 {
				preserve
					keep if longterm_outcomes == `longterm_outcomes'
					
					quietly su lower, detail
					local min = r(min) + r(min)/3
					quietly su upper, detail
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
			
			*Graph with estimations for shortterm outcomes
			graph combine short1.gph short2.gph short3.gph short4.gph short5.gph short6.gph, graphregion(fcolor(white)) ysize(5) xsize(10) title(, fcolor(white) size(medium) color(cranberry))
			graph export "$figures/Local Rand. Shortterm outcomes.pdf", as(pdf) replace
			forvalues figure = 1(1)6 {
			erase short`figure'.gph
			}	
			*Graph with estimations for longterm outcomes
			graph combine long1.gph long2.gph long3.gph long4.gph 						   , graphregion(fcolor(white)) ysize(5) xsize(8) title(, fcolor(white) size(medium) color(cranberry))
			graph export "$figures/Local Rand. Longterm outcomes.pdf", as(pdf) replace
			forvalues figure = 1(1)4  {
			erase long`figure'.gph
			}	
			
			
	*________________________________________________________________________________________________________________________________*
	**
	**	
	*Robustness check 
	**
	*________________________________________________________________________________________________________________________________*
	
		**The command rdsensitivity calculates how sensitity is our estimation to different windows around the cutoff. 
	*--------------------------------------------------------------------------------------------------------------------------------*

		use "$final/Child Labor Data.dta" if urban == 1 & male == 1, clear

		**
		*1999		//using 1999, waves. Robustness check for variables in which we found significant effect of the child labor ban
		**
			preserve
			
			keep if year == 1999
			
				**
				*EAP
				**
				rdrandinf 		pwork 		 zw, c(0) wl(-13) wr(12) interfci(0.05) seed(1029)
				
				local lower =  r(obs_stat) - 0.10
				local upper =  r(obs_stat) + 0.10	
				local mean  =  r(obs_stat)
				
				di `mean'
				di `lower'
				di `upper'

				rdsensitivity  	pwork 		 zw, wlist(10(1)18) tlist(`lower' (0.01) `upper') verbose nodots saving("$inter/Robustness_eap") 			seed(93850)
			
				**
				*Paid work
				**
				rdrandinf		pwork 		 zw, c(0) wl(-13) wr(12) interfci(0.05) seed(1029)
				
				local lower =  r(obs_stat) - 0.10
				local upper =  r(obs_stat) + 0.10
				local mean  =  r(obs_stat)

				rdsensitivity  	pwork 		 zw, wlist(10(1)18) tlist(`lower' (0.01) `upper') verbose nodots saving("$inter/Robustness_pwork") 		seed(20468)

				**
				*School attendance
				**
				rdrandinf 		schoolatt 	 zw, c(0) wl(-13) wr(12) interfci(0.05) seed(93757)
				
				local lower =  r(obs_stat) - 0.10
				local upper =  r(obs_stat) + 0.10
				local mean  =  r(obs_stat)
				
				rdsensitivity  	schoolatt    zw, wlist(10(1)18) tlist(`lower' (0.01) `upper') verbose nodots saving("$inter/Robustness_schoolatt") 	seed(29273)
			
			restore
		
		**
		*2003
		**
			keep if year == 2003
			
				**
				*Formal paid work
				**
				rdrandinf		pwork_formal zw, c(0) wl(-13) wr(12) interfci(0.05) seed(34958)
				
				local lower =  r(obs_stat) - 0.10
				local upper =  r(obs_stat) + 0.10
				local mean  =  r(obs_stat)
				
				rdsensitivity   pwork_formal zw, wlist(10(1)18) tlist(`lower' (0.01) `upper') verbose nodots saving("$inter/Robustness_pwork_formal")  seed(93875)

				
				**
				*Log earnings
				**
				rdrandinf		lnwage_hour  zw, c(0) wl(-13) wr(12) interfci(0.05) seed(12546)
				
				local lower =  r(obs_stat) - 0.10
				local upper =  r(obs_stat) + 0.10
				local mean  =  r(obs_stat)
				
				rdsensitivity   lnwage_hour  zw, wlist(10(1)18) tlist(`lower' (0.01) `upper') verbose nodots saving("$inter/Robustness_lnwage_hour") 	 seed(93875)

		
		**
		*Charts
		**
		
			foreach name in eap pwork schoolatt pwork_formal lnwage_hour {
				
				use "$inter/Robustness_`name'.dta", clear
	 
				if "`name'" == "eap" 		  local title =  "Economically Active Population"
				if "`name'" == "pwork" 		  local title =  "Paid work"
				if "`name'" == "schoolatt" 	  local title =  "School attendance"
				if "`name'" == "pwork_formal" local title =  "Formal paid work"
				if "`name'" == "lnwage_hour"  local title =  "Ln wage hour"
				
				
				twoway contour pvalue t w, ccuts(0(0.05)1) xlabel(10(1)18,labsize(small)) ylabel(, labsize(small) nogrid) ///
				xtitle("Weeks around the cutoff") ///
				ytitle("ATE under the null hyphothesis") ///
				title("{bf:`title'}") ///
				saving("Robustness_`name'")
			
			}
		
			graph combine Robustness_eap.gph 			Robustness_pwork.gph Robustness_schoolatt.gph, graphregion(fcolor(white)) cols(3) ysize(5) xsize(10) title(, fcolor(white) size(medium) color(cranberry))
			graph export "$figures/Robustness_1999.pdf", as(pdf) replace
			graph combine Robustness_pwork_formal.gph 	Robustness_lnwage_hour.gph					 , graphregion(fcolor(white)) cols(2) ysize(5) xsize(7)  title(, fcolor(white) size(medium) color(cranberry))
			graph export "$figures/Robustness_2003.pdf", as(pdf) replace

			
			foreach name in eap pwork schoolatt pwork_formal lnwage_hour {
				erase Robustness_`name'.gph
			}
			
			
			
			
			
			
			
			
			
			
			
