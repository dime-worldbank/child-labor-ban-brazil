	
	
																	*RD ROBUST*
	*____________________________________________________________________________________________________________________________________*
		

	**
	*PROGRAM TO CALCULATE Q-VALUES
	*-----------------------------------------------------------------------------------------------------------------------------------*
	{
		cap program drop qsharp
		program define   qsharp
		syntax,  band_tested(string)  urban(integer) male(integer) cohort(integer) year(integer) outcomes(string)
			
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
			matrix y = J(`nrows',2,.)										//matrix to save sharped p-values, column 1 code of the dependent var(outcome) 
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
		mat colnames y = "dep_var" "bandwidth" 
	
	
		*REGRESSIONS
		*--------------------------------------------------------------------------------------------------------------------------------*
		{
		use "$final/child-labor-ban-brazil.dta" if urban == `urban' & male == `male' & cohort`cohort'_12 == 1 & year  == `year', clear
				local dep_var = 1
				foreach variable in `outcomes'			   {
					replace `variable' = `variable'*100
						foreach bandwidth in `band_tested' { 
							rdrobust `variable' zw`cohort', h(`bandwidth') c(0) p(1)  vce(cluster zw`cohort') all kernel(uniform)
								parmest, saving("$inter\results`dep_var'`bandwidth'.dta", replace)
						}
						local dep_var = `dep_var' + 1
				}
				local dep_var = `dep_var' - 1
				clear
				forvalues dep_var = 1(1)`dep_var'		{
				    foreach bandwidth in `band_tested' 	{
					    append using "$inter\results`dep_var'`bandwidth'.dta"
						erase 		 "$inter\results`dep_var'`bandwidth'.dta"
					}
				}
				keep if parm == "Conventional"
	            qqvalue p, method(sidak) qvalue(myqval)
				drop parm
				mkmat estimate p myqval, matrix(results)
		}	
	
	
		*Q-VALUES
		*--------------------------------------------------------------------------------------------------------------------------------*
		{
			matrix qvalues = y,results
			clear
			svmat qvalues 
			rename (qvalues1-qvalues5) (dep_var bandwidth estimate pvalue qvalue)
			save "$inter/sharpenedqvals.dta", replace
		}
	

		end
	}	
	

 
	**
	*PROGRAM TO STORE Q-VALUE IN THE REGRESSION RESULTS
	*-----------------------------------------------------------------------------------------------------------------------------------*
	{
		cap program drop   qsharpvalue
			program define qsharpvalue
			syntax, bandwidth(integer) dep_var(integer)
			preserve
				use "$inter/sharpenedqvals.dta", clear
				keep if bandwidth == `bandwidth' & dep_var == `dep_var'
				su 		qvalue, detail
				scalar  qvalue  = `r(mean)'
			restore
		end
	}
				
			
					
	**
	*Table 1
	*-----------------------------------------------------------------------------------------------------------------------------------*
	{		
		set more off
		estimates clear
		foreach groupvar in 1 2 { //
				
				if `groupvar' == 1 qsharp, band_tested(14 26 39)  urban(1) male(1) cohort(1) year(1999) outcomes("eap pwork pwork_formal pwork_informal schoolatt study_only")
				if `groupvar' == 3 qsharp, band_tested(14 26 39)  urban(1) male(1) cohort(2) year(1998) outcomes("eap pwork pwork_formal pwork_informal schoolatt study_only")
				if `groupvar' == 5 qsharp, band_tested(14 26 39)  urban(1) male(1) cohort(1) year(1998) outcomes("eap pwork pwork_formal pwork_informal schoolatt study_only")
				
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
							qsharpvalue, bandwidth(`bandwidth') dep_var(`dep_var')
							estadd scalar qvalue     = qvalue: reg`bandwidth'`dep_var'
						}
						local dep_var = `dep_var' + 1
				}
				
				if `groupvar' == 1 estout * using "$tables\Table1.xls" ,  keep(Conventional)   label  mgroups("Economically active" 	"Paid work" 		"Formal paid work"		,  pattern(1 0 0 1 0 0 1 0 0))  stats(qvalue Obs)  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) replace
				if `groupvar' == 2 estout * using "$tables\Table1.xls" ,  keep(Conventional)   label  mgroups("Informal paid work" 		"Attending school" 	"Only attending school"	,  pattern(1 0 0 1 0 0 1 0 0))  stats(qvalue Obs)  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
				if `groupvar' == 3 estout * using "$tables\TableA3.xls",  keep(Conventional)   label  mgroups("Economically active" 	"Paid work" 		"Formal paid work"		,  pattern(1 0 0 1 0 0 1 0 0))  stats(qvalue Obs)  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) replace
				if `groupvar' == 4 estout * using "$tables\TableA3.xls",  keep(Conventional)   label  mgroups("Informal paid work" 		"Attending school" 	"Only attending school"	,  pattern(1 0 0 1 0 0 1 0 0))  stats(qvalue Obs)  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
				if `groupvar' == 5 estout * using "$tables\TableA3.xls",  keep(Conventional)   label  mgroups("Economically active" 	"Paid work" 		"Formal paid work"		,  pattern(1 0 0 1 0 0 1 0 0))  stats(qvalue Obs)  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
				if `groupvar' == 6 estout * using "$tables\TableA3.xls",  keep(Conventional)   label  mgroups("Informal paid work" 		"Attending school" 	"Only attending school"	,  pattern(1 0 0 1 0 0 1 0 0))  stats(qvalue Obs)  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
				estimates clear
			}
			cap erase "$inter/sharpenedqvals.dta"
	}
	
	/*
	
	{	
		qsharp, band_tested(14 26 27 28 29 30 31 32 34 35 36 37 38 39)  urban(1) male(1) cohort(1) year(1999) outcomes("eap pwork pwork_formal pwork_informal schoolatt study_only")
			use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1 & year == 1999, clear	//boys, urban, 1999ta
			estimates clear
			local dep_var = 1 //	 	
				foreach variable in eap pwork pwork_formal pwork_informal schoolatt study_only	{
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
					estimates clear
					replace `variable' = `variable'*100
						foreach bandwidth in 14 26 27 28 29 30 31 32 34 35 36 37 38 39			{ 
							eststo reg`bandwidth'`dep_var', title("`bandwidth' weeks"): rdrobust `variable' zw1, h(`bandwidth') c(0) p(1)  vce(cluster zw1) all kernel(uniform)
							scalar Obs =  e(N_h_l) + e(N_h_r)
							estadd scalar Obs     = Obs: reg`bandwidth'`dep_var'
							qsharpvalue, bandwidth(`bandwidth') dep_var(`dep_var')
							estadd scalar qvalue     = qvalue: reg`bandwidth'`dep_var'
						}
						local dep_var = `dep_var' + 1
					if "`variable'" == "eap" estout * using "$tables\TableA2.xls",  keep(Conventional)   title("`title'") label  stats(qvalue Obs)  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) replace
					if "`variable'" != "eap" estout * using "$tables\TableA2.xls",  keep(Conventional)   title("`title'") label  stats(qvalue Obs)  cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
				}
	}

		
		
		
		
		
		
		
		
	**
	*Table 1
	*-----------------------------------------------------------------------------------------------------------------------------------*
	{		
		
		estimates clear
				use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1 & year  == 1999, clear	//boys, urban, 1999ta
				local dep_var = `dep_var' + 1
				 foreach variable of eap pwork pwork_formal	{
					replace `variable' = `variable'*100
						foreach bandwidth in 14 26 39	{ 
							eststo reg`bandwidth'`dep_var', title("`bandwidth' weeks"): rdrobust `variable' zw`cohort', h(`bandwidth') c(0) p(1)  vce(cluster zw1) all kernel(uniform)
							scalar Obs =  e(N_h_l) + e(N_h_r)
							estadd scalar Obs     = Obs: reg`bandwidth'`dep_var'
						}
						local dep_var = `dep_var' + 1
				}
				estimates clear
			}
	}		
		
		
		
		
		
		
	qsharp, band_tested(14 26 39)  urban(1) male(1) cohort(1) year(1998) outcomes("eap pwork pwork_formal pwork_informal schoolatt study_only")

	estimates clear
	 use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1 & year  == 1998, clear	
	 local dep_var = 1
				foreach variable in eap pwork pwork_formal pwork_informal schoolatt study_only	{
					replace `variable' = `variable'*100
						foreach bandwidth in 14 26 39	{ 
							eststo reg`bandwidth'`dep_var': rdrobust `variable' zw1, h(`bandwidth') c(0) p(1)  vce(cluster zw1) all kernel(uniform)
							qsharpvalue, bandwidth(`bandwidth') dep_var(`dep_var')
							estadd scalar qvalue     = qvalue: reg`bandwidth'`dep_var'
						}
						local dep_var = `dep_var' + 1
				}
		estout * using "$tables\teste.xls",  keep(Conventional)  replace cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) stats(qvalue) 
		

		
		
			qtest, band_tested("14 26 39 44") number_outcomes(5)
		
	
	local i=1
	foreach var of varlist Y1 Y2 Y3 Y4 Y5 {
	areg `var' treat1 treat2 treat3 treat4 b_`var', r a(strata)
	test treat1=0
	mat y[4*`i'-3,3]=r(p)
	test treat2=0
	mat y[4*`i'-2,3]=r(p)
	test treat3=0
	mat y[4*`i'-1,3]=r(p)
	test treat4=0
	mat y[4*`i',3]=r(p)
	local i=`i'+1
	}
	mat colnames y = "Outcome" "Treatment" "p-value" 

	drop _all
	svmat double y
	rename y1 outcome
	rename y2 treatment
	rename y3 pval
	save "Tablepvals.dta", replace

	version 10
	set more off

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
	pause off
	set more on

	display "Code has completed."
	display "Benjamini Krieger Yekutieli (2006) sharpened q-vals are in variable 'bky06_qval'"
	display	"Sorting order is the same as the original vector of p-values"

	keep outcome treatment pval bky06_qval
	save "output/sharpenedqvals.dta", replace

	
	
	
	
	
	

	

	
	
	
	
	
	/*
							
						if "`variable'" == "eap" & `bandwidth' == 14 {
							outreg2 a using "$tables\Table.xls",  replace dec(2) label(proper)  title() noobs paren(se) adds(Unnafected cohort, `unaf', Affected cohort, `af')  ctitle("No Covars") 
						}
						else {
							outreg2 a using "$tables\Table.xls",   append dec(2) label(proper)  title() noobs paren(se) adds(Unnafected cohort, `unaf', Affected cohort, `af')  ctitle("No Covars") 
						}
						
	

								
								
								
	/*
	
	*pwork pwork_formal pwork_informal schoolatt study_only  	
	
	
	estout * using "$tables\Table.xls",   replace

	
		**
	*Regs
	*-----------------------------------------------------------------------------------------------------------------------------------*
	{		
		
		use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1 & year == 1999, clear	//boys, urban, 1999ta
		estimates clear
			foreach variable in eap 	pwork pwork_formal pwork_informal schoolatt study_only		{
				replace `variable' = `variable'*100
				local dep_var = 1
							**
							if "`variable'" == "eap"    		local title = "Economically active"
							if "`variable'" == "pwork"			local title = "Paid work"
							if "`variable'" == "pwork_informal"	local title = "Informal paid work"
							if "`variable'" == "study_only"		local title = "Only attending school"
							if "`variable'" == "pwork_formal"	local title = "Formal paid work"
							if "`variable'" == "schoolatt"		local title = "Attending school"

				
					foreach bandwidth in 14 26 27 28 29 30 34 39	{ 
												
						eststo a: rdrobust `variable' zw1, h(`bandwidth') c(0) p(1)  vce(cluster zw1) covs($bargain_controls_our_def ) all
						
						local unaf = e(N_h_l)
						local af   = e(N_h_r)
						
						if "`variable'" == "eap" & `bandwidth' == 14 {
							outreg2 a using "$tables\Table.xls",  replace dec(2) label(proper)  title("`title'") noobs paren(se) adds(Unnafected cohort, `unaf', Affected cohort, `af') ctitle(Triangular) 
						}
						else {
							outreg2 a using "$tables\Table.xls",   append dec(2) label(proper)  title("`title'") noobs paren(se) adds(Unnafected cohort, `unaf', Affected cohort, `af') ctitle(Triangular) 
						}
						
						eststo b: rdrobust `variable' zw1, h(`bandwidth') c(0) p(1)  vce(cluster zw1) covs($bargain_controls_our_def ) all kernel(uniform)
						
						local unaf = e(N_h_l)
						local af   = e(N_h_r)
						
						outreg2  b using "$tables\Table.xls",   append dec(2) label(proper) title("`title'") noobs paren(se) adds(Unnafected cohort, `unaf', Affected cohort, `af') ctitle(Uniform) 
					}
				}
	}

	
	
	
	

	
		*-----------------------------------------------------------------------------------------------------------------------------------*
	{
		matrix results = (0,0,0,0,0,0,0,0,0,0,0)
		//each column of the matrix will save: year, bandwidth, dependent variable, estimate, lower bound, upper bound, standard error, whether the model has covars, ///
		//number of observations to the left of the cutoff, and number of observations to the right of the cutoff
		
		foreach year in 1999  { //2001 2002 2003 2004 2005 2006 2007
		
			foreach bandwidth in 14 26 39 	    { //27 28 29 30 34
			
				local dep_var = 1
				
				use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1, clear	//boys, urban, 1999ta

					foreach var of varlist $shortterm_outcomes {
					replace `var' = `var'*100
					*if `year' == 1999 keep if year == 1999
					*if `year' == 2001 keep if inlist(year, 1999, 2001)
					
					keep if year == `year'
					
					est store a`dep_var'`bandwidth'1
					rdrobust `var' zw1, h(`bandwidth') c(0) p(1)  vce(cluster zw1)  all					
					

					*rdrobust `var' zw1, h(`bandwidth') c(0) p(1)  vce(cluster zw1) covs($bargain_controls_our_def ) all
					*matrix results = results\(`year', `bandwidth',`dep_var', e(tau_bc), e(ci_r_rb), e(ci_l_rb),  e(se_tau_rb) , 1,  e(N_h_l),  e(N_h_r),1)
					
										
						if "`var'" == "eap" &  `bandwidth' == 14 {
							outreg2 * using "$tables\Table.xls",  replace dec(2) label(proper)
						}
						else {
							outreg2 * using "$tables\Table.xls",  append dec(2)  label(proper)
						}
					
					
					
					
					local dep_var = `dep_var' + 1 
				}
			}
		}
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	**
	*Regs
	*-----------------------------------------------------------------------------------------------------------------------------------*
	{
		matrix results = (0,0,0,0,0,0,0,0,0,0,0)
		//each column of the matrix will save: year, bandwidth, dependent variable, estimate, lower bound, upper bound, standard error, whether the model has covars, ///
		//number of observations to the left of the cutoff, and number of observations to the right of the cutoff
		
		foreach year in 1999  { //2001 2002 2003 2004 2005 2006 2007
		
			foreach bandwidth in 14 26  39 	    { //27 28 29 30 34
			
				local dep_var = 1
				
				use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1, clear	//boys, urban, 1999ta

					foreach var of varlist $shortterm_outcomes {
					
					*if `year' == 1999 keep if year == 1999
					*if `year' == 2001 keep if inlist(year, 1999, 2001)
					
					keep if year == `year'
					
					rdrobust `var' zw1, h(`bandwidth') c(0) p(1)  vce(cluster zw1)  all
					matrix results = results\(`year', `bandwidth',`dep_var', e(tau_cl), e(ci_r_cl), e(ci_l_cl),  e(se_tau_cl) , e(pv_cl),  e(N_h_l),  e(N_h_r) ,0,1 )
					matrix results = results\(`year', `bandwidth',`dep_var', e(tau_bc), e(ci_r_cl), e(ci_l_cl),  e(se_tau_cl) , e(pv_cl),  e(N_h_l),  e(N_h_r) ,0,2 )
					matrix results = results\(`year', `bandwidth',`dep_var', e(tau_bc), e(ci_r_rb), e(ci_l_rb),  e(se_tau_rb) , e(pv_rb),  e(N_h_l),  e(N_h_r) ,0,3 )
					
					
					rdrobust `var' zw1, h(`bandwidth') c(0) p(1)  vce(cluster zw1) covs($bargain_controls_our_def ) all
					matrix results = results\(`year', `bandwidth',`dep_var', e(tau_bc), e(ci_r_rb), e(ci_l_rb),  e(se_tau_rb) , 1,  e(N_h_l),  e(N_h_r),1)
					
					local dep_var = `dep_var' + 1 
				}
			}
		}
	}
	
	
	
	
	use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & zw1 >= -14 & zw1 <= 14 & year == 1999, clear	//boys, urban, 1999ta
			rdrobust uwork zw1, h(14) c(0) p(1)  vce(cluster zw1)  kernel(uniform)	all
			
			
			reg uwork 	   zw1	 D1 , cluster(zw1)	

					
					
					
	**
	*Results
	*-----------------------------------------------------------------------------------------------------------------------------------*
	{	
		clear
		svmat 		results						//storing the results of our estimates so we can present the estimates in charts
		drop  		in 1
		rename 		(results1-results10) (year bandwidth shortterm_outcomes  ATE  upper lower stderror covs obs_unaffected obs_affected)	
		
		foreach var of varlist ATE  upper lower {
		    replace `var' = `var'*100
		}
		
		
		**
		label 		define shortterm_outcomes 	1 "Economically Active"  		 2 "Paid work"  	  				3 "Unpaid work" 						///
												4 "Formal paid work"  			 5 "Informal paid work" 			6 "Attending school" 					///
												7 "Only paid work" 				 8 "Only attending school " 	  	9 "Neither working nor attending school" 								   
		label		val    shortterm_outcomes shortterm_outcomes
		
		save	"$inter/Results RD-Robust.dta", replace
	}
	
	
	**
	*Figures of the persistence of the short-term effects
	*-----------------------------------------------------------------------------------------------------------------------------------*
	{
	use "$inter/Results RD-Robust.dta", clear
		foreach bandwidth in 14 26 39  {
				use  `datacharts' if covs == 1 & bandwidth == `bandwidth', clear
				local figure = 1
			

					**
					*Outcomes 1 a 9
					forvalues shortterm_outcomes = 1(1)9{
						preserve
							keep if shortterm_outcomes == `shortterm_outcomes'						
							quietly su lower, detail
							local min = r(min) + r(min)/3
							quietly su upper, detail
							local max = r(max) + r(max)/3
							
							twoway  ///
							||  	scatter ATE 	 year ,   color(orange) msize(large) msymbol(O) 																					///
							|| 		rcap lower upper year ,  lcolor(navy) lwidth( medthick )  	 																					///
							yline(0, lw(0.6) lp(shortdash) lcolor(cranberry*06))  ylabel(, labsize(small) gmax angle(horizontal) format (%4.1fc)) 				 						///
							xtitle("", size(small)) 											  																						///
							yscale(r(`min' `max'))	 																																	///
							ytitle("ATE, in pp", size(small))					 																										///					
							title({bf:`: label shortterm_outcomes `shortterm_outcomes''}, pos(11) color(navy) span size(medsmall))														///
							legend(off) xsize(6) ysize(4)																																			///
							note(".", color(black) fcolor(background) pos(7) size(small)) saving(short`figure'.gph, replace)
							local figure = `figure' + 1
						restore
					}
			graph combine short1.gph short2.gph short4.gph short5.gph short6.gph short8.gph, cols(3) graphregion(fcolor(white)) ysize(10) xsize(18) title(, fcolor(white) size(medium) color(cranberry))
		    graph export "$figures/teste_band`bandwidth'.pdf",  as(pdf) replace
		}
		}
	
				
	**
	*Tables
	*-----------------------------------------------------------------------------------------------------------------------------------*
	{
		use "$inter/Results RD-Robust.dta", clear
		**
		gen 	 	CI  = "[" + substr(string(lower),1,4) + "," + substr(string(upper),1,4) + "]" if substr(string(lower),1,1) == "-" & substr(string(upper),1,1) == "-"
		replace  	CI  = "[" + substr(string(lower),1,4) + "," + substr(string(upper),1,3) + "]" if substr(string(lower),1,1) == "-" & substr(string(upper),1,1) != "-"
		replace  	CI  = "[" + substr(string(lower),1,3) + "," + substr(string(upper),1,3) + "]" if substr(string(lower),1,1) != "-" & substr(string(upper),1,1) != "-"
		replace  	CI  = "[" + substr(string(lower),1,3) + "," + substr(string(upper),1,4) + "]" if substr(string(lower),1,1) != "-" & substr(string(upper),1,1) == "-"

		tostring 	ATE, force replace
		replace  	ATE = substr(ATE, 1, 5) 
		replace 	ATE = ATE + "*"    if pvalue <= 0.10 & pvalue > 0.05
		replace 	ATE = ATE + "**"   if pvalue <= 0.05 & pvalue > 0.01
		replace 	ATE = ATE + "***"  if pvalue <= 0.01
		drop		upper lower pvalue
		
		expand 2, gen (REP)
		sort year bandwidth shortterm_outcomes covs REP
		replace ATE = CI[_n-1]  if shortterm_outcomes== shortterm_outcomes[_n-1] & REP == 1 & REP[_n-1] == 0 & bandwidth == bandwidth[_n-1] & year == year[_n-1]
		drop CI REP
		
		gen 	tipo = 1 
		replace tipo = 2 if substr(ATE, 1, 1) == "["
		
		reshape wide ATE , i(year bandwidth shortterm_outcomes tipo) j(covs)
		reshape wide ATE*, i(	  bandwidth shortterm_outcomes tipo) j(year)
		reshape wide ATE*, i(	  			shortterm_outcomes tipo) j(bandwidth)

		
		drop if inlist(shortterm_outcomes, 3,7,9)
		replace dep_var = . if tipo == 2
		drop 	tipo
		save  "$inter/Results RD-Robust.dta", replace
	}
	
	
	
	
	
	
	
	
		**
	*Program to calculate sharped q-values
	*-----------------------------------------------------------------------------------------------------------------------------------*
		capture program drop qtest
		program define qtest
		set more off
		syntax, band_tested(string)  urban(integer) male(integer) cohort(integer) year(integer) outcomes(varlist)
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
			*preserve
			estimates clear
			use "$final/child-labor-ban-brazil.dta" if urban == `urban' & male == `male' & cohort`cohort'_12 == 1 & year  == `year', clear
				local row = 1
				foreach variable in `outcomes'			   {
					replace `variable' = `variable'*100
						foreach bandwidth in `band_tested' { 
							eststo: rdrobust `variable' zw`cohort', h(`bandwidth') c(0) p(1)  vce(cluster zw`cohort') all kernel(uniform)
							matrix y[`row',3] = e(pv_cl)					//storing the p values in matrix y
							local row = `row' + 1
						}
				}
				estout * using "$inter\Regs`urban'_`male'_`cohort'_`year'.xls", keep(Conventional) cells(b p) replace
				mat colnames y = "dep_var" "bandwidth" "p-value" 
				
				drop _all
				svmat  y
				rename y1 dep_var
				rename y2 bandwidth
				rename y3 pval
				set more off
				version 10
				save "$inter\Qvalue`urban'_`male'_`cohort'_`year'.dta", replace
				
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
				*/
			*restore
		end
						
		use "$final/child-labor-ban-brazil.dta", clear
		qtest, band_tested(14 26 39) urban(1) male(1) cohort(1) year(1999) outcomes(eap pwork pwork_formal pwork_informal schoolatt study_only)

	
	
				
				
				

	
	
	
	
	
	
	
		
		
		
		use "$inter/Local Randomization Results_1999.dta" if window == 14 & polinomio ==0, clear		
		
		keep dep_var ATE CI

		merge 1:1 dep_var using `rdrobust'