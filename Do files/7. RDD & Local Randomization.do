
													*CONTINUITY BASED DESIGN & LOCAL RANDOMIZATION*
	*____________________________________________________________________________________________________________________________________*


	**=================================================================>>
	**======================================================>>
	**
	*SAMPLE:
		* ALL 14 YEAR-OLDS MALES IN URBAN AREAS
 	**
		
		estimates clear
		clear
	*____________________________________________________________________________________________________________________________________*
	**
	*Continuity Based Design
	*____________________________________________________________________________________________________________________________________*
	**

			**
			*Regs   ----------------------------------->>
				
				**
				foreach example in -1 0 1 2 {																	//example 1 -> 1999, example 2 -> 1999 & 2001
				
					if `example' == -1 use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort2_12 == 1 & (year  == 1998			     ), clear	//boys, urban
					if `example' == 0  use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1 & (year  == 1998			     ), clear	//boys, urban
					if `example' == 1  use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1 & (year  == 1999			     ), clear	//boys, urban
					if `example' == 2  use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1 & (year  == 1999 | year == 2001), clear	//boys, urban					
					
					if `example' == - 1 local cohort = 2 //cpohort of those born in 83
					if `example' !=  -1 local cohort = 1 //same cohort of those born in 84
					
					**
					foreach variable in eap pwork pwork_informal study_only {
					replace `variable' = `variable'*100
						
						**
						if "`variable'" == "eap"   		 	& `example' == -1		local title = "Economically Active Children (1998, same age)"
						if "`variable'" == "eap"   		 	& `example' == 0 		local title = "Economically Active Children (1998, same cohort)"
						if "`variable'" == "eap"   		 	& `example' == 1 		local title = "Economically Active Children (1999)"
						if "`variable'" == "eap"    		& `example' == 2 		local title = "Economically Active Children (Pooled 1999 and 2001)"
						if "`variable'" == "pwork"			& `example' == -1		local title = "Paid work (1998, same age)"
						if "`variable'" == "pwork"			& `example' == 0		local title = "Paid work (1998, same cohort)"
						if "`variable'" == "pwork"			& `example' == 1		local title = "Paid work (1999)"
						if "`variable'" == "pwork"			& `example' == 2		local title = "Paid work (Pooled 1999 and 2001)"
						if "`variable'" == "pwork_informal"	& `example' == -1		local title = "Informal paid work (1998, same age)"
						if "`variable'" == "pwork_informal"	& `example' == 0		local title = "Informal paid work (1998, same cohort)"
						if "`variable'" == "pwork_informal"	& `example' == 1		local title = "Informal paid work (1999)"
						if "`variable'" == "pwork_informal"	& `example' == 2		local title = "Informal paid work (Pooled 1999 and 2001)"
						if "`variable'" == "study_only"		& `example' == -1		local title = "Only attending school (1998, same age)"
						if "`variable'" == "study_only"		& `example' == 0		local title = "Only attending school (1998, same cohort)"
						if "`variable'" == "study_only"		& `example' == 1		local title = "Only attending school (1999)"
						if "`variable'" == "study_only"		& `example' == 2		local title = "Only attending school (Pooled 1999 and 2001)"
						
					
						foreach bandwidth in 4 6 9 {			//bandwidths
							reg `variable' zw`cohort' 		  	 				$bargain_controls_our_def  D`cohort' i.year [aw = weight] if cohort`cohort'_`bandwidth' == 1 , cluster(zw`cohort')	
							eststo, title("Linear")
							reg `variable' zw`cohort'  zw`cohort'2	  			$bargain_controls_our_def  D`cohort' i.year [aw = weight] if cohort`cohort'_`bandwidth' == 1 , cluster(zw`cohort')	
							eststo, title("Quadratic")
							reg `variable' zw`cohort'  zw`cohort'D`cohort'      $bargain_controls_our_def  D`cohort' i.year [aw = weight] if cohort`cohort'_`bandwidth' == 1 , cluster(zw`cohort')	
							eststo, title("Sliptwise")
						}
						
						**
						*Tables ----------------------------------->>
						if  	  `example' == -1  & "`variable'" == "eap" {
								estout * using "$tables\TableA6.xls",  keep(D`cohort')  title("`title'") label mgroups("4-month bandwidth" "6-month bandwidth" "9-month bandwidth",  pattern(1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0)) stats() cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) replace
						}
						if inlist(`example', -1,0) & "`variable'" != "eap" {
								estout * using "$tables\TableA6.xls",  keep(D`cohort')  title("`title'") label mgroups("4-month bandwidth" "6-month bandwidth" "9-month bandwidth",  pattern(1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0)) stats() cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
						}
						
						**
						*Tables ----------------------------------->>
						if  	  `example' == 1  & "`variable'" == "eap" {
								estout * using "$tables\Table1.xls",  keep(D`cohort')  title("`title'") label mgroups("4-month bandwidth" "6-month bandwidth" "9-month bandwidth",  pattern(1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0)) stats() cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) replace
						}
						if inlist(`example', 1,2) & "`variable'" != "eap" {
								estout * using "$tables\Table1.xls",  keep(D`cohort')  title("`title'") label mgroups("4-month bandwidth" "6-month bandwidth" "9-month bandwidth",  pattern(1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0)) stats() cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
						}							
						estimates clear	
					} 	//examples
				} //variables
	

	
	
	*____________________________________________________________________________________________________________________________________*
	**
	*Local Randomization
	*____________________________________________________________________________________________________________________________________*
	**
		use"$inter/Local Randomization Results_1999.dta", clear
		keep		dep_var year window ATE2- att_perc_mean2
		reshape 	wide ATE2-att_perc_mean2, i(dep_var year) j(window)

			
	
	
		/*
		
		use"$inter/Local Randomization Results_1999.dta" if inlist(dep_var, 1,2,5,6) , clear
		keep		dep_var window ATE2- att_perc_mean2
		expand 		2, gen(REP)
		sort 		dep_var window REP
		replace 	ATE2 			= CI2[_n-1] 			if REP == 1 & window[_n] == window[_n-1]
 		replace 	mean_outcome2 	= att_perc_mean2[_n-1] 	if REP == 1 & window[_n] == window[_n-1]
		drop 		CI2 att_perc_mean2 
		
		preserve
		keep		if REP == 0
		reshape 	wide ATE2 mean_outcome2, i(dep_var) j(window)
		tempfile 	results
		save 	   `results'
		restore
		
		keep 		if REP == 1
		reshape 	wide ATE2 mean_outcome2, i(dep_var) j(window)
		append  	using `results'
		
		sort 		dep_var REP
		drop 				REP
		export  	excel using "$tables\Table3.xls", replace firstrow(variables)
		
		
		
		
		
		
		
		
		
		

		
		
	/*
	*____________________________________________________________________________________________________________________________________*
	**
	*Difference in Differences using the same cohort in 1998 and 1999
	*____________________________________________________________________________________________________________________________________*
	**	

			**
			*Regs   ----------------------------------->>
	
				foreach example in 1 2 {																	//example 1 -> 1998 e 1999, example 2 -> 1998 & 1999 & 2001
				
					if `example' == 1 use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1 & (year  == 1999 | year == 1998				  ), clear	//boys, urban
					if `example' == 2 use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1 & (year  == 1999 | year == 2001 | year == 1998  ), clear	//boys, urban					
					
					gen after_treat = year > 1998
					gen D1T 		= D1*after_treat
					label var D1T "DiD same cohort"
					
					**
					foreach variable in eap pwork pwork_informal study_only  {
					replace `variable' = `variable'*100
						
						**
						if "`variable'" == "eap"   		 	& `example' == 1 		local title = "Economically Active Children (DiD same cohort 1998 and 1999)"
						if "`variable'" == "eap"    		& `example' == 2 		local title = "Economically Active Children (DiD same cohort 1998 and Pooled 1999 and 2001)"
						if "`variable'" == "pwork"			& `example' == 1		local title = "Paid work (DiD same cohort 1998 and 1999)"
						if "`variable'" == "pwork"			& `example' == 2		local title = "Paid work (DiD same cohort 1998 and Pooled 1999 and 2001)"
						if "`variable'" == "pwork_informal"	& `example' == 1		local title = "Informal paid work (DiD same cohort 1998 and 1999)"
						if "`variable'" == "pwork_informal"	& `example' == 2		local title = "Informal paid work (DiD same cohort 1998 and Pooled 1999 and 2001)"
						if "`variable'" == "study_only"		& `example' == 1		local title = "Only attending school (DiD same cohort 1998 and 1999)"
						if "`variable'" == "study_only"		& `example' == 2		local title = "Only attending school (DiD same cohort 1998 and Pooled 1999 and 2001)"

						foreach bandwidth in 4 6 9 {			//bandwidths
							reg `variable' zw1 		  	 			$covariates2  D1 D1T i.year [aw = weight] if cohort1_`bandwidth' == 1 , cluster(xw1)	
							eststo, title("Linear")
							reg `variable' zw1 zw12	  				$covariates2  D1 D1T i.year [aw = weight] if cohort1_`bandwidth' == 1 , cluster(xw1)	
							eststo, title("Quadratic")
							reg `variable' zw1 zw1D1  		   		$covariates2  D1 D1T i.year [aw = weight] if cohort1_`bandwidth' == 1 , cluster(xw1)	
							eststo, title("Piecewise")
						}
						
						**
						*Tables ----------------------------------->>
						if  `example' == 1 & "`variable'" == "eap" {
								estout * using "$tables\Table2.xls",  keep(D1T)  title("`title'") label mgroups("4-month bandwidth" "6-month bandwidth" "9-month bandwidth",  pattern(1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0)) stats() cells(b(star fmt(2)) se(par(`"="("' `")""') fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) replace
							}
							else 							       {
								estout * using "$tables\Table2.xls",  keep(D1T)  title("`title'") label mgroups("4-month bandwidth" "6-month bandwidth" "9-month bandwidth",  pattern(1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0)) stats() cells(b(star fmt(2)) se(par(`"="("' `")""') fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
							}
						estimates clear	
					} 	//examples
				} //variables
