	
															 *TABLES*
	*________________________________________________________________________________________________________________________________*

	
	*Table 1
	*--------------------------------------------------------------------------------------------------------------------------------*
		estimates clear
		use "$final/Child Labor Data.dta" if urban == 1 & male == 1 & year == 1999 & xw >= - 9 & xw < 9, clear
		eststo sumstats1: estpost sum working pwork pwork_formal pwork_informal uwork schoolatt white mom_yrs_school hh_size
		esttab sumstats1 using "$tables/Table1.tex", noobs nonumbers booktabs label 															///
		cells("count(label(Obs) fmt(0)) mean(label(Mean) fmt(2)) sd(label(Stand.Dev.) fmt(2)) min(label(Min.) fmt(0)) max(label(Max.) fmt(0))") ///
		addnotes("Source: PNAD 1999.") title("Descriptive Statistics for the sample of urban males, 9-Month Bandwidth (1999)") 			  replace 
		
		
	*Table 2
	*--------------------------------------------------------------------------------------------------------------------------------*
		estimates clear

		use "$final/Child Labor Data.dta" if urban == 1 & male == 1 & year == 1999 & xw >= - 9 & xw < 9, clear
		iebaltab  mom_yrs_school mom_age hh_size per_capita_inc, format(%12.2fc) grpvar(D) savetex("$tables/Table2.tex") rowvarlabels 			///
		tblnote("Source: PNAD 1999.") notecombine texdocument  texcaption("Balance test for affected and unaffected cohorts, 9-Month Bandwidth (1999)") replace

		
	*Tables 3/4
	*--------------------------------------------------------------------------------------------------------------------------------*
	use "$final/Child Labor Data.dta" if urban == 1 & male == 1, clear

		foreach year in 1999 2001 {
		
			estimates clear
			use "$final/Child Labor Data.dta" if urban == 1 & male == 1, clear
			
			if `year' == 1999 {
			keep if year == 1999							//Only 1999 sample
			local table = 3									//Table number
			}
			if `year' == 2001 {
			keep if year == 1999 | year == 2001				//Checking robustness doing pooled 1999 and 2001
			local table = 4									//Table number
			}
			
			local bandwidth 	"3 5 9" 					//bandwidths, in months				
		
			foreach var of varlist eap pwork uwork schoolatt {		//short-term outcomes
			
				if "`var'" == "eap"   		local title = "Eco. Act. Pop"
				if "`var'" == "pwork" 		local title = "Paid work"
				if "`var'" == "schoolatt" 	local title = "School attendance"
				if "`var'" == "uwork" 		local title = "Unpaid work"
			
				local model = 1
				
				foreach bdw of local bandwidth {
					quietly su `var' [w = weight] 					  						  if xw >= -`bdw' & xw < `bdw' 
					scalar mean_outcome = r(mean) 
				
					quietly reg `var' $dep_vars1 mom_yrs_school i.year 			[pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
					eststo model`model', title("Linear")
					estadd scalar mean_outcome = mean_outcome: model`model'
					local model = `model' + 1
					
					quietly reg `var' $dep_vars2 mom_yrs_school i.year 			[pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
					eststo model`model', title("Quadratic")
					estadd scalar mean_outcome = mean_outcome: model`model'
					local model = `model' + 1
					
					if `bdw' == 3 {
					quietly reg `var' $dep_vars3  								[pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
					eststo model`model', title("No controls")
					estadd scalar mean_outcome = mean_outcome: model`model'
					local model = `model' + 1
					}
				}
				
				if "`var'" == "eap" estout model1 model2 model3 model4 model5 model6 model7 using "$tables/Table`table'.tex", style(tex) keep(D*)  title("`title'") label mgroups("3-months" "5-months" "9-months", pattern(1 0 0 1 0 1 0)) cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) replace
				if "`var'" != "eap" estout model1 model2 model3 model4 model5 model6 model7 using "$tables/Table`table'.tex", style(tex) keep(D*)  title("`title'") label mgroups("3-months" "5-months" "9-months", pattern(1 0 0 1 0 1 0)) cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
				estimates clear
			}	
		}
		
	*Tables 5/6
	*--------------------------------------------------------------------------------------------------------------------------------*
		estimates clear
			use "$final/Child Labor Data.dta" if urban == 1 & male == 1 & year == 1999, clear
			
			local bandwidth 	"3 5 9" 					
		
			foreach var of varlist pwork_sch uwork_sch pwork_only uwork_only study_only nemnem {
			
				if "`var'" == "pwork_sch"   local title = "Paid work and studying"
				if "`var'" == "uwork_sch" 	local title = "Unpaid work and studying"
				if "`var'" == "pwork_only" 	local title = "Only paid work"
				if "`var'" == "uwork_only" 	local title = "Only unpaid work"
				if "`var'" == "study_only" 	local title = "Only studying"
				if "`var'" == "nemnem" 		local title = "Neither working or studying"
			
				local model = 1
				
				foreach bdw of local bandwidth {
					quietly su `var' [w = weight] 					  						  if xw >= -`bdw' & xw < `bdw' 
					scalar mean_outcome = r(mean) 
				
					quietly reg `var' $dep_vars1 mom_yrs_school i.year 			[pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
					eststo model`model', title("Linear")
					estadd scalar mean_outcome = mean_outcome: model`model'
					local model = `model' + 1
					
					quietly reg `var' $dep_vars2 mom_yrs_school i.year 			[pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
					eststo model`model', title("Quadratic")
					estadd scalar mean_outcome = mean_outcome: model`model'
					local model = `model' + 1
					
					if `bdw' == 3 {
					quietly reg `var' $dep_vars3 mom_yrs_school i.year 			[pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
					eststo model`model', title("No controls")
					estadd scalar mean_outcome = mean_outcome: model`model'
					local model = `model' + 1
					}
				}
				
				*Two tables otherwise the table would be so big to fit in overleaf
				if "`var'" == "pwork_sch" 								estout model1 model2 model3 model4 model5 model6 model7 using "$tables/Table5.tex", style(tex) keep(D*)  title("`title'") label mgroups("3-months" "5-months" "9-months", pattern(1 0 0 1 0 1 0)) cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) replace
				if "`var'" == "uwork_sch"  | "`var'" == "pwork_only"	estout model1 model2 model3 model4 model5 model6 model7 using "$tables/Table5.tex", style(tex) keep(D*)  title("`title'") label mgroups("3-months" "5-months" "9-months", pattern(1 0 0 1 0 1 0)) cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
				
				if "`var'" == "uwork_only" 								estout model1 model2 model3 model4 model5 model6 model7 using "$tables/Table6.tex", style(tex) keep(D*)  title("`title'") label mgroups("3-months" "5-months" "9-months", pattern(1 0 0 1 0 1 0)) cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) replace
				if "`var'" == "study_only" | "`var'" == "nemnem" 		estout model1 model2 model3 model4 model5 model6 model7 using "$tables/Table6.tex", style(tex) keep(D*)  title("`title'") label mgroups("3-months" "5-months" "9-months", pattern(1 0 0 1 0 1 0)) cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
				
				estimates clear
			}	
		
		
	*Table 7, Placebo tests
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
		
		local bandwidth 	"3 9" 					
				
		foreach var of varlist eap pwork uwork schoolatt {
		
			local model = 1
		
			if "`var'" == "eap"   		local title = "Eco. Act. Pop"
			if "`var'" == "pwork" 		local title = "Paid work"
			if "`var'" == "schoolatt" 	local title = "School attendance"
			if "`var'" == "uwork" 		local title = "Unpaid work"
		
			foreach bdw of local bandwidth {
				quietly reg `var' D zwP1 zwDP1 mom_yrs_school [pw = weight] if xwP1 >= - `bdw' & xwP1 < `bdw' & year == 1998, cluster(zwP1)  	//Placebo 1. Dec 1997 = cut-off. 9-month bandwidth
				eststo model`model', title("Placebo 1")
				local model = `model' + 1
				
				quietly reg `var' D zwP2 zwDP2 mom_yrs_school [pw = weight] if xwP2 >= - `bdw' & xwP2 < `bdw' & year == 2001, cluster(zwP2)		//Placebo 2. Dec 2000 = cut-off. 9-month bandwidth
				eststo model`model', title("Placebo 2")
				local model = `model' + 1
				
				quietly reg `var' D zwP3 zwDP3 mom_yrs_school [pw = weight] if xwP3 >= - `bdw' & xwP3 < `bdw' & year == 1999, cluster(zwP3)		//Placebo 3. June 1999 = cut-off. 6-month bandwidth
				eststo model`model', title("Placebo 3")
				local model = `model' + 1
			}
			
			if "`var'" == "eap" estout model1 model2 model3 model4 model5 model6 using "$tables/Table7.tex", style(tex) keep(D*)  title("`title'") label mgroups("3-months"  "9-months", pattern(1 0 0 1 0 0)) cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2, labels("Obs" "R2") fmt(%9.0g %9.3f %9.3f)) replace
			if "`var'" != "eap" estout model1 model2 model3 model4 model5 model6 using "$tables/Table7.tex", style(tex) keep(D*)  title("`title'") label mgroups("3-months"  "9-months", pattern(1 0 0 1 0 0)) cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2, labels("Obs" "R2") fmt(%9.0g %9.3f %9.3f)) append
			estimates clear
			
		}	

		
	*Table 8, long term outcomes
	*--------------------------------------------------------------------------------------------------------------------------------*
		estimates clear
		use "$final/Child Labor Data.dta" if urban == 1 & male == 1 & (year >= 2007 & year <= 2014), clear

			local bandwidth 	"3 5 9" 					//bandwidths					
		
			foreach var of varlist $longterm_outcomes {
			
				if "`var'" == "highschool_degree"   local title = "High School"
				if "`var'" == "working" 			local title = "Working"
				if "`var'" == "formal" 				local title = "Formal work"
				if "`var'" == "lnwage_hour" 		local title = "Ln wage hour"

				local model = 1
				
				foreach bdw of local bandwidth {
					quietly su `var' [w = weight] 					  						  if xw >= -`bdw' & xw < `bdw' 
					scalar mean_outcome = r(mean) 
				
					quietly reg `var' $dep_vars1 i.year 						[pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
					eststo model`model', title("Linear")
					estadd scalar mean_outcome = mean_outcome: model`model'
					local model = `model' + 1
					
					quietly reg `var' $dep_vars2 i.year 						[pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
					eststo model`model', title("Quadratic")
					estadd scalar mean_outcome = mean_outcome: model`model'
					local model = `model' + 1
					
					if `bdw' == 3 {
					quietly reg `var' $dep_vars3 i.year 						[pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
					eststo model`model', title("No controls")
					estadd scalar mean_outcome = mean_outcome: model`model'
					local model = `model' + 1
					}
				}
				
				if "`var'" == "highschool_degree" estout model1 model2 model3 model4 model5 model6 model7 using "$tables/Table8.tex", style(tex) keep(D*)  title("`title'") label mgroups("3-months" "5-months" "9-months", pattern(1 0 0 1 0 1 0)) cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) replace
				if "`var'" != "highschool_degree" estout model1 model2 model3 model4 model5 model6 model7 using "$tables/Table8.tex", style(tex) keep(D*)  title("`title'") label mgroups("3-months" "5-months" "9-months", pattern(1 0 0 1 0 1 0)) cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
				estimates clear
			}		
		
		
	*Table 9, placebo for long term outcomes
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
		label var D "ITT"

			local bandwidth 	"3 5 9" 					//bandwidths					
		
			foreach var of varlist $longterm_outcomes {
			
				if "`var'" == "highschool_degree"   local title = "High School"
				if "`var'" == "working" 			local title = "Working"
				if "`var'" == "formal" 				local title = "Formal work"
				if "`var'" == "lnwage_hour" 		local title = "Ln wage hour"

				local model = 1
				
				foreach bdw of local bandwidth {
					quietly su `var' [w = weight] 					  						  if xw >= -`bdw' & xw < `bdw' 
					scalar mean_outcome = r(mean) 
				
					quietly reg `var' $dep_vars1 i.year 						[pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
					eststo model`model', title("Linear")
					estadd scalar mean_outcome = mean_outcome: model`model'
					local model = `model' + 1
					
					quietly reg `var' $dep_vars2 i.year 						[pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
					eststo model`model', title("Quadratic")
					estadd scalar mean_outcome = mean_outcome: model`model'
					local model = `model' + 1
					
					if `bdw' == 3 {
					quietly reg `var' $dep_vars3 i.year 						[pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
					eststo model`model', title("No controls")
					estadd scalar mean_outcome = mean_outcome: model`model'
					local model = `model' + 1
					}
				}
				
				if "`var'" == "highschool_degree" estout model1 model2 model3 model4 model5 model6 model7 using "$tables/Table9.tex", style(tex) keep(D*)  title("`title'") label mgroups("3-months" "5-months" "9-months", pattern(1 0 0 1 0 1 0)) cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) replace
				if "`var'" != "highschool_degree" estout model1 model2 model3 model4 model5 model6 model7 using "$tables/Table9.tex", style(tex) keep(D*)  title("`title'") label mgroups("3-months" "5-months" "9-months", pattern(1 0 0 1 0 1 0)) cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) append
				estimates clear
			}		
			
			
			
			
			
			
	*Bargain
	*--------------------------------------------------------------------------------------------------------------------------------*
	estimates clear
		
			use "$final/Child Labor Data.dta" if year == 1999, clear
			
			local bandwidth 	"3 5 9" 						//bandwidths, in months				
			local controls 		i.male i.color hh_head_school hh_head_age i.hh_head_male i.urban i.metro		
			
			local model = 1
		
			foreach var of varlist child_labor_bargain {		//short-term outcomes
				
				foreach bdw of local bandwidth {
					quietly su `var' [w = weight] 					  	  if xw >= -`bdw' & xw < `bdw' 
					scalar mean_outcome = r(mean) 
				
					reg `var' $dep_vars1 `controls' [pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
					eststo model`model', title("Linear")
					estadd scalar mean_outcome = mean_outcome: model`model'
					local model = `model' + 1
					
					reg `var' $dep_vars2 `controls' [pw = weight] if xw >= -`bdw' & xw < `bdw', cluster(zw)
					eststo model`model', title("Quadratic")
					estadd scalar mean_outcome = mean_outcome: model`model'
					local model = `model' + 1
				}
			}			
			estout  using "$tables/Bargain.tex", style(tex) keep(D*) label mgroups("3-months" "5-months" "9-months", pattern(1 0 1 0 1 0)) cells(b(star fmt(3)) se(fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 mean_outcome, labels("Obs" "R2" "Mean outcome") fmt(%9.0g %9.3f %9.3f)) replace

			
			
			
			
			
			
			
			
	
