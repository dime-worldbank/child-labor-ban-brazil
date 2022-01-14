
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
		
		**
		*Main sample (1999)
		use "$final/child-labor-ban-brazil.dta" if year == 1999 & cohort1_12 == 1, clear
				
			**Remember zw1 is our running variable in terms of weeks between the date of birth and December 16th 1984
			rdwinselect zw1 mom_yrs_school hh_head_edu hh_head_age hh_size,   seed(2198)	obsmin(500)							// obsmin() is the minimum number of observations below and above the cutoff. 
			//-14 e 13  selected window 
			rdwinselect zw1 mom_yrs_school hh_head_edu hh_head_age hh_size,   seed(2198)	nwin(50) plot						// obsmin() is the minimum number of observations below and above the cutoff. 
			graph export "$figures/FigureA5.pdf", as(pdf) replace
		
		**
		*Placebo (1998)
		use "$final/child-labor-ban-brazil.dta" if year == 1998 & cohort2_12 == 1, clear
			rdwinselect zw2  mom_yrs_school hh_head_edu hh_head_age hh_size ,   seed(2198)	obsmin(1000)						// obsmin() is the minimum number of observations below and above the cutoff. 
			rdwinselect zw2  mom_yrs_school hh_head_edu hh_head_age hh_size ,   seed(2198)	nwin(50) plot						// obsmin() is the minimum number of observations below and above the cutoff. 
			graph export "$figures/FigureA6.pdf", as(pdf) replace
		
		/*
		*________________________________________________________________________________________________________________________________*
		**
		**
		*Local Randomization Inference, 1999
		**
		*________________________________________________________________________________________________________________________________*
			estimates clear
			matrix results = (0,0,0,0,0,0,0,0,0,0) 									//storing dependent variable, sample, observed statistic, lower bound and upper bounds, and mean of the dependent outcome
			local dep_var = 1														//we attributed a model number for each specification we tested
			
			**
			*Estimates using Cattaneo
			*----------------------------------------------------------------------------------------------------------------------------*
			foreach variable in eap pwork uwork pwork_formal pwork_informal schoolatt pwork_only study_only nemnem {					//short-term outcomes
				
				foreach year in 1998 1999 {																									//example = 1 -> PNAD 1999 wave. Example = 2 -> Placebo using 1998 wave )
					//only running example 1 because we could not find a window around the cutoff where the local randomization holds. 
					
					foreach sample in 1 2 3 4 {																							//testing the results with different samples
												
						**
						*Sample
						if `sample' == 1 use "$final/child-labor-ban-brazil.dta" if 						  year == `year' & cohort1_12 == 1, clear	//all sample
						
						if `sample' == 2 use "$final/child-labor-ban-brazil.dta" if urban  == 1	& male == 1 & year == `year' & cohort1_12 == 1, clear	//only boys, urban areas

						if `sample' == 3 use "$final/child-labor-ban-brazil.dta" if urban  == 1	& male == 0 & year == `year' & cohort1_12 == 1, clear	//only girls, urban areas
		
						if `sample' == 4 use "$final/child-labor-ban-brazil.dta" if urban  == 0				& year == `year' & cohort1_12 == 1, clear	//only girls, urban areas
						
						foreach window in 8 10 12 14 {
						
							**
							*Mean of the dependent variable
							su `variable' [w = weight] if inrange(zw1, -`window', `window' - 1), detail
							local mean = r(mean)
							
							local wl = - `window'
							local wr =   `window' - 1
							
							**
							*Local randomization
							rdrandinf `variable' zw1,  wl(`wl') wr(`wr')  interfci(0.05) seed(493734)	
							matrix results = results \ (`year',`dep_var', `sample', r(obs_stat), r(randpval), r(int_lb), r(int_ub), `mean',0, `window')
							
							//We decided in the meeting not to use the polinomio of order 1
							*rdrandinf `variable' zw`example',  wl(-`window') wr(`window' - 1) interfci(0.05) seed(493734) p(1)
							*matrix results = results \ (`year',`dep_var', `sample', r(obs_stat), r(randpval), r(int_lb), r(int_ub), `mean',1, `window')
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
			rename 		(results1-results10) (year dep_var sample ATE pvalue lower upper mean_outcome polinomio window)	

			**
			**
			label 		define dep_var 1 "Economically Active Children"  2 "Paid work"  	  				3 "Unpaid work" 						///
									   4 "Formal paid work"  			 5 "Informal paid work" 			6 "Attending school" 					///
									   7 "Only paid work" 				 8 "Only attending school " 	  	9 "Neither working nor attending school" 								   
			label		val    dep_var dep_var
		
			**
			**
			foreach 	 var of varlist ATE lower upper mean_outcome	{
			replace 	`var'  = `var' *100
			}
			
			**
			**
			gen 	 	att_perc_mean = (ATE/mean_outcome)*100	 if pvalue  <= 0.10
			format   	ATE-att_perc_mean %4.2fc
		
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
			drop  		lower upper pvalue
			order 		dep_var year ATE CI mean_outcome att_perc_mean
			reshape 	wide ATE CI mean_outcome att_perc_mean, i(year polinomio window dep_var) j(sample)
			save 		"$inter/Local Randomization Results_1999.dta", replace 
			
			**
			**
			use 		"$inter/Local Randomization Results_1999.dta", clear
			
			
			**
			**
			drop 		polinomio year
			sort		dep_var window 
			
			**
			*Setting up the table with main results
			**
			
			**
			local 		num_dp_var  = 9						//number of dependent variables
			local 		number_rows = `num_dp_var'*5		//total number of rows in the table
			
			**
			**
			set 	 	obs `number_rows'
			replace  	window 	 = 0 		if window == .
			
			**
			**
			forvalues 	row = 1(1)`num_dp_var' {
				local 	n_row 	= `row' + `num_dp_var'*4
				replace dep_var = `row'  					in `n_row'
			}
			
			**
			**
			sort     	dep_var  window
			decode   	dep_var, gen(var)
			drop     	dep_var
			replace  	window = . 			if window == 0
			tostring 	window, replace
			replace  	window = var 	    if window == "."
			drop     	var
		
			**
			**
			gen 		space1 = .
			gen 		space2 = .
			gen 		space3 = .
			order 		window *1 *2 *3 *4
			
			**
			*Table A11
			preserve
			keep in 1/25
			export		excel using "$tables/TableA11.xlsx",  replace   //All results for Local Randomization for Appendix
			restore
			
			**
			*Table A12
			keep in 26/45
			export		excel using "$tables/TableA12.xlsx",  replace   //All results for Local Randomization for Appendix	
	
	
	
		*________________________________________________________________________________________________________________________________*
		**
		**
		*Estimate of ATE disaggregating by mother education //only for boys in urban areas
		*________________________________________________________________________________________________________________________________*
			estimates clear
			matrix results = (0,0,0,0,0,0,0,0) 									//storing dependent variable, sample, observed statistic, lower bound and upper bounds, and mean of the dependent outcome
			local   dep_var = 1													//we attributed a model number for each specification we tested

			
			**
			*Estimates using Cattaneo
			*----------------------------------------------------------------------------------------------------------------------------*
		
			foreach variable in eap pwork uwork pwork_formal pwork_informal schoolatt {	

				foreach year in 1999 2001 2003 {																

					foreach sample in 1 2 { //sample 1 -> mother did not reach high school. sample 2 -> mother reached high school
				
						use "$final/child-labor-ban-brazil.dta" if year == `year' & urban == 1 & male == 1 & cohort1_12 == 1, clear
						
							**
							*Sample
							if `sample' == 1 keep if inlist(mom_edu_att2,1,2) 
							if `sample' == 2 keep if inlist(mom_edu_att2,3,4)
			
							**
							**Mean of dependent variable
							su `variable' [w = weight]  if inrange(zw1, -14, 13), detail
							local mean = r(mean)														//mean of the shor-term outcome
							
							**
							**
							rdrandinf `variable' zw1,  wl(-14) wr(13) interfci(0.05) seed(8474085)	
							matrix results = results \ (`year', `dep_var', `sample', r(obs_stat), r(randpval), r(int_lb), r(int_ub), `mean')
								
					}
				}
				local dep_var = `dep_var' + 1	
			}
			
			**
			*Results
			*----------------------------------------------------------------------------------------------------------------------------*
			clear
			svmat 	results						//storing the results of our estimates so we can present the estimates in charts
			drop  	in 1
			rename (results1-results8) (year dep_var sample ATE pvalue lower upper mean_outcome)	

			**
			**
			label 	define dep_var 	1 "Economically Active Children"   	2 "Paid work"  	  	  		3 "Unpaid work" 	 					///
									4 "Formal paid work"  				5 "Informal paid work" 		6 "School attendance"				 	///
									7 "Only paid work" 				  	8 "Studying only" 	  		9 "Neither working or studying" 								   
					
			label   define sample   1 "Mother without High School"	  	2 "Mother with High School" 										///
			
			label	val    dep_var dep_var
			label   val    sample  sample 
		
			
			**
			**
			foreach var of varlist ATE lower upper mean_outcome	{
				replace `var'  = `var' *100
			}
			
			**
			gen 	 att_perc_mean = (ATE/mean_outcome)*100	 if pvalue  <= 0.10
			format   ATE-att_perc_mean %4.2fc
		
			**
			**
			gen 	 CI  = "[" + substr(string(lower),1,4) + "," + substr(string(upper),1,4) + "]" if substr(string(lower),1,1) == "-" & substr(string(upper),1,1) == "-"
			replace  CI  = "[" + substr(string(lower),1,4) + "," + substr(string(upper),1,3) + "]" if substr(string(lower),1,1) == "-" & substr(string(upper),1,1) != "-"
			replace  CI  = "[" + substr(string(lower),1,3) + "," + substr(string(upper),1,3) + "]" if substr(string(lower),1,1) != "-" & substr(string(upper),1,1) != "-"
			replace  CI  = "[" + substr(string(lower),1,3) + "," + substr(string(upper),1,4) + "]" if substr(string(lower),1,1) != "-" & substr(string(upper),1,1) == "-"
			
			**
			**
			tostring ATE, force replace
			replace  ATE = substr(ATE, 1, 5) 
			replace  ATE = ATE + "*"    if pvalue <= 0.10 & pvalue > 0.05
			replace  ATE = ATE + "**"   if pvalue <= 0.05 & pvalue > 0.01
			replace  ATE = ATE + "***"  if pvalue <= 0.01

			**
			**
			drop  	lower upper pvalue
			order 	dep_var  ATE CI mean_outcome att_perc_mean
			reshape wide ATE CI mean_outcome att_perc_mean, i(dep_var year) j(sample)
			
			
			**
			*Setting up the table with main results
			**
			
			**
			local 		num_dp_var  = 6 					//number of dependent variables
			local 		number_rows = `num_dp_var'*4		//total number of rows in the table
			
			**
			**
			set 	 	obs `number_rows'
			replace  	year 	 = 0 		if year == .
			
			**
			**
			forvalues 	row = 1(1)`num_dp_var' {
				local 	n_row 	= `row' + `num_dp_var'*3
				replace dep_var = `row'  					in `n_row'
			}
			
			**
			**
			sort     	dep_var  year
			decode   	dep_var, gen(var)
			drop     	dep_var
			replace  	year = . 			if year == 0
			tostring 	year, replace
			replace  	year = var 			if year == "."
			drop     	var
		
			**
			**
			gen 		space1 = .
			gen 		space2 = .
			gen 		space3 = .
			order 		year *1 *2 
			
			
			**
			**Table A13
			keep 		year *1* *2*
			export		excel using "$tables/TableA13.xlsx",  replace
			*/
			
		*________________________________________________________________________________________________________________________________*
		**
		**
		*Estimate of ATE on short and long term outcomes
		*For shortterm outcomes we used PNAD samples of 1999, 2001, 2002, 2003, 2004, 2005, 2006
		**
		*________________________________________________________________________________________________________________________________*

			**The command rdrandinf estimates ATE, lower and upper bounds for a specific window around the cutoff. 
		*--------------------------------------------------------------------------------------------------------------------------------*
		estimates clear
		matrix results = (0,0,0,0,0,0,0) //we set up this matrix to store our estimates. 
									     //it stores year, outcome under analysis (short-term or long-term), observed statistic, lower bound and upper bound. 
				
			**
			*Short term outcomes
			**
			*----------------------------------------------------------------------------------------------------------------------------*
			foreach bandwidth in 8 10 12 14 { //boys in urban areas
				local wl = - `bandwidth'
				local wr =   `bandwidth' - 1
			
				foreach year in 1998 1999 2001 2002 2003 2004 2005 2006  {												//pnad waves 
					
							**
							*Sample

							use  "$final/child-labor-ban-brazil.dta" if urban  == 1	& male == 1 & year == `year' & cohort1_12 == 1, clear	//only boys, urban areas
							
							**
							**
							local variable = 1
							foreach var of varlist $shortterm_outcomes  {																					//short term outcomes
								
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
							foreach var of varlist $longterm_outcomes   {												//long term outcomes					
								rdrandinf `var' zw1,  cutoff(0)   wl(`wl') wr(`wr') interfci(0.05) seed(493734)	
								matrix results = results \ (`year', 0, `variable', r(obs_stat), r(int_lb), r(int_ub), `bandwidth')
								local variable = `variable' + 1
							}
				}
			}
					
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
				label 		define shortterm_outcomes  	1 "Economically Active Population" 			2 "Paid work" 						3 "Informal paid work" 	 ///
														4 "School attendance" 						5 "Only studying" 					6 "Wage per hour" 
						
				**
				**
				label 		define longterm_outcomes   	1 "At least High School degree" 																		 ///
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
				local 		ordem = 1
				foreach 	year in 2007 2008 2009 2011 2012 2013 2014      {		//organizing data for short-term outcomes	
				replace 	year_n2 = `ordem' if year == `year'
				local  		ordem	= `ordem' + 1 
				}
				save "$inter/Local Randomization Results_1998-2014.dta", replace
				
			cd "$figures/"
			**
			*Charts
			**
			*----------------------------------------------------------------------------------------------------------------------------*
				**
				*Shortterm outcomes
				foreach bandwidth in 8 10 12 14 {
				
				use    "$inter/Local Randomization Results_1998-2014.dta" if shortterm_outcomes != 0 & bandwidth == `bandwidth', clear
			
				local figure = 1

					forvalues shortterm_outcomes = 1(1)6 {
						preserve
							keep if shortterm_outcomes == `shortterm_outcomes'						
							quietly su lower, detail
							local min = r(min) + r(min)/3
							quietly su upper, detail
							local max = r(max) + r(max)/3
							
							twoway  ///
							||  	scatter ATE 	 year_n1 ,   color(orange) msize(large) msymbol(O) 			///
							|| 		rcap lower upper year_n1 ,  lcolor(navy) lwidth( medthick )  	 				///
							yline(0, lw(0.6) lp(shortdash) lcolor(cranberry*06))  ylabel(, labsize(small) gmax angle(horizontal) format (%4.1fc)) 				 													///
							xlabel(1 `" "1998" "' 2 `" "1999" "' 3 `" "2001" "' 4 `" "2002" "' 5 `" "2003" "' 6 `" "2004" "' 7 `" "2005" "' 8 `" "2006" "' , labsize(small) ) 			///
							xtitle("", size(medsmall)) 											  																						///
							yscale(r(`min' `max'))	 																																	///
							ytitle("ATE, in pp", size(small))					 																										///					
							title({bf:`: label shortterm_outcomes `shortterm_outcomes''}, pos(11) color(navy) span size(medium))														///
							legend(order(1 "Boys, urban") region(lwidth(white) lcolor(white) fcolor(white)) cols(2) size(medsmall)) 																																				///
							note(".", color(black) fcolor(background) pos(7) size(small)) saving(short`figure'.gph, replace)
							local figure = `figure' + 1
						restore
					}
					
					*Graph with estimations for shortterm outcomes
					graph combine short1.gph short2.gph short3.gph short4.gph short5.gph short6.gph, graphregion(fcolor(white)) ysize(5) xsize(10) title(, fcolor(white) size(medium) color(cranberry))
					
					if `bandwidth' == 10 graph export "$figures/Figure3.pdf", as(pdf) replace
					if `bandwidth' == 8  graph export "$figures/FigureA7.pdf", as(pdf) replace
					if `bandwidth' == 12 graph export "$figures/FigureA8.pdf", as(pdf) replace	
					if `bandwidth' == 14 graph export "$figures/FigureA9.pdf", as(pdf) replace
					
					forvalues figure = 1(1)6 {
					erase short`figure'.gph
					}	
				}
				
				**
				*Longterm outcomes
				use    "$inter/Local Randomization Results_1998-2014.dta" if longterm_outcomes != 0 & bandwidth == 10, clear
					local figure = 1
					
					forvalues longterm_outcomes = 1(1)4 {
						preserve
							keep if longterm_outcomes == `longterm_outcomes'
							quietly su lower, detail
							local min = r(min) + r(min)/3
							quietly su upper, detail
							local max = r(max) + r(max)/3

							twoway  ///
							||  	scatter ATE 	 year_n2 ,   color(orange) msize(large) msymbol(O) 		///
							|| 		rcap lower upper year_n2 ,  lcolor(navy) lwidth( medthick )  	 			///
							yline(0, lw(0.6) lp(shortdash) lcolor(cranberry*0.6))  ylabel(, labsize(small) gmax angle(horizontal) format (%4.1fc))  				 														///
							xlabel(1 `" "2007" "' 2 `" "2008" "' 3 `" "2009" "' 4 `" "2011" "' 5 `" "2012" "' 6 `" "2013" "' 7 `" "2014" "' , labsize(small) ) 							///
							xtitle("", size(medsmall)) 											  																						///
							yscale(r(`min' `max')) 																																		///
							ytitle("ATE, in pp", size(small))					 																										///					
							title({bf:`: label longterm_outcomes `longterm_outcomes''}, pos(11) color(navy) span size(medium))															///
							legend(order(1 "Boys, urban" ) region(lwidth(white) lcolor(white) fcolor(white)) cols(2) size(medsmall)) 																																				///
							note("", color(black) fcolor(background) pos(7) size(small)) saving(long`figure'.gph, replace)
							local figure = `figure' + 1
						restore
					}
					
					*Graph with estimations for longterm outcomes
					graph combine long1.gph long2.gph long3.gph long4.gph 						  , graphregion(fcolor(white)) ysize(5) xsize(8) title(, fcolor(white) size(medium) color(cranberry))
					graph export "$figures/Figure4.pdf", as(pdf) replace
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

			use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1, clear

			**
			*1999		//using 1999 wave. Robustness check for variables in which we found significant effect of the child labor ban
			**
			*----------------------------------------------------------------------------------------------------------------------------*
				preserve
				
				keep if year == 1999 & cohort1_12 == 1
				
					**
					*EAP
					**
					rdrandinf 		eap 		 zw1, c(0) wl(-14) wr(13) interfci(0.05) seed(1029) //estimating RDD for economically active children. Window between -13 and 12 weeks. 
					
					local lower =  r(obs_stat) - 0.10		//upper bound of ATE
					local upper =  r(obs_stat) + 0.10		//lower bound of ATE
					local mean  =  r(obs_stat)				//ATE
						
					di `mean'
					di `lower'
					di `upper'

					rdsensitivity  	eap  		 zw1, wlist(10(1)18) tlist(`lower' (0.01) `upper') verbose nodots saving("$inter/Robustness_eap") 		   seed(93850)	
													//wlist is is the window to the right of the cutoff to be tested
													//tlist specifies the list of null values for the treatment effect
				
					**
					*Paid work
					**
					rdrandinf		pwork 		 zw1, c(0) wl(-14) wr(13) interfci(0.05) seed(1029)
					
					local lower =  r(obs_stat) - 0.10
					local upper =  r(obs_stat) + 0.10
					local mean  =  r(obs_stat)

					rdsensitivity  	pwork 		 zw, wlist(10(1)18) tlist(`lower' (0.01) `upper') verbose nodots saving("$inter/Robustness_pwork") 		   seed(20468)

					
					
					**
					*School attendance
					**
					rdrandinf 		schoolatt 	 zw if highschool_degree == 0, c(0) wl(-14) wr(13) interfci(0.05) seed(93757)
					
					local lower =  r(obs_stat) - 0.10
					local upper =  r(obs_stat) + 0.10
					local mean  =  r(obs_stat)
					
					rdsensitivity  	schoolatt    zw if highschool_degree == 0, wlist(10(1)18) tlist(`lower' (0.01) `upper') verbose nodots saving("$inter/Robustness_schoolatt")     seed(29273)
				
				restore
			
			**
			*2003				//using 2003 wave. Robustness check for variables in which we found significant effect of the child labor ban
			**
			*----------------------------------------------------------------------------------------------------------------------------*
			/*
				keep if year == 2003 & cohort1_12 == 1
				
					**
					*Formal paid work
					**
					rdrandinf		pwork_formal zw1, c(0) wl(-14) wr(13) interfci(0.05) seed(34958)
					
					local lower =  r(obs_stat) - 0.10		//upper bound of ATE
					local upper =  r(obs_stat) + 0.10		//lower bound of ATE
					local mean  =  r(obs_stat)				//ATE
					
					rdsensitivity   pwork_formal zw1, wlist(10(1)18) tlist(`lower' (0.01) `upper') verbose nodots saving("$inter/Robustness_pwork_formal")  seed(93875)

					
					**
					*Log earnings
					**
					rdrandinf		lnwage_hour  zw1, c(0) wl(-14) wr(13) interfci(0.05) seed(12546)
					
					local lower =  r(obs_stat) - 0.10
					local upper =  r(obs_stat) + 0.10
					local mean  =  r(obs_stat)
					
					rdsensitivity   lnwage_hour  zw1, wlist(10(1)18) tlist(`lower' (0.01) `upper') verbose nodots saving("$inter/Robustness_lnwage_hour")   seed(93875)
			*/	
			**
			*Figures
			**
			*----------------------------------------------------------------------------------------------------------------------------*
				foreach name in eap pwork schoolatt  {			//pwork_formal lnwage_hour //outcomes
					
					use "$inter/Robustness_`name'.dta", clear
		 
					if "`name'" == "eap" 		  local title =  "Economically Active Children"
					if "`name'" == "pwork" 		  local title =  "Paid work"
					if "`name'" == "schoolatt" 	  local title =  "School attendance"
					if "`name'" == "pwork_formal" local title =  "Formal paid work"
					if "`name'" == "lnwage_hour"  local title =  "Wage per hour"
					
					
					twoway contour pvalue t w, ccuts(0(0.05)1) xlabel(10(1)18,labsize(small)) ylabel(, labsize(small) nogrid) ///
					xtitle("Weeks around the cutoff") ///
					ytitle("ATE under the null hyphothesis") ///
					title("{bf:`title'}", color(navy) pos(11)) ///
					saving("Robustness_`name'", replace)
				
				}
			
				**
				*Robusteness check using 1999 PNAD wave
				graph combine Robustness_eap.gph 			Robustness_pwork.gph Robustness_schoolatt.gph, graphregion(fcolor(white)) cols(3) ysize(5) xsize(12) title(, fcolor(white) size(medium) color(cranberry))
				graph export "$figures/Figure2.pdf", as(pdf) replace
				
				**
				*Robusteness check using 2003 PNAD wave
				*graph combine Robustness_pwork_formal.gph 	Robustness_lnwage_hour.gph					 , graphregion(fcolor(white)) cols(2) ysize(5) xsize(7)  title(, fcolor(white) size(medium) color(cranberry))
				*graph export "$figures/robustness-2003.pdf", as(pdf) replace

				**
				*Erasing charts
				foreach name in eap pwork schoolatt  { //pwork_formal lnwage_hour
					erase Robustness_`name'.gph
				}
	
	*____________________________________________________________________________________________________________________________________*
	
	

	/*		
	**=================================================================>>
	**======================================================>>
	**
	*SAMPLE: ALL 14-YEAR-OLDS IN URBAN AND RURAL AREAS
		*	 ALL 14 YEAR-OLDS IN URBAN AREAS
		*	 ALL 14 YEAR-OLD MALES
		*    ALL 14 YEAR-OLD MALES IN URBAN AREAS
 	**
			
	*________________________________________________________________________________________________________________________________*
	**
	*Local Randomization Inference in Charts
	**
	*________________________________________________________________________________________________________________________________*
		estimates clear
		matrix results = (0,0,0,0,0,0) 									//storing dependent variable, sample, observed statistic, lower bound and upper bounds, and mean of the dependent outcome
		local model = 1													//we attributed a model number for each specification we tested
		
		**
		*Estimates using Cattaneo
		*----------------------------------------------------------------------------------------------------------------------------*
		foreach variable in eap pwork uwork employ_bargain schoolatt nemnem {			//short-term outcomes
			foreach sample in 1 2 3 4 {													//testing the results with different samples
				
				if `sample' == 1 use "$final/child-labor-ban-brazil.dta" if							   year == 1999, clear		//all sample
				if `sample' == 2 use "$final/child-labor-ban-brazil.dta" if urban		== 1		 & year == 1999, clear		//boys and girls, urban
				if `sample' == 3 use "$final/child-labor-ban-brazil.dta" if 			   male == 1 & year == 1999, clear		//only boys
				if `sample' == 4 use "$final/child-labor-ban-brazil.dta" if urban 	== 1 & male == 1 & year == 1999, clear		//only boys, urban areas
				
				su `variable', detail
				local mean = r(mean)									//mean of the shor-term outcome
			
				rdrandinf `variable' zw,  wl(-13) wr(12) interfci(0.05) seed(493734)	
				matrix results = results \ (`model', `sample', r(obs_stat), r(int_lb), r(int_ub), `mean')
			}
			local model = `model' + 1								
		}

		
		**
		*Results
		*----------------------------------------------------------------------------------------------------------------------------*
		clear
		svmat results						//storing the results of our estimates so we can present the estimates in charts
		drop  in 1
		rename (results1-results6) (model sample ATE lower upper mean_outcome)	

		label define model 1 "Economically Active Children"  2 "Paid work"  3  "Unpaid work" 	 4 "Child Labor/Bargain"  5 "School attainment" 6 "Neither working or studying" 
		label val    model model
		
		
		**
		**Impact of the ban
		*----------------------------------------------------------------------------------------------------------------------------*
		local figure = 1
		local number_figures = 6
			forvalues model = 1(1)`number_figures' {		//models, each one is one of our dependent variables
			
				preserve
					keep if model == `model'
					
					quietly su lower, detail
					local 						min = r(min) + r(min)/3		//to define the ylabels
					quietly su upper, detail
					local 						max = r(max) + r(max)/3		//to define the ylabels
					
					twoway  bar ATE sample,  barw(0.4) color(cranberry) || rcap lower upper sample, lcolor(navy) lwidth(thick) 																///
					yline(0, lw(1) lp(shortdash) lcolor(cranberry))  ylabel(, labsize(small) gmax angle(horizontal) format (%4.2fc)) 				 																								///
					xlabel(1 `" "Boys, girls" "urban, rural" "' 2 `" "Boys, girls" "urban" "' 3 `" "Boys" "urban, rural" "' 4 `" "Boys" "urban" "' , labsize(small) ) 			///
					xtitle("", size(medsmall)) 											  																						///
					ylabel(-0.15(0.05)0.05)	 																																	///
					ytitle("ATE", size(small))					 																												///					
					title({bf:`: label  model `model''}, color(navy) pos(11) size(medium))																										///
					legend(off)  																																				///
					note("", color(black) fcolor(background) pos(7) size(small)) saving(l_rand_`figure'.gph, replace)
					local figure = `figure' + 1
				restore
				
			}
			graph combine l_rand_1.gph l_rand_2.gph l_rand_3.gph l_rand_4.gph l_rand_5.gph l_rand_6.gph, graphregion(fcolor(white)) ysize(5) xsize(8) note("Source: PNAD 1999." ) title(, fcolor(white) size(medium) color(cranberry))
			graph export "$figures/local-randomization-1999.pdf", as(pdf) replace
			forvalues figure = 1(1)`number_figures' {
			erase l_rand_`figure'.gph
			}	
		
		
		**
		*Estimate of the reduction in paid-work, for model 2 (sample of all 14 year-olds in urban areas)
		*----------------------------------------------------------------------------------------------------------------------------*
			replace mean_outcome 	= mean_outcome*100		//percentage of kids in paid work in 1999	
			replace ATE				= ATE*100				//estimate of the reduction in paid work
			gen  	new_outcome 	= mean_outcome+ATE		//estimate % of children in paid work after the ban
			
			graph bar (asis)mean_outcome new_outcome if model == 2, bargap(-30) graphregion(color(white)) bar(1, lwidth(0.2) lcolor(navy) color(emidblue)) bar(2, lwidth(0.2) lcolor(black) color(cranberry))  bar(3, color(emidblue))   																	///
			over(sample, sort(sample) relabel( 1 `" "Boys, girls" "urban, rural" "' 2 `" "Boys, girls" "urban" "' 3 `" "Boys" "urban, rural "' 4 `" "Boys" "urban" "' ))										///
			blabel(bar, position(outside) orientation(horizontal) size(vsmall)  color(black) format (%12.1fc))   																								///
			ylabel(, nogrid labsize(small) angle(horizontal)) 																																					///
			yscale(alt) 																																														///
			ysize(5) xsize(7) 																																													///
			ytitle("% children in paid work", size(medsmall) color(black))  																																	///
			legend(order(1 "Before Ban" 2 "Estimate after Ban") region(lwidth(none) color(white) fcolor(none)) cols(4) size(large) position(6))																	///
			note("Source: PNAD. 1999", span color(black) fcolor(background) pos(7) size(vsmall))
			graph export "$figures/local-rando-paid-work-1999.pdf", as(pdf) replace	
		
	
			
			
			
			
			
