
	*Globals
	*________________________________________________________________________________________________________________________________*


	global shortterm_outcomes  "pwork pwork_formal pwork_informal uwork schoolatt pwork_sch uwork_sch pwork_only uwork_only study_only nemnem lnwage_hour"
	global longterm_outcomes   "yrs_school highschool_degree college_degree working formal lnwage_hour"
	global dep_vars1 			D zw 	 	   mom_yrs_school
	global dep_vars2 			D zw zw2 	   mom_yrs_school
	global dep_vars3 			D zw 	 zwD   mom_yrs_school
	global covariates1 			per_capita_inc mom_yrs_school yrs_school hh_members 
	global covariates2 			per_capita_inc 				  yrs_school hh_members 
