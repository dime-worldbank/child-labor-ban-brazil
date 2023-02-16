

															 *CONTINUITY BASED APPROACH*

	*____________________________________________________________________________________________________________________________________*
		
		use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1 & (year  == 1998), clear	//boys, urban, 1999
			foreach bandwidth in 14 26 39 {
			estimates clear
				foreach variable in eap pwork pwork_formal pwork_informal schoolatt study_only {
					if `bandwidth' == 14 replace `variable' = `variable'*100
							eststo: reg `variable' zw1  c.zw1#i.D1 D1  if zw1 >= -`bandwidth' & zw1 <= `bandwidth' , cluster(zw1)
						}
						if `bandwidth' == 14 estout * using "$tables\Table.xls",  keep(D1)   label  stats(N) cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) replace
						if `bandwidth' != 14 estout * using "$tables\Table.xls",  keep(D1)   label  stats(N) cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2)) p(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
				}
	
		foreach bandwidth in 14 26 39 {
			use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1 & (year  == 1998), clear	//boys, urban, 1999
			
				rwolf2  (reg eap   			zw1  c.zw1#i.D1 D1  if zw1 >= -`bandwidth' & zw1 <= `bandwidth' , cluster(zw1))   ///
						(reg pwork 			zw1  c.zw1#i.D1 D1  if zw1 >= -`bandwidth' & zw1 <= `bandwidth' , cluster(zw1))   ///
						(reg pwork_formal 	zw1  c.zw1#i.D1 D1  if zw1 >= -`bandwidth' & zw1 <= `bandwidth' , cluster(zw1))   ///
						(reg pwork_informal zw1  c.zw1#i.D1 D1  if zw1 >= -`bandwidth' & zw1 <= `bandwidth' , cluster(zw1))   ///
						(reg schoolatt 		zw1  c.zw1#i.D1 D1  if zw1 >= -`bandwidth' & zw1 <= `bandwidth' , cluster(zw1))   ///
						(reg study_only 	zw1  c.zw1#i.D1 D1  if zw1 >= -`bandwidth' & zw1 <= `bandwidth' , cluster(zw1)),  ///
				indepvars(D1, D1, D1, D1, D1, D1) reps(3000) seed(346446)
				matrix A = e(RW)
				clear
				svmat  A
				save "$inter\wolf2_6hyphotesis_`bandwidth'.dta", replace
			}	
			use "$inter\wolf2_6hyphotesis_14.dta", clear
			append using "$inter\wolf2_6hyphotesis_26.dta"
			append using "$inter\wolf2_6hyphotesis_39.dta"
			save "$inter\wolf2_6hyphotesis.dta", replace
			clear
			
		
		use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1 & (year  == 1998), clear	//boys, urban, 1999

			rwolf2  (reg eap   			zw1  c.zw1#i.D1 D1  if zw1 >= -14 & zw1 <= 14 , cluster(zw1))   ///
					(reg pwork 			zw1  c.zw1#i.D1 D1  if zw1 >= -14 & zw1 <= 14 , cluster(zw1))   ///
					(reg pwork_formal 	zw1  c.zw1#i.D1 D1  if zw1 >= -14 & zw1 <= 14 , cluster(zw1))   ///
					(reg pwork_informal zw1  c.zw1#i.D1 D1  if zw1 >= -14 & zw1 <= 14 , cluster(zw1))   ///
					(reg schoolatt 		zw1  c.zw1#i.D1 D1  if zw1 >= -14 & zw1 <= 14 , cluster(zw1))   ///
					(reg study_only 	zw1  c.zw1#i.D1 D1  if zw1 >= -14 & zw1 <= 14 , cluster(zw1))   ///
					(reg eap   			zw1  c.zw1#i.D1 D1  if zw1 >= -26 & zw1 <= 26 , cluster(zw1))   ///
					(reg pwork 			zw1  c.zw1#i.D1 D1  if zw1 >= -26 & zw1 <= 26 , cluster(zw1))   ///
					(reg pwork_formal 	zw1  c.zw1#i.D1 D1  if zw1 >= -26 & zw1 <= 26 , cluster(zw1))   ///
					(reg pwork_informal zw1  c.zw1#i.D1 D1  if zw1 >= -26 & zw1 <= 26 , cluster(zw1))   ///
					(reg schoolatt 		zw1  c.zw1#i.D1 D1  if zw1 >= -26 & zw1 <= 26 , cluster(zw1))   ///
					(reg study_only 	zw1  c.zw1#i.D1 D1  if zw1 >= -26 & zw1 <= 26 , cluster(zw1))   ///			
					(reg eap   			zw1  c.zw1#i.D1 D1  if zw1 >= -39 & zw1 <= 39 , cluster(zw1))   ///
					(reg pwork 			zw1  c.zw1#i.D1 D1  if zw1 >= -39 & zw1 <= 39 , cluster(zw1))   ///
					(reg pwork_formal 	zw1  c.zw1#i.D1 D1  if zw1 >= -39 & zw1 <= 39 , cluster(zw1))   ///
					(reg pwork_informal zw1  c.zw1#i.D1 D1  if zw1 >= -39 & zw1 <= 39 , cluster(zw1))   ///
					(reg schoolatt 		zw1  c.zw1#i.D1 D1  if zw1 >= -39 & zw1 <= 39 , cluster(zw1))   ///
					(reg study_only 	zw1  c.zw1#i.D1 D1  if zw1 >= -39 & zw1 <= 39 , cluster(zw1)) ,  ///		
			indepvars(D1, D1, D1, D1, D1, D1, D1, D1, D1, D1, D1, D1, D1, D1, D1, D1, D1, D1 ) reps(3000) seed(346446)	
			
			matrix A = e(RW)
			clear
			svmat  A
			save "$inter\wolf2_18hyphotesis.dta", replace

		
		
		
		foreach bandwidth in 14 26 39 {
		  use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1 & (year  == 1998), clear	//boys, urban, 1999
			keep if zw1 >= -`bandwidth' & zw1 <= `bandwidth'
			 wyoung eap pwork pwork_formal pwork_informal schoolatt study_only, cmd(regress OUTCOMEVAR zw1  c.zw1#i.D1 D1, cluster(zw1)) force ///
			 familyp(D1) bootstraps(500) seed(497641)
				matrix A =  r(table)
				clear
				svmat  A
				
				save "$inter\wyoung_6hyphotesis_`bandwidth'.dta", replace
		}
			
			
			use "$inter\wyoung_6hyphotesis_14.dta", clear
			append using "$inter\wyoung_6hyphotesis_26.dta"
			append using "$inter\wyoung_6hyphotesis_39.dta"
			save "$inter\wyoung_6hyphotesis.dta", replace
			clear
			
			
	
	use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1 & (year  == 1998), clear	//boys, urban, 1999
	
	 wyoung, cmd("regress eap   		 zw1  c.zw1#i.D1 D1 if zw1 >= -14 & zw1 <= 14, cluster(zw1)"  ///
				 "regress pwork 		 zw1  c.zw1#i.D1 D1 if zw1 >= -14 & zw1 <= 14, cluster(zw1)"  ///
				 "regress pwork_formal 	 zw1  c.zw1#i.D1 D1 if zw1 >= -14 & zw1 <= 14, cluster(zw1)"  ///
				 "regress pwork_informal zw1  c.zw1#i.D1 D1 if zw1 >= -14 & zw1 <= 14, cluster(zw1)"  ///
				 "regress schoolatt 	 zw1  c.zw1#i.D1 D1 if zw1 >= -14 & zw1 <= 14, cluster(zw1)"  ///
				 "regress study_only	 zw1  c.zw1#i.D1 D1 if zw1 >= -14 & zw1 <= 14, cluster(zw1)"  ///
				 ///
				 "regress eap   		 zw1  c.zw1#i.D1 D1 if zw1 >= -26 & zw1 <= 26, cluster(zw1)"  ///
				 "regress pwork 		 zw1  c.zw1#i.D1 D1 if zw1 >= -26 & zw1 <= 26, cluster(zw1)"  ///
				 "regress pwork_formal 	 zw1  c.zw1#i.D1 D1 if zw1 >= -26 & zw1 <= 26, cluster(zw1)"  ///
				 "regress pwork_informal zw1  c.zw1#i.D1 D1 if zw1 >= -26 & zw1 <= 26, cluster(zw1)"  ///
				 "regress schoolatt 	 zw1  c.zw1#i.D1 D1 if zw1 >= -26 & zw1 <= 26, cluster(zw1)"  ///
				 "regress study_only	 zw1  c.zw1#i.D1 D1 if zw1 >= -26 & zw1 <= 26, cluster(zw1)"  ///
				 ///
				 "regress eap 		 	 zw1  c.zw1#i.D1 D1 if zw1 >= -39 & zw1 <= 39, cluster(zw1)"  ///
				 "regress pwork 		 zw1  c.zw1#i.D1 D1 if zw1 >= -39 & zw1 <= 39, cluster(zw1)"  ///
				 "regress pwork_formal 	 zw1  c.zw1#i.D1 D1 if zw1 >= -39 & zw1 <= 39, cluster(zw1)"  ///
				 "regress pwork_informal zw1  c.zw1#i.D1 D1 if zw1 >= -39 & zw1 <= 39, cluster(zw1)"  ///
				 "regress schoolatt 	 zw1  c.zw1#i.D1 D1 if zw1 >= -39 & zw1 <= 39, cluster(zw1)"  ///
				 "regress study_only	 zw1  c.zw1#i.D1 D1 if zw1 >= -39 & zw1 <= 39, cluster(zw1)"  ///
				 ) ///
			force familyp(D1) bootstraps(3000) seed(457637)
			matrix A =  r(table)
			clear
			svmat  A
			save "$inter\wyoung_18hyphotesis.dta", replace

			/*
			use "$inter\wolf2_6hyphotesis.dta", clear
			
			
			
			/*
	
		use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_12 == 1 & (year  == 1999), clear	//boys, urban, 1999

		keep if zw1 >= -14 & zw1 <= 14 
		
		mhtreg  (eap   zw1 c.zw1#i.D1 D1		, cluster(zw1)) 			///
				(pwork zw1 c.zw1#i.D1 D1		, cluster(zw1)) 			///
				(pwork_formal zw1 c.zw1#i.D1 D1	, cluster(zw1)) force
	
	
       
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	**
	*Program to calculate sharped q-values
	*-----------------------------------------------------------------------------------------------------------------------------------*
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
			mat colnames y = "dep_var" "bandwidth" 
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
				
				
		cap program drop qsharpvalue
		program define pvalue
		syntax, bandwidth(integer) dep_var(integer)
		preserve
			use "$inter/sharpenedqvals.dta", clear
			keep if bandwidth == `bandwidth' & dep_var == `dep_var'
			su 		bky06_qval, detail
			scalar  qvalue  = `r(mean)'
		restore
		end
	
	
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
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
					foreach variable in eap pwork uwork pwork_formal pwork_informal schoolatt study_only{
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
					
						foreach bandwidth in 14 26 39 {			//bandwidths
							reg `variable' zw`cohort' 		  	 				 $bargain_controls_our_def D`cohort' i.year [aw = weight] if zw`cohort' >= -bandwidth & zw`cohort' <= `bandwidth', cluster(zw`cohort')	
							eststo, title("Linear")
							reg `variable' zw`cohort'  zw`cohort'2	  			 $bargain_controls_our_def D`cohort' i.year [aw = weight] if zw`cohort' >= -bandwidth & zw`cohort' <= `bandwidth' , cluster(zw`cohort')	
							eststo, title("Quadratic") 
							reg `variable' zw`cohort'  zw`cohort'D`cohort'       $bargain_controls_our_def D`cohort' i.year [aw = weight] if if zw`cohort' >= -bandwidth & zw`cohort' <= `bandwidth' , cluster(zw`cohort')	
							eststo, title("Sliptwise")
						}
						
						
						
						
						**
						*Tables ----------------------------------->>
						if  	  `example' == -1  & "`variable'" == "eap" { //ROBSTUNESS, SAME AGE, SAME COHORT
								estout * using "$tables\TableA6.xls",  keep(D`cohort')  title("`title'") label mgroups("4-month bandwidth" "6-month bandwidth" "9-month bandwidth",  pattern(1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0)) stats(N) cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) replace
						}
						if  	 (`example' == - 1  & "`variable'" != "eap") | `example' == 0 {
								estout * using "$tables\TableA6.xls",  keep(D`cohort')  title("`title'") label mgroups("4-month bandwidth" "6-month bandwidth" "9-month bandwidth",  pattern(1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0)) stats(N) cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
						}
						
						**
						*Tables ----------------------------------->>
						if  	  `example' == 1  & "`variable'" == "eap" 					{
								estout * using "$tables\Table1.xls",  keep(D`cohort')  title("`title'") label mgroups("4-month bandwidth" "6-month bandwidth" "9-month bandwidth",  pattern(1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0)) stats(N) cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) replace
						}
						if  	 (`example' == 1  & "`variable'" != "eap") | `example' == 2 {
								estout * using "$tables\Table1.xls",  keep(D`cohort')  title("`title'") label mgroups("4-month bandwidth" "6-month bandwidth" "9-month bandwidth",  pattern(1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0)) stats(N) cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
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
	
	
	
	
	use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & (year  == 1999), clear	//boys, urban, 1999ta
	
	replace eap = eap*100
	reg eap  zw1 D1 c.zw1#i.D1 if zw1 >= - 14 & zw1 <= 14  [aw = weig], cluster(zw1)	


	rdrobust eap zw1, h(14) c(0) p(1)  vce(cluster zw1) all kernel(uniform)


        
	rdrobust pwork_formal zw1,  c(0) p(1)  vce(cluster zw1) kernel(uniform) 


	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	/*
	*____________________________________________________________________________________________________________________________________*
	**
	**
	*Tables A7-A11
	**
	*____________________________________________________________________________________________________________________________________*
	{
		
		
			
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
					foreach variable in eap pwork uwork pwork_formal pwork_informal schoolatt study_only{
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
					
						foreach bandwidth in 14 26 39 {			//bandwidths
							reg `variable' zw`cohort' 		  	 				 $bargain_controls_our_def D`cohort' i.year [aw = weight] if zw`cohort' >= -bandwidth & zw`cohort' <= `bandwidth', cluster(zw`cohort')	
							eststo, title("Linear")
							reg `variable' zw`cohort'  zw`cohort'2	  			 $bargain_controls_our_def D`cohort' i.year [aw = weight] if zw`cohort' >= -bandwidth & zw`cohort' <= `bandwidth' , cluster(zw`cohort')	
							eststo, title("Quadratic") 
							reg `variable' zw`cohort'  zw`cohort'D`cohort'       $bargain_controls_our_def D`cohort' i.year [aw = weight] if if zw`cohort' >= -bandwidth & zw`cohort' <= `bandwidth' , cluster(zw`cohort')	
							eststo, title("Sliptwise")
						}
						
						
						
						
						**
						*Tables ----------------------------------->>
						if  	  `example' == -1  & "`variable'" == "eap" { //ROBSTUNESS, SAME AGE, SAME COHORT
								estout * using "$tables\TableA6.xls",  keep(D`cohort')  title("`title'") label mgroups("4-month bandwidth" "6-month bandwidth" "9-month bandwidth",  pattern(1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0)) stats(N) cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) replace
						}
						if  	 (`example' == - 1  & "`variable'" != "eap") | `example' == 0 {
								estout * using "$tables\TableA6.xls",  keep(D`cohort')  title("`title'") label mgroups("4-month bandwidth" "6-month bandwidth" "9-month bandwidth",  pattern(1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0)) stats(N) cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
						}
						
						**
						*Tables ----------------------------------->>
						if  	  `example' == 1  & "`variable'" == "eap" 					{
								estout * using "$tables\Table1.xls",  keep(D`cohort')  title("`title'") label mgroups("4-month bandwidth" "6-month bandwidth" "9-month bandwidth",  pattern(1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0)) stats(N) cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) replace
						}
						if  	 (`example' == 1  & "`variable'" != "eap") | `example' == 2 {
								estout * using "$tables\Table1.xls",  keep(D`cohort')  title("`title'") label mgroups("4-month bandwidth" "6-month bandwidth" "9-month bandwidth",  pattern(1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0)) stats(N) cells(b(star fmt(2) ) se(par(`"="("' `")""')  fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) append
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
	
	
	
	
	use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & cohort1_3 == 1 & (year  == 1999), clear	//boys, urban, 1999ta
	
	
	reg eap  zw1 D1 c.zw1#i.D1   , cluster(zw1)	


	rdrobust eap zw1, h(14) c(0) p(1)  vce(cluster zw1) all kernel(uniform)


        
	rdrobust pwork_formal zw1,  c(0) p(1)  vce(cluster zw1) kernel(uniform) 



		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
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
	
	
