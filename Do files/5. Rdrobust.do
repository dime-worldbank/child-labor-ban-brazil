	
	
																	*RD ROBUST*
	*____________________________________________________________________________________________________________________________________*
		
					
	**
	*Table 1
	*-----------------------------------------------------------------------------------------------------------------------------------*
	{		
		set more off
		estimates clear
		foreach groupvar in 1 2 3 { //
								
				use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1 & year  == 1999, clear	//boys, urban, 1999ta
				if `groupvar' == 1  local varlist = "eap 				pwork 		"
				if `groupvar' == 2  local varlist = "pwork_formal       pwork_informal 	"
				if `groupvar' == 3  local varlist = "schoolatt 			study_only"
				
				foreach variable of local varlist 		{
					replace `variable' = `variable'*100 
						foreach bandwidth in 14 26 39	{ 
							eststo reg`bandwidth'`dep_var', title("`bandwidth' weeks"): rdrobust `variable' zw1, h(`bandwidth') c(0) p(1)  vce(cluster zw1) all kernel(uniform)
							scalar Obs =  e(N_h_l) + e(N_h_r)
							estadd scalar Obs     = Obs: reg`bandwidth'`dep_var'
						}
						local dep_var = `dep_var' + 1
				}
				
				if `groupvar' == 1 estout * using "$tables\Table1.xls" ,  keep(Conventional)   label  mgroups("Economically active" 	"Paid work" 				,  pattern(1 0 0 1 0 0))  stats(Obs)  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) replace
				if `groupvar' == 2 estout * using "$tables\Table1.xls" ,  keep(Conventional)   label  mgroups("Formal paid work"        "Informal paid work" 		,  pattern(1 0 0 1 0 0))  stats(Obs)  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
				if `groupvar' == 3 estout * using "$tables\Table1.xls" ,  keep(Conventional)   label  mgroups("Attending school" 	    "Only attending school"	    ,  pattern(1 0 0 1 0 0))  stats(Obs)  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
				estimates clear
			}
	}
	
	
	use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1 & year  == 1999, clear	//boys, urban, 1999ta
    rdbwselect pwork zw1 , c(0)  p(1) kernel(uniform) vce(cluster zw1) 
