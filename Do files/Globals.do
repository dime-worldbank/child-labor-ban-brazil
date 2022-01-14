
	*Globals*
	*________________________________________________________________________________________________________________________________*

		global shortterm_outcomes  		"eap pwork pwork_informal schoolatt study_only lnwage_hour"								//short-term outcomes
		global longterm_outcomes   		"lowersec_degree working pwork_formal lnwage_hour"										//long-term outcomes
		global dep_vars1 				D gap84 	  																			//linear model
		global dep_vars2 				D gap84 gap84_2																			//quadratic model
		global dep_vars3 				D 																						//without including the running variable, just the treatment dummy
		
		global covariates1 				hh_spouse_edu																	//covariates Piza/Portela used for balance tests						
		
		global bargain_controls			region1 region2 region3 region4 		 color_bargain2 color_bargain5 hh_head_edu_bargain hh_head_male hh_head_age_bargain adults_income_bargain urban hh_size_bargain //Covariates used by Bargain/Boutin (2021) Paper
		global bargain_controls_our_def region1 region2 region3 region4 region5  white		    pardo		   hh_head_edu 		   hh_head_male hh_head_age		   		 				  urban hh_size         //Covariates used by Bargain/Boutin (2021) Paper
			
			
			//but using our variable definitions (Check do file '3. Setting up Paper Data' to see the main differences)
		*number of siblings older than 16 years ols. 
																																					

																																							