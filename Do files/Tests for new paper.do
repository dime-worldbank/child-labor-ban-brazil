
	*--------------------------------------------------------------------------------------------------------------------------------*
	*Parametric
	*--------------------------------------------------------------------------------------------------------------------------------*
	foreach year in 1999 2001 {
		
		foreach variable in eap pwork uwork schoolatt child_labor_bargain {		//short-term outcomes
		
			if "`variable'" == "eap"   				 local title = "Eco. Act. Pop"
			if "`variable'" == "pwork" 				 local title = "Paid work"
			if "`variable'" == "schoolatt" 			 local title = "School attendance"
			if "`variable'" == "uwork" 				 local title = "Unpaid work"
			if "`variable'" == "child_labor_bargain" local title = "Child Labor/Bargain"
			estimates clear
				
				foreach sample in 1 2 3 4 {
					if `sample' == 1 use "$final/Child Labor Data.dta"								, clear
					if `sample' == 2 use "$final/Child Labor Data.dta" if urban		== 1			, clear
					if `sample' == 3 use "$final/Child Labor Data.dta" if 				   male == 1, clear
					if `sample' == 4 use "$final/Child Labor Data.dta" if urban 	== 1 & male == 1, clear
										
					if `year' == 1999 keep if year == 1999								//Only 1999 sample
					if `year' == 2001 keep if year == 1999 | year == 2001				//Checking robustness doing pooled 1999 and 2001
									
						foreach bdw in 3 6 9 12 {
					
							reg `variable' $dep_vars1 mom_yrs_school 	i.urban i.male i.year 	[pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
							eststo, title("Linear")
							
							reg `variable' $dep_vars2 mom_yrs_school 	i.urban i.male i.year 	[pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
							eststo, title("Quadratic")
							
							reg `variable' $dep_vars1 $bargain_controls i.year 					[pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
							eststo, title("Linear, Bargain")
							
							if `bdw' == 3 {
							reg `variable' $dep_vars3  						    i.year			[pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
							eststo, title("No controls")
							}
						}
				}
				if "`variable'" == "eap" estout * using "$tables/NewPaper`year'.xls",  keep(D*)  title("`title'") label mgroups("3-months" "5-months" "9-months" "12-months" "3-months" "5-months" "9-months" "12-months" "3-months" "5-months" "9-months" "12-months" "3-months" "5-months" "9-months" "12-months", pattern(1 0 0 0 1 0 0 1 0 0 1 0 0  1 0 0 0 1 0 0 1 0 0 1 0 0  1 0 0 0 1 0 0 1 0 0 1 0 0  1 0 0 0 1 0 0 1 0 0 1 0 0)) cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2, labels("Obs" "R2") fmt(%9.0g %9.3f %9.3f)) replace
				if "`variable'" != "eap" estout * using "$tables/NewPaper`year'.xls",  keep(D*)  title("`title'") label mgroups("3-months" "5-months" "9-months" "12-months" "3-months" "5-months" "9-months" "12-months" "3-months" "5-months" "9-months" "12-months" "3-months" "5-months" "9-months" "12-months", pattern(1 0 0 0 1 0 0 1 0 0 1 0 0  1 0 0 0 1 0 0 1 0 0 1 0 0  1 0 0 0 1 0 0 1 0 0 1 0 0  1 0 0 0 1 0 0 1 0 0 1 0 0)) cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2, labels("Obs" "R2") fmt(%9.0g %9.3f %9.3f)) append
				estimates clear
			}	
		}
		
		
	*--------------------------------------------------------------------------------------------------------------------------------*
	*Local Randomization Inference	
	*--------------------------------------------------------------------------------------------------------------------------------*
		estimates clear
		matrix results = (0,0,0,0,0,0) //storing dependent variable, sample, observed statistic, lower bound and upper bound. 
		local model = 1
		

		foreach variable in eap pwork uwork child_labor_bargain {		//short-term outcomes
			foreach sample in 1 2 3 4 {
				if `sample' == 1 use "$final/Child Labor Data.dta" if							   year == 1999, clear
				if `sample' == 2 use "$final/Child Labor Data.dta" if urban		== 1			 & year == 1999, clear
				if `sample' == 3 use "$final/Child Labor Data.dta" if 				   male == 1 & year == 1999, clear
				if `sample' == 4 use "$final/Child Labor Data.dta" if urban 	== 1 & male == 1 & year == 1999, clear
				
				su `variable', detail
				local mean = r(mean)
			
				rdrandinf `variable' zw,  wl(-13) wr(12) interfci(0.05) seed(493734)	
				matrix results = results \ (`model', `sample', r(obs_stat), r(int_lb), r(int_ub), `mean')
			}
			local model = `model' + 1	
		}

		clear
		svmat results						//storing the results of our estimates so we can present the estimates in charts
		drop  in 1
		rename (results1-results6) (model sample ATE lower upper mean_outcome)	

		label define model 1 "Economically Active Population"  2 "Paid work"  3  "Unpaid work" 	 4 "Child Labor/Bargain" 
		label val    model model
		
		local figure = 1
			forvalues model = 1(1)4 {		//models, each one is one of our dependent variables
				preserve
					keep if model == `model'
					
					quietly su lower, detail
					local min = r(min) + r(min)/3
					quietly su upper, detail
					local max = r(max) + r(max)/3
					
					twoway  bar ATE sample,  barw(0.4) color(cranberry) || rcap lower upper sample, lcolor(navy)																///
					yline(0, lw(1) lp(shortdash) lcolor(cranberry))				 																								///
					xlabel(1 `" "Boys, girls" "urban, rural" "' 2 `" "Boys, girls" "urban" "' 3 `" "Boys" "urban, rural" "' 4 `" "Boys" "urban" "' , labsize(small) ) 			///
					xtitle("", size(medsmall)) 											  																						///
					ylabel(-0.15(0.05)0.05)	 																																	///
					ytitle("ATE", size(small))					 																												///					
					title({bf:`: label  model `model''}, size(medlarge))																										///
					legend(off)  																																				///
					note("Source: PNAD. 1999", color(black) fcolor(background) pos(7) size(small)) saving(l_rand_`figure'.gph, replace)
					local figure = `figure' + 1
				restore
			}
		
			**
			**Impact of the ban
			graph combine l_rand_1.gph l_rand_2.gph l_rand_3.gph l_rand_4.gph , graphregion(fcolor(white)) ysize(5) xsize(7) title(, fcolor(white) size(medium) color(cranberry))
			graph export "$figures/local-randomization-1999.pdf", as(pdf) replace
			forvalues figure = 1(1)4 {
			erase l_rand_`figure'.gph
			}	
		
			**
			*Estimate of the reduction in paid-work
			replace mean_outcome 	= mean_outcome*100
			replace ATE				= ATE*100
			gen  	new_outcome 	= mean_outcome+ATE
		
			graph bar (asis)mean_outcome new_outcome if model == 2, bargap(-30) graphregion(color(white)) bar(1, lwidth(0.2) lcolor(navy) color(emidblue)) bar(2, lwidth(0.2) lcolor(black) color(cranberry))  bar(3, color(emidblue))   																	///
			over(sample, sort(sample) relabel( 1 `" "Boys, girls" "urban, rural" "' 2 `" "Boys, girls" "urban" "' 3 `" "Boys" "urban, rural "' 4 `" "Boys" "urban" "' ))				///
			blabel(bar, position(outside) orientation(horizontal) size(vsmall)  color(black) format (%12.1fc))   																								///
			ylabel(, nogrid labsize(small) angle(horizontal)) 																																					///
			yscale(alt) 																																														///
			ysize(5) xsize(7) 																																													///
			ytitle("% children in paid work", size(medsmall) color(black))  																																							///
			legend(order(1 "Before Ban" 2 "Estimate after Ban") region(lwidth(none) color(white) fcolor(none)) cols(4) size(large) position(6))													///
			note("Source: PNAD. 1999", span color(black) fcolor(background) pos(7) size(vsmall))
			graph export "$figures/paid-work-effects.pdf", as(pdf) replace	
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		

		
			use "$final/Child Labor Data.dta" if year == 1999 & urban == 1, clear		//urban and male children 
			rdrandinf pwork dw, wl(-90) wr(90) interfci(0.05) seed(94757)

			use "$final/Child Labor Data.dta" if year == 1999 & hh_member == 3, clear		//urban and male children 
			drop if hh_head_age < 18 & hh_head_age > 60
			rdrandinf child_labor_bargain dw, wl(-90) wr(90) interfci(0.05) seed(94757)

