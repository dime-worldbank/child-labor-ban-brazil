
			
	**
	*____________________________________________________________________________________________________________________________________*
	**
	*Overall descriptive statistics
	*I used these statistics in the presentation to justify the choice of our sample of analysis: boys in urban areas. 
	*____________________________________________________________________________________________________________________________________*
	**
	
			
			*----------------------------------------------------------------------------------------------------------------------------*
			**Girls and Boys
			**Rural and Urban Areas
			*----------------------------------------------------------------------------------------------------------------------------*
			
			**
			*Hours worked in paid and unpaid jobs
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14, clear
			bys nonpaid_work: su hours_worked  [w = weight]
				
			**
			*Among those working, % in paid jobs and in unpaid jobs
			replace pwork = . if working == 0
			replace uwork = . if working == 0
			collapse (mean)working pwork uwork [pw = weight]
			
			**
			*Unpaid jobs, agriculture
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14, clear
				tab 	agri_sector 	 if nonpaid_work == 1 [w = weight], mis						//non paid jobs in agriculture
				tab 	type_work_agric  if nonpaid_work == 1 & agri_sector == 1 [w = weight], mis	//non paid jobs in agriculture, % that are members of the household
			
			**
			*Unpaid jobs, non agriculture sector
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14 & agri_sector == 0 & nonpaid_work == 1, clear
				tab 	type_work_noagric 	[w = weight], mis											//% that are members of the household
				tab 	place_work 		  	[w = weight], mis											//where do they work?
				tab 	activity90s		  	[w = weight], mis 										//5 = commerce, 6 = services
			
			**
			*Paid jobs
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14 & nonpaid_work == 0, clear
				tab place_work 				[w = weight], mis										//40% working in stores, factories, offices
				tab type_work_noagric 		[w = weight], mis	
				tab type_work_agric 		[w = weight], mis	
				
			**
			*Girls and boys living in urban areas
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14, clear
			tab urban [w = weight]
			
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
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14 & male == 0 & nonpaid_work == 0 & urban == 1, clear
				tab working		[w = weight]
				tab agri_sector [w = weight], mis												//99% in non-agriculture sectors
				tab type_work_noagric, mis														//majority as housekeepers
				tab activity90s if type_work_noagric !=2 [w = weight], mis						//activity sector for those not working as housekeepers
				tab place_work  if type_work_noagric !=2 [w = weight], mis
			
			**
			**Girls non paid work, rural areas. 
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14 & male == 0 & nonpaid_work == 1 & urban == 0, clear
				tab 		agri_sector [w = weight], mis										//% of girls working in agriculture sector in rural areas
					tab 	type_work_agric   if agri_sector == 1 [w = weight], mis				//% of these girls that are member of the household. 

			
			
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
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14 & male == 1 & nonpaid_work == 0 & urban == 1, clear
				tab agri_sector [w = weight], mis												//in urban areas, still we have some boys working with agriculture sector
				tab activity90s 	if agri_sector == 1	 [w = weight], mis
				tab occupation90s 	if agri_sector == 1	 [w = weight], mis
						
				tab type_work, mis																//20% self-employee a, 60% employees
				tab activity90s if type_work_noagric != 3, mis									//activity sector then the boy is not a self-employee

			**		
			**Boys non paid work, rural areas. 
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14 & male == 1 & nonpaid_work == 1 & urban == 0, clear
				tab 		agri_sector [w = weight], mis										//% of boys working in agriculture sector in rural areas
					tab 	type_work_agric   if agri_sector == 1 [w = weight], mis				//% of these boys that are member of the household
	
							
	**
	*____________________________________________________________________________________________________________________________________*
	*
	*PNAD sample: out of labor market, employed (paid and non paid), and unemployed. 
	*____________________________________________________________________________________________________________________________________*
	**
				
			*----------------------------------------------------------------------------------------------------------------------------*
			**
			*Total number of children in paid and unpaid jobs
			*----------------------------------------------------------------------------------------------------------------------------*

				use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14, clear
					gen  member_household_self_consu = 1 if inlist(type_work_noagric, 5, 7) |  inlist(type_work_agric, 4, 6)
					gen  others_nonpaid 			 = 1 if nonpaid_work == 1 & member_household_self_consu != 1
					gen  paid_work_girls_urban		 = 1 if nonpaid_work == 0 & male == 0 & urban == 1
					gen  paid_work_girls_rural		 = 1 if nonpaid_work == 0 & male == 0 & urban == 0
					gen  paid_work_boys_urban		 = 1 if nonpaid_work == 0 & male == 1 & urban == 1
					gen  paid_work_boys_rural		 = 1 if nonpaid_work == 0 & male == 1 & urban == 0
					gen  no_employed_children		 = 1 if working      == 0 
					egen paid_workers				 = rsum(paid_work_girls_urban paid_work_girls_rural paid_work_boys_urban paid_work_boys_rural)  
					tab  nonpaid_work member_household_self_consu, mis //majority of kids in nonpaid activities are member of the household/self consumption

					
					**Each row must have the value 1 for at least of variable we defined
						**If the children has a non-paid job and is member of the household
						**If the children has a non-paid job and it is not member of the household
						**Girls in paid jobs in urban areas
						**Girls in paid jobs in rural areas
						**Boys in paid jobs in urban areas
						**Boys  in paid jobs in rural areas
						**No employed children
				egen test = rsum(member_household_self_consu-no_employed_children) 
				tab  test, mis			//okkkk
				drop test

				**Total
				collapse (sum) member_household_self_consu-no_employed_children employed unemployed out_labor paid_workers[pw = weight]

				**
				*Out of the labor force, employed and unemployed
				graph pie out_labor employed unemployed, pie(1, explode color(gs12) )  pie(2, explode color(cranberry))  pie(3, explode color(navy*0.6) ) pie(4, explode color(gs8))  pie(5, explode color(cranberry)) pie(6, explode color(olive_teal*1.4))						   					///
				plabel(_all percent,   gap(-15) format(%2.1fc) size(small)) 																 							///
				plabel(1 "Out labor force",  	 color(black)  gap(-1) format(%2.1fc) size(large)) 																 		///
				plabel(2 "Employed",  		 	 color(white) gap(2) format(%2.1fc) size(large)) 																 		///
				plabel(3 "Unemployed",  		 color(black) gap(2) format(%2.1fc) size(large)) 																 		///
				title("", pos(12) size(huge) color(black)) 																												///
				legend(off) 																																			///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 								///
				plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 								///
				note("Source: PNAD 1999. 14 year olds.", span color(black) fcolor(background) pos(7) size(small))														///
				ysize(5) xsize(5) 	
				graph export "$figures/out-labor-market-employed-unemployed.pdf", as(pdf) replace	
				
				**
				*Non-paid worker member of the household, other non-paid workers and paid workers
				graph pie member_household_self_consu others_nonpaid paid_workers, pie(1, explode  color(emidblue)) pie(2, explode color(cranberry))  pie(3, explode color(gs12)) pie(4, explode color(gs8))  pie(5, explode color(cranberry)) pie(6, explode color(olive_teal*1.4))						   					///
				plabel(_all percent,   gap(10) format(%2.0fc) size(small)) 																 								///
				plabel(1 "Household member/self-consumption", color(black)  gap(-10) format(%2.0fc) size(small)) 														///
				plabel(2 "Other non-paid workers", color(black)  gap(-5) format(%2.0fc) size(small)) 																 	///
				plabel(3 "Paid-workers", color(black)  gap(-2) format(%2.0fc) size(small)) 																 				///
				title("", pos(12) size(huge) color(black)) 																												///
				legend(off) 																																			///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 								///
				plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 								///
				note("Source: PNAD 1999. 14 year olds.", span color(black) fcolor(background) pos(7) size(small))														///
				ysize(5) xsize(5) 	
				graph export "$figures/member-household-self-consumption.pdf", as(pdf) replace	

				**
				*Paid workers: boys, girls, rural and urban. 
				graph pie paid_work_boys_urban paid_work_boys_rural paid_work_girls_urban paid_work_girls_rural, pie(1, explode  color(gs12)) pie(2, explode color(gs8))   pie(3, explode color(olive_teal))  pie(4, explode color(olive_teal*1.6)) pie(5, explode color(cranberry))						   					///
				plabel(_all percent,   gap(12) format(%2.0fc) size(small)) 																 								///
				plabel(1 "Boys, paid work, urban" 	,  color(black) gap(-10) format(%2.0fc) size(small)) 																///
				plabel(2 "Boys, paid work, rural" 	,  color(black) gap(-5) format(%2.0fc) size(small)) 																///
				plabel(3 "Girls, paid work, urban" 	,  color(black) gap(-10) format(%2.0fc) size(small)) 																///
				plabel(4 "Girls, paid work, rural" 	,  color(black) gap(5) format(%2.0fc) size(small)) 																 	///
				title("", pos(12) size(huge) color(black)) 																												///
				legend(off) 																																			///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 								///
				plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 								///
				note("Source: PNAD 1999. 14 year olds.", span color(black) fcolor(background) pos(7) size(small))														///
				ysize(5) xsize(5) 	
				graph export "$figures/employed-by-type.pdf", as(pdf) replace	

	**
	*____________________________________________________________________________________________________________________________________*
	*
	*Time in service
	*____________________________________________________________________________________________________________________________________*
	**
			use "$final/Child Labor Data.dta" if urban == 1 & male == 1 & year == 1999 & xw >= - 1 & xw < 1, clear	

			gen 	time_job = 12*years_current_work + months_current_work if !missing(years_current_work)
	
			replace time_job = months_current_work 						 if  missing(years_current_work)
	
			su 		time_job, detail
			replace time_job = . if time_job > r(p95)
			
			gen 	got_work_bef_law = 1 if time_job >= 9 & !missing(time_job)
			replace got_work_bef_law = 0 if time_job <  9
						
			gen id = 1
			collapse (sum) id working pwork uwork formal informal  (mean)time_job got_work_bef_law age [pw = weight], by(D)	//70% of our unaffected cohort got the job before the law changed
	
	
