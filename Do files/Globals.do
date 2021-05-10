
	*Globals*
	*________________________________________________________________________________________________________________________________*

		global shortterm_outcomes  		"eap pwork uwork schoolatt lnwage_hour"												//short-term outcomes
		global longterm_outcomes   		"highschool_degree working formal lnwage_hour"										//long-term outcomes
		global dep_vars1 				D zw 	  																			//linear model
		global dep_vars2 				D zw zw2  																			//quadratic model
		global dep_vars3 				D 																					//without including the running variable, just the treatment dummy
		global covariates 				per_capita_inc mom_yrs_school yrs_school hh_size									//covariates Piza/Portela used for balance tests											
		global bargain_controls			region1 region2 region3 region4 color_bargain2 color_bargain5 hh_head_edu_bargain hh_head_male hh_head_age_bargain adults_income_bargain urban hh_size_bargain
		global bargain_controls_our_def region1 region2 region3 region4 white		   pardo		  hh_head_edu 		  hh_head_male hh_head_age		   adults_income		 urban hh_size
