		
															 *FIGURES*
	*________________________________________________________________________________________________________________________________*

	
	*Visual Inspection
	*--------------------------------------------------------------------------------------------------------------------------------*
		use "$final/Child Labor Data.dta" if urban == 1 & male == 1 & year == 1999 & xw >= - 12 & xw < 12, clear	

			foreach v of varlist eap {
				local `v'_label: var label `v'
			}
			collapse eap [pw = weight], by(xw)
			foreach v of varlist  eap {
				replace   `v' = `v'*100
				label var `v' `"``v'_label'"'
			}

			foreach var of varlist eap {
				tw  (lpolyci `var' xw if xw >= 0, degree(0) bw(1) acolor(gs12) fcolor(gs12) clcolor(gray) clwidth(0.3)) 		///
					(lpolyci `var' xw if xw <  0, degree(0) bw(1) acolor(gs12) fcolor(gs12) clcolor(gray) clwidth(0.3)) 		///
					(scatter `var' xw if xw >= -12 & xw <  0 , sort msymbol(circle) msize(small) mcolor(navy))         		 	///
					(scatter `var' xw if xw >=   0 & xw <= 12, sort msymbol(circle) msize(small) mcolor(cranberry)), xline(0) 	///
					legend(off) 																								///
					title({bf:`: variable label `var''}, pos(11) span size(large))												///
					ytitle("%") xtitle("Age difference from the cutoff (in months)") 											/// 
					note("Source: PNAD 1999. 95% CI.", color(black) fcolor(background) pos(7) size(small)) 
					graph export "$figures/Figure_`var'.pdf", as(pdf) replace
			}
			
	/*		
	*Figure 1a/1b
	*--------------------------------------------------------------------------------------------------------------------------------*
		use "$final/Child Labor Data.dta" if urban == 1 & year == 1999 & xw >= - 9 & xw < 0, clear	

			collapse (mean) $shortterm_outcomes [pw = weight], by(male)
		
			foreach var of varlist $shortterm_outcomes {
				replace `var' = `var'*100
				format 	`var' %12.2fc
				rename  `var' A_`var'
			}
		
			reshape long A_, i(male) 	 j(variable) string
			reshape wide A_, i(variable) j(male)
			
			gen 	ordem = 1  if variable == "uwork"
			replace ordem = 2  if variable == "pwork"
			replace ordem = 3  if variable == "schoolatt"
			replace ordem = 4  if variable == "pwork_sch"
			replace ordem = 5  if variable == "uwork_sch"
			replace ordem = 6  if variable == "pwork_only"
			replace ordem = 7  if variable == "uwork_only"
			replace ordem = 8  if variable == "study_only"
			replace ordem = 9  if variable == "nemnem"

			//unpaid work, unpaid work and school attendance
			graph bar (asis)A_0 A_1 if ordem == 1 | ordem == 2 | ordem == 3, bargap(5) bar(2,  lw(0.5) lcolor(navy) fcolor(gs12)) bar(1, lw(0.5) lcolor(emidblue) fcolor(gs12) fintensity(70))			///
			over(ordem, sort(ordem) label(labsize(small))relabel(1 `"Unpaid work"'  2 `"Paid work"' 3 `""School" "Attendance""'))																		///
			blabel(bar, position(outside) orientation(horizontal) size(medsmall) color(black) format (%4.1fc))   																						///
			title("", pos(12) size(medsmall) color(black)) subtitle(, pos(12) size(medsmall) color(black)) 																								///
			ytitle("%", size(medsmall)) 																																								///
			yscale(off)	 																																												///
			legend(order(1 "Girls" 2 "Boys")  region(lwidth(none) color(white) fcolor(none)) cols(2) size(large) position(12))      		            												///
			note("Source: PNAD 1999." , color(black) fcolor(background) pos(7) size(small)) 																											///
			xsize(6) ysize(5) 
			local nb =`.Graph.plotregion1.barlabels.arrnels'
			di `nb'
			forval i = 1/`nb' {
			  di "`.Graph.plotregion1.barlabels[`i'].text[1]'"
			  .Graph.plotregion1.barlabels[`i'].text[1]="`.Graph.plotregion1.barlabels[`i'].text[1]'%"
			}
			.Graph.drawgraph
			graph export "$figures/Figure1a.pdf", as(pdf) replace

			//working and studying, only working or only studying
			graph bar (asis)A_0 A_1 if ordem > 3 & ordem < 10 , bargap(5) bar(2,  lw(0.5) lcolor(navy) fcolor(gs12)) bar(1, lw(0.5) lcolor(emidblue) fcolor(gs12) fintensity(70))			///
			over(ordem, sort(A_1) label(labsize(small)) relabel(1 `" "Paid work" "and study  "' 2 `" "Unpaid work"  "and study" "'  3 `" "Only" "paid work"   "'  4 `"  "Only" "unpaid work"  "'  5 `" "Only" "study"  "'  6 `" "Neither working" "or studying" "'  ) )																					///
			blabel(bar, position(outside) orientation(horizontal) size(medsmall) color(black) format (%4.1fc))   																			///
			title("", pos(12) size(medsmall) color(black)) subtitle(, pos(12) size(medsmall) color(black)) 																					///
			yscale(off)	 																																									///		
			ytitle("%", size(medsmall)) 																																					///
			legend(order(1 "Girls" 2 "Boys")  region(lwidth(none) color(white) fcolor(none)) cols(2) size(large) position(12))      		            									///
			note("Source: PNAD 1999." , color(black) fcolor(background) pos(7) size(small)) 																								///	
			xsize(6) ysize(5) 
			local nb =`.Graph.plotregion1.barlabels.arrnels'
			forval i = 1/`nb' {
			.Graph.plotregion1.barlabels[`i'].text[1]="`.Graph.plotregion1.barlabels[`i'].text[1]'%"
			}
			.Graph.drawgraph
			graph export "$figures/Figure1b.pdf", as(pdf) replace

	
	*Figure 4
	*--------------------------------------------------------------------------------------------------------------------------------*
		use "$final/Child Labor Data.dta" if year >= 1998 & year <= 2006 & urban == 1 & male == 1 & xw >= - 9 & xw <= 0, clear	

			collapse (mean) $shortterm_outcomes [pw = weight], by(year)
		
			foreach var of varlist $shortterm_outcomes {
				replace `var' = `var'*100
				format 	`var' %12.1fc
			}
	
			tw 	///
				(line pwork year, msize(1) lwidth(1) color(emidblue)  lp(shortdash) connect(direct) recast(connected) mlabel(pwork) mlabcolor(black) mlabpos(12))   		///  
				(line uwork year, msize(1) lwidth(1) color(cranberry) lp(shortdash) connect(direct) recast(connected) mlabel(uwork) mlabcolor(black) mlabpos(12)) 		 	///  
				(line schoolatt year , msize(1) lwidth(1) color(green*0.8)   lp(shortdash) connect(direct) recast(connected) mlabel(schoolatt) mlabcolor(black) mlabpos(12) ///
				ylabel(, labsize(small) angle(horizontal) format(%2.1fc)) 																									///
				yscale(off) 																																				/// 
				xlabel(1998 `" "1998" "Age-13" "' 1999 `" "1999" "Age-14" "' 2001 `" "2001" "Age-16" "' 2002 `" "2002" "Age-17" "' 2003 `" "2003" "Age-18" "' 2004 `" "2004" "Age-19" "' 2005 `" "2005" "Age-20" "' 2006 `" "2006" "Age-21" "', labsize(small) gmax angle(horizontal)) 											///
				ytitle("%", size(medsmall)) xtitle("") 			 																											///
				legend(order(1 "Paid work" 2 "Unpaid work" 3 "School attainment") pos(12) region(lstyle(none) fcolor(none)) size(medsmall))  								///
				note("Source: PNAD.", span color(black) fcolor(background) pos(7) size(small))) 
				graph export "$figures/Figure4.pdf", as(pdf) replace
						
						
	*Appendix C						
	*--------------------------------------------------------------------------------------------------------------------------------*
		use "$final/Child Labor Data.dta" if urban == 1 & male == 1 & year == 1999 & xw >= - 9 & xw <= 9, clear	
											
			collapse (mean) work_formal work_informal [pw = weight], by(D)
		
			foreach var of varlist work_formal work_informal {
				replace `var' = `var'*100
				format 	`var' %12.2fc
				rename  `var' A_`var'
			}
			
			reshape long A_, i(D) j(variable) string
			reshape wide A_, i(variable) j(D)
						
			graph bar (asis)A_0 A_1, bargap(5) bar(2,  lw(0.5) lcolor(navy) fcolor(gs12)) bar(1, lw(0.5) lcolor(emidblue) fcolor(gs12) fintensity(70))						///
			over(variable, sort() label(labsize(small)) relabel(1 `" Formal "' 2 	`" Informal "'  ))																		///
			blabel(bar, position(outside) orientation(horizontal) size(medsmall) color(black) format (%4.1fc))   															///
			title("", pos(12) size(medsmall) color(black)) subtitle(, pos(12) size(medsmall) color(black)) 																	///
			ytitle("%", size(medsmall)) 																																	///
			yscale(off)	 																																					///
			legend(order(1 "Unaffected cohort" 2 "Affected cohort")  region(lwidth(none) color(white) fcolor(none)) cols(2) size(large) position(12))      		            ///
			note("Source: PNAD 1999." , color(black) fcolor(background) pos(7) size(small)) 																				///
			xsize(5) ysize(5) 
			local nb =`.Graph.plotregion1.barlabels.arrnels'
			forval i = 1/`nb' {
			.Graph.plotregion1.barlabels[`i'].text[1]="`.Graph.plotregion1.barlabels[`i'].text[1]'%"
			}
			.Graph.drawgraph
			graph export "$figures/FigureAppendixC.pdf", as(pdf) replace
						
		
	*Figures 6 - 14
	*--------------------------------------------------------------------------------------------------------------------------------*
		
		**
		*Regressions
		**
		
			matrix results = (0, 0, 0, 0, 0, 0)
			set level 90
			estimates clear
			use "$final/Child Labor Data.dta" if urban == 1 & male == 1, clear
			local bandwidth 	"6" 						
			local variable = 1
			foreach var of varlist $shortterm_outcomes {
				foreach year in 1998 1999 2001 2002 2003 2004 2005 2006 {
					foreach bdw of local bandwidth {
						quietly reg `var' D zw [pw = weight] if xw >= -`bdw' & xw <= `bdw' & year == `year', cluster(zw)
						matrix results = results \ (`year', `variable', 0, el(r(table),1,1), el(r(table),5,1), el(r(table),6,1))
					}
				}
				local variable = `variable' + 1
			}
			local bandwidth 	"6" 						
			local variable = 1
			foreach var of varlist $longterm_outcomes {
				foreach year in 2007 2008 2009 2011 2012 2013 2014      { 
					foreach bdw of local bandwidth {
						quietly reg `var' D zw [pw = weight] if xw >= -`bdw' & xw <= `bdw' & year == `year', cluster(zw)
						matrix results = results \ (`year', 0, `variable', el(r(table),1,1), el(r(table),5,1), el(r(table),6,1))
					}
				}
				local variable = `variable' + 1
			}
			set level 95

		**
		*Results
		**
			clear
			svmat results
			
			drop  in 1
			rename (results1-results6) (year shortterm_outcomes longterm_outcomes ITT lower upper)	
			
			label define shortterm_outcomes  1 "Paid work" 					2 "Formal paid work" 				3 "Informal paid work" 	4  "Unpaid work"    5 "School attendance" 				6 "Paid work and studying" ///
											 7 "Unpaid work and studying" 	8 "Only paid work" 					9 "Only unpaid work" 	10 "Only studying" 11 "Neither working or studying"

			label define longterm_outcomes   1 "Years of schooling" 		2 "At least High School degree" 	3 "College degree" 		///
											 4 "Employed" 					5 "Formal occupation" 				6 "Log-earnings" 
											
			label val shortterm_outcomes shortterm_outcomes
			label val longterm_outcomes  longterm_outcomes

			label var ITT    "ITT"
			label var lower  "Lower bound"
			label var upper  "Upper bound"
			format ITT lower upper %4.2fc
			
			gen	 	year_n1 = 0
			local 	ordem = 1
			foreach year in 1998 1999 2001 2002 2003 2004 2005 2006 {
				replace year_n1 = `ordem' if year == `year'
				local  ordem = `ordem' + 1 
			}
			gen 	year_n2 = 0
			local 	ordem = 1
			foreach year in  2007 2008 2009 2011 2012 2013 2014     {
				replace year_n2 = `ordem' if year == `year'
				local  ordem = `ordem' + 1 
			}
			save "$final/Regression Results.dta", replace
		
		**
		*Charts
		**
			use  "$final/Regression Results.dta" if shortterm_outcomes != 0, clear
			local figure = 6
			forvalues shortterm_outcomes = 1(1)11 {
				preserve
					keep if shortterm_outcomes == `shortterm_outcomes'
					
					su lower, detail
					local min = r(min) + r(min)/3
					su upper, detail
					local max = r(max) + r(max)/3
					
					twoway   scatter ITT year_n1,  color(cranberry) || rcap lower upper year_n1, lcolor(navy)																	///
					yline(0, lw(1) lp(shortdash) lcolor(cranberry))				 																								///
					xlabel(1 `" "1998" "' 2 `" "1999" "' 3 `" "2001" "' 4 `" "2002" "' 5 `" "2003" "' 6 `" "2004" "' 7 `" "2005" "' 8 `" "2006" "' , labsize(small) ) 			///
					xtitle("", size(medsmall)) 											  																						///
					yscale(r(`min' `max'))	 																																	///
					ytitle("ITT", size(small))					 																												///					
					title(`: label shortterm_outcomes `shortterm_outcomes'')																									///
					legend(off)  																																				///
					note("Source: PNAD.", color(black) fcolor(background) pos(7) size(small)) 
					graph export "$figures/Figure`figure'.pdf", as(pdf) replace
					local figure = `figure' + 1
				restore
			}
		
		use  "$final/Regression Results.dta" if longterm_outcomes != 0, clear
			local figure = 16
			forvalues longterm_outcomes = 1(1)6 {
				preserve
					keep if longterm_outcomes == `longterm_outcomes'
					
					su lower, detail
					local min = r(min) + r(min)/3
					su upper, detail
					local max = r(max) + r(max)/3

					twoway   scatter ITT year_n2,  color(cranberry) || rcap lower upper year_n2, lcolor(navy)																	///
					yline(0, lw(1) lp(shortdash) lcolor(cranberry))				 																								///
					xlabel(1 `" "2007" "' 2 `" "2008" "' 3 `" "2009" "' 4 `" "2011" "' 5 `" "2012" "' 6 `" "2013" "' 7 `" "2014" "' , labsize(small) ) 							///
					xtitle("", size(medsmall)) 											  																						///
					yscale(r(`min' `max')) 																																		///
					ytitle("ITT", size(small))					 																												///					
					title(`: label longterm_outcomes `longterm_outcomes'')																										///
					legend(off)  																																				///
					note("Source: PNAD.", color(black) fcolor(background) pos(7) size(small)) 
					graph export "$figures/Figure`figure'.pdf", as(pdf) replace
					local figure = `figure' + 1
				restore
			}

	
	
