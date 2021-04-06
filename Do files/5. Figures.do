		
															 *FIGURES*
	*________________________________________________________________________________________________________________________________*

	
	*Visual Inspection
	*--------------------------------------------------------------------------------------------------------------------------------*
		use "$final/Child Labor Data.dta" if urban == 1 & male == 1 & year == 1999 & xw >= - 12 & xw < 12, clear	

			foreach v of varlist $shortterm_outcomes {
				local `v'_label: var label `v'
			}
			collapse $shortterm_outcomes [pw = weight], by(xw)
			foreach v of varlist $shortterm_outcomes {
				replace   `v' = `v'*100
				label var `v' `"``v'_label'"'
			}

			foreach var of varlist $shortterm_outcomes {
				tw  (lpolyci `var' xw if xw >= 0, degree(0) bw(1) acolor(gs12) fcolor(gs12) clcolor(gray) clwidth(0.3)) 		///
					(lpolyci `var' xw if xw <  0, degree(0) bw(1) acolor(gs12) fcolor(gs12) clcolor(gray) clwidth(0.3)) 		///
					(scatter `var' xw if xw >= -12 & xw <  0 , sort msymbol(circle) msize(small) mcolor(navy))         		 	///
					(scatter `var' xw if xw >=   0 & xw <= 12, sort msymbol(circle) msize(small) mcolor(cranberry)), xline(0) 	///
					legend(off) 																								///
					title({bf:`: variable label `var''}, pos(11) span size(large))												///
					ytitle("%") xtitle("Age difference from the cutoff (in months)") 											/// 
					note("Source: PNAD 1999. 95% CI.", color(black) fcolor(background) pos(7) size(small)) saving(short_`var'.gph, replace) 
					*graph export "$figures/Figure_RDD_`var'.pdf", as(pdf) replace
			}
			
			graph combine short_eap.gph short_pwork.gph short_uwork.gph short_schoolatt.gph, graphregion(fcolor(white)) ysize(5) xsize(7) title(, fcolor(white) size(medium) color(cranberry))
			graph export "$figures/RDD_shortterm outcomes.pdf", as(pdf) replace
			foreach var of varlist $shortterm_outcomes {
			erase short_`var'.gph
			}	
			
					
