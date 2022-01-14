
															 *CONTINUITY BASED APPROACH*
	*____________________________________________________________________________________________________________________________________*
	**
	*Tables A7-A12
	*____________________________________________________________________________________________________________________________________*
		estimates clear
		
		local table = 7
			
		**
		foreach variable in eap pwork uwork pwork_informal study_only pwork_formal { 						//pwork_only study_only nemnem
		
			
			**
			if "`variable'" == "eap"     		local title = "Economically Active Children"
			if "`variable'" == "pwork"			local title = "Paid work"
			if "`variable'" == "uwork"   		local title = "Unpaid work"
			if "`variable'" == "pwork_formal" 	local title = "Formal paid work"	
			if "`variable'" == "pwork_informal" local title = "Informal paid work"	
			if "`variable'" == "schoolatt" 		local title = "School attendance"	
			if "`variable'" == "pwork_only" 	local title = "Only paid work"	
			if "`variable'" == "study_only" 	local title = "Only attending school"	
			if "`variable'" == "nemnem" 		local title = "Neither working nor studying"	
			
			
			**
			*Regs   ----------------------------------->>
			foreach sample 		in 1 2 {																	//sample  1 -> All, sample 2   -> Urban boys
			
				**
				foreach example in 1 2 {																	//example 1 -> 1999, example 2 -> 1999 & 2001
				
					**
					if `sample' == 1 & `example' == 1 {
					use "$final/child-labor-ban-brazil.dta" if						    (year  == 1999			     ) & cohort1_12, clear	//all
					local title = "Boys and girls, urban and rural (1999)"
					}
					
					if `sample' == 2 & `example' == 1 {
					use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & (year  == 1999			     ) & cohort1_12, clear	//boys, urban
					local title = "Boys urban (1999)"
					}
					
					**
					if `sample' == 1 & `example' == 2 {
					use "$final/child-labor-ban-brazil.dta" if						    (year  == 1999 | year == 2001) & cohort1_12, clear	//all
					local title = "Boys and girls, urban and rural (Pooled 1999 and 2001)"
					}
					
					if `sample' == 2 & `example' == 2 {
					use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & (year  == 1999 | year == 2001) & cohort1_12, clear	//boys, urban					
					local title = "Boys urban (Pooled 1999 and 2001)"
					}
				
					replace `variable' = `variable'*100
						foreach bandwidth in 4 6 8 9 {			//bandwidths
							reg `variable' zw1 		  	 			$bargain_controls_our_def  D1 i.year [aw = weight] if cohort1_`bandwidth' == 1 , cluster(zw1)	
							eststo, title("Linear")
							reg `variable' zw1 zw12	  				$bargain_controls_our_def  D1 i.year [aw = weight] if cohort1_`bandwidth' == 1 , cluster(zw1)	
							eststo, title("Quadratic")
							reg `variable' zw1 zw1D1  		   		$bargain_controls_our_def  D1 i.year [aw = weight] if cohort1_`bandwidth' == 1 , cluster(zw1)	
							eststo, title("Piecewise")
						}
						
					**
					*Tables ----------------------------------->>
					if  `example' == 1 & `sample' == 1	{
							estout * using "$tables/TableA`table'.xls",  keep(D1)  title("`title'") label mgroups("4-month bandwidth" "6-month bandwidth" "8-month bandwidth" "9-month bandwidth",  pattern(1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0)) cells(b(star fmt(2)) se(par(`"="("' `")""')  fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N, labels("Obs") fmt(%9.0g %9.3f %9.3f)) replace
						}
						else 							{
							estout * using "$tables/TableA`table'.xls",  keep(D1)  title("`title'") label mgroups("4-month bandwidth" "6-month bandwidth" "8-month bandwidth" "9-month bandwidth",  pattern(1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0)) cells(b(star fmt(2)) se(par(`"="("' `")""')  fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N, labels("Obs") fmt(%9.0g %9.3f %9.3f)) append
						}
					estimates clear	
				} 	//examples
			} 		//sample 
			local table = `table' + 1
			} //variables
			
