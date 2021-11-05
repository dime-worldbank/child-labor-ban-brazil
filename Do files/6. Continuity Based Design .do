		
		

															 *CONTINUITY BASED APPROACH*
	*____________________________________________________________________________________________________________________________________*

	**
	*Table A7 and A8
	*____________________________________________________________________________________________________________________________________*
		
		foreach year in 1998 1999 {										//1: Control variables used in Bargain/Boutin (their harmonization). 

			use "$final/child-labor-ban-brazil.dta" if year  == `year', clear
					
				estimates clear
				
					foreach variable in eap pwork uwork pwork_formal pwork_informal schoolatt pwork_only study_only nemnem {

						if "`variable'" == "eap"     		local title = "Economically Active Children"
						if "`variable'" == "pwork"			local title = "Paid work"
						if "`variable'" == "uwork"   		local title = "Unpaid work"
						if "`variable'" == "pwork_formal" 	local title = "Formal paid work"	
						if "`variable'" == "pwork_informal" local title = "Informal paid work"	
						if "`variable'" == "schoolatt" 		local title = "School attendance"	
						if "`variable'" == "pwork_only " 	local title = "Only paid work"	
						if "`variable'" == "study_only" 	local title = "Only attending school"	
						if "`variable'" == "nemnem" 		local title = "Neither working nor studying"	
							
							
							foreach sample in 1 2 {								//1 -> All 2 -> Urban boys
									
								if sample == 1 use "$final/child-labor-ban-brazil.dta" 							, clear
								if sample == 2 use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1, clear
										
									foreach bandwidth in 3 6 9 {							//bandwidths
										reg `variable' zw  mom_yrs_school D [aw = weight] if cohort84_`bandwidth' == 1 , cluster(zw)			//boys, urban
										eststo, title("`bandwidth'-month")
									}
							}
							
							if `year' == 1999 {
								if "`variable'" == "eap" {
								estout * using "$tables/online_appendix_tableA7.xls",  keep(D*)  title("`title'") label mgroups("All" "Urban Boys", pattern(1 0 0 1 0 0)) cells(b(star fmt(4)) se(fmt(4))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2, labels("Obs" "R2") fmt(%9.0g %9.3f %9.3f)) replace
								}
								else{
								estout * using "$tables/online_appendix_tableA7.xls",  keep(D*)  title("`title'") label mgroups("All" "Urban Boys", pattern(1 0 0 1 0 0)) cells(b(star fmt(4)) se(fmt(4))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2, labels("Obs" "R2") fmt(%9.0g %9.3f %9.3f)) append
								}
							}
							if `year' == 1998 {
								if "`variable'" == "eap" {
								estout * using "$tables/online_appendix_tableA8.xls",  keep(D*)  title("`title'") label mgroups("All" "Urban Boys", pattern(1 0 0 1 0 0)) cells(b(star fmt(4)) se(fmt(4))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2, labels("Obs" "R2") fmt(%9.0g %9.3f %9.3f)) replace
								}
								else{
								estout * using "$tables/online_appendix_tableA8.xls",  keep(D*)  title("`title'") label mgroups("All" "Urban Boys", pattern(1 0 0 1 0 0)) cells(b(star fmt(4)) se(fmt(4))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2, labels("Obs" "R2") fmt(%9.0g %9.3f %9.3f)) append
								}
							}								
			}
			
			
			
	**
	*Table A9
	*____________________________________________________________________________________________________________________________________*
				
				
				rdrobust pwork xw if xw>-52 & xw<=52 & urban==1 & male==1, all level(90) p(0) covs(motheduc)

				
