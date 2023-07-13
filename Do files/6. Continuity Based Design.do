

															 *CONTINUITY BASED APPROACH*

	*____________________________________________________________________________________________________________________________________*
	
	
	**
	*PROGRAM TO CALCULATE ADJUSTED P VALUES (you can include as many bandwidths as you want)
	*------------------------------------------------------------------------------------------------------------------------------------*
	cap program drop mht_inside_bandwidth  //multiple hypothesis test inside each bandwidth
	program define   mht_inside_bandwidth  //for each bandwidth, lets calculate the adjusted p-value for each one of the 6 outcomes. 
	syntax,  band_tested(string) cohort(integer) year(integer) 
	
	
		*CREATING THE MATRIX TO STORE THE Q-VALUES (Matrix y)
		*--------------------------------------------------------------------------------------------------------------------------------*
		{
			**
			*---------------------------------------------------->>
			local number_band_tested = 0
			foreach bandwidth in `band_tested' {							//band_test( 14 26 39) so 3 bandwidths, if it is (14 26 39 46) so 4 bandwidths. 
				local number_band_tested = `number_band_tested' + 1
			}
				
			**
			*---------------------------------------------------->>
			local nrows = `number_band_tested'*6							//number of rows that we need in the table. 
			matrix y = J(`nrows',2,.)										//matrix to save sharped p-values, column 1 code of the dependent var(outcome) 

					
			*Filling column 1 the code of the outcome 
			*---------------------------------------------------->>
			local jump = 0
			forvalues outcome = 1(1)6	 {	//
				forvalues row = 1(1)`number_band_tested' {	//lets put outcome 1 the number of times we have a bandwitdh associated with it. 
				mat y[`row'+ `jump',1] = `outcome'
				}
				local jump =  `jump' + `number_band_tested' 
			}
			
			*Filling column 2 with the bandwidths tested
			*---------------------------------------------------->>
			local row = 1
			local final = `nrows' -  `number_band_tested'
			forvalues jump = 0(`number_band_tested')`final' {
				local row = 1 + `jump'
				foreach bandwidth in `band_tested'			{
					mat y[`row',2] = `bandwidth'
					local row = `row' + 1 
				}
			}
		}
		clear
		svmat y
		sort  y2 y1
		mkmat y1 y2 , matrix(y)

		
		*REGRESSIONS
		*--------------------------------------------------------------------------------------------------------------------------------*
		{
		foreach bandwidth in `band_tested' {							//band_test( 14 26 39) so 3 bandwidths, if it is (14 26 39 46) so 4 bandwidths. 
			use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort`cohort'_12 == 1 & (year  == `year'), clear	//boys, urban, 1999
			
				rwolf2  (reg eap   			zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort'  if zw`cohort' >= -`bandwidth' & zw`cohort' <= `bandwidth' , cluster(zw`cohort'))   ///
						(reg pwork 			zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort'  if zw`cohort' >= -`bandwidth' & zw`cohort' <= `bandwidth' , cluster(zw`cohort'))   ///
						(reg pwork_formal 	zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort'  if zw`cohort' >= -`bandwidth' & zw`cohort' <= `bandwidth' , cluster(zw`cohort'))   ///
						(reg pwork_informal zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort'  if zw`cohort' >= -`bandwidth' & zw`cohort' <= `bandwidth' , cluster(zw`cohort'))   ///
						(reg schoolatt 		zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort'  if zw`cohort' >= -`bandwidth' & zw`cohort' <= `bandwidth' , cluster(zw`cohort'))   ///
						(reg study_only 	zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort'  if zw`cohort' >= -`bandwidth' & zw`cohort' <= `bandwidth' , cluster(zw`cohort')),  ///
				indepvars(D`cohort', D`cohort', D`cohort', D`cohort', D`cohort', D`cohort') reps(3000) seed(346446)
				matrix A`bandwidth' = e(RW)
				clear
				svmat   A`bandwidth'
				keep    A`bandwidth'1 A`bandwidth'3
				rename (A`bandwidth'1 A`bandwidth'3) (pvalue pwolf)
				save "$inter\mht_inside_`bandwidth'.dta", replace
			}
		}

		
		*DATASET WITH RESULTS
		*--------------------------------------------------------------------------------------------------------------------------------*
		{	
			clear
			foreach bandwidth in `band_tested' {							//band_test( 14 26 39) so 3 bandwidths, if it is (14 26 39 46) so 4 bandwidths. 
				append using 	"$inter\mht_inside_`bandwidth'.dta"
				erase 			"$inter\mht_inside_`bandwidth'.dta"
			}
			mkmat pvalue pwolf, matrix(A)
			matrix A = (A , y)
			clear
			svmat  A
			rename (A1-A4) (pvalue pwolf dep_var bandwidth)
			format p* %20.2fc
			save "$inter\mht_inside_bandwidth.dta", replace
		}	
	end
	
	
	
	**
	*PROGRAM TO CALCULATE ADJUSTED P VALUES (testing 18  hypothesis)
	*------------------------------------------------------------------------------------------------------------------------------------*
	cap program drop mht_18hypothesis 
	program define   mht_18hypothesis   
	syntax,  band_tested(string) cohort(integer) year(integer) 
	
	
		*CREATING THE MATRIX TO STORE THE Q-VALUES (Matrix y)
		*--------------------------------------------------------------------------------------------------------------------------------*
		{
			**
			*---------------------------------------------------->>
			matrix y = J(18,2,.)										//matrix to save sharped p-values, column 1 code of the dependent var(outcome) 

					
			*Filling column 1 the code of the outcome 
			*---------------------------------------------------->>
			local jump = 0
			forvalues outcome = 1(1)6	 {	//
				forvalues row = 1(1)3 {	
				mat y[`row'+ `jump',1] = `outcome'
				}
				local jump =  `jump' + 3
			}
			
			*Filling column 2 with the bandwidths tested
			*---------------------------------------------------->>
			local row = 1
			forvalues jump = 0(3)17 {
				local row = 1 + `jump'
				foreach bandwidth in `band_tested'			{
					mat y[`row',2] = `bandwidth'
					local row = `row' + 1 
				}
			}
		}
		clear
		svmat y
		sort  y2 y1
		mkmat y1 y2 , matrix(y)

		
		*REGRESSIONS
		*--------------------------------------------------------------------------------------------------------------------------------*
		{
			use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort`cohort'_12 == 1 & (year  == `year'), clear	//boys, urban, 1999
			local i = 1
			foreach bandwidth in `band_tested'{
				local band`i' = `bandwidth'
				local i = `i' + 1
			}
			rwolf2  (reg eap   			zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort'  if zw`cohort' >= -`band1' & zw`cohort' <= `band1' , cluster(zw`cohort'))   ///
					(reg pwork 			zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort'  if zw`cohort' >= -`band1' & zw`cohort' <= `band1' , cluster(zw`cohort'))   ///
					(reg pwork_formal 	zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort'  if zw`cohort' >= -`band1' & zw`cohort' <= `band1' , cluster(zw`cohort'))   ///
					(reg pwork_informal zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort'  if zw`cohort' >= -`band1' & zw`cohort' <= `band1' , cluster(zw`cohort'))   ///
					(reg schoolatt 		zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort'  if zw`cohort' >= -`band1' & zw`cohort' <= `band1' , cluster(zw`cohort'))   ///
					(reg study_only 	zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort'  if zw`cohort' >= -`band1' & zw`cohort' <= `band1' , cluster(zw`cohort'))   ///
					(reg eap   			zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort'  if zw`cohort' >= -`band2' & zw`cohort' <= `band2' , cluster(zw`cohort'))   ///
					(reg pwork 			zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort'  if zw`cohort' >= -`band2' & zw`cohort' <= `band2' , cluster(zw`cohort'))   ///
					(reg pwork_formal 	zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort'  if zw`cohort' >= -`band2' & zw`cohort' <= `band2' , cluster(zw`cohort'))   ///
					(reg pwork_informal zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort'  if zw`cohort' >= -`band2' & zw`cohort' <= `band2' , cluster(zw`cohort'))   ///
					(reg schoolatt 		zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort'  if zw`cohort' >= -`band2' & zw`cohort' <= `band2' , cluster(zw`cohort'))   ///
					(reg study_only 	zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort'  if zw`cohort' >= -`band2' & zw`cohort' <= `band2' , cluster(zw`cohort'))   ///			
					(reg eap   			zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort'  if zw`cohort' >= -`band3' & zw`cohort' <= `band3' , cluster(zw`cohort'))   ///
					(reg pwork 			zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort'  if zw`cohort' >= -`band3' & zw`cohort' <= `band3' , cluster(zw`cohort'))   ///
					(reg pwork_formal 	zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort'  if zw`cohort' >= -`band3' & zw`cohort' <= `band3' , cluster(zw`cohort'))   ///
					(reg pwork_informal zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort'  if zw`cohort' >= -`band3' & zw`cohort' <= `band3' , cluster(zw`cohort'))   ///
					(reg schoolatt 		zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort'  if zw`cohort' >= -`band3' & zw`cohort' <= `band3' , cluster(zw`cohort'))   ///
					(reg study_only 	zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort'  if zw`cohort' >= -`band3' & zw`cohort' <= `band3' , cluster(zw`cohort')) ,  ///		
			indepvars(D`cohort', D`cohort', D`cohort', D`cohort', D`cohort', D`cohort', D`cohort', D`cohort', D`cohort', D`cohort', D`cohort', D`cohort', D`cohort', D`cohort', D`cohort', D`cohort', D`cohort', D`cohort' ) reps(3000) seed(346446)	
			matrix A = e(RW)
			matrix A = (A , y)
			clear
			svmat  A
			rename (A1-A5) (pvalue psample pwolf dep_var bandwidth)
			format p* %20.2fc
			save  "$inter\mht_18hypothesis.dta", replace
		}
	end
	


	**
	*PROGRAM TO SAVE THE ADJUSTED P VALUE OF AN SPECIFIC MODEL
	*------------------------------------------------------------------------------------------------------------------------------------*
	cap program drop pwolf
	program define   pwolf
		syntax,  method(integer) bandwidth(integer) dep_var(integer)
		preserve
			if `method' == 1 use "$inter\mht_inside_bandwidth.dta", clear
			if `method' == 2 use "$inter\mht_18hypothesis.dta", clear
			keep if bandwidth == `bandwidth' & dep_var == `dep_var'
			su 		pwolf, detail
			scalar  	  pwolf`method'  = `r(mean)'
			estadd scalar pwolf`method'  = pwolf`method': reg`bandwidth'`dep_var'
		restore
	end
		
			
			
	*Tables A2, A3
	*-----------------------------------------------------------------------------------------------------------------------------------*
	{
		mht_inside_bandwidth, band_tested(14 26 28 30 32 34 36 38 39) cohort(1) year(1999) 				//as many bandwidths as you want
			
			use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1 & year == 1999, clear	//boys, urban, 1999ta
			estimates clear
			local dep_var = 1 //	 	
				foreach variable in eap pwork pwork_formal pwork_informal schoolatt study_only	{
					**
					if "`variable'" == "eap"    		local title = "Economically active"
					if "`variable'" == "pwork"			local title = "Paid work"
					if "`variable'" == "pwork_informal"	local title = "Informal paid work"
					if "`variable'" == "study_only"		local title = "Only attending school"
					if "`variable'" == "pwork_formal"	local title = "Formal paid work"
					if "`variable'" == "schoolatt"		local title = "Attending school "
					if "`variable'" == "pwork_only"		local title = "Only paid work"

					estimates clear
					replace `variable' = `variable'*100
						foreach bandwidth in 14 26 28 30 32 34 36 38 39		{ 
							eststo reg`bandwidth'`dep_var', title("`bandwidth' weeks"):reg `variable' zw1  zw1D1 D1 if zw1 >= - `bandwidth' & zw1 <= `bandwidth' , cluster(zw1)	
							pwolf, method(1) bandwidth(`bandwidth') dep_var(`dep_var')
						}
						local dep_var = `dep_var' + 1
					
					if "`variable'" == "eap" 							  estout * using "$tables\TableA2.xls",  keep(D1)   title("`title'") label  stats(pwolf1  N,  labels("Romano-Wolf" "Number of Cases"))  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) replace
					if inlist("`variable'", "pwork"		, "pwork_formal") estout * using "$tables\TableA2.xls",  keep(D1)   title("`title'") label  stats(pwolf1  N,  labels("Romano-Wolf" "Number of Cases"))  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
					
					if "`variable'" == "pwork_informal" 				  estout * using "$tables\TableA3.xls",  keep(D1)   title("`title'") label  stats(pwolf1  N,  labels("Romano-Wolf" "Number of Cases"))  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) replace
					if inlist("`variable'", "schoolatt"	, "study_only"  ) estout * using "$tables\TableA3.xls",  keep(D1)   title("`title'") label  stats(pwolf1  N,  labels("Romano-Wolf" "Number of Cases"))  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
				}
			 cap erase "$inter\mht_inside_bandwidth.dta"
		}

		
	*Table A4
	*-----------------------------------------------------------------------------------------------------------------------------------*
	{
	set more off
		estimates clear
		foreach groupvar in 1 2 3 4 5 6 { //
								
				if `groupvar' == 1 mht_inside_bandwidth, band_tested(14 26 39) cohort(1) year(1999) //as many bandwidths as you want
				if `groupvar' == 3 mht_inside_bandwidth, band_tested(14 26 39) cohort(2) year(1998) 
				if `groupvar' == 5 mht_inside_bandwidth, band_tested(14 26 39) cohort(1) year(1998) 
				
			   *if `groupvar' == 1 mht_18hypothesis	   , band_tested(14 26 39) cohort(1) year(1999) //only accepts 3 bandwidths
			   *if `groupvar' == 3 mht_18hypothesis	   , band_tested(14 26 39) cohort(2) year(1998) 
			   *if `groupvar' == 5 mht_18hypothesis	   , band_tested(14 26 39) cohort(1) year(1998) 
				
				if `groupvar' == 1 | `groupvar' == 2 use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1 & year  == 1999, clear	//boys, urban, 1999ta
				if `groupvar' == 3 | `groupvar' == 4 use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort2_12 == 1 & year  == 1998, clear	//1998 boys, urban, same age 
				if `groupvar' == 5 | `groupvar' == 6 use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1 & year  == 1998, clear	//1998 boys, urban, same cohort
				if `groupvar' == 1 | `groupvar' == 3 | `groupvar' == 5 local varlist = "eap 			pwork 		pwork_formal"
				if `groupvar' == 2 | `groupvar' == 4 | `groupvar' == 6 local varlist = "pwork_informal 	schoolatt 	study_only"
				if `groupvar' == 3 | `groupvar' == 4 	local cohort = 2
				if `groupvar' != 3 & `groupvar' != 4 	local cohort = 1
				
				if inlist(`groupvar',1,3,5) local dep_var = 1
				if inlist(`groupvar',2,4,6) local dep_var = 4
				
				foreach variable of local varlist 		{
					replace `variable' = `variable'*100
						foreach bandwidth in 14 26 39	{ 
							eststo reg`bandwidth'`dep_var', title("`bandwidth' weeks"):reg `variable' zw`cohort'  c.zw`cohort'#i.D`cohort' D`cohort' if zw`cohort' >= - `bandwidth' & zw`cohort' <= `bandwidth' , cluster(zw`cohort')	
							pwolf		, method(1) bandwidth(`bandwidth') dep_var(`dep_var')
							*pwolf		, method(2) bandwidth(`bandwidth') dep_var(`dep_var')
						}
						local dep_var = `dep_var' + 1
				}
				
			   *if `groupvar' == 1 estout * using "$tables\.xls" 		,  keep(D`cohort')   label  mgroups("Economically active" 	"Paid work" 		"Formal paid work"		,  pattern(1 0 0 1 0 0 1 0 0))  stats(pwolf1 pwolf2 N,  labels("Romano-Wolf"))  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) replace
			   *if `groupvar' == 2 estout * using "$tables\.xls" 		,  keep(D`cohort')   label  mgroups("Informal paid work" 	"Attending school" 	"Only attending school"	,  pattern(1 0 0 1 0 0 1 0 0))  stats(pwolf1 pwolf2 N,  labels("Romano-Wolf"))  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
				if `groupvar' == 3 estout * using "$tables\TableA4.xls" ,  keep(D`cohort')   label  mgroups("Economically active" 	"Paid work" 		"Formal paid work"		,  pattern(1 0 0 1 0 0 1 0 0))  stats(pwolf1 pwolf2 N,  labels("Romano-Wolf"))  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) replace
				if `groupvar' == 4 estout * using "$tables\TableA4.xls" ,  keep(D`cohort')   label  mgroups("Informal paid work" 	"Attending school" 	"Only attending school"	,  pattern(1 0 0 1 0 0 1 0 0))  stats(pwolf1 pwolf2 N,  labels("Romano-Wolf"))  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
				if `groupvar' == 5 estout * using "$tables\TableA5.xls" ,  keep(D`cohort')   label  mgroups("Economically active" 	"Paid work" 		"Formal paid work"		,  pattern(1 0 0 1 0 0 1 0 0))  stats(pwolf1 pwolf2 N,  labels("Romano-Wolf"))  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
				if `groupvar' == 6 estout * using "$tables\TableA5.xls" ,  keep(D`cohort')   label  mgroups("Informal paid work" 	"Attending school" 	"Only attending school"	,  pattern(1 0 0 1 0 0 1 0 0))  stats(pwolf1 pwolf2 N,  labels("Romano-Wolf"))  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
				estimates clear
			}
			 cap erase "$inter\mht_inside_bandwidth.dta"
			 *cap erase "$inter\mht_18hypothesis.dta"
	}	
		

		
		
		
		

		
		

