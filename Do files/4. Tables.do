
	
															 *TABLES*
	*________________________________________________________________________________________________________________________________*

	
	*Table 1
	*--------------------------------------------------------------------------------------------------------------------------------*
		estimates clear
		use "$final/Child Labor Data.dta" if urban == 1 & male == 1 & year == 1999 & xw >= - 9 & xw <= 9, clear
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
				su `var' [aw = weight] 							   if xw >= -`bdw' & xw <= `bdw' 
				scalar mean_outcome = r(mean) 
			
				quietly reg `var' $dep_vars1 i.year [aw = weight]  if xw >= -`bdw' & xw <= `bdw', cluster(zw)
				eststo model`model', title("Linear")
				estadd scalar mean_outcome = mean_outcome: model`model'
				local model = `model' + 1
				
				quietly reg `var' $dep_vars2 i.year [aw = weight] if xw >= -`bdw' & xw <= `bdw', cluster(zw)
				eststo model`model', title("Quadratic")
				estadd scalar mean_outcome = mean_outcome: model`model'
				local model = `model' + 1
				
				quietly reg `var' $dep_vars3 i.year [aw = weight] if xw >= -`bdw' & xw <= `bdw', cluster(zw)
				eststo model`model', title("Piecewise Linear")
				estadd scalar mean_outcome = mean_outcome: model`model'
				local model = `model' + 1
			}
		}	
		estout * using "$tables/Table2.csv", delimiter(";") keep(D*)  label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, fmt(%9.0g %9.3f %9.3f)) replace


	*Table 3
	*--------------------------------------------------------------------------------------------------------------------------------*
		estimates clear
		use "$final/Child Labor Data.dta" if urban == 1 & male == 1 & year == 1999 & xw >= - 9 & xw <= 9, clear
		iebaltab  mom_yrs_school mom_age hh_members per_capita_inc [aw = weight], format(%12.2fc) grpvar(D) save("$tables/Table3.xlsx") rowvarlabels replace 
	

	*Table 4
	*--------------------------------------------------------------------------------------------------------------------------------*
		estimates clear
		**
		*Placebo 1. Dec 1997 = cut-off. 9-month bandwidth
		**
		use "$final/Child Labor Data.dta" 						if urban == 1 & male == 1 & year == 1998, clear
		drop 	D zw* zw* xw*
		gen 	xw = mofd(dateofbirth  - mdy(12, 15, 1983)) 		
		gen  	zw = wofd(dateofbirth  - mdy(12, 15, 1983))
		gen 	D 	 = 1 		if zw >=  0
		replace D	 = 0 		if zw <   0			
		gen 	zwD  = zw*D

		foreach var of varlist $shortterm_outcomes {
			quietly reg `var' $dep_vars3 i.year [aw = weight] 	if xw >= - 9 & xw <= 9, cluster(zw)
			eststo, title("Piecewise Linear")
		}	
		
		**
		*Placebo 2. Dec 2000 = cut-off. 9-month bandwidth
		**
		use "$final/Child Labor Data.dta" 						if urban == 1 & male == 1 & year == 1999, clear
		drop 	D zw* zw* xw*
		gen 	xw = mofd(dateofbirth  - mdy(6, 15, 1985)) 			
		gen  	zw = wofd(dateofbirth  - mdy(6, 15, 1985))
		gen 	D 	 = 1 		if zw >=  0
		replace D	 = 0 		if zw <   0			
		gen 	zwD  = zw*D

		foreach var of varlist $shortterm_outcomes {
			quietly reg `var' $dep_vars3 i.year [aw = weight] 	if xw >= - 6 & xw <= 6, cluster(zw)
			eststo, title("Piecewise Linear")
		}	
	
		**
		*Placebo 3. June 1999 = cut-off. 6-month bandwidth
		**
		use "$final/Child Labor Data.dta" 						if urban == 1 & male == 1 & year ==  2001, clear
		drop 	D zw* zw* xw*
		gen 	xw = mofd(dateofbirth  - mdy(12, 15, 1986)) 			
		gen  	zw = wofd(dateofbirth  - mdy(12, 15, 1986))
		
		gen 	D 	 = 1 		if zw >=  0
		replace D	 = 0 		if zw <   0			
		gen 	zwD  = zw*D

		foreach var of varlist $shortterm_outcomes {
			quietly reg `var' $dep_vars3 i.year [aw = weight] 	if xw >= - 9 & xw <= 9, cluster(zw)
			eststo, title("Piecewise Linear")
		}	

		estout * using "$tables/Table4.csv", delimiter(";") keep(D*)  label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%9.0g %9.3f )) replace


	*Table 5
	*--------------------------------------------------------------------------------------------------------------------------------*
		estimates clear
		use "$final/Child Labor Data.dta" if urban == 1 & male == 1 & (year >= 2007 & year <= 2014), clear

		local bandwidth 	"6" 						//12 16 20 26 30 36 40  //6months is equivalent to 24 weeks

		foreach var of varlist $longterm_outcomes {
			foreach bdw of local bandwidth {
				su `var' [aw = weight] 					     	if xw >= -`bdw' & xw <= `bdw' 
				scalar mean_outcome = r(mean) 
			
				quietly reg `var' D zw i.year [aw = weight]  	if xw >= -`bdw' & xw <= `bdw', cluster(zw)
				eststo model`model', title("Linear")
				estadd scalar mean_outcome = mean_outcome: model`model'
				local model = `model' + 1
				
				quietly reg `var' D zw zw2 i.year [aw = weight] if xw >= -`bdw' & xw <= `bdw', cluster(zw)
				eststo model`model', title("Quadratic")
				estadd scalar mean_outcome = mean_outcome: model`model'
				local model = `model' + 1
				
				quietly reg `var' D zw zwD i.year [aw = weight] if xw >= -`bdw' & xw <= `bdw', cluster(zw)
				eststo model`model', title("Piecewise Linear")
				estadd scalar mean_outcome = mean_outcome: model`model'
				local model = `model' + 1
			}
		}	
	
		estout * using "$tables/Table5.csv", delimiter(";") keep(D*)  label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%9.0g %9.3f )) replace

		
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

		local bandwidth 	"6" 						//12 16 20 26 30 36 40  //6months is equivalent to 24 weeks

		foreach var of varlist $longterm_outcomes {
			foreach bdw of local bandwidth {
				su `var' [aw = weight] 					     	if xw >= -`bdw' & xw <= `bdw' 
				scalar mean_outcome = r(mean) 
			
				quietly reg `var' D zw i.year [aw = weight]  	if xw >= -`bdw' & xw <= `bdw', cluster(zw)
				eststo model`model', title("Linear")
				estadd scalar mean_outcome = mean_outcome: model`model'
				local model = `model' + 1
				
				quietly reg `var' D zw zw2 i.year [aw = weight] if xw >= -`bdw' & xw <= `bdw', cluster(zw)
				eststo model`model', title("Quadratic")
				estadd scalar mean_outcome = mean_outcome: model`model'
				local model = `model' + 1
				
				quietly reg `var' D zw zwD i.year [aw = weight] if xw >= -`bdw' & xw <= `bdw', cluster(zw)
				eststo model`model', title("Piecewise Linear")
				estadd scalar mean_outcome = mean_outcome: model`model'
				local model = `model' + 1
			}
		}	
	
		estout * using "$tables/Table6.csv", delimiter(";") keep(D*)  label cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%9.0g %9.3f )) replace
		
		
		
		
		
		
		
		
		
		
		
