
	*Globals*
	*________________________________________________________________________________________________________________________________*

		global shortterm_outcomes  "eap pwork uwork schoolatt lnwage_hour"												//short-term outcomes
		global longterm_outcomes   "highschool_degree working formal lnwage_hour"										//long-term outcomes
		global dep_vars1 			D zw zwD	  																		//linear model
		global dep_vars2 			D zw zwD zw2  																		//quadratic model
		global dep_vars3 			D 																					//without including the running variable, just the treatment dummy
		global covariates 			per_capita_inc mom_yrs_school yrs_school hh_size									//covariates Piza/Portela used for balance tests
		global bargain_controls 	hh_head_age i.hh_head_male hh_head_school hh_size i.region i.urban adults_income	//dependent variables used in the paper of Bargain/Boutin  
														
		
