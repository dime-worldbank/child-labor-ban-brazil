
													*REGRESSION DISCONTINUITY UNDER LOCAL RANDOMIZATION*
	*____________________________________________________________________________________________________________________________________*


	

	**=================================================================>>
	**======================================================>>
	**
	*SAMPLE: ALL 14-YEAR-OLDS 			IN URBAN AREAS AND RURAL AREAS
		*	 ALL 14 YEAR-OLDS MALES   	IN URBAN AREAS
		*	 ALL 14 YEAR-OLDS FEMALES 	IN URBAN AREAS
		*    ALL 14 YEAR-OLD 							   RURAL AREAS
 	**
		
	
		*________________________________________________________________________________________________________________________________*
		**
		**
		*Selecting the window around the cutoff
		**
		*________________________________________________________________________________________________________________________________*
		
			**The command rdwinselect helps us to find a window near the cutoff in which we can assume that the treatment assignment
			**may be regarded as a known randomization mechanism. 
			**For the procedure to be useful, the distribution of the covariates for control and treatment units should be unaffected
			**by the treatment status within Wo (selected window around the cutoff) but should be affected by the treatment 
			**outside the window. 
		*--------------------------------------------------------------------------------------------------------------------------------*
		{
		**
		*Main sample (1999)
		use "$final/child-labor-ban-brazil.dta" if year == 1999 & cohort1_12 == 1, clear
				
			cap noi  rdwinselect xw1 mom_yrs_school hh_head_edu hh_head_age hh_size,   seed(980324) p(1)	obsmin(2000)						
			cap noi  rdwinselect zw1 mom_yrs_school hh_head_edu hh_head_age hh_size,   seed(980324)	obsmin(800)							// obsmin() is the minimum number of observations below and above the cutoff. 
			cap noi  rdrinselect zw1 mom_yrs_school hh_head_edu hh_head_age hh_size,   seed(980324) 	nwin(50) plot						// obsmin() is the minimum number of observations below and above the cutoff. 

			**Remember zw1 is our running variable in terms of weeks between the date of birth and December 16th 1984
			cap noi  rdwinselect  zw1 mom_yrs_school hh_head_edu hh_head_age hh_size,   seed(980324)	obsmin(500)							// obsmin() is the minimum number of observations below and above the cutoff. 
			//-14 e 13  selected window 
			cap noi  rdwinselect  zw1 mom_yrs_school hh_head_edu hh_head_age hh_size,   seed(980324)	nwin(50) plot						// obsmin() is the minimum number of observations below and above the cutoff. 
			cap noi  graph export "$figures/FigureA5.pdf", as(pdf) replace
		
		/*
		**
		*Placebo (1998) 
		**Children cohort 2: cutoff 12, 16, 1983. We do not have a window in which the local randomization holds. 
		use "$final/child-labor-ban-brazil.dta" if year == 1998 & cohort2_12 == 1, clear
			cap noi rdwinselect  zw2  mom_yrs_school hh_head_edu hh_head_age hh_size ,   seed(2198)	obsmin(1000)						// obsmin() is the minimum number of observations below and above the cutoff. 
			cap noi rdwinselect zw2  mom_yrs_school hh_head_edu hh_head_age hh_size ,   seed(2198)	nwin(50) plot						// obsmin() is the minimum number of observations below and above the cutoff. 
			
		**
		*Placebo (1998) 
		**Children cohort 2: cutoff 12, 16, 1983. We do not have a window in which the local randomization holds. 
		use "$final/child-labor-ban-brazil.dta" if year == 1997 & cohort4_12 == 1, clear
			cap noi rdwinselect zw4  mom_yrs_school hh_head_edu hh_head_age hh_size ,   seed(2198)	obsmin(1000)						// obsmin() is the minimum number of observations below and above the cutoff. 
			cap noi rdwinselect zw4  mom_yrs_school hh_head_edu hh_head_age hh_size ,   seed(2198)	nwin(50) plot						// obsmin() is the minimum number of observations below and above the cutoff. 
		}
		*/
		
		*________________________________________________________________________________________________________________________________*
		**
		**
		*Storing Local Randomization Results, 1998 & 1999
		**
		*________________________________________________________________________________________________________________________________*
		{
			use "$final/child-labor-ban-brazil.dta",clear 
			estimates clear
			matrix results = (0,0,0,0,0,0,0,0,0,0,0,0) 									//storing dependent variable, sample, observed statistic, lower bound and upper bounds, and mean of the dependent outcome
			local dep_var = 1														//we attributed a model number for each specification we tested
			
			set seed 740592
			
			**
			*Estimates using Cattaneo
			*----------------------------------------------------------------------------------------------------------------------------*
			foreach variable in eap pwork pwork_formal pwork_informal schoolatt study_only {		//short-term outcomes
				foreach cohort in 1			    							 {		      //cohort1 = cutoff Dec 16, 1984.
					foreach year in  1998 1999  							 {																							
						
						if (`year' == 1998 & `cohort' == 1) | `year' == 1999 {
											
							foreach sample in 2								 {			 // testing the results with different samples, but we decided to include only URBAN BOYS
														
								**
								*Sample
								if `sample' == 1 use "$final/child-labor-ban-brazil.dta" if 						  cohort`cohort'_12 == 1, clear	//all sample
								
								if `sample' == 2 use "$final/child-labor-ban-brazil.dta" if urban  == 1	& male == 1 & cohort`cohort'_12 == 1, clear	//only boys, urban areas

								if `sample' == 3 use "$final/child-labor-ban-brazil.dta" if urban  == 1	& male == 0 & cohort`cohort'_12 == 1, clear	//only girls, urban areas
				
								if `sample' == 4 use "$final/child-labor-ban-brazil.dta" if urban  == 0				& cohort`cohort'_12 == 1, clear	//only girls, urban areas
								
								if  `year' == 1998 keep if year == `year'
								if  `year' == 1999 keep if year == `year'
							   *if  `year' == 1999 keep if inlist(year, 1999,2001) //when I tried the estimation with the pooled sample
								
								
								foreach window in 10 14 {
								
									**
									*Mean of the dependent variable
									su `variable' [w = weight] if inrange(zw`cohort', -`window', -1), detail
									local mean = r(mean)
									
									local wl = - `window'
									local wr =   `window' - 1 //for weeks/days
									
									**
									*Local randomization
									rdrandinf `variable' zw`cohort',  wl(`wl') wr(`wr')  interfci(0.05) seed(493734)	
									matrix results = results \ (`year',`dep_var', `sample', r(obs_stat), r(randpval), r(int_lb), r(int_ub), `mean',0, `window', `cohort', r(N))
									
									/*
									if `cohort' == 1 {
									//We decided in the meeting not to use the polinomio of order 1
									rdrandinf `variable' zw`cohort',  wl(`wl') wr(`wr')  interfci(0.05) seed(356869) p(1)
									matrix results = results \ (`year',`dep_var', `sample', r(obs_stat), r(randpval), r(int_lb), r(int_ub), `mean',1, `window',`cohort',r(N))
									}
									*/
								}
							}
						}
					}
				}
				local dep_var = `dep_var' + 1		
			}

			**
			*Results
			*----------------------------------------------------------------------------------------------------------------------------*
			clear
			svmat 		results						//storing the results of our estimates so we can present the estimates in charts
			drop  		in 1
			rename 		(results1-results12) (year dep_var sample ATE pvalue lower upper mean_outcome polinomio window cohort obs)	

			format 		lower upper %12.5fc
			**
			**
			
			label 		define dep_var 1 "Economically Active"  		 2 "Paid work"  	  														///
									   3 "Formal paid work"  			 4 "Informal paid work" 			5 "Attending school" 					///
									   6 "Only attending school " 	   								   
			label 		val dep_var dep_var	
			**
			**
			foreach 	 var of varlist ATE lower upper mean_outcome	{
			replace 	`var'  = `var' *100
			}
			
			**
			**
			gen 	 	att_perc_mean = (ATE/mean_outcome)*100	 if pvalue  <= 0.10
			format   	ATE-att_perc_mean pvalue* %4.3fc
			format 		obs %4.0fc
					
			**
			**
			gen 	 	CI  = "[" + substr(string(lower),1,4) + "," + substr(string(upper),1,4) + "]" if substr(string(lower),1,1) == "-" & substr(string(upper),1,1) == "-"
			replace  	CI  = "[" + substr(string(lower),1,4) + "," + substr(string(upper),1,3) + "]" if substr(string(lower),1,1) == "-" & substr(string(upper),1,1) != "-"
			replace  	CI  = "[" + substr(string(lower),1,3) + "," + substr(string(upper),1,3) + "]" if substr(string(lower),1,1) != "-" & substr(string(upper),1,1) != "-"
			replace  	CI  = "[" + substr(string(lower),1,3) + "," + substr(string(upper),1,4) + "]" if substr(string(lower),1,1) != "-" & substr(string(upper),1,1) == "-"

			
			**
			**
			tostring 	ATE, force replace
			replace  	ATE = substr(ATE, 1, 5) 
			replace 	ATE = ATE + "*"    if pvalue <= 0.10 & pvalue > 0.05
			replace 	ATE = ATE + "**"   if pvalue <= 0.05 & pvalue > 0.01
			replace 	ATE = ATE + "***"  if pvalue <= 0.01

			**
			**
			drop  		lower upper 
			order 		dep_var year ATE CI mean_outcome att_perc_mean pvalue
			reshape 	wide ATE CI mean_outcome att_perc_mean pvalue obs, i(year polinomio window dep_var) j(sample)
			save 		"$inter/Local Randomization Results_1999.dta", replace 
		}
		
		
		*________________________________________________________________________________________________________________________________*
		**
		**
		*Table 2-> urban boys only
		**
		*________________________________________________________________________________________________________________________________*
		
		
			**
			*
			*----------------------------------------------------------------------------------------------------------------------------*
			{
				use 	dep_var year  polinomio window ATE2- att_perc_mean2 obs2 cohort using "$inter/Local Randomization Results_1999.dta" if cohort == 1 & polinomio == 0, clear

				
				**
				**
				drop 		polinomio
				reshape 	wide ATE2-att_perc_mean2 obs2, i(dep_var year) j(window)
				drop 		cohort
				**
				local 		num_dp_var  = 6						//number of dependent variables
				local 		number_rows = `num_dp_var'*3		//total number of rows in the table
				
				**
				**
				set 	 	obs `number_rows'
				replace  	year 	 = 2000 		if year == .
				
				**
				**
				forvalues 	row = 1(1)`num_dp_var' {
					local 	n_row 	= `row' + `num_dp_var'*2
					replace dep_var = `row'  					in `n_row'
				}
				
				**
				**
				gsort     	dep_var  -year
				decode   	dep_var, gen(var)
				drop     	dep_var
				replace  	year = . 			if year == 2000
				tostring 	year, replace
				replace  	year = var 			if year == "."
				drop     	var
				
				**
				**
				export		excel using "$tables/TableA6.xlsx",  replace   
				drop if year == "1998"
				export		excel using "$tables/Table2.xlsx",  replace   
			}
			
				
			
		*________________________________________________________________________________________________________________________________*
		**
		**
		*Estimate of ATE on short and long term outcomes
		*For shortterm outcomes we used PNAD samples of 1999, 2001, 2002, 2003, 2004, 2005, 2006
		**
		*________________________________________________________________________________________________________________________________*
		
		**The command rdrandinf estimates ATE, lower and upper bounds for a specific window around the cutoff. 
		*--------------------------------------------------------------------------------------------------------------------------------*
		{
		estimates clear
		matrix results = (0,0,0,0,0,0,0) //we set up this matrix to store our estimates. 
									     //it stores year, outcome under analysis (short-term or long-term), observed statistic, lower bound and upper bound. 
				
			**
			*Short term outcomes
			**
			*----------------------------------------------------------------------------------------------------------------------------*
			foreach bandwidth in 10 12 14 { //boys in urban areas
				local wl = - `bandwidth'
				local wr =   `bandwidth' - 1
			
				foreach year in 1998 1999 2001 2002 2003 2004 2005 2006  {												//pnad waves 
					
							**
							*Sample

							use  "$final/child-labor-ban-brazil.dta" if urban  == 1	& male == 1 & year == `year' & cohort1_12 == 1, clear	//only boys, urban areas
							
							**
							**
							local variable = 1
							foreach var of varlist eap pwork pwork_formal pwork_informal schoolatt study_only highschool_degree wage_hour {																					//short term outcomes
								
								if "`var'" == "schoolatt" {
								rdrandinf `var' zw1 if highschool_degree == 0, cutoff(0) wl(`wl') wr(`wr') interfci(0.05) seed(8474085)						//estimate of ATE
								}
								else {
								rdrandinf `var' zw1							 , cutoff(0) wl(`wl') wr(`wr') interfci(0.05) seed(8474085)						//estimate of ATE
								}
								matrix results = results \ (`year', `variable', 0, r(obs_stat), r(int_lb), r(int_ub), `bandwidth')							//storing results
								local variable = `variable' + 1
							}
				}
			}
				
			/*	
			**
			*Long term outcomes
			**	
			*----------------------------------------------------------------------------------------------------------------------------*
			foreach bandwidth in 10 { //boys in urban areas
				local wl = - `bandwidth'
				local wr =   `bandwidth' - 1
			
				foreach year in 2007 2008 2009 2011 2012 2013 2014  {												//pnad waves
					
							use "$final/child-labor-ban-brazil.dta" if urban  == 1	& male == 1 & year == `year' & cohort1_12 == 1, clear	//only boys, urban areas

							*
							**
							local variable = 1
							foreach var of varlist college_degree working pwork_formal wage_hour   {												//long term outcomes					
								rdrandinf `var' zw1,  cutoff(0)   wl(`wl') wr(`wr') interfci(0.05) seed(493734)	
								matrix results = results \ (`year', 0, `variable', r(obs_stat), r(int_lb), r(int_ub), `bandwidth')
								local variable = `variable' + 1
							}
				}
			}
			*/
					
			**
			*Results
			**
			*----------------------------------------------------------------------------------------------------------------------------*
				clear
				svmat 		results	//storing the results of our estimates so we can present the estimates in charts
				drop  		in 1
				rename 		(results1-results7) (year shortterm_outcomes longterm_outcomes ATE lower upper bandwidth)	
							
				
				**
				**
				label 		define shortterm_outcomes  	1 "Economically Active" 					2 "Paid work" 								  ///
														3 "Formal paid work" 						4 "Informal paid work" 				 						  ///
														5 "Attending school"                        6 "Only attending school" ///		
														
					
				**
				**
				label 		define longterm_outcomes   	1 "Reached undergrad" 																		 ///
														2 "Employed" 								3 "Formal occupation" 				4 "Wage per hour" 
				
												
					
				**
				**
				label val shortterm_outcomes shortterm_outcomes
				label val longterm_outcomes  longterm_outcomes
				
				**
				**
				foreach var of varlist ATE lower upper {
				replace `var' = `var'*100
				}

				**
				**
				label var 	ATE    "ATE"
				label var 	lower  "Lower bound"
				label var 	upper  "Upper bound"
				format 		ATE lower upper %4.3fc

				**
				**
				gen	 		year_n1 = 0
				gen 		year_n2 = 0
				
				**
				**
				local 		ordem = 1
				foreach 	year in 1998 1999 2001 2002 2003 2004 2005 2006 {		//organizing data for short-term outcomes	
				replace 	year_n1 = `ordem' if year == `year'						//I am just doing this to adjust the years in the graph, otherwise xaxis would show 1999, 2000 and 2001, and we do not have data for 2000. 
				local  		ordem    = `ordem' + 1 
				}
				/*
				local 		ordem = 1
				foreach 	year in 2007 2008 2009 2011 2012 2013 2014      {		//organizing data for short-term outcomes	
				replace 	year_n2 = `ordem' if year == `year'
				local  		ordem	= `ordem' + 1 
				}
				*/
				save "$inter/Local Randomization Results_1998-2014.dta", replace
			}	
				
				
				
		*________________________________________________________________________________________________________________________________*
		**
		**
		*Figures for short and long-term. Figures 2
		**
		*________________________________________________________________________________________________________________________________*
		{
			cd "$datawork\Output"

				**
				*Shortterm outcomes
				*------------------------------------------------------------------------------------------------------------------------*
				{
				foreach bandwidth in 10   {
				
				use    "$inter/Local Randomization Results_1998-2014.dta" if shortterm_outcomes != 0 & bandwidth == `bandwidth', clear
				
				local figure = 1
					
					**
					*Outcomes 1 a 9
					forvalues shortterm_outcomes = 1(1)6{
						preserve
							keep if shortterm_outcomes == `shortterm_outcomes'						
							quietly su lower, detail
							local min = r(min) + r(min)/3
							quietly su upper, detail
							local max = r(max) + r(max)/3
							if shortterm_outcomes == 1 local title = "Economically Active"
							if shortterm_outcomes == 2 local title = "Paid work"
							if shortterm_outcomes == 3 local title = "Formal paid work"
							if shortterm_outcomes == 4 local title = "Informal paid work"
							if shortterm_outcomes == 5 local title = "Attending school"
							if shortterm_outcomes == 6 local title = "Only attending school"
							
							twoway  ///
							||  	scatter ATE 	 year_n1 ,   color(orange) msize(large) msymbol(O) 																					///
							|| 		rcap lower upper year_n1 ,  lcolor(navy) lwidth( medthick )  	 																					///
							yline(0, lw(0.6) lp(shortdash) lcolor(cranberry*06))  ylabel(, labsize(small) gmax angle(horizontal) format (%4.1fc)) 				 						///
							xlabel(1 `" "13" "years" "old" "' 2 `" "14" "years" "old" "' 3 `" "16" "years" "old" "' 4 `" "17" "years" "old" "' 5 `" "18" "years" "old" "' 6 `" "19" "years" "old" "' 7 `" "20" "years" "old" "' 8 `" "21" "years" "old" "' ,  labsize(small)) ///
							xtitle("", size(small)) 											  																						///
							yscale(r(`min' `max'))	 																																	///
							ytitle("ATE, in pp", size(small))					 																										///					
							title({bf: `title'}, pos(11) color(navy) span size(medsmall))														///
							legend(off) xsize(6) ysize(4)																																			///
							note(".", color(black) fcolor(background) pos(7) size(small)) saving(short`figure'.gph, replace)
							local figure = `figure' + 1
						restore
					}
				
					
					*Graph with estimations for shortterm outcomes
					graph combine short1.gph short2.gph short3.gph short4.gph short5.gph short6.gph, cols(3) graphregion(fcolor(white)) ysize(10) xsize(15) title(, fcolor(white) size(medium) color(cranberry))
					if `bandwidth' == 10 graph export "$figures/Figure2.pdf",  as(pdf) replace
				
					forvalues figure = 1(1)6 {
					erase short`figure'.gph
					}
				}	
			}
		}
			
		
		
		*________________________________________________________________________________________________________________________________*
		**
		**	
		*Robustness check, Figure A6
		*
		*________________________________________________________________________________________________________________________________*
		
		**The command rdsensitivity calculates how sensitity is our estimation to different windows around the cutoff. 
		*--------------------------------------------------------------------------------------------------------------------------------*
		{
			**
			*Local Randomization Inference Package
			**
			*----------------------------------------------------------------------------------------------------------------------------*
			use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & year == 1999 & cohort1_12 == 1, clear
			clonevar T = D1
				foreach var of varlist eap pwork pwork_formal pwork_informal schoolatt study_only {
					rdrandinf 		`var' zw1, c(0) wl(-14) wr(13) interfci(0.05) seed(547946)  		//estimating RDD for economically active children. Window between -13 and 12 weeks. 
						
					local lower =  r(obs_stat) - 0.10		//upper bound of ATE
					local upper =  r(obs_stat) + 0.10		//lower bound of ATE
					local mean  =  r(obs_stat)				//ATE
							
					di `mean'
					di `lower'
					di `upper'

					rdsensitivity 	`var' zw1, wlist(10(1)18) tlist(`lower' (0.01) `upper') verbose nodots saving("$inter/Robustness_`var'") seed(938500)	
														//wlist is is the window to the right of the cutoff to be tested
														//tlist specifies the list of null values for the treatment effect
				}
									
			**
			*Figure
			**
			*----------------------------------------------------------------------------------------------------------------------------*
				foreach name in eap pwork pwork_formal pwork_informal schoolatt study_only  {			//pwork_formal lnwage_hour //outcomes
					
					use "$inter/Robustness_`name'.dta", clear
		 
					if "`name'" == "eap" 		  	local title =  "Economically active"
					if "`name'" == "pwork" 		  	local title =  "Paid work"
					if "`name'" == "pwork_formal"   local title =  "Formal paid work"
					if "`name'" == "pwork_informal" local title =  "Informal paid work"
					if "`name'" == "schoolatt"   	local title =  "Attending school"
					if "`name'" == "study_only"   	local title =  "Only attending school"
					
					twoway contour pvalue t w, ccuts(0(0.1)1) xlabel(10(1)18, labsize(small)) ylabel(, labsize(small) nogrid) ///
					xtitle("Weeks around cutoff", size(medsmall)) ///
					ytitle("ATE under H0", size(medsmall)) ///
					title("{bf:`title'}", size(large) color(navy) pos(11)) ///
					saving("$figures/Robustness_`name'.gph", replace)
				
				}
			
				**
				*Robusteness check using 1999 PNAD wave
				graph combine   "$figures/Robustness_eap.gph" 			       "$figures/Robustness_pwork.gph" 			  		///
				, graphregion(fcolor(white)) cols(3) ysize(6) xsize(12) title(, fcolor(white) size(medium) color(cranberry))	
				graph export  "$figures/FigureA6a.pdf", as(pdf) replace
				
				graph combine    "$figures/Robustness_pwork_formal.gph"        "$figures/Robustness_pwork_informal.gph"  			        ///
				, graphregion(fcolor(white)) cols(3) ysize(6) xsize(12) title(, fcolor(white) size(medium) color(cranberry))	
				graph export  "$figures/FigureA6b.pdf", as(pdf) replace
				
				graph combine    "$figures/Robustness_schoolatt.gph"  "$figures/Robustness_study_only.gph" 		        ///
				, graphregion(fcolor(white)) cols(3) ysize(6) xsize(12) title(, fcolor(white) size(medium) color(cranberry))	
				graph export  "$figures/FigureA6c.pdf", as(pdf) replace
				
				**
				*Erasing charts
				foreach name in $shortterm_outcomes { 
					erase "$figures/Robustness_`name'.gph"
				}
		}
	*____________________________________________________________________________________________________________________________________*
	
	

	
	
	
	
	
	
	
	
	
	
	
	/*
	use "$final/child-labor-ban-brazil.dta" if urban  == 1	& male == 1 & year == 2007 & cohort1_12 == 1, clear	
	rdsampsi  	working zw1, samph(10 11)  nratio(0.25) plot
	
	use "$final/child-labor-ban-brazil.dta" if urban  == 1	& male == 1 & cohort1_12 == 1, clear	//only boys, urban areas
	rdrandinf mom_working zw1,  wl(-14) wr(13)  interfci(0.05) seed(493734)	

	*/
	
	
	
	
	
	
	
	
	
	
	
	
			
			
