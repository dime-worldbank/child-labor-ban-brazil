


			use "$final/Child Labor Data.dta" if male == 1 & urban == 1 & zw > -13 & zw < 12 & schoolatt != ., clear
		
			tab edu_att, gen(educ)
			
			collapse (mean)schoolatt educ1-educ7 [pw = weight], by(year D)


			
		use "$final/Child Labor Data.dta" if male == 1 & urban == 1 & zw > -13 & zw < 12 & schoolatt != . & year > 2006, clear

			
			gen ef =  inlist(edu_att, 2, 3)
			gen em =  inlist(edu_att, 4, 5)
			gen es =  inlist(edu_att, 6, 7)
			
			
			collapse (mean)schoolatt ef em es [pw = weight], by(year D)
		
			graph bar (asis) ef em es  , graphregion(color(white)) bar(1, lwidth(0.2) lcolor(navy) color(emidblue)) bar(2, lwidth(0.2) lcolor(black) color(gs12))  bar(3, color(emidblue))   																	///
			over(year, sort(year) label(labsize(small))) over(D) stack 				///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 																									///
			plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 																									///
			blabel(bar, position(outside) orientation(horizontal) size(vsmall)  color(black) format (%12.2fc))   																								///
			ylabel(, nogrid labsize(small) angle(horizontal)) 																																					///
			yscale(alt) 																																														///
			ysize(5) xsize(7) 																																													///
			ytitle("%", size(medsmall) color(black))  																

			legend(order(1 "Extended winter break" 2 "Other municipalities") region(lwidth(none) color(white) fcolor(none)) cols(4) size(large) position(6))													///
			note("Source: School Census INEP 2009.", span color(black) fcolor(background) pos(7) size(vsmall))
			graph export "$figures/school_infra.pdf", as(pdf) replace	

				
		use "$final/Child Labor Data.dta" if male == 1 & urban == 1 & zw > -13 & zw < 12 & schoolatt != . & year < 2007 , clear
	
			collapse (mean)schoolatt highschool_degree [pw = weight], by(year D)
				
			tw ///
			(line schoolatt year if D == 1, lcolor(black)) ///
			(line schoolatt year if D == 0, lcolor(black) lp(shortdash)) ///
						
			
						tw ///
			(line highschool_degree year if D == 1, lcolor(black)) ///
			(line highschool_degree year if D == 0, lcolor(black) lp(shortdash)) ///
						
			
			
			
		use "$final/Child Labor Data.dta" if male == 1 & urban == 1 & zw > -13 & zw < 12 & schoolatt != . & year < 2007 , clear
	

			gen ef =  inlist(edu_level_enrolled, 3, 4, 5)
			gen em =  inlist(edu_level_enrolled, 6, 7, 8)
			gen es =  inlist(edu_level_enrolled, 9)
			
	
			collapse (mean)schoolatt  ef em es [pw = weight], by(year D)

			
			tw ///
			(line ef year if D == 1, lcolor(black)) ///
			(line ef year if D == 0, lcolor(black) lp(shortdash)) ///
			(line em year if D == 1, lcolor(red)) ///
			(line em year if D == 0, lcolor(red) lp(shortdash)) ///
			(line es year if D == 1, lcolor(blue)) ///
			(line es year if D == 0, lcolor(blue) lp(shortdash)) ///
			
			
			
			
			
			
			
			
			
			
			
			
			
			gen ef =  inlist(edu_level_enrolled, 3, 4, 5)
			gen em =  inlist(edu_level_enrolled, 6, 7, 8)
			gen es =  inlist(edu_level_enrolled, 9)
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			gen ef = level_enrolled1 + level_enrolled2
			 
			
			foreach var of varlist educ* {
				replace `var' = `var'*100
			}
			
			format educ* %12.2fc
			
			
			graph bar (percent) educ4 educ5 educ6 educ7, over(year) stack
			
			
			
			
	
	
			use "$final/Child Labor Data.dta", clear
	
			gen 		age14_15 = age == 14 | age== 15
			replace 	age14_15 = . if age== .
			
			keep if age14_15 == 1
			collapse (mean)pea ocupado working [pw = weight], by(year)
			
			tw ///
			line working year
			
	
			
	
	
	
	
			use "$final/Child Labor Data.dta" if urban == 1 & male == 1 & year == 1999 & xw >= - 1 & xw < 1, clear	
			
			
			
			gen 	tempo_trabalho = 12*years_current_work + months_current_work if !missing(years_current_work)
	
			replace tempo_trabalho = months_current_work 						 if  missing(years_current_work)
	
			su 		tempo_trabalho, detail
			replace tempo_trabalho = . if tempo_trabalho > r(p95)
			
			gen got_work_bef_law= 1 if tempo_trabalho >= 9 & !missing(tempo_trabalho)
			replace got_work_bef_law= 0 if tempo_trabalho < 9
			
			 graph box  tempo_trabalho [pw = weight], over(D)
			
			gen id = 1
			collapse (sum) id working pwork uwork formal informal  (mean)tempo_trabalho got_work_bef_law age [pw = weight], by(D)

			
			
			
			
			
			
			
			tw (histogram tempo_trabalho if D == 0, lcolor(blue) fcolor(none)) || (histogram tempo_trabalho if D == 1, lcolor(red) fcolor(none))
			
			
			gen 	threshold = 9 - tempo_trabalho if !missing(tempo_trabalho)
			
			
			
			tw (scatter working threshold if threshold >= 0) || (scatter working threshold if threshold < 0) 
	
	
	
	
	
	
	
	
	
	
	sort zw month_birth day_birth
	
	br year day_birth month_birth year_birth xw zw if year == 1999 & zw > -3 & zw < 3			
	
	
	
