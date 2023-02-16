	
	
																	*RD ROBUST*
	*____________________________________________________________________________________________________________________________________*

	
	**
	*Program to calculate sharped q-values
	*-----------------------------------------------------------------------------------------------------------------------------------*
		capture program drop qtest
		program define qtest
		set more off
		syntax, band_tested(string)  urban(integer) male(integer) cohort(integer) year(integer) outcomes(string)
		cap erase "$inter/sharpenedqvals.dta"
		
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
			local number_outcomes = 0										//number of outcomes in the model
			foreach variable in `outcomes'			   {
				local number_outcomes = `number_outcomes' + 1
			}
				
			**
			*---------------------------------------------------->>
			local nrows = `number_band_tested'*`number_outcomes'			//number of rows that we need in the table. 
			di as red `number_band_tested'
			di as red `nrows '
			matrix y = J(`nrows',3,.)										//matrix to save sharped p-values, column 1 code of the dependent var(outcome) 
																			//column 2 bandwidths			
			*Filling column 1 the code of the outcome 
			*---------------------------------------------------->>
			local jump = 0
			forvalues outcome = 1(1)`number_outcomes'	 {	//
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
			
		
		
		*RUNNING THE REGRESSIONS
		*--------------------------------------------------------------------------------------------------------------------------------*
			preserve
			estimates clear
			use "$final/child-labor-ban-brazil.dta" if urban == `urban' & male == `male' & cohort`cohort'_12 == 1 & year  == `year', clear
				local row = 1
				foreach variable in `outcomes'			   {
					replace `variable' = `variable'*100
						foreach bandwidth in `band_tested' { 
							rdrobust `variable' zw`cohort', h(`bandwidth') c(0) p(1)  vce(cluster zw`cohort') all kernel(uniform)
							matrix y[`row',3] = e(pv_cl)					//storing the p values in matrix y
							local row = `row' + 1
						}
				}
				mat colnames y = "dep_var" "bandwidth" "p-value" 
				
				drop _all
				svmat  y
				rename y1 dep_var
				rename y2 bandwidth
				rename y3 pval
				set more off
				version 10
				
				* Collect the total number of p-values tested
				quietly sum pval
				local totalpvals = r(N)
				di `totalpvals'
				* Sort the p-values in ascending order and generate a variable that codes each p-value's rank
				quietly gen int original_sorting_order = _n
				quietly sort pval
				quietly gen int rank = _n if pval~=.
				* Set the initial counter to 1 
				local qval = 1
				* Generate the variable that will contain the BKY (2006) sharpened q-values
				gen bky06_qval = 1 if pval~=.
				* Set up a loop that begins by checking which hypotheses are rejected at q = 1.000, then checks which hypotheses are rejected at q = 0.999, then checks which hypotheses are rejected at q = 0.998, etc.  The loop ends by checking which hypotheses are rejected at q = 0.001.
				while `qval' > 0 {
					* First Stage
					* Generate the adjusted first stage q level we are testing: q' = q/1+q
					local qval_adj = `qval'/(1+`qval')
					* Generate value q'*r/M
					gen fdr_temp1 = `qval_adj'*rank/`totalpvals'
					* Generate binary variable checking condition p(r) <= q'*r/M
					gen reject_temp1 = (fdr_temp1>=pval) if pval~=.
					* Generate variable containing p-value ranks for all p-values that meet above condition
					gen reject_rank1 = reject_temp1*rank
					* Record the rank of the largest p-value that meets above condition
					egen total_rejected1 = max(reject_rank1)

					* Second Stage
					* Generate the second stage q level that accounts for hypotheses rejected in first stage: q_2st = q'*(M/m0)
					local qval_2st = `qval_adj'*(`totalpvals'/(`totalpvals'-total_rejected1[1]))
					* Generate value q_2st*r/M
					gen fdr_temp2 = `qval_2st'*rank/`totalpvals'
					* Generate binary variable checking condition p(r) <= q_2st*r/M
					gen reject_temp2 = (fdr_temp2>=pval) if pval~=.
					* Generate variable containing p-value ranks for all p-values that meet above condition
					gen reject_rank2 = reject_temp2*rank
					* Record the rank of the largest p-value that meets above condition
					egen total_rejected2 = max(reject_rank2)
					* A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
					replace bky06_qval = `qval' if rank <= total_rejected2 & rank~=.
					* Reduce q by 0.001 and repeat loop
					drop fdr_temp* reject_temp* reject_rank* total_rejected*
					local qval = `qval' - .001
				}
				quietly sort original_sorting_order
				keep dep_var bandwidth pval bky06_qval
				save "$inter/sharpenedqvals_`band_tested'.dta", replace
			restore
			
			
		end
		
		qtest, band_tested(14) urban(1) male(1) cohort(1) year(1998) outcomes("eap pwork pwork_formal pwork_informal schoolatt study_only")
		qtest, band_tested(26) urban(1) male(1) cohort(1) year(1998) outcomes("eap pwork pwork_formal pwork_informal schoolatt study_only")
		qtest, band_tested(39) urban(1) male(1) cohort(1) year(1998) outcomes("eap pwork pwork_formal pwork_informal schoolatt study_only")
			
			clear
		    append using "$inter/sharpenedqvals_14.dta"
					append using "$inter/sharpenedqvals_26.dta"
					append using "$inter/sharpenedqvals_39.dta"
					save "$inter/sharpenedqvals.dta",replace

			
			
		cap program drop pvalue
		program define pvalue
		syntax, bandwidth(integer) dep_var(integer)
		preserve
			use "$inter/sharpenedqvals.dta", clear
			keep if bandwidth == `bandwidth' & dep_var == `dep_var'
			su 		bky06_qval, detail
			scalar  qvalue  = `r(mean)'
		restore
		end

	**
	*Table 1
	*-----------------------------------------------------------------------------------------------------------------------------------*
	{		
		set more off
		estimates clear
		foreach groupvar in  5 6 { //
		
			*	if `groupvar' == 1 	qtest, band_tested(14) urban(1) male(1) cohort(1) year(1999) outcomes("eap pwork pwork_formal pwork_informal schoolatt study_only")
				*if `groupvar' == 3 	qtest, band_tested(14) urban(1) male(1) cohort(2) year(1998) outcomes("eap pwork pwork_formal pwork_informal schoolatt study_only")
				*if `groupvar' == 5 	qtest, band_tested(14) urban(1) male(1) cohort(1) year(1998) outcomes("eap pwork pwork_formal pwork_informal schoolatt study_only")
				
				
				
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
							eststo reg`bandwidth'`dep_var', title("`bandwidth' weeks"): rdrobust `variable' zw`cohort', h(`bandwidth') c(0) p(1)  vce(cluster zw`cohort') all kernel(uniform)
							scalar Obs =  e(N_h_l) + e(N_h_r)
							estadd scalar Obs     = Obs: reg`bandwidth'`dep_var'
							pvalue, bandwidth(`bandwidth') dep_var(`dep_var')
							estadd scalar qvalue  = qvalue: reg`bandwidth'`dep_var'
						}
						local dep_var = `dep_var' + 1
				}
				
				if `groupvar' == 1 estout * using "$tables\Table1.xls" ,  keep(Conventional)   label  mgroups("Economically active" 	"Paid work" 		"Formal paid work"		,  pattern(1 0 0 1 0 0 1 0 0))  stats(qvalue Obs)  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) replace
				if `groupvar' == 2 estout * using "$tables\Table1.xls" ,  keep(Conventional)   label  mgroups("Informal paid work" 		"Attending school" 	"Only attending school"	,  pattern(1 0 0 1 0 0 1 0 0))  stats(qvalue Obs)  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
				if `groupvar' == 3 estout * using "$tables\TableA2.xls",  keep(Conventional)   label  mgroups("Economically active" 	"Paid work" 		"Formal paid work"		,  pattern(1 0 0 1 0 0 1 0 0))  stats(qvalue Obs)  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) replace
				if `groupvar' == 4 estout * using "$tables\TableA2.xls",  keep(Conventional)   label  mgroups("Informal paid work" 		"Attending school" 	"Only attending school"	,  pattern(1 0 0 1 0 0 1 0 0))  stats(qvalue Obs)  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
				if `groupvar' == 5 estout * using "$tables\TableA2.xls",  keep(Conventional)   label  mgroups("Economically active" 	"Paid work" 		"Formal paid work"		,  pattern(1 0 0 1 0 0 1 0 0))  stats(qvalue Obs)  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
				if `groupvar' == 6 estout * using "$tables\TableA2.xls",  keep(Conventional)   label  mgroups("Informal paid work" 		"Attending school" 	"Only attending school"	,  pattern(1 0 0 1 0 0 1 0 0))  stats(qvalue Obs)  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
				
				estimates clear
			}
			*cap erase "$inter/sharpenedqvals.dta"
	}
	
	
		
	/*
	
		
	
																	*RD ROBUST*
	*____________________________________________________________________________________________________________________________________*

	
	**
	*Program to calculate sharped q-values
	*-----------------------------------------------------------------------------------------------------------------------------------*
		capture program drop qtest
		program define qtest
		set more off
		syntax, band_tested(string)  urban(integer) male(integer) cohort(integer) year(integer) outcomes(string)
		cap erase "$inter/sharpenedqvals.dta"
		
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
			local number_outcomes = 0										//number of outcomes in the model
			foreach variable in `outcomes'			   {
				local number_outcomes = `number_outcomes' + 1
			}
				
			**
			*---------------------------------------------------->>
			local nrows = `number_band_tested'*`number_outcomes'			//number of rows that we need in the table. 
			di as red `number_band_tested'
			di as red `nrows '
			matrix y = J(`nrows',3,.)										//matrix to save sharped p-values, column 1 code of the dependent var(outcome) 
																			//column 2 bandwidths			
			*Filling column 1 the code of the outcome 
			*---------------------------------------------------->>
			local jump = 0
			forvalues outcome = 1(1)`number_outcomes'	 {	//
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
			
		
		
		*RUNNING THE REGRESSIONS
		*--------------------------------------------------------------------------------------------------------------------------------*
			preserve
			estimates clear
			use "$final/child-labor-ban-brazil.dta" if urban == `urban' & male == `male' & cohort`cohort'_12 == 1 & year  == `year', clear
				local row = 1
				foreach variable in `outcomes'			   {
					replace `variable' = `variable'*100
						foreach bandwidth in `band_tested' { 
							rdrobust `variable' zw`cohort', h(`bandwidth') c(0) p(1)  vce(cluster zw`cohort') all kernel(uniform)
							matrix y[`row',3] = e(pv_cl)					//storing the p values in matrix y
							local row = `row' + 1
						}
				}
				mat colnames y = "dep_var" "bandwidth" "p-value" 
				
				drop _all
				svmat  y
				rename y1 dep_var
				rename y2 bandwidth
				rename y3 pval
				set more off
				version 10
				
				* Collect the total number of p-values tested
				quietly sum pval
				local totalpvals = r(N)
				di `totalpvals'
				* Sort the p-values in ascending order and generate a variable that codes each p-value's rank
				quietly gen int original_sorting_order = _n
				quietly sort pval
				quietly gen int rank = _n if pval~=.
				* Set the initial counter to 1 
				local qval = 1
				* Generate the variable that will contain the BKY (2006) sharpened q-values
				gen bky06_qval = 1 if pval~=.
				* Set up a loop that begins by checking which hypotheses are rejected at q = 1.000, then checks which hypotheses are rejected at q = 0.999, then checks which hypotheses are rejected at q = 0.998, etc.  The loop ends by checking which hypotheses are rejected at q = 0.001.
				while `qval' > 0 {
					* First Stage
					* Generate the adjusted first stage q level we are testing: q' = q/1+q
					local qval_adj = `qval'/(1+`qval')
					* Generate value q'*r/M
					gen fdr_temp1 = `qval_adj'*rank/`totalpvals'
					* Generate binary variable checking condition p(r) <= q'*r/M
					gen reject_temp1 = (fdr_temp1>=pval) if pval~=.
					* Generate variable containing p-value ranks for all p-values that meet above condition
					gen reject_rank1 = reject_temp1*rank
					* Record the rank of the largest p-value that meets above condition
					egen total_rejected1 = max(reject_rank1)

					* Second Stage
					* Generate the second stage q level that accounts for hypotheses rejected in first stage: q_2st = q'*(M/m0)
					local qval_2st = `qval_adj'*(`totalpvals'/(`totalpvals'-total_rejected1[1]))
					* Generate value q_2st*r/M
					gen fdr_temp2 = `qval_2st'*rank/`totalpvals'
					* Generate binary variable checking condition p(r) <= q_2st*r/M
					gen reject_temp2 = (fdr_temp2>=pval) if pval~=.
					* Generate variable containing p-value ranks for all p-values that meet above condition
					gen reject_rank2 = reject_temp2*rank
					* Record the rank of the largest p-value that meets above condition
					egen total_rejected2 = max(reject_rank2)
					* A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
					replace bky06_qval = `qval' if rank <= total_rejected2 & rank~=.
					* Reduce q by 0.001 and repeat loop
					drop fdr_temp* reject_temp* reject_rank* total_rejected*
					local qval = `qval' - .001
				}
				quietly sort original_sorting_order
				keep dep_var bandwidth pval bky06_qval
				save "$inter/sharpenedqvals.dta", replace
				
			restore
		end
				
				
		cap program drop pvalue
		program define pvalue
		syntax, bandwidth(integer) dep_var(integer)
		preserve
			use "$inter/sharpenedqvals.dta", clear
			keep if bandwidth == `bandwidth' & dep_var == `dep_var'
			su 		bky06_qval, detail
			scalar  qvalue  = `r(mean)'
		restore
		end

	**
	*Table 1
	*-----------------------------------------------------------------------------------------------------------------------------------*
	{		
		set more off
		estimates clear
		foreach groupvar in 3 4 5 6 { //
		
				if `groupvar' == 1 	qtest, band_tested(14 26 39) urban(1) male(1) cohort(1) year(1999) outcomes("eap pwork pwork_formal pwork_informal schoolatt study_only")
				if `groupvar' == 3 	qtest, band_tested(14 26 39) urban(1) male(1) cohort(2) year(1998) outcomes("eap pwork pwork_formal pwork_informal schoolatt study_only")
				if `groupvar' == 5 	qtest, band_tested(14 26 39) urban(1) male(1) cohort(1) year(1998) outcomes("eap pwork pwork_formal pwork_informal schoolatt study_only")
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
							eststo reg`bandwidth'`dep_var', title("`bandwidth' weeks"): rdrobust `variable' zw`cohort', h(`bandwidth') c(0) p(1)  vce(cluster zw`cohort') all kernel(uniform)
							scalar Obs =  e(N_h_l) + e(N_h_r)
							estadd scalar Obs     = Obs: reg`bandwidth'`dep_var'
							pvalue, bandwidth(`bandwidth') dep_var(`dep_var')
							estadd scalar qvalue  = qvalue: reg`bandwidth'`dep_var'
						}
						local dep_var = `dep_var' + 1
				}
				
				if `groupvar' == 1 estout * using "$tables\Table1.xls" ,  keep(Conventional)   label  mgroups("Economically active" 	"Paid work" 		"Formal paid work"		,  pattern(1 0 0 1 0 0 1 0 0))  stats(qvalue Obs)  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) replace
				if `groupvar' == 2 estout * using "$tables\Table1.xls" ,  keep(Conventional)   label  mgroups("Informal paid work" 		"Attending school" 	"Only attending school"	,  pattern(1 0 0 1 0 0 1 0 0))  stats(qvalue Obs)  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
				if `groupvar' == 3 estout * using "$tables\TableA2.xls",  keep(Conventional)   label  mgroups("Economically active" 	"Paid work" 		"Formal paid work"		,  pattern(1 0 0 1 0 0 1 0 0))  stats(qvalue Obs)  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) replace
				if `groupvar' == 4 estout * using "$tables\TableA2.xls",  keep(Conventional)   label  mgroups("Informal paid work" 		"Attending school" 	"Only attending school"	,  pattern(1 0 0 1 0 0 1 0 0))  stats(qvalue Obs)  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
				if `groupvar' == 5 estout * using "$tables\TableA2.xls",  keep(Conventional)   label  mgroups("Economically active" 	"Paid work" 		"Formal paid work"		,  pattern(1 0 0 1 0 0 1 0 0))  stats(qvalue Obs)  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
				if `groupvar' == 6 estout * using "$tables\TableA2.xls",  keep(Conventional)   label  mgroups("Informal paid work" 		"Attending school" 	"Only attending school"	,  pattern(1 0 0 1 0 0 1 0 0))  stats(qvalue Obs)  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
				
				estimates clear
			}
			*cap erase "$inter/sharpenedqvals.dta"
	}
	
	
	
	
	

	/*
				use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1 & year  == 1999, clear

	*keep eap pwork pwork_formal pwork_informal schoolatt study_only zw1 D1
	
		wyoung eap pwork pwork_formal pwork_informal schoolatt study_only, cmd(rdrobust OUTCOMEVAR zw1, h(14) c(0) p(1)  vce(cluster zw1) all kernel(uniform)) familyp(familypexp )   bootstraps(100) seed(20)
	
	
	rdrobust eap zw1, h(14) c(0) p(1)  vce(cluster zw1) all kernel(uniform)
	
	
	
	
	