			
												  *ONLINE APPENDIX FOR CHILD LABOR BAN PAPER*
	*________________________________________________________________________________________________________________________________*

	
	*________________________________________________________________________________________________________________________________*
	**
	**
	*We reproduce the main results found by Bargain/Boutin.
	*We work with the same:
		* -> dependent variables, 'child_labor_bargain' and 'paid_work'
		* -> control variables,   `controls_bargain'
		* -> sample exclusions, program `bargain_sample'
		* -> cluster for standard errors
		* -> running variable (difference in days between date of birth and December 16th, 1984).
		* -> PNAD survey sample weight. 
	*________________________________________________________________________________________________________________________________*
		
	
		*A*
		*----------------------------------------------------------------------------------------------------------------------------*		
		**
		**
		**Program to perform the sample exclusions as suggested by Bargain/Boutin
		*----------------------------------------------------------------------------------------------------------------------------*		
			cap program drop bargain_sample
			program define   bargain_sample
			
				**Son/daughter of the head of the household
				keep if hh_member ==  3											//the authors work with 14-year-olds that are son/daughter of the head of the household
				
				*Date of birth
				gen 	ppb	=	(no_dateofbirth	==	1)
				bys 	year	 hh_id: egen spb=sum(ppb)
				drop 	if  spb > 0
				drop 	spb ppb			
				keep 	if no_dateofbirth == 0
				
				**Age of the head of the household
				drop 	if hh_head_age_bargain < 18 | hh_head_age_bargain > 60 //if we do not apply this restriction, the results are significant even considering only household members son/daughter of the head of the household. 
			end 
			
			**
			*Decrease in sample size due to the exclusions suggested by Bargain/Boutin
			use "$final/child-labor-ban-brazil.dta" if year == 1999 & cohort1_12 == 1, clear
			count
			bargain_sample
			count
		
		*B*
		*----------------------------------------------------------------------------------------------------------------------------*		
		**
		**
		**Controls 
		*----------------------------------------------------------------------------------------------------------------------------*		
			**
			**Controls suggested by Bargain/Boutin. The authors include: region, urban areas, age, gender and education of the head of
			**the household, adults income, household size, children's color of the skin. 
			**As we explained in our do file 3. Setting up Paper Data, some variables were harmonized differently by us and Bargain and Boutin
				*Global $bargain_controls				-> Control variables used in Bargain/Boutin (their harmonization). 
				*Global $bargain_controls_our_def 		-> Same control variables used by Bargain/Boutin but using our harmonization for skin color, education, age, household income.
			
			**
			*Controls used by Piza/Portela 2017 -> mother's years of schooling
			
			/*
			**
			*Lasso controls
				use "$final/child-labor-ban-brazil.dta" if year == 1999, clear
					
					*=======================================*
					*YOU NEED STATA 16 + to run LASSO
					*=======================================*
						**
						**Child Labor
						lasso linear employ_bargain  i.region i.color c.adults_income##c.adults_income urban c.hh_size##c.hh_size male c.mom_yrs_school##c.mom_yrs_school if cohort84_9 == 1							global lasso_employ  `e(allvars_sel)'	
							global lasso_pwork   `e(allvars_sel)'
							
						**
						**Paid work
						lasso linear pwork			 i.region i.color c.adults_income##c.adults_income urban c.hh_size##c.hh_size male c.mom_yrs_school##c.mom_yrs_school if cohort84_9 == 1							global lasso_employ  `e(allvars_sel)'	
							global lasso_pwork   `e(allvars_sel)'
						
						
						**
						*In case you do not have lasso, these are the variables selected
						global lasso_employ 1bn.region 3bn.region 5bn.region 6bn.color 8bn.color adults_income urban hh_size male mom_yrs_school c.mom_yrs_school#c.mom_yrs_school
						global lasso_pwork  1bn.region 2bn.region 4bn.region 5bn.region 0bn.color 4bn.color 6bn.color 8bn.color adults_income c.adults_income#c.adults_income urban hh_size male mom_yrs_school
			 */	
						
					
		*C*
		*----------------------------------------------------------------------------------------------------------------------------*		
		**
		**
		**Table 1, online appendix
		*----------------------------------------------------------------------------------------------------------------------------*		
		estimates clear	
			
			foreach table in 1 {												//1: Control variables used by Bargain/Boutin but using our harmonization for skin color, education, age, household income. 
																				//2: Control variables used in Bargain/Boutin (their harmonization).
																				//3: Control variable: mother's years of schooling
																				//4: Lasso selected controls
				//Controls															
				if `table' == 1 								local controls $bargain_controls_our_def
				if `table' == 2 								local controls $bargain_controls
				if `table' == 3 								local controls mom_yrs_school
				if `table' == 4 								local controls i.region
			   *if `table' == 4 & "`variable'" == "employ" 		local controls $lasso_employ
			   *if `table' == 4 & "`variable'" == "pwork"  		local controls $lasso_pwork
			   
			   
				foreach bandwidth in 6 9 {											
				
					foreach variable in employ_bargain eap pwork {						//% of children's working and % of children in paid jobs
					
						if "`variable'" == "employ_bargain" & `bandwidth'  == 6  	 local title = "Economically Active Children, Child Labor definition according to Bargain and Boutin, 6-month bandwidth"
						if "`variable'" == "employ_bargain" & `bandwidth'  == 9  	 local title = "Economically Active Children, Child Labor definition according to Bargain and Boutin, 9-month bandwidth"
						if "`variable'" == "eap" 			& `bandwidth'  == 6  	 local title = "Economically Active Children, IBGE definition, 6-month bandwidth"
						if "`variable'" == "eap"			& `bandwidth'  == 9  	 local title = "Economically Active Children, IBGE definition, 9-month bandwidth"
						if "`variable'" == "pwork" 			& `bandwidth'  == 6  	 local title = "Paid work, 6-month bandwidth"	
						if "`variable'" == "pwork" 			& `bandwidth'  == 9  	 local title = "Paid work, 9-month bandwidth"	
							
						foreach sample in 1 2 3 4 {								//1 -> applying Bargain/Boutin sample exclusions. 2 -> Not applying exclusions suggested by Bargain/Boutin. 
									
							if `sample' == 1 | `sample' == 3 use "$final/child-labor-ban-brazil.dta" if  year  == 1999				   & cohort1_12 == 1, clear
							if `sample' == 2 | `sample' == 4 use "$final/child-labor-ban-brazil.dta" if (year  == 1999 | year == 2001) & cohort1_12 == 1, clear
							
							replace `variable' = `variable'*100		
									
							if `sample' == 1 | `sample' == 2 bargain_sample 					//running the exclusions suggested by Bargain/Boutin
													
								reg `variable' zw1 `controls' D1 i.year [aw = weight] if cohort1_`bandwidth' == 1							, cluster(zw1)			//boys/girls, rural/urban
								eststo, title("All")
											
								reg `variable' zw1 `controls' D1 i.year [aw = weight] if cohort1_`bandwidth' == 1 & urban == 1		 	  	, cluster(zw1)			//boys/girls, urban
								eststo, title("Urban")
											
								reg `variable' zw1 `controls' D1 i.year [aw = weight] if cohort1_`bandwidth' == 1 & urban == 1 & male == 1 	, cluster(zw1)			//boys, urban
								eststo, title("Boys, urban")
						}
						
						
						if "`variable'" == "employ_bargain" & `bandwidth' == 6 {
						estout * using "$tables/online_appendix_table`table'.xls",  keep(D*)  title("`title'") label mgroups("1999" "Pooling 1999 and 2001" "1999" "Pooling 1999 and 2001", pattern(1 0 0 1 0 0 1 0 0 1 0 0)) cells(b(star fmt(2)) se(par(`"="("' `")""') fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N, labels("Obs") fmt(%9.0g %9.3f %9.3f)) replace
						}
						else{
						estout * using "$tables/online_appendix_table`table'.xls",  keep(D*)  title("`title'") label mgroups("1999" "Pooling 1999 and 2001" "1999" "Pooling 1999 and 2001", pattern(1 0 0 1 0 0 1 0 0 1 0 0)) cells(b(star fmt(2)) se(par(`"="("' `")""') fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N, labels("Obs") fmt(%9.0g %9.3f %9.3f)) append
						}
						estimates clear
					}
				}
			}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		*----------------------------------------------------------------------------------------------------------------------------*		
		**
		**
		**Testing adding gender as control
		*----------------------------------------------------------------------------------------------------------------------------*		
				/*
				use "$final/child-labor-ban-brazil.dta" if year  == 1999, clear
				
				**
				**Adding the children's gender does not change the results 
				*preserve
				quiet bargain_sample
				reg employ_bargain gap84 $bargain_controls        D 		[aw = weight_bargain] if cohort84_3 == 1, cluster(cluster_bargain)		//reproducing main result of Table 1 of Bargain/Boutin Paper
				reg employ_bargain gap84 $bargain_controls i.male D  		[aw = weight_bargain] if cohort84_3 == 1, cluster(cluster_bargain)		//checking if adding the gender dummy changes the result
				restore
				*/
			
		
		*----------------------------------------------------------------------------------------------------------------------------*		
		**
		**
		**Using Bargain/Boutin dta file available in their replication package to reproduce the main result of the Table 1
		*----------------------------------------------------------------------------------------------------------------------------*		
			/*
			**
			**We downloaded Bargain/Boutin data for replication "lhz047_supplemental_files". The files .dta are saved inside the folder data_for_replication
			
			**
			**Path of the replication package: 
				global bargaindata "C:\Users\wb495845\OneDrive - WBG\III. Labor\child-labor-ban-brazil\Documentation\Literature\Bargain, Boutin\lhz047_supplemental_files\data_for_replication"

			use "$bargaindata/PNAD_same_cohort.dta" if year == 1999, clear
			
				**
				**Descriptive statistics
				su k_d_p  if cohort84_3 == 1 	//% childrem working in paid jobs
				su employ if cohort84_3 == 1	//% childrem working 
			
				**
				**Variables defined in their estimation do file
				egen 	hhinc = rowtotal(m_inc f_inc)
				tab  	region, gen(reg)
				tab  	ethnie, gen(eth) 
				gen 	treat = (gap >= 1)
				gen 	weightdd	=	peso_pes
				bys 	year: egen sweight	=	mean(peso_pes)
				gen 	weight	=	peso_pes/sweight
				drop 	sweight
				
				**
				*3-month-bandwidth, cluster
				keep 	if cohort84_3 == 1
				rename 	cohort84_3 maincohort
				gen 	gapmonth	=	round((gap/365)*12) 										//standard errors clustered at the level of variability of age, i.e. cohort x day of birth (default)
				egen 	clust1		=	group(gapmonth)
						
				**
				**Controls
				local 	control "reg1 reg2 reg3 reg4 eth2 eth5 head_edu head_moth head_age hhinc rural hhsize " 

				**
				**Regressions
				eststo: reg k_d    gap `control' treat [aw=weight] , cluster(clust1)				//we get the numbers. GOOD
				eststo: reg k_d_p  gap `control' treat [aw=weight] , cluster(clust1)		
				
				
				
				
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
