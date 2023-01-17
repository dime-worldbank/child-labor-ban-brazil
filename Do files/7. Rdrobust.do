	
	
																	*RD ROBUST*
	*____________________________________________________________________________________________________________________________________*

	
	
	
	*____________________________________________________________________________________________________________________________________*
	
	
	**
	*Regs
	*-----------------------------------------------------------------------------------------------------------------------------------*
		matrix results = (0,0,0,0,0,0,0,0)
		
		foreach year in 1999 2001 2002 2003 2004 2005 2006 2007 {
		
			foreach bandwidth in 14 26 39 {
			
				local dep_var = 1
				
				use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1, clear	//boys, urban, 1999ta

					foreach var of varlist $shortterm_outcomes {
					
					*if `year' == 1999 keep if year == 1999
					*if `year' == 2001 keep if inlist(year, 1999, 2001)
					
					keep if year == `year'
					
					rdrobust `var' zw1, h(`bandwidth') c(0) p(1)  vce(cluster zw1) kernel(uniform)
					matrix results = results\(`year', `bandwidth',`dep_var', e(tau_cl), e(ci_r_cl), e(ci_l_cl),  e(pv_cl) ,0)
					
					rdrobust `var' zw1, h(`bandwidth') c(0) p(1)  vce(cluster zw1) kernel(uniform) covs($bargain_controls_our_def )
					matrix results = results\(`year', `bandwidth',`dep_var', e(tau_cl), e(ci_r_cl), e(ci_l_cl),  e(pv_cl) , 1)
					
					local dep_var = `dep_var' + 1 
				}
			}
		}
	
	
	**
	*Results
	*-----------------------------------------------------------------------------------------------------------------------------------*
		clear
		svmat 		results						//storing the results of our estimates so we can present the estimates in charts
		drop  		in 1
		rename 		(results1-results8) (year bandwidth shortterm_outcomes  ATE  upper lower pvalue covs)	
		
		foreach var of varlist ATE  upper lower {
		    replace `var' = `var'*100
		}
		
		
		**
		label 		define shortterm_outcomes 	1 "Economically Active"  		 2 "Paid work"  	  				3 "Unpaid work" 						///
												4 "Formal paid work"  			 5 "Informal paid work" 			6 "Attending school" 					///
												7 "Only paid work" 				 8 "Only attending school " 	  	9 "Neither working nor attending school" 								   
		label		val    shortterm_outcomes shortterm_outcomes
		

		tempfile 	datacharts
		save 	   `datacharts'
		
		/*
		**
		preserve
		gen 	 	CI  = "[" + substr(string(lower),1,4) + "," + substr(string(upper),1,4) + "]" if substr(string(lower),1,1) == "-" & substr(string(upper),1,1) == "-"
		replace  	CI  = "[" + substr(string(lower),1,4) + "," + substr(string(upper),1,3) + "]" if substr(string(lower),1,1) == "-" & substr(string(upper),1,1) != "-"
		replace  	CI  = "[" + substr(string(lower),1,3) + "," + substr(string(upper),1,3) + "]" if substr(string(lower),1,1) != "-" & substr(string(upper),1,1) != "-"
		replace  	CI  = "[" + substr(string(lower),1,3) + "," + substr(string(upper),1,4) + "]" if substr(string(lower),1,1) != "-" & substr(string(upper),1,1) == "-"

		tostring 	ATE, force replace
		replace  	ATE = substr(ATE, 1, 5) 
		replace 	ATE = ATE + "*"    if pvalue <= 0.10 & pvalue > 0.05
		replace 	ATE = ATE + "**"   if pvalue <= 0.05 & pvalue > 0.01
		replace 	ATE = ATE + "***"  if pvalue <= 0.01
		drop		upper lower pvalue
		
		expand 2, gen (REP)
		sort year bandwidth shortterm_outcomes covs REP
		replace ATE = CI[_n-1]  if shortterm_outcomes== shortterm_outcomes[_n-1] & REP == 1 & REP[_n-1] == 0 & bandwidth == bandwidth[_n-1] & year == year[_n-1]
		drop CI REP
		
		gen 	tipo = 1 
		replace tipo = 2 if substr(ATE, 1, 1) == "["
		
		reshape wide ATE , i(year bandwidth shortterm_outcomes tipo) j(covs)
		reshape wide ATE*, i(	  bandwidth shortterm_outcomes tipo) j(year)
		reshape wide ATE*, i(	  			shortterm_outcomes tipo) j(bandwidth)

		
		drop if inlist(shortterm_outcomes, 3,7,9)
		replace dep_var = . if tipo == 2
		drop 	tipo
		
		tempfile rdrobust
		save 	`rdrobust'
		restore
		*/
		
		
			foreach bandwidth in 14 26 39  {
				use  `datacharts' if covs == 1 & bandwidth == `bandwidth', clear
				local figure = 1
			

				**
					*Outcomes 1 a 9
					forvalues shortterm_outcomes = 1(1)9{
						preserve
							keep if shortterm_outcomes == `shortterm_outcomes'						
							quietly su lower, detail
							local min = r(min) + r(min)/3
							quietly su upper, detail
							local max = r(max) + r(max)/3
							
							twoway  ///
							||  	scatter ATE 	 year ,   color(orange) msize(large) msymbol(O) 																					///
							|| 		rcap lower upper year ,  lcolor(navy) lwidth( medthick )  	 																					///
							yline(0, lw(0.6) lp(shortdash) lcolor(cranberry*06))  ylabel(, labsize(small) gmax angle(horizontal) format (%4.1fc)) 				 						///
							xtitle("", size(small)) 											  																						///
							yscale(r(`min' `max'))	 																																	///
							ytitle("ATE, in pp", size(small))					 																										///					
							title({bf:`: label shortterm_outcomes `shortterm_outcomes''}, pos(11) color(navy) span size(medsmall))														///
							legend(off) xsize(6) ysize(4)																																			///
							note(".", color(black) fcolor(background) pos(7) size(small)) saving(short`figure'.gph, replace)
							local figure = `figure' + 1
						restore
					}


			
			graph combine short1.gph short2.gph short4.gph short5.gph short6.gph short8.gph, cols(3) graphregion(fcolor(white)) ysize(10) xsize(18) title(, fcolor(white) size(medium) color(cranberry))
		    graph export "$figures/teste_band`bandwidth'.pdf",  as(pdf) replace
		}
	
	
	

		
		
		
		use "$inter/Local Randomization Results_1999.dta" if window == 14 & polinomio ==0, clear		
		
		keep dep_var ATE CI

		merge 1:1 dep_var using `rdrobust'