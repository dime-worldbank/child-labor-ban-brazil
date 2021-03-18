		
															 *FIGURES*
	*________________________________________________________________________________________________________________________________*

	
	*APPENDIX B FIGURES
	*--------------------------------------------------------------------------------------------------------------------------------*
		use "$final/Child Labor Data.dta" if urban == 1 & male == 1 & year == 1999 & xw >= - 12 & xw <= 12, clear	
		
			foreach v of varlist $shortterm_outcomes {
				local `v'_label: var label `v'
			}
			collapse $shortterm_outcomes  [aw = weight], by(xw)
			foreach v of varlist $shortterm_outcomes {
				replace   `v' = `v'*100
				label var `v' `"``v'_label'"'
			}

			foreach var of varlist $outcome {
				tw  (lpolyci `var' xw if xw >  0, degree(0) bw(1) acolor(gs12) fcolor(gs12) clcolor(gray) clwidth(0.3)) 		///
					(lpolyci `var' xw if xw <= 0, degree(0) bw(1) acolor(gs12) fcolor(gs12) clcolor(gray) clwidth(0.3)) 		///
					(scatter `var' xw if xw >= -12 & xw <  0 , sort msymbol(circle) msize(small) mcolor(navy))         		 	///
					(scatter `var' xw if xw >=   0 & xw <= 12, sort msymbol(circle) msize(small) mcolor(cranberry)), xline(0) 	///
					legend(off) 																								///
					title({bf:`: variable label `var''}, pos(11) span size(large))												///
					ytitle("%") xtitle("Age difference from the cutoff (in months)") 											/// 
					note("Source: PNAD 1999. 95% CI.", color(black) fcolor(background) pos(7) size(small)) 
					graph export "$figures/Local linear_`var'.pdf", as(pdf) replace
			}
			
	*Figure 1a/1b
	*--------------------------------------------------------------------------------------------------------------------------------*
		use "$final/Child Labor Data.dta" if urban == 1 & male == 1 & year == 1999 & xw >= - 9 & xw < 0, clear	

			collapse (mean) $shortterm_outcomes [aw = weight], by(male)
		
			foreach var of varlist $outcome {
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
			over(ordem, sort(ordem) label(labsize(small))relabel(1 `"Unpaid work"'  2 `"Paid work"' 3 `""School" "Attendance""'))																						///
			blabel(bar, position(outside) orientation(horizontal) size(medsmall) color(black) format (%4.1fc))   								///
			title("", pos(12) size(medsmall) color(black)) subtitle(, pos(12) size(medsmall) color(black)) 									///
			ytitle("%", size(medsmall)) 																		///
			legend(order(1 "Girls" 2 "Boys")  region(lwidth(none) color(white) fcolor(none)) cols(2) size(large) position(12))      		            		///
			note("Source: PNAD 1999." , color(black) fcolor(background) pos(7) size(small)) 		///
			xsize(7) ysize(5) 
			local nb =`.Graph.plotregion1.barlabels.arrnels'
				di `nb'
				forval i = 1/`nb' {
				  di "`.Graph.plotregion1.barlabels[`i'].text[1]'"
				  .Graph.plotregion1.barlabels[`i'].text[1]="`.Graph.plotregion1.barlabels[`i'].text[1]'%"
				}
				.Graph.drawgraph

			graph bar (asis)A_0 A_1 if ordem > 3 & ordem < 10 , bargap(5) bar(2,  lw(0.5) lcolor(navy) fcolor(gs12)) bar(1, lw(0.5) lcolor(emidblue) fcolor(gs12) fintensity(70))			///
			over(ordem, sort(A_1) label(labsize(small)) relabel(1 `" "Paid work" "and study  "' 2 `" "Unpaid work"  "and study" "'  3 `" "Only" "paid work"   "'  4 `"  "Only" "unpaid work"  "'  5 `" "Only" "study"  "'  6 `" "Neither working" "or studying" "'  ) )																					///
			blabel(bar, position(outside) orientation(horizontal) size(medsmall) color(black) format (%4.1fc))   								///
			title("", pos(12) size(medsmall) color(black)) subtitle(, pos(12) size(medsmall) color(black)) 									///
			yscale(off) ///
			ytitle("%", size(medsmall)) 																		///
			legend(order(1 "Girls" 2 "Boys")  region(lwidth(none) color(white) fcolor(none)) cols(2) size(large) position(12))      		            		///
			note("Source: PNAD 1999." , color(black) fcolor(background) pos(7) size(small)) 	 ///	
			xsize(6) ysize(5) 
			local nb =`.Graph.plotregion1.barlabels.arrnels'
				di `nb'
				forval i = 1/`nb' {
				  di "`.Graph.plotregion1.barlabels[`i'].text[1]'"
				  .Graph.plotregion1.barlabels[`i'].text[1]="`.Graph.plotregion1.barlabels[`i'].text[1]'%"
				}
				.Graph.drawgraph
	

	
	
	use "$final/Child Labor Data.dta" if year >= 1998 & year <= 2006 & urban == 1 & male == 1 & xw >= - 9 & xw <= 0, clear	

	collapse (mean) $outcome [aw = weight], by(year)
	
	foreach var of varlist $outcome {
		replace `var' = `var'*100
		format 	`var' %12.1fc
	}
	
	
	
				tw 	///
												(line pwork year, msize(1) lwidth(1) color(emidblue) lp(shortdash) connect(direct) recast(connected) mlabel(pwork) mlabcolor(black) mlabpos(12))   ///  
												(line uwork year, msize(1) lwidth(1) color(cranberry) lp(shortdash) connect(direct) recast(connected) mlabel(uwork) mlabcolor(black) mlabpos(12))  ///  
												(line schoolatt year , msize(1) lwidth(1) color(green*0.8)   lp(shortdash) connect(direct) recast(connected) mlabel(schoolatt) mlabcolor(black) mlabpos(3)   ///
												ylabel(, labsize(small) angle(horizontal) format(%2.1fc)) 											///
												yscale(off) /// 
												xlabel(, labsize(small) gmax angle(horizontal)) 											///
												ytitle("%", size(medsmall))			 											///
												xtitle("", size(medsmall)) 																			///
												title("", pos(12) size(medsmall)) 																	///
												subtitle(, pos(12) size(medsmall)) 																	///
												legend(order(1 "Paid work" 2 "Unpaid work" 3 "School attainment") pos(6) region(lstyle(none) fcolor(none)) size(medsmall))  ///
												note("Source: PNAD.", color(black) fcolor(background) pos(7) size(small))) 
												graph export "$.pdf", as(pdf) replace
											
							
