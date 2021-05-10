		
	**
	*____________________________________________________________________________________________________________________________________*
	**
	*Visualization RDD
	*____________________________________________________________________________________________________________________________________*
	**
		
		use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & year == 1999 & xw >= - 12 & xw < 12, clear	

			foreach v of varlist $shortterm_outcomes {
				local `v'_label: var label `v'
			}
			collapse $shortterm_outcomes [pw = weight], by(xw)
			foreach v of varlist $shortterm_outcomes {
				replace   `v' = `v'*100
				label var `v' `"``v'_label'"'
			}

			foreach var of varlist $shortterm_outcomes {
				tw  (lpolyci `var' xw if xw >= 0, degree(0) bw(1) acolor(gs12) fcolor(gs12) clcolor(gray) clwidth(0.3)) 		///
					(lpolyci `var' xw if xw <  0, degree(0) bw(1) acolor(gs12) fcolor(gs12) clcolor(gray) clwidth(0.3)) 		///
					(scatter `var' xw if xw >= -12 & xw <  0 , sort msymbol(circle) msize(small) mcolor(navy))         		 	///
					(scatter `var' xw if xw >=   0 & xw <= 12, sort msymbol(circle) msize(small) mcolor(cranberry)), xline(0) 	///
					legend(off) 																								///
					title({bf:`: variable label `var''}, pos(11) span size(large))												///
					ytitle("%") xtitle("Age difference from the cutoff (in months)") 											/// 
					note("Source: PNAD 1999. 95% CI.", color(black) fcolor(background) pos(7) size(small)) saving(short_`var'.gph, replace) 
			}
			
			graph combine short_eap.gph short_pwork.gph short_uwork.gph short_schoolatt.gph, graphregion(fcolor(white)) ysize(5) xsize(7) title(, fcolor(white) size(medium) color(cranberry))
			graph export "$figures/RDD_shortterm-outcomes.pdf", as(pdf) replace
			foreach var of varlist $shortterm_outcomes {
			erase short_`var'.gph
			}	
		
	**
	*____________________________________________________________________________________________________________________________________*
	**
	*Overall descriptive statistics
	*We used these statistics to justify the choice of our sample of analysis: boys in urban areas. 
	*____________________________________________________________________________________________________________________________________*
	**
	
			
			*----------------------------------------------------------------------------------------------------------------------------*
			**Girls and Boys
			**Rural and Urban Areas
			*----------------------------------------------------------------------------------------------------------------------------*
			
			**
			*Hours worked in paid and unpaid jobs
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14, clear
				bys unpaid_work: su hours_worked  	[w = weight]
				
			**
			*Among those working, % in paid jobs and in unpaid jobs
			replace pwork = . if working == 0
			replace uwork = . if working == 0
			collapse (mean)working pwork uwork 	[pw = weight]
			
			**
			*Unpaid jobs, agriculture
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14, clear
				tab 	agric_sector 	 if unpaid_work == 1 					 [w = weight], mis						//unpaid jobs in agriculture
				tab 	type_work_agric  if unpaid_work == 1 & agric_sector == 1 [w = weight], mis						//unpaid jobs in agriculture, % that are members of the household
			
			**
			*Unpaid jobs, non agriculture sector
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14 & agric_sector == 0 & unpaid_work == 1, clear
				tab type_work_noagric 		[w = weight], mis															//% that are members of the household
				tab place_work 		  		[w = weight], mis															//where do they work?
				tab activity90s		  		[w = weight], mis 															//5 = commerce, 6 = services
			
			**
			*Paid jobs
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14 & unpaid_work == 0, clear
				tab place_work 				[w = weight], mis															//40% working in stores, factories, offices
				tab type_work_noagric 		[w = weight], mis	
				tab type_work_agric 		[w = weight], mis	
				
			**
			*Girls and boys living in urban areas
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14, clear
				tab urban [w = weight]
				
				
			**
			*Member of the household, self-consumption, statistic for the APPENDIX
			use "$final/child-labor-ban-brazil.dta" if year == 1999 & age == 14 & unpaid_work == 1, clear
			tab working member_household_self_consu [w = weight], mis //% of 14-year-olds in unpaid work that are member of the household/self-consumption

			**
			*% of children in upaid jobs in rural areas
			use "$final/child-labor-ban-brazil.dta" if year == 1999 & age == 14 & urban == 0, clear
			tab working unpaid_work					[w = weight], mis
			
			
			**
			*ttest for a 9-month bandwidth
			use "$final/child-labor-ban-brazil.dta" if year == 1999 & cohort84_9 == 1, clear	
			
			foreach var of varlist $bargain_controls_our_def {
				ttest `var', by(D)
			}	
			
			
			
			
			
			*----------------------------------------------------------------------------------------------------------------------------*
			**
			*Girls
			*----------------------------------------------------------------------------------------------------------------------------*

			**
			*Among those working, % in paid jobs and in unpaid jobs, by urban/rural areas
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14 & male == 0, clear
			replace pwork = . if working == 0
			replace uwork = . if working == 0
			collapse (mean)working pwork uwork [pw = weight], by(urban)

			**
			**Girls paid work, urban areas
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14 & male == 0 & unpaid_work == 0 & urban == 1, clear
				tab working												[w = weight]
				tab agric_sector 										[w = weight], mis				//99% in non-agriculture sectors
				tab type_work_noagric, mis																//majority as housekeepers
				tab activity90s if type_work_noagric !=2 				[w = weight], mis				//activity sector for those not working as housekeepers
				tab place_work  if type_work_noagric !=2 				[w = weight], mis
			
			**
			**Girls unpaid work, rural areas. 
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14 & male == 0 & unpaid_work == 1 & urban == 0, clear
				tab 		agric_sector 								[w = weight], mis				//% of girls working in agriculture sector in rural areas
					tab 	type_work_agric   if agric_sector == 1 		[w = weight], mis				//% of these girls that are member of the household. 

			
			
			*----------------------------------------------------------------------------------------------------------------------------*
			**
			*Boys
			*----------------------------------------------------------------------------------------------------------------------------*

			**
			*Among those working, % in paid jobs and in unpaid jobs, by urban/rural areas
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14 & male == 1, clear
			replace pwork = . if working == 0
			replace uwork = . if working == 0
			collapse (mean)working pwork uwork [pw = weight], by(urban)
			
			**
			*Boys paid work, urban areas
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14 & male == 1 & unpaid_work == 0 & urban == 1, clear
				tab agric_sector	 									[w = weight], mis				//in urban areas, still we have some boys working with agriculture sector
				tab activity90s 	if agric_sector == 1	 			[w = weight], mis
				tab occupation90s 	if agric_sector == 1	 			[w = weight], mis
				tab type_work 											[w = weight], mis				//20% self-employee a, 60% employees
				tab activity90s 	if type_work_noagric != 3 			[w = weight], mis				//activity sector then the boy is not a self-employee

			**		
			**Boys unpaid work, rural areas. 
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14 & male == 1 & unpaid_work == 1 & urban == 0, clear
				tab 		agric_sector 								[w = weight], mis				//% of boys working in agriculture sector in rural areas
					tab 	type_work_agric   if agric_sector == 1 		[w = weight], mis				//% of these boys that are member of the household
		
				
				
	**
	*____________________________________________________________________________________________________________________________________*
	*
	*PNAD sample: out of labor market, employed (paid and unpaid), and unemployed children
	*____________________________________________________________________________________________________________________________________*
	**
		use "$final/child-labor-ban-brazil.dta" if year == 1999 & age == 14, clear
			tab  unpaid_work member_household_self_consu [w = weight], mis 																//majority of kids in nonpaid activities are member of the household/self consumption

			collapse (sum) member_household_self_consu-no_working_children employed unemployed out_labor paid_workers[pw = weight]

			*----------------------------------------------------------------------------------------------------------------------------*
			**
			*Out of the labor force, employed and unemployed
			*----------------------------------------------------------------------------------------------------------------------------*
				graph pie out_labor employed unemployed, pie(1, explode color(gs12))  pie(2, explode color(cranberry))  pie(3, explode color(navy*0.6)) 				///
				plabel(_all percent,   gap(-15) format(%2.1fc) size(small)) 																 							///
				plabel(1 "Out labor force",  	 color(black) gap(-1) format(%2.1fc) size(large)) 																 		///
				plabel(2 "Employed",  		 	 color(white) gap(2)  format(%2.1fc) size(large)) 																 		///
				plabel(3 "Unemployed",  		 color(black) gap(2)  format(%2.1fc) size(large)) 																 		///
				legend(off) 																																			///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 								///
				plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 								///
				note("Source: PNAD 1999. 14-year-olds.", span color(black) fcolor(background) pos(7) size(small))														///
				ysize(5) xsize(5) 	
				graph export "$figures/out-labor-market-employed-unemployed.pdf", as(pdf) replace	
				
				
			*----------------------------------------------------------------------------------------------------------------------------*
			**
			*Non-paid worker member of the household, other non-paid workers and paid workers
			*----------------------------------------------------------------------------------------------------------------------------*
				graph pie member_household_self_consu  others_unpaid paid_workers, pie(1, explode  color(emidblue)) pie(2, explode color(cranberry))  pie(3, explode color(gs12)) pie(4, explode color(gs8))  pie(5, explode color(cranberry)) pie(6, explode color(olive_teal*1.4))						   					///
				plabel(_all percent,   gap(10) format(%2.0fc) size(small)) 																 								///
				plabel(1 "Household member/self-consumption", 	color(black)  gap(-10) format(%2.0fc) size(small)) 														///
				plabel(2 "Other non-paid workers", 				color(black)  gap(-5)  format(%2.0fc) size(small)) 														///
				plabel(3 "Paid-workers", 						color(black)  gap(-2)  format(%2.0fc) size(small)) 														///
				legend(off) 																																			///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 								///
				plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 								///
				note("Source: PNAD 1999. 14-year-olds.", span color(black) fcolor(background) pos(7) size(small))														///
				ysize(5) xsize(5) 	
				graph export "$figures/member-household-self-consumption.pdf", as(pdf) replace	

			*----------------------------------------------------------------------------------------------------------------------------*
			**
			*Paid workers: boys, girls, rural and urban. 
			*----------------------------------------------------------------------------------------------------------------------------*
				graph pie paid_work_boys_urban paid_work_boys_rural paid_work_girls_urban paid_work_girls_rural, pie(1, explode  color(gs12)) pie(2, explode color(gs8))   pie(3, explode color(olive_teal))  pie(4, explode color(olive_teal*1.6)) pie(5, explode color(cranberry))						   					///
				plabel(_all percent,   gap(12) format(%2.0fc) size(small)) 																 								///
				plabel(1 "Boys, paid work, urban" 	,  color(black) gap(-10) format(%2.0fc) size(small)) 																///
				plabel(2 "Boys, paid work, rural" 	,  color(black) gap(-5)  format(%2.0fc) size(small)) 																///
				plabel(3 "Girls, paid work, urban" 	,  color(black) gap(-10) format(%2.0fc) size(small)) 																///
				plabel(4 "Girls, paid work, rural" 	,  color(black) gap(5)   format(%2.0fc) size(small)) 																///
				legend(off) 																																			///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 								///
				plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 								///
				note("Source: PNAD 1999. 14-year-olds.", span color(black) fcolor(background) pos(7) size(small))														///
				ysize(5) xsize(5) 	
				graph export "$figures/employed-by-type.pdf", as(pdf) replace	

		
	**
	*____________________________________________________________________________________________________________________________________*
	*
	*Safety in the workplace, available for 2001 wave
	*____________________________________________________________________________________________________________________________________*
	**		

			*Why are these children working?
			*----------------------------------------------------------------------------------------------------------------------------*
			use "$inter/Pooled_PNAD.dta" if year == 2001 & age == 14, clear
				
				tab reason_work  unpaid_work if working == 1 [w = weight], mis
				tab happy_work   unpaid_work if working == 1 [w = weight], mis
				
				gen childrens_want = reason_work == 1		//children wants to work
				gen parents_want   = reason_work == 2 		//parents want them to work
				
				label define 	unpaid_work 					1 "Unpaid work" 0 "Paid work"
				label val		unpaid_work unpaid_work
				
				graph pie childrens_want parents_want [w = weight], by(unpaid_work,   note("") legend(off) graphregion(color(white)) cols(3)) pie(1, explode  color(emidblue)) pie(2, explode color(gs8))   pie(3, explode color(olive_teal))  pie(4, explode color(olive_teal*1.6)) pie(5, explode color(cranberry))						   					///
				plabel(_all percent,   gap(12) format(%2.0fc) size(small)) 																 								///
				plabel(1 "They want to work" 			,  color(black) gap(-10) format(%2.0fc) size(large)) 															///
				plabel(2 "Parents want them to work" 	,  color(black) gap(-5)  format(%2.0fc) size(medsmall)) 														///
				legend(off) 																																			///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 								///
				plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 								///
				note("Source: PNAD 2001. 14-year-olds.", span color(black) fcolor(background) pos(7) size(small))														///
				ysize(3) xsize(5) 	
				graph export "$figures/reason-work.pdf", as(pdf) replace	


	**
	*____________________________________________________________________________________________________________________________________*
	*
	*Boutin/Bargain definition of visible/invisible work
	*____________________________________________________________________________________________________________________________________*
	**
		use "$final/child-labor-ban-brazil.dta" if year == 1999, clear

			tab visible_activities 				  if working == 1 [w = weight], mis									//percentage of children working on visible activities
			
			tab visible_activities work_home 	  if working == 1 [w = weight], mis									//visible actitivies & home/work in the same area
				
			tab member_household_self_consu		  if working == 1 &  visible_activities == 1 [w = weight], mis		//60% children in these defined visible actitivies are members of the household/self-consumption
				
								
				
	**
	*____________________________________________________________________________________________________________________________________*
	*
	*Time in service
	*____________________________________________________________________________________________________________________________________*
	**
			use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & year == 1999 & xw >= - 1 & xw < 1, clear	

			gen 	time_job = 12*years_current_work + months_current_work if !missing(years_current_work)
	
			replace time_job = months_current_work 						 if  missing(years_current_work)
	
			su 		time_job, detail
			replace time_job = . if time_job > r(p95)
			
			gen 	got_work_bef_law = 1 if time_job >= 9 & !missing(time_job)
			replace got_work_bef_law = 0 if time_job <  9
						
			gen id = 1
			collapse (sum) id working pwork uwork formal informal  (mean)time_job got_work_bef_law age [pw = weight], by(D)	//70% of our unaffected cohort got the job before the law changed
	
	
