	
															 *TABLES*
	*________________________________________________________________________________________________________________________________*

	
	*Table 1
	*--------------------------------------------------------------------------------------------------------------------------------*
		estimates clear
		use "$final/Child Labor Data.dta" if urban == 1 & male == 1 & year == 1999 & xw >= - 9 & xw < 9, clear
		eststo sumstats1: estpost sum working $shortterm_outcomes white mom_yrs_school hh_members 
		esttab sumstats1 using "$tables/Table1.tex", noobs nonumbers booktabs label 															///
		cells("count(label(Obs) fmt(0)) mean(label(Mean) fmt(2)) sd(label(Stand.Dev.) fmt(2)) min(label(Min.) fmt(0)) max(label(Max.) fmt(0))") ///
		addnotes("Source: PNAD 1999.") title("Descriptive Statistics of the Whole Sample of Males, 9-Month Bandwidth (1999)") replace 
	

	*Table 2a and 2b
	*--------------------------------------------------------------------------------------------------------------------------------*
		estimates clear
		use "$final/Child Labor Data.dta" if urban == 1 & male == 1 & (year == 1999 | year == 2001), clear
		local bandwidth 	"6" 						//12 16 20 26 30 36 40  //6months is equivalent to 24 weeks
		local model = 1
	
		foreach var of varlist $shortterm_outcomes {
			foreach bdw of local bandwidth {
				su `var' [w = weight] 							  if xw >= -`bdw' & xw < `bdw' 
				scalar mean_outcome = r(mean) 
			
				quietly reg `var' $dep_vars1 i.year [pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
				eststo model`model', title("Linear")
				estadd scalar mean_outcome = mean_outcome: model`model'
				local model = `model' + 1
				
				quietly reg `var' $dep_vars2 i.year [pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
				eststo model`model', title("Quadratic")
				estadd scalar mean_outcome = mean_outcome: model`model'
				local model = `model' + 1
				
				quietly reg `var' $dep_vars3 i.year [pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
				eststo model`model', title("Piecewise Linear")
				estadd scalar mean_outcome = mean_outcome: model`model'
				local model = `model' + 1
			}
		}
		
		estout model1  model2  model3  using "$tables/Table2.csv", delimiter(";") keep(D*)  title("Paid work"		  			) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) replace
		estout model4  model5  model6  using "$tables/Table2.csv", delimiter(";") keep(D*)  title("Informal paid work"			) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
		estout model7  model8  model9  using "$tables/Table2.csv", delimiter(";") keep(D*)  title("Unpaid work" 	  			) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
		estout model10 model11 model12 using "$tables/Table2.csv", delimiter(";") keep(D*)  title("School attendance" 			) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
		estout model13 model14 model15 using "$tables/Table2.csv", delimiter(";") keep(D*)  title("Paid work and studying" 		) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
		estout model16 model17 model18 using "$tables/Table2.csv", delimiter(";") keep(D*)  title("Unpaid work and studying" 	) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
		estout model19 model20 model21 using "$tables/Table2.csv", delimiter(";") keep(D*)  title("Only paid work" 				) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
		estout model22 model23 model24 using "$tables/Table2.csv", delimiter(";") keep(D*)  title("Only unpaid work" 			) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
		estout model25 model26 model27 using "$tables/Table2.csv", delimiter(";") keep(D*)  title("Only studying" 				) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
		estout model28 model29 model30 using "$tables/Table2.csv", delimiter(";") keep(D*)  title("Neither working or studying" ) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
		
		
	*Table 3
	*--------------------------------------------------------------------------------------------------------------------------------*
		estimates clear
		use "$final/Child Labor Data.dta" if urban == 1 & male == 1 & year == 1999 & xw >= - 9 & xw < 9, clear
		iebaltab  mom_yrs_school mom_age hh_members per_capita_inc [pw = weight], format(%12.2fc) grpvar(D) save("$tables/Table3.xlsx") rowvarlabels replace 
	

	*Table 4
	*--------------------------------------------------------------------------------------------------------------------------------*
		estimates clear
		use "$final/Child Labor Data.dta" 						if urban == 1 & male == 1, clear
		
		gen 	xwP1 = mofd(dateofbirth  - mdy(12, 15, 1983)) 	if year == 1998	
		gen  	zwP1 = wofd(dateofbirth  - mdy(12, 15, 1983))	if year == 1998	

		gen 	xwP2 = mofd(dateofbirth  - mdy(12, 15, 1986)) 	if year == 2001		
		gen  	zwP2 = wofd(dateofbirth  - mdy(12, 15, 1986))	if year == 2001	

		gen 	xwP3 = mofd(dateofbirth  - mdy(6,  15, 1985)) 	if year == 1999
		gen  	zwP3 = wofd(dateofbirth  - mdy(6,  15, 1985))	if year == 1999

		drop 	D
		gen  	D = .
		replace D   = 1 					if zwP1 >= 0 & year == 1998
		replace D   = 0 					if zwP1 <  0 & year == 1998
		replace D   = 1 					if zwP2 >= 0 & year == 2001
		replace D   = 0 					if zwP2 <  0 & year == 2001		
		replace D   = 1 					if zwP3 >= 0 & year == 1999
		replace D   = 0 					if zwP3 <  0 & year == 1999
		label var D "ITT"
		
		foreach placebo in P1 P2 P3 {
			gen 	zwD`placebo' = zw`placebo'*D
		}
		
		local model = 1
		
		foreach var of varlist $shortterm_outcomes {
			quietly reg `var' D zwP1 zwDP1 mom_yrs_school [pw = weight] if xwP1 >= - 9 & xwP1 < 9 & year == 1998, cluster(zwP1)  	//Placebo 1. Dec 1997 = cut-off. 9-month bandwidth
			eststo model`model', title("Placebo 1")
			local model = `model' + 1
			
			quietly reg `var' D zwP2 zwDP2 mom_yrs_school [pw = weight] if xwP2 >= - 9 & xwP2 < 9 & year == 2001, cluster(zwP2)	//Placebo 2. Dec 2000 = cut-off. 9-month bandwidth
			eststo model`model', title("Placebo 2")
			local model = `model' + 1
			
			quietly reg `var' D zwP3 zwDP3 mom_yrs_school [pw = weight] if xwP3 >= - 6 & xwP3 < 6 & year == 1999, cluster(zwP3)	//Placebo 3. June 1999 = cut-off. 6-month bandwidth
			eststo model`model', title("Placebo 3")
			local model = `model' + 1
		}	

		estout model1  model2  model3  using "$tables/Table4.csv", delimiter(";") keep(D*)  title("Paid work"		  			) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) replace
		estout model4  model5  model6  using "$tables/Table4.csv", delimiter(";") keep(D*)  title("Informal paid work"			) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
		estout model7  model8  model9  using "$tables/Table4.csv", delimiter(";") keep(D*)  title("Unpaid work" 	  			) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
		estout model10 model11 model12 using "$tables/Table4.csv", delimiter(";") keep(D*)  title("School attendance" 			) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
		estout model13 model14 model15 using "$tables/Table4.csv", delimiter(";") keep(D*)  title("Paid work and studying" 		) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
		estout model16 model17 model18 using "$tables/Table4.csv", delimiter(";") keep(D*)  title("Unpaid work and studying" 	) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
		estout model19 model20 model21 using "$tables/Table4.csv", delimiter(";") keep(D*)  title("Only paid work" 				) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
		estout model22 model23 model24 using "$tables/Table4.csv", delimiter(";") keep(D*)  title("Only unpaid work" 			) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
		estout model25 model26 model27 using "$tables/Table4.csv", delimiter(";") keep(D*)  title("Only studying" 				) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
		estout model28 model29 model30 using "$tables/Table4.csv", delimiter(";") keep(D*)  title("Neither working or studying" ) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append

		
	*Table 5
	*--------------------------------------------------------------------------------------------------------------------------------*
		estimates clear
		use "$final/Child Labor Data.dta" if urban == 1 & male == 1 & (year >= 2007 & year <= 2014), clear

		local bandwidth 	"6" 					
		local model = 1
		
		foreach var of varlist $longterm_outcomes {
			foreach bdw of local bandwidth {
				su `var' [w = weight] 					     	if xw >= -`bdw' & xw < `bdw' 
				scalar mean_outcome = r(mean) 
			
				quietly reg `var' D zw 	   i.year [pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
				eststo model`model', title("Linear")
				estadd scalar mean_outcome = mean_outcome: model`model'
				local model = `model' + 1
				
				quietly reg `var' D zw zw2 i.year [pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
				eststo model`model', title("Quadratic")
				estadd scalar mean_outcome = mean_outcome: model`model'
				local model = `model' + 1
				
				quietly reg `var' D zw zwD i.year [pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
				eststo model`model', title("Piecewise Linear")
				estadd scalar mean_outcome = mean_outcome: model`model'
				local model = `model' + 1
			}
		}	
	
		estout model1  model2  model3  using "$tables/Table5.csv", delimiter(";") keep(D*)  title("Years of schooling"		  	) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) replace
		estout model4  model5  model6  using "$tables/Table5.csv", delimiter(";") keep(D*)  title("At least High School degree" ) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
		estout model7  model8  model9  using "$tables/Table5.csv", delimiter(";") keep(D*)  title("College degree"				) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
		estout model10 model11 model12 using "$tables/Table5.csv", delimiter(";") keep(D*)  title("Employed" 	  				) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
		estout model13 model14 model15 using "$tables/Table5.csv", delimiter(";") keep(D*)  title("Formal occupation" 			) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
		estout model16 model17 model18 using "$tables/Table5.csv", delimiter(";") keep(D*)  title("Log-earnings" 				) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
		
		
	*Table 6
	*--------------------------------------------------------------------------------------------------------------------------------*
		estimates clear
		use "$final/Child Labor Data.dta" if urban == 1 & male == 1 & (year >= 2007 & year <= 2014), clear
		
		drop 	D zw* zw* xw*
		gen 	xw = mofd(dateofbirth  - mdy(12, 15, 1983)) 		
		gen  	zw = wofd(dateofbirth  - mdy(12, 15, 1983))
		gen 	D 	 = 1 		if zw >=  0
		replace D	 = 0 		if zw <   0			
		gen 	zwD  = zw*D
		gen 	zw2  = zw^2
		gen 	zw3  = zw^3
		gen 	zw2D = zw2*D
		format 	zw2* zw3* %12.2fc

		local bandwidth 	"6" 					
		local model = 1

		foreach var of varlist $longterm_outcomes {
			foreach bdw of local bandwidth {			
				quietly reg `var' D zw 	   i.year [pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
				eststo model`model', title("Linear")
				local model = `model' + 1
				
				quietly reg `var' D zw zw2 i.year [pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
				eststo model`model', title("Quadratic")
				local model = `model' + 1
				
				quietly reg `var' D zw zwD i.year [pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
				eststo model`model', title("Piecewise Linear")
				local model = `model' + 1
			}
		}	
	
		estout model1  model2  model3  using "$tables/Table6.csv", delimiter(";") keep(D*)  title("Years of schooling"		  	) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2, labels("Obs" "R2") fmt(%9.0g %9.3f)) replace
		estout model4  model5  model6  using "$tables/Table6.csv", delimiter(";") keep(D*)  title("At least High School degree" ) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2, labels("Obs" "R2") fmt(%9.0g %9.3f)) append
		estout model7  model8  model9  using "$tables/Table6.csv", delimiter(";") keep(D*)  title("College degree"				) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2, labels("Obs" "R2") fmt(%9.0g %9.3f)) append
		estout model10 model11 model12 using "$tables/Table6.csv", delimiter(";") keep(D*)  title("Employed" 	  				) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2, labels("Obs" "R2") fmt(%9.0g %9.3f)) append
		estout model13 model14 model15 using "$tables/Table6.csv", delimiter(";") keep(D*)  title("Formal occupation" 			) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2, labels("Obs" "R2") fmt(%9.0g %9.3f)) append
		estout model16 model17 model18 using "$tables/Table6.csv", delimiter(";") keep(D*)  title("Log-earnings" 				) label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2, labels("Obs" "R2") fmt(%9.0g %9.3f)) append
		
		
		

		
		
		
