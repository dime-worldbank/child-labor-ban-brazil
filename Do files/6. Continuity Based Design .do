
															 *CONTINUITY BASED APPROACH*
	
	
	*____________________________________________________________________________________________________________________________________*
	**
	*Continuity Based Design
	*____________________________________________________________________________________________________________________________________*
	**

	
	*____________________________________________________________________________________________________________________________________*
	**
	**
	*Tables 1 and Table A5
	**
	*____________________________________________________________________________________________________________________________________*
	{
	estimates clear
	clear
			**
			*Regs   ----------------------------------->>
				
				**
				foreach example in -1 0 1 2 {																	//example 1 -> 1999, example 2 -> 1999 & 2001
				
					if `example' == -1 use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort2_12 == 1 & (year  == 1998			      ), clear	//boys, urban, same age 
					if `example' == 0  use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1 & (year  == 1998			      ), clear	//boys, urban, same cohort
					if `example' == 1  use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1 & (year  == 1999			      ), clear	//boys, urban, 1999
					if `example' == 2  use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1 & (year  == 1999 | year == 2001), clear	//boys, urban, pooling 1999 & 2011					
					
					if `example' == - 1 local cohort = 2 //cpohort of those born in 83
					if `example' !=  -1 local cohort = 1 //same cohort of those born in 84
					
					**
					foreach variable in eap pwork uwork pwork_formal pwork_informal schoolatt pwork_only study_only nemnem {
					replace `variable' = `variable'*100
						
						**
						if "`variable'" == "eap"   		 	& `example' == -1		local title = "Economically active (1998, same age)"
						if "`variable'" == "eap"   		 	& `example' == 0 		local title = "Economically active(1998, same cohort)"
						if "`variable'" == "eap"   		 	& `example' == 1 		local title = "Economically active (1999)"
						if "`variable'" == "eap"    		& `example' == 2 		local title = "Economically active (Pooled 1999 and 2001)"
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
						if "`variable'" == "uwork"			& `example' == -1		local title = "Unpaid work (1998, same age)"
						if "`variable'" == "uwork"			& `example' == 0		local title = "Unpaid work (1998, same cohort)"
						if "`variable'" == "uwork"			& `example' == 1		local title = "Unpaid work (1999)"
						if "`variable'" == "uwork"			& `example' == 2		local title = "Unpaid work (Pooled 1999 and 2001)"
						if "`variable'" == "pwork_formal"	& `example' == -1		local title = "Formal paid work (1998, same age)"
						if "`variable'" == "pwork_formal"	& `example' == 0		local title = "Formal paid work (1998, same cohort)"
						if "`variable'" == "pwork_formal"	& `example' == 1		local title = "Formal paid work (1999)"
						if "`variable'" == "pwork_formal"	& `example' == 2		local title = "Formal paid work (Pooled 1999 and 2001)"
						if "`variable'" == "schoolatt"		& `example' == -1		local title = "Attending school (1998, same age)"
						if "`variable'" == "schoolatt"		& `example' == 0		local title = "Attending school (1998, same cohort)"
						if "`variable'" == "schoolatt"		& `example' == 1		local title = "Attending school (1999)"
						if "`variable'" == "schoolatt"		& `example' == 2		local title = "Attending school (Pooled 1999 and 2001)"
						if "`variable'" == "pwork_only"		& `example' == -1		local title = "Only paid work (1998, same age)"
						if "`variable'" == "pwork_only"		& `example' == 0		local title = "Only paid work (1998, same cohort)"
						if "`variable'" == "pwork_only"		& `example' == 1		local title = "Only paid work (1999)"
						if "`variable'" == "pwork_only"		& `example' == 2		local title = "Only paid work (Pooled 1999 and 2001)"
						if "`variable'" == "nemnem"			& `example' == -1		local title = "Neither working nor studying (1998, same age)"
						if "`variable'" == "nemnem"			& `example' == 0		local title = "Neither working nor studying (1998, same cohort)"
						if "`variable'" == "nemnem"			& `example' == 1		local title = "Neither working nor studying (1999)"
						if "`variable'" == "nemnem"			& `example' == 2		local title = "Neither working nor studying (Pooled 1999 and 2001)"
																			
					
						foreach bandwidth in 4 6 9 {			//bandwidths
							reg `variable' zw`cohort' 		  	 				 $bargain_controls_our_def D`cohort' i.year [aw = weight] if cohort`cohort'_`bandwidth' == 1 , cluster(zw`cohort')	
							eststo, title("Linear")
							reg `variable' zw`cohort'  zw`cohort'2	  			 $bargain_controls_our_def D`cohort' i.year [aw = weight] if cohort`cohort'_`bandwidth' == 1 , cluster(zw`cohort')	
							eststo, title("Quadratic") 
							reg `variable' zw`cohort'  zw`cohort'D`cohort'       $bargain_controls_our_def D`cohort' i.year [aw = weight] if cohort`cohort'_`bandwidth' == 1 , cluster(zw`cohort')	
							eststo, title("Sliptwise")
						}
						
						
						
						
						**
						*Tables ----------------------------------->>
						if  	  `example' == -1  & "`variable'" == "eap" { //ROBSTUNESS, SAME AGE, SAME COHORT
								estout * using "$tables\TableA6.xls",  keep(D`cohort')  title("`title'") label mgroups("4-month bandwidth" "6-month bandwidth" "9-month bandwidth",  pattern(1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0)) stats() cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) replace
						}
						if  	 (`example' == - 1  & "`variable'" != "eap") | `example' == 0 {
								estout * using "$tables\TableA6.xls",  keep(D`cohort')  title("`title'") label mgroups("4-month bandwidth" "6-month bandwidth" "9-month bandwidth",  pattern(1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0)) stats() cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
						}
						
						**
						*Tables ----------------------------------->>
						if  	  `example' == 1  & "`variable'" == "eap" 					{
								estout * using "$tables\Table1.xls",  keep(D`cohort')  title("`title'") label mgroups("4-month bandwidth" "6-month bandwidth" "9-month bandwidth",  pattern(1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0)) stats() cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) replace
						}
						if  	 (`example' == 1  & "`variable'" != "eap") | `example' == 2 {
								estout * using "$tables\Table1.xls",  keep(D`cohort')  title("`title'") label mgroups("4-month bandwidth" "6-month bandwidth" "9-month bandwidth",  pattern(1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0)) stats() cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
						}							
						estimates clear	
					} 	//examples
				} //variables
	}
	
	
	
	
	*____________________________________________________________________________________________________________________________________*
	**
	**
	*Table A5
	**
	*____________________________________________________________________________________________________________________________________*
	{
	estimates clear
	clear
			**
			*Regs   ----------------------------------->>
				
				**	
				**
				foreach year in 1 2 {
					
					foreach variable in eap pwork uwork pwork_formal pwork_informal schoolatt pwork_only study_only nemnem {
						
						foreach sample in 1 2 3 4 {
							
							if `sample' == 1 use "$final/child-labor-ban-brazil.dta" if cohort1_12 == 1 & (year  == 1999 | year == 2001), clear
							
							if `sample' == 2 use "$final/child-labor-ban-brazil.dta" if cohort1_12 == 1 & (year  == 1999 | year == 2001) & male == 1 & urban == 1, clear	
							
							if `sample' == 3 use "$final/child-labor-ban-brazil.dta" if cohort1_12 == 1 & (year  == 1999 | year == 2001) & male == 0 & urban == 1, clear						
							
							if `sample' == 4 use "$final/child-labor-ban-brazil.dta" if cohort1_12 == 1 & (year  == 1999 | year == 2001) &			   urban == 0, clear
							
							if `year'   == 1 keep if year == 1999
						
							replace `variable' = `variable'*100
						
							**
							if "`variable'" == "eap"    		local title = "Economically active"
							if "`variable'" == "pwork"			local title = "Paid work"
							if "`variable'" == "pwork_informal"	local title = "Informal paid work"
							if "`variable'" == "study_only"		local title = "Only attending school"
							if "`variable'" == "uwork"			local title = "Unpaid work"
							if "`variable'" == "pwork_formal"	local title = "Formal paid work"
							if "`variable'" == "schoolatt"		local title = "Attending school "
							if "`variable'" == "pwork_only"		local title = "Only paid work"
							if "`variable'" == "nemnem"			local title = "Neither working nor studying"
																			
										
							foreach bandwidth in 6 9 {			//bandwidths
								reg `variable' zw1 		  	 				 $bargain_controls_our_def D1 i.year [aw = weight] if cohort1_`bandwidth' == 1 , cluster(zw1)	
								eststo, title("`bandwidth'")
							}
						}
						
						**
						*Tables ----------------------------------->>
						if  	 "`variable'" == "eap" & `year' == 1		 			{
								estout * using "$tables\TableA5.xls",  keep(D1)  title("`title'") label mgroups("Boys, Girls, rural and urban" "Boys, urban" "Girls, urban" "Boys, Girls, rural",  pattern(1 0 1 0 1 0 1 0 1 0)) stats() cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) replace
						}
						if  	("`variable'" != "eap" & `year' == 1) | `year' == 2		{
								estout * using "$tables\TableA5.xls",  keep(D1)  title("`title'") label mgroups("Boys, Girls, rural and urban" "Boys, urban" "Girls, urban" "Boys, Girls, rural",  pattern(1 0 1 0 1 0 1 0 1 0)) stats() cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
						}							
						estimates clear	
					} 	//examples
				}
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	/*
	*____________________________________________________________________________________________________________________________________*
	**
	**
	*Tables A7-A11
	**
	*____________________________________________________________________________________________________________________________________*
	{
		estimates clear
		
		local table = 7
			
		**
		foreach variable in eap pwork uwork pwork_informal study_only { 						//pwork_only study_only nemnem
		
			
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
							reg `variable' zw1 		  	 			$bargain_controls_our_def    D1 i.year [aw = weight] if cohort1_`bandwidth' == 1 , cluster(zw1)	
							eststo, title("Linear")
							reg `variable' zw1 zw12	  				$bargain_controls_our_def    D1 i.year [aw = weight] if cohort1_`bandwidth' == 1 , cluster(zw1)	
							eststo, title("Quadratic")
							reg `variable' zw1 zw1D1  		   		$bargain_controls_our_def    D1 i.year [aw = weight] if cohort1_`bandwidth' == 1 , cluster(zw1)	
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
	}		
