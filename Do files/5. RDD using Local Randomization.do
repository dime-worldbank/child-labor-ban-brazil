
													*REGRESSION DISCONTINUITY UNDER LOCAL RANDOMIZATION*
	*____________________________________________________________________________________________________________________________________*

	rdrobust optmium bandwidth
	eap  number of observations
	
	
	
	rdrobust p values
	
	apendix
	ols with MHT 
	
	

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
				
			rdwinselect xw1 mom_yrs_school hh_head_edu hh_head_age hh_size,   seed(980324) p(1)	obsmin(2000)						
			rdwinselect zw1 mom_yrs_school hh_head_edu hh_head_age hh_size,   seed(980324)	obsmin(800)							// obsmin() is the minimum number of observations below and above the cutoff. 
			rinselectdw zw1 mom_yrs_school hh_head_edu hh_head_age hh_size,   seed(980324) 	nwin(50) plot						// obsmin() is the minimum number of observations below and above the cutoff. 

			**Remember zw1 is our running variable in terms of weeks between the date of birth and December 16th 1984
			rdwinselect zw1 mom_yrs_school hh_head_edu hh_head_age hh_size,   seed(980324)	obsmin(500)							// obsmin() is the minimum number of observations below and above the cutoff. 
			//-14 e 13  selected window 
			rinselectdw zw1 mom_yrs_school hh_head_edu hh_head_age hh_size,   seed(980324)	nwin(50) plot						// obsmin() is the minimum number of observations below and above the cutoff. 
			graph export "$figures/FigureA5.pdf", as(pdf) replace
		
		
		**
		*Placebo (1998) 
		**Children cohort 2: cutoff 12, 16, 1983. We do not have a window in which the local randomization holds. 
		use "$final/child-labor-ban-brazil.dta" if year == 1998 & cohort2_12 == 1, clear
			rdwinselect zw2  mom_yrs_school hh_head_edu hh_head_age hh_size ,   seed(2198)	obsmin(1000)						// obsmin() is the minimum number of observations below and above the cutoff. 
			rdwinselect zw2  mom_yrs_school hh_head_edu hh_head_age hh_size ,   seed(2198)	nwin(50) plot						// obsmin() is the minimum number of observations below and above the cutoff. 
			graph export "$figures/FigureA6.pdf", as(pdf) replace
			
		**
		*Placebo (1998) 
		**Children cohort 2: cutoff 12, 16, 1983. We do not have a window in which the local randomization holds. 
		use "$final/child-labor-ban-brazil.dta" if year == 1997 & cohort4_12 == 1, clear
			rdwinselect zw4  mom_yrs_school hh_head_edu hh_head_age hh_size ,   seed(2198)	obsmin(1000)						// obsmin() is the minimum number of observations below and above the cutoff. 
			rdwinselect zw4  mom_yrs_school hh_head_edu hh_head_age hh_size ,   seed(2198)	nwin(50) plot						// obsmin() is the minimum number of observations below and above the cutoff. 
			*graph export "$figures/FigureA6.pdf", as(pdf) replace			
		}
		
		
		*________________________________________________________________________________________________________________________________*
		**
		**
		*Local Randomization Inference, 1998 & 1999
		**
		*________________________________________________________________________________________________________________________________*
		{
		
			estimates clear
			matrix results = (0,0,0,0,0,0,0,0,0,0,0,0) 									//storing dependent variable, sample, observed statistic, lower bound and upper bounds, and mean of the dependent outcome
			local dep_var = 1														//we attributed a model number for each specification we tested
			
			set seed 740592
			**
			*Estimates using Cattaneo
			*----------------------------------------------------------------------------------------------------------------------------*
			foreach variable in   has_sibling13working 	has_sibling16working					 {		//short-term outcomes
				foreach cohort in 1			    							 {		//cohort1 = cutoff Dec 17, 1984. cohort3 = cut March 16th 1984
					foreach year in  1999  							 {																							
						
						if (`year' == 1998 & `cohort' == 1) | `year' == 1999 {
											
							foreach sample in 2								 {																							//testing the results with different samples
														
								**
								*Sample
								if `sample' == 1 use "$final/child-labor-ban-brazil.dta" if 						  cohort`cohort'_12 == 1, clear	//all sample
								
								if `sample' == 2 use "$final/child-labor-ban-brazil.dta" if urban  == 1	& male == 1 & cohort`cohort'_12 == 1, clear	//only boys, urban areas

								if `sample' == 3 use "$final/child-labor-ban-brazil.dta" if urban  == 1	& male == 0 & cohort`cohort'_12 == 1, clear	//only girls, urban areas
				
								if `sample' == 4 use "$final/child-labor-ban-brazil.dta" if urban  == 0				& cohort`cohort'_12 == 1, clear	//only girls, urban areas
								
								if  `year' == 1998 keep if year == `year'
								if  `year' == 1999 keep if year == `year'
							   *if  `year' == 1999 keep if inlist(year, 1999,2001) //when I tried the estimation with the pooled sample
								
								
								foreach window in 10 12 14 {
								
									**
									*Mean of the dependent variable
									su `variable' [w = weight] if inrange(zw`cohort', -`window', -1), detail
									local mean = r(mean)
									
									local wl = - `window'
									local wr =   `window' - 1 //for weeks/days
									*local wr =   `window' 
									
									**
									*Local randomization
									rdrandinf `variable' zw`cohort',  wl(`wl') wr(`wr')  interfci(0.05) seed(493734)	
									matrix results = results \ (`year',`dep_var', `sample', r(obs_stat), r(randpval), r(int_lb), r(int_ub), `mean',0, `window', `cohort', r(N))
									
									if `cohort' == 1 {
									//We decided in the meeting not to use the polinomio of order 1
									*rdrandinf `variable' zw`cohort',  wl(`wl') wr(`wr')  interfci(0.05) seed(356869) p(1)
									*matrix results = results \ (`year',`dep_var', `sample', r(obs_stat), r(randpval), r(int_lb), r(int_ub), `mean',1, `window',`cohort',r(N))
									}
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

			**
			**
			
			label 		define dep_var 1 "Economically Active"  		 2 "Paid work"  	  				3 "Unpaid work" 						///
									   4 "Formal paid work"  			 5 "Informal paid work" 			6 "Attending school" 					///
									   7 "Only paid work" 				 8 "Only attending school " 	  	9 "Neither working nor attending school" 								   
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
		*Tables for Local Randomization Inference
		**
		*________________________________________________________________________________________________________________________________*
		
		
			**
			*Table 2 -> urban boys only
			*----------------------------------------------------------------------------------------------------------------------------*
			{
				use 	dep_var year  polinomio window ATE2- att_perc_mean2 obs2 cohort using "$inter/Local Randomization Results_1999.dta" if cohort == 1 & polinomio == 0, clear

				
				**
				**
				drop 		polinomio
				reshape 	wide ATE2-att_perc_mean2 obs2, i(dep_var year) j(window)
				drop 		cohort
				**
				local 		num_dp_var  = 9						//number of dependent variables
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
				
				
				drop if inlist(dep_var,3,7,9,10)

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
				export		excel using "$tables/Table2.xlsx",  replace   
			}
			
			
						
			**
			*Table A7> urban, rural, boys and girls
			*----------------------------------------------------------------------------------------------------------------------------*
			{

				use "$inter/Local Randomization Results_1999.dta" if polinomio == 0 & year == 1999, clear
		
				**
				**
				drop 		polinomio year pvalue*
				sort		dep_var window 
				
				**
				*Setting up the table with main results
				**
				
				**
				local 		num_dp_var  = 9						//number of dependent variables
				local 		number_rows = `num_dp_var'*4		//total number of rows in the table
				
				**
				**
				set 	 	obs `number_rows'
				replace  	window 	 = 0 		if window == .
				
				**
				**
				forvalues 	row = 1(1)`num_dp_var' {
					local 	n_row 	= `row' + `num_dp_var'*3
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
				drop     	var att_perc_mean4 att_perc_mean3

				**
				**
				export		excel using "$tables/TableA7.xlsx",  replace   //All results for Local Randomization for Appendix
			}
			
	
	
		*________________________________________________________________________________________________________________________________*
		**
		**
		*Estimate of ATE disaggregating by mother education //only for boys in urban areas. Table A13
		**
		*________________________________________________________________________________________________________________________________*

		
			**
			*Table A8
			*----------------------------------------------------------------------------------------------------------------------------*
			{
			estimates clear
			matrix results = (0,0,0,0,0,0,0,0) 									//storing dependent variable, sample, observed statistic, lower bound and upper bounds, and mean of the dependent outcome
			local   dep_var = 1													//we attributed a model number for each specification we tested
 
			
			**
			*Estimates using Cattaneo
			*----------------------------------------------------------------------------------------------------------------------------*
		
			foreach variable in $shortterm_outcomes {	

				foreach year in 1999 2001 2003 {																

					foreach sample in 1 2 { //sample 1 -> mother did not reach high school. sample 2 -> mother reached high school
				
						use "$final/child-labor-ban-brazil.dta" if year == `year' & urban == 1 & male == 1 & cohort1_12 == 1, clear
						
							**
							*Sample
							if `sample' == 1 keep if inlist(mom_edu_att2,1,2) 
							if `sample' == 2 keep if inlist(mom_edu_att2,3,4)
			
							**
							**Mean of dependent variable
							su `variable' [w = weight]  if inrange(zw1, -10, -1), detail
							local mean = r(mean)														//mean of the shor-term outcome
							
							**
							**
							rdrandinf `variable' zw1,  wl(-10) wr(9) interfci(0.05) seed(8474085)	
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
			label 	define dep_var 1 "Economically Active"  		 2 "Paid work"  	  				3 "Unpaid work" 						///
								   4 "Formal paid work"  			 5 "Informal paid work" 			6 "Attending school" 					///
								   7 "Only paid work" 				 8 "Only attending school " 	  	9 "Neither working nor attending school" 								   
					
			label   define sample   1 "Mother without High School"	 2 "Mother with High School" 												///
			
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
			local 		num_dp_var  = 9 					//number of dependent variables
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
			**Table
			keep 		year *1* *2*
			export		excel using "$tables/TableA8.xlsx",  replace
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
							foreach var of varlist $shortterm_outcomes highschool_degree wage_hour {																					//short term outcomes
								
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
				label 		define shortterm_outcomes  	1 "Economically Active" 					2 "Paid work" 						3 "Unpaid work" 		  ///
														4 "Formal paid work" 						5 "Informal paid work" 				 						  ///
														6 "Attending school" 						7 "Only paid work" 					8 "Only attending school" ///		
														9 "Neither working nor attending school" 	10 "High School degree" 			11 "Wage per hour"
						
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
				local 		ordem = 1
				foreach 	year in 2007 2008 2009 2011 2012 2013 2014      {		//organizing data for short-term outcomes	
				replace 	year_n2 = `ordem' if year == `year'
				local  		ordem	= `ordem' + 1 
				}
				save "$inter/Local Randomization Results_1998-2014.dta", replace
			}	
				
				
				
		*________________________________________________________________________________________________________________________________*
		**
		**
		*Figures for short and long-term. Figures 3, 4, A7 and A8
		**
		*________________________________________________________________________________________________________________________________*
		{
			cd "$figures/"

				**
				*Shortterm outcomes
				*------------------------------------------------------------------------------------------------------------------------*
				{
				foreach bandwidth in 10 12 14  {
				
				use    "$inter/Local Randomization Results_1998-2014.dta" if shortterm_outcomes != 0 & bandwidth == `bandwidth', clear
				
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
							||  	scatter ATE 	 year_n1 ,   color(orange) msize(large) msymbol(O) 																					///
							|| 		rcap lower upper year_n1 ,  lcolor(navy) lwidth( medthick )  	 																					///
							yline(0, lw(0.6) lp(shortdash) lcolor(cranberry*06))  ylabel(, labsize(small) gmax angle(horizontal) format (%4.1fc)) 				 						///
							xlabel(1 `" "13" "years" "old" "' 2 `" "14" "years" "old" "' 3 `" "16" "years" "old" "' 4 `" "17" "years" "old" "' 5 `" "18" "years" "old" "' 6 `" "19" "years" "old" "' 7 `" "20" "years" "old" "' 8 `" "21" "years" "old" "' ,  labsize(small)) ///
							xtitle("", size(small)) 											  																						///
							yscale(r(`min' `max'))	 																																	///
							ytitle("ATE, in pp", size(small))					 																										///					
							title({bf:`: label `shortterm_outcomes' `shortterm_outcomes''}, pos(11) color(navy) span size(medsmall))														///
							legend(off) xsize(6) ysize(4)																																			///
							note(".", color(black) fcolor(background) pos(7) size(small)) saving(short`figure'.gph, replace)
							local figure = `figure' + 1
						restore
					}
					
					/*
					**
					*High school degree
						preserve
							keep if shortterm_outcomes == 10 & year >= 2004					
							su lower, detail
							local min = r(min) + r(min)/3
							quietly su upper, detail
							local max = r(max) + r(max)/3
							
							twoway  ///
							||  	scatter ATE 	 year_n1 ,   color(orange) msize(large) msymbol(O) 																					///
							|| 		rcap lower upper year_n1 ,  lcolor(navy) lwidth( medthick )  	 																					///
							yline(0, lw(0.6) lp(shortdash) lcolor(cranberry*06))  ylabel(, labsize(medsmall) gmax angle(horizontal) format (%4.1fc)) 				 					///
							xlabel(6 `" "2004" "' 7 `" "2005" "' 8 `" "2006" "' , angle(0)  labsize(medsmall) ) 																		///
							xtitle("", size(small)) 											  																						///
							yscale(r(`min' `max'))	 																																	///
							ytitle("ATE, in pp", size(medsmall))					 																									///					
							title({bf: `:label shortterm_outcomes 10' `bandwidth'- bandwidth}, pos(11) color(navy) span size(medsmall))												///
							legend(off) ///
							xsize(4) ysize(6) ///
							note(".", color(black) fcolor(background) pos(7) size(small)) saving(short`figure'_`bandwidth'.gph, replace)
							local figure = `figure' + 1
						restore
					
					**
					*Wage per hour
						preserve
							keep if shortterm_outcomes == 11 & year >= 2004						
							su lower, detail
							local min = r(min) + r(min)/3
							quietly su upper, detail
							local max = r(max) + r(max)/3
							
							twoway  ///
							||  	scatter ATE 	 year_n1 ,   color(orange) msize(large) msymbol(O) 																					///
							|| 		rcap lower upper year_n1 ,  lcolor(navy) lwidth( medthick )  	 																					///
							yline(0, lw(0.6) lp(shortdash) lcolor(cranberry*06))  ylabel(, labsize(medsmall) gmax angle(horizontal) format (%4.1fc)) 				 					///
							xlabel(6 `" "2004" "' 7 `" "2005" "' 8 `" "2006" "' , angle(0)  labsize(medsmall) ) 																		///
							xtitle("", size(small)) 											  																						///
							yscale(r(`min' `max'))	 																																	///
							ytitle("ATE, in R$", size(medsmall))					 																									///					
							title({bf: `:label shortterm_outcomes 11' `bandwidth'- bandwidth}, pos(11) color(navy) span size(medsmall))												///
							legend(off) ///
							xsize(4) ysize(6) ///
							note(".", color(black) fcolor(background) pos(7) size(small)) saving(short`figure'_`bandwidth'.gph, replace)
							local figure = `figure' + 1
						restore
					*/
					
					*Graph with estimations for shortterm outcomes
					graph combine short1.gph short2.gph short4.gph short5.gph short6.gph short8.gph, cols(3) graphregion(fcolor(white)) ysize(10) xsize(18) title(, fcolor(white) size(medium) color(cranberry))
					
					if `bandwidth' == 10 graph export "$figures/Figure3.pdf",  as(pdf) replace
					if `bandwidth' == 12 graph export "$figures/FigureA7.pdf", as(pdf) replace	
					if `bandwidth' == 14 graph export "$figures/FigureA8.pdf", as(pdf) replace
				
					forvalues figure = 1(1)9 {
					*erase short`figure'.gph
					}
					
				}	
					/*
					graph combine short10_10.gph short11_10.gph	short10_12.gph short11_12.gph short11_14.gph short11_14.gph			, cols(2) graphregion(fcolor(white)) ysize(7)  xsize(5) title(, fcolor(white) size(medium) color(cranberry))
					graph export "$figures/FigureA9.pdf", as(pdf) replace
					erase short10_10.gph
					erase short11_10.gph
					erase short10_12.gph
					erase short11_12.gph
					erase short10_14.gph
					erase short11_14.gph
					*/
				}
				
				**
				*Longterm outcomes.
				*------------------------------------------------------------------------------------------------------------------------*
				{
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
							yline(0, lw(0.6) lp(shortdash) lcolor(cranberry*0.6))  ylabel(, labsize(small) gmax angle(horizontal) format (%4.1fc))  				 					///
							xlabel(1 `" "22 years" "old" "' 2 `" "23 years" "old" "' 3 `" "24 years" "old" "' 4 `" "26 years" "old" "' 5 `" "27 years" "old" "' 6 `" "28 years" "old" "' 7 `" "29 years" "old" "' , labsize(vsmall) ) 						///
							xtitle("", size(small)) 											  																						///
							yscale(r(`min' `max')) 																																		///
							ytitle("ATE, in pp", size(small))					 																										///					
							title({bf:`: label longterm_outcomes `longterm_outcomes''}, pos(11) color(navy) span size(medsmall))														///
							legend(order(1 "Boys, urban" ) region(lwidth(white) lcolor(white) fcolor(white)) cols(2) size(medsmall)) 																																				///
							note("", color(black) fcolor(background) pos(7) size(small)) saving(long`figure'.gph, replace)
							local figure = `figure' + 1
						restore
					}
					
					/*
					**
					*Wage per hour
						preserve
							keep if longterm_outcomes == 4				
							su lower, detail
							local min = r(min) + r(min)/3
							quietly su upper, detail
							local max = r(max) + r(max)/3
							
							twoway  ///
							||  	scatter ATE 	 year_n1 ,   color(orange) msize(large) msymbol(O) 																					///
							|| 		rcap lower upper year_n1 ,  lcolor(navy) lwidth( medthick )  	 																					///
							yline(0, lw(0.6) lp(shortdash) lcolor(cranberry*06))  ylabel(, labsize(small) gmax angle(horizontal) format (%4.1fc)) 				 						///
							xlabel(6 `" "2004" "' 7 `" "2005" "' 8 `" "2006" "' , angle(90)  labsize(small) ) 																			///
							xtitle("", size(small)) 											  																						///
							yscale(r(`min' `max'))	 																																	///
							ytitle("ATE, in R$", size(small))					 																										///					
							title({bf: `:label longterm_outcomes 4'}, pos(11) color(navy) span size(medsmall))																		///
							legend(off) 																																				///
							note(".", color(black) fcolor(background) pos(7) size(small)) saving(long`figure'.gph, replace)
							local figure = `figure' + 1
						restore
					*/	
					
					
					*Graph with estimations for longterm outcomes
					graph combine long1.gph long2.gph long3.gph long4.gph 						  , graphregion(fcolor(white)) ysize(5) xsize(8) title(, fcolor(white) size(medium) color(cranberry))
					graph export "$figures/Figure4.pdf", as(pdf) replace
					forvalues figure = 1(1)4  {
					erase long`figure'.gph
					}	
				}	
		}		
			
			
		*________________________________________________________________________________________________________________________________*
		**
		**	
		*Robustness check, Figure 2
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
			
				foreach var of varlist  eap pwork uwork pwork_formal pwork_informal schoolatt pwork_only study_only nemnem {
					rdrandinf 		`var' zw1, c(0) wl(-14) wr(13) interfci(0.05) seed(547946) 			//estimating RDD for economically active children. Window between -13 and 12 weeks. 
						
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
				foreach name in eap pwork uwork pwork_formal pwork_informal schoolatt pwork_only study_only nemnem {			//pwork_formal lnwage_hour //outcomes
					
					use "$inter/Robustness_`name'.dta", clear
		 
					if "`name'" == "eap" 		  	local title =  "Economically active"
					if "`name'" == "pwork" 		  	local title =  "Paid work"
					if "`name'" == "uwork"   	  	local title =  "Unpaid work"
					if "`name'" == "pwork_formal"   local title =  "Formal paid work"
					if "`name'" == "pwork_informal" local title =  "Informal paid work"
					if "`name'" == "schoolatt"   	local title =  "Attending school"
					if "`name'" == "pwork_only"   	local title =  "Only paid work"
					if "`name'" == "study_only"   	local title =  "Only attending school"
					if "`name'" == "nemnem"   		local title =  "Neither working nor attending school"
					
					twoway contour pvalue t w, ccuts(0(0.1)1) xlabel(10(1)18, labsize(small)) ylabel(, labsize(small) nogrid) ///
					xtitle("Weeks around cutoff", size(medsmall)) ///
					ytitle("ATE under H0", size(medsmall)) ///
					title("{bf:`title'}", size(medium) color(navy) pos(11)) ///
					saving("$figures/Robustness_`name'.gph", replace)
				
				}
			
				**
				*Robusteness check using 1999 PNAD wave
				graph combine   "$figures/Robustness_eap.gph" 			"$figures/Robustness_pwork.gph"  			"$figures/Robustness_uwork.gph"  		///
				, graphregion(fcolor(white)) cols(3) ysize(6) xsize(12) title(, fcolor(white) size(medium) color(cranberry))	
				graph export  "$figures/Figure2a.pdf", as(pdf) replace
				
				graph combine   "$figures/Robustness_pwork_formal.gph"  "$figures/Robustness_pwork_informal.gph"  	"$figures/Robustness_schoolatt.gph"  	///
				, graphregion(fcolor(white)) cols(3) ysize(6) xsize(12) title(, fcolor(white) size(medium) color(cranberry))	
				graph export  "$figures/Figure2b.pdf", as(pdf) replace
				
				graph combine   "$figures/Robustness_pwork_only.gph" 	"$figures/Robustness_study_only.gph"  		"$figures/Robustness_nemnem.gph"  		///
				, graphregion(fcolor(white)) cols(3) ysize(6) xsize(12) title(, fcolor(white) size(medium) color(cranberry)) 
				graph export  "$figures/Figure2c.pdf", as(pdf) replace
				
				**
				*Erasing charts
				foreach name in eap pwork uwork pwork_formal pwork_informal schoolatt pwork_only study_only nemnem  { //pwork_formal lnwage_hour
					erase "$figures/Robustness_`name'.gph"
				}
		}
	*____________________________________________________________________________________________________________________________________*
	
	

	
	
	
	
	
	
	
	
		use "$final/child-labor-ban-brazil.dta" if urban  == 1	& male == 1 & year == 2007 & cohort1_12 == 1, clear	
	


	
		rdsampsi  	working zw1, samph(10 11)  nratio(0.25) plot
	
	
	
	use "$final/child-labor-ban-brazil.dta" if urban  == 1	& male == 1 & cohort1_12 == 1, clear	//only boys, urban areas
	
	rdrandinf mom_working zw1,  wl(-14) wr(13)  interfci(0.05) seed(493734)	

	
	
	
	
	
	
	
	
	
	
	
	
	
			
			
