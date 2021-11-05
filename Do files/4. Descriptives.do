

	*Figures and Tables
	*____________________________________________________________________________________________________________________________________*
	*____________________________________________________________________________________________________________________________________*
	*____________________________________________________________________________________________________________________________________*



	**
	*____________________________________________________________________________________________________________________________________*
	**
	*Descriptive Statistics cited in the Paper
	*____________________________________________________________________________________________________________________________________*
	**
	
		//-------------->>
		//3. Institutional Setting and the Intervention
		//
		{
			**
			*The share of unaffected and affected 14-year-olds in formal sector in 1999
			**
			
				use "$final/child-labor-ban-brazil.dta" if year == 1999 & xw >= - 6 & xw < 6, clear		//6-month bandwidth
				
				tab working informal 	if D == 0 						[w = weight]	// 1/30  in formal sector
				
				tab working informal 	if D == 1 						[w = weight]	// 1/100 in formal sector
				
				**Thus, among those working, the unaffected 14-year-olds were 3 times more likely to be in the formal sector than the affected ones. 
			
			**
			*% of 14-year-olds in the formal market
			**
				use "$final/child-labor-ban-brazil.dta" if year == 1999 & age == 14, clear	
					su formal if working == 1 [w = weight], detail	//1.5% of 14-year-olds working were in the formal sector
				
			**
			*% of 14-year-olds that already finished lower secondary education (9th grade)
			**
				use "$final/child-labor-ban-brazil.dta" if year == 1999 & age == 14, clear	
					su lowersec_degree, detail						//Only 3.3% of 14-year-olds in 1999 had finished lower secondary education
					
	
					
		}	
			
		//-------------->>
		//5. Data
		//
		{
			**
			*Average number of individuals in PNAD
			**
				use "$inter/Pooled_PNAD.dta", clear
				gen id = 1
				collapse (sum) id, by(year)
				collapse (mean)id						//380.000
				
			**
			*Average number of households in PNAD
			**
				use "$inter/Pooled_PNAD.dta", clear
				duplicates drop hh_id year, force //
				gen 	id = 1
				collapse (sum) id, by(year)
				collapse (mean)id						//111.000
				
			**
			*Part of the unaffected cohort that was still studying by the age of 19 
			**
				use "$final/child-labor-ban-brazil.dta" if year == 2004 & zw >= - 12 & zw < 12 & schoolatt == 1, clear	
				tab 		edu_level_enrolled 			[w = weight]	
				bys D: tab 	edu_level_enrolled 			[w = weight]						//the majority of them still in primary and secondary education, suggesting delays
			
			**
			*Unemployment rate in Brasil in 1998
			**
				use "$inter/Pooled_PNAD.dta", clear
				su unemployed [w = weight] if inrange(age, 18,65)     //unemployment rate in Brasil in 1998

			**
			*14-year-olds in urban areas 
			**
				use "$final/child-labor-ban-brazil.dta" if year == 1998 & age == 14, clear	
				tab urban [w = weight]
			
			**
			*14-year-olds in economically active population and unemployed
			**
				use "$final/child-labor-ban-brazil.dta" if year == 1998 & age == 14, clear	
				tab eap  			[w = weight]			
				tab unemployed		[w = weight]	
				
			**
			*14-year-olds working in paid and unpaid activities
			**
				use "$final/child-labor-ban-brazil.dta" if year == 1998 & age == 14, clear	
				tab unpaid_work if working == 1 [w = weight]
				
			**
			*Share of children's income in total household income
			**
				use "$final/child-labor-ban-brazil.dta" if year == 1998 & age == 14, clear	
				gen share_chidren_income = children_income/hh_income
				su 	share_chidren_income, detail
				
				
			**
			*14-year-olds attending school
			**				
				use "$final/child-labor-ban-brazil.dta" if year == 1998 & age == 14, clear	
				tab schoolatt									[w = weight]
				tab edu_level_enrolled 		if schoolatt == 1	[w = weight]
				
				tab schoolatt  				if working   == 1 	[w = weight]
				tab edu_att										[w = weight]						
				
		}
		
		//-------------->>
		//6. Results
		//
		{
			**
			**Educational attainment of the affected cohorts by 2003
			**				
				use "$final/child-labor-ban-brazil.dta" if zw >= - 12 & zw < 12 & male == 1 & urban == 1, clear
				
				bys D: tab edu_level_enrolled 	  [w = weight] if year == 2003 
				bys D: tab edu_att 				  [w = weight] if year == 2004 
				bys D: tab lowersec_degree		  [w = weight] if year == 2004
				bys D: tab highschool_degree	  [w = weight] if year == 2004
				
				bys year: su goes_public_school if schoolatt == 1 & inrange(edu_level_enrolled, 1,5) [w = weight]
				
								
			**	
			**Educational level of those affected and unaffected within time
			**				
				use "$final/child-labor-ban-brazil.dta" if zw >= - 12 & zw < 12 & male == 1 & urban == 1 & year < 2005, clear
				
				bys year: su schoolatt			  [w = weight] 	if D == 1
				bys year: tab edu_level_enrolled  [w = weight]	if D == 1				
				bys year: tab edu_att 			  [w = weight] 	if D == 1 & schoolatt == 0	// a maior parte dos que estavam fora da escola tinha EF incompleto
				
				bys year: su schoolatt			  [w = weight]  if D == 0
				bys year: tab edu_level_enrolled  [w = weight]  if D == 0				
				bys year: tab edu_att 			  [w = weight]  if D == 0 & schoolatt == 0	// a maior parte dos que estavam fora da escola tinha EF incompleto

				
				
				use "$final/child-labor-ban-brazil.dta" if zw >= - 12 & zw < 12, clear
								
				bys D: tab edu_level_enrolled 		if year == 2003, mis
				bys D: tab edu_att 					if year == 2003
				bys D: tab lowersec_degree
				bys D: tab highschool_degree
		}
	
	
	**
	*____________________________________________________________________________________________________________________________________*
	**
	*Table A1
	*____________________________________________________________________________________________________________________________________*
	**
	{
		estimates clear
		use "$final/child-labor-ban-brazil.dta" if year == 1999 & (zw >= -12 & zw < 12 ), clear			//12 week bandwidth in 1999
		iebaltab  mom_yrs_school hh_head_edu mom_age hh_size adults_income [pw = weight],   pttest  format(%12.2fc) grpvar(D) savetex("$tables/TableA1.tex") rowvarlabels 			///
		tblnote("Source: PNAD, 1999.") notecombine texdocument  texcaption("Balance test for affected and unaffected cohorts, 12-week bandwidth (1999)") replace
	}	
			
	**
	*____________________________________________________________________________________________________________________________________*
	**
	*Table A2
	*____________________________________________________________________________________________________________________________________*
	**
	{
		use "$final/child-labor-ban-brazil.dta" if year == 1998 & age == 14, clear	
	
		replace pwork 				  		= . 				if working 	== 0										//among those working, % in paid work 				(because pwork = . if working = 0)
		replace uwork 				  		= . 				if working 	== 0										//among those working, % in unpaid work				(because uwork = . if working = 0)
		replace pwork_formal	 	  		= . 				if pwork 	== 0										//among those in paid work, % in formal sector		(formal = 0 or 1 only if pwork == 1)
		gen 	hours_worked_pwork 	  		= hours_worked 		if pwork 	== 1										//hours worked in paid work
		gen 	hours_worked_uwork 	  		= hours_worked 		if uwork 	== 1										//hours worked in unpaid work

		gen 	housekeeper 		  		= 1 				if pwork 	== 1 & type_work_noagric 			== 2	//among paid workers, % working as housekeepers
		replace housekeeper 		  		= 0 				if pwork 	== 1 & missing(housekeeper)  		  
		
		gen 	place_work_factory    		= 1					if pwork 	== 1 & place_work 		  			== 1	//among the paid workers, % working in factories
		replace place_work_factory    		= 0					if pwork 	== 1 & missing(place_work_factory)		
		
		gen 	place_work_employer_house 	= 1 				if pwork 	== 1 & place_work 		  			== 4	//among the paid workers, % working in the house of the employee
		replace place_work_employer_house 	= 0 				if pwork 	== 1 & missing(place_work_employer_house)
		
		gen 	agriculture			  		= 1 				if uwork 	== 1 & agric_sector 	  			== 1 	//among the unpaid workers, % working in the agriculture sector
		replace agriculture 		  		= 0 		 		if uwork 	== 1 & missing(agriculture)
		
		gen	 	working_for_household 		= 1 				if uwork 	== 1 & member_household_self_consu  == 1	//among unpaid workers, % working for the household
		replace working_for_household 		= 0 				if uwork 	== 1 & missing(working_for_household)

		gen 	lower_sec_enrollment = 0 						if schoolatt == 1 & inlist(edu_level_enrolled, 6, 7, 8, 9)
		replace lower_sec_enrollment = 1 						if schoolatt == 1 & missing(lower_sec_enrollment)
		
		label var lower_sec_enrollment							"Among those attending school, share enrolled 1st to 9th grade"
		label var pwork_formal									"Among those paid, share in the formal sector"
		label var eap											"Economically active children"
		label var unemployed									"Share unemployed among the economically active"
		label var working										"Share of 14-year-olds working"
		label var pwork											"Among those working, share in paid work"
		label var uwork											"Among those working, share in unpaid work"
		label var working_for_household 						"Among those unpaid, share working for the household" 
		label var housekeeper									"Among those paid, share working as housekeepers" 
		label var hours_worked_uwork							"Among those unpaid, weekly hours of work"
		label var hours_worked_pwork							"Among those paid, weekly hours of work"
		label var agriculture									"Among those unpaid, share working in agriculture"
		label var place_work_employer_house						"Among those paid, share working household employee"
		label var place_work_factory							"Among those paid, share working in offices/factories"
		
		
		
		
		global  balance eap unemployed schoolatt lower_sec_enrollment working pwork hours_worked_pwork real_wage_all_jobs place_work_factory place_work_employer_house housekeeper pwork_formal 	///
				uwork hours_worked_uwork  agriculture working_for_household pwork_only uwork_only pwork_sch uwork_sch study_only nemnem  

		iebaltab $balance [pw = weight], format(%12.2fc) grpvar(urban) savetex("$tables/TableA2.tex") rowvarlabels 																///
		tblnote("Source: PNAD, 1998.") notecombine texdocument  texcaption("Balance test for 14-year-olds in urban and rural areas (1998)") replace
	}
	
	**
	*____________________________________________________________________________________________________________________________________*
	**
	*Table A3
	*____________________________________________________________________________________________________________________________________*
	**
	{	
		iebaltab $balance if urban == 1 [pw = weight], format(%12.2fc) grpvar(male) savetex("$tables/TableA3.tex") rowvarlabels 													///
		tblnote("Source: PNAD, 1998.") notecombine texdocument  texcaption("Balance test for 14-year-olds boys and girls in urban areas (1998)") replace
	}
	
	**
	*____________________________________________________________________________________________________________________________________*
	**
	*Table A4
	*____________________________________________________________________________________________________________________________________*
	**
	{
		iebaltab $balance if urban == 0 [pw = weight], format(%12.2fc) grpvar(male) savetex("$tables/TableA4.tex") rowvarlabels 													///
		tblnote("Source: PNAD, 1998.") notecombine texdocument  texcaption("Balance test for14-year-olds boys and girls in rural areas (1998)") replace
	}
		
	**
	*____________________________________________________________________________________________________________________________________*
	**
	*Table A6
	*____________________________________________________________________________________________________________________________________*
	**
	
		use "$final/RAIS.dta" if amostra == 1 & (dw >= -84 & dw < 84) & sexo != ., clear
		
		**
		gen id_total = 1
		gen id_atdez = 1 if po_3112 == 1
		
		
		**
		*collapse (mean)id_total  id_atdez, by(ano sexo		D pis)
		
		**
		collapse (sum) id_total  id_atdez, by(ano sexo 		D)
	
		**
		reshape wide   id_total  id_atdez , i(ano sexo)   j(D)
		reshape wide   id_total* id_atdez*, i(ano)  	  j(sexo)
		
		**
		foreach name in total atdez {
			gen 	p`name'01 = (id_`name'01/(id_`name'01 + id_`name'11))*100
			gen 	p`name'11 = (id_`name'11/(id_`name'01 + id_`name'11))*100
			gen 	p`name'02 = (id_`name'02/(id_`name'02 + id_`name'12))*100
			gen 	p`name'12 = (id_`name'12/(id_`name'02 + id_`name'12))*100
		}
		
		**
		order 	ano *total01* *total11* *total02* *total12*  *atdez01* *atdez11* *atdez02* *atdez12*  
					
		drop 	*atdez*
		
		format 	p* %4.2fc
		
		export excel using "$tables/TableA7.xlsx", replace
		

	**
	*____________________________________________________________________________________________________________________________________*
	**
	*Table
	*____________________________________________________________________________________________________________________________________*
	**
	{
		use "$final/child-labor-ban-brazil.dta" if (zw >= -12 & zw < 12) & formal == 1, clear	
		
		gen id = 1
		
		collapse (sum)id [pw = weight], by(year D)
		reshape wide id, i(year) j(D)
		
	}	
	
	
	**
	*____________________________________________________________________________________________________________________________________*
	**
	*Figure A1
	*____________________________________________________________________________________________________________________________________*
	**
	{
	foreach band in 12 24 {
		use "$final/child-labor-ban-brazil.dta" if year == 1999 & (zw >= -`band' & zw < `band'), clear	
			
		if `band' == 12 local fig = "a"
		if `band' == 24 local fig = "b"
		
			replace formal 		= 0  	if working == 0
			replace informal 	= 0 	if working == 0
			
			collapse (mean) eap pwork pwork_formal pwork_informal [pw = weight], by(D year)
		
			foreach var of varlist eap pwork_formal pwork_informal pwork  {
				replace `var' = `var'*100
				format 	`var' %12.2fc
				rename  `var' A_`var'
			}
		
			reshape long A_, i(year D)  j(status) string
			reshape wide A_, i(year status) j(D)
					
			graph bar (asis)A_0 A_1, bargap(5) bar(2,  lw(0.5) lcolor(navy) fcolor(gs12)) bar(1, lw(0.5) lcolor(emidblue) fcolor(gs12) fintensity(70))	bar(2, lw(0.5) lcolor(navy) fcolor(emidblue) )		///
			over(status, sort(status) label(labsize(small)) relabel(1 `"Economically active"' 2 `"Paid work"' 3 `"Formal"'  4 `"Informal"' ))																			///
			blabel(bar, position(outside) orientation(horizontal) size(medsmall) color(black) format (%4.1fc))   																						///
			title("", pos(12) size(medsmall) color(black)) subtitle(, pos(12) size(medsmall) color(black)) 																								///
			ytitle("%", size(medsmall)) 																																								///
			yscale(off)	 ylabel(,nogrid nogextend) 																																						///	
			plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 																							///						
			legend(order(1 "Unnafected cohort" 2 "Affected cohort")  region(lwidth(none) color(white) fcolor(none)) cols(2) size(large) position(12))      		            							///
			note("Source: PNAD, 1999." , color(black) fcolor(background) pos(7) size(small)) 																											///
			xsize(7) ysize(5) 

			local nb =`.Graph.plotregion1.barlabels.arrnels'
			di `nb'
			forval i = 1/`nb' {
			  di "`.Graph.plotregion1.barlabels[`i'].text[1]'"
			  .Graph.plotregion1.barlabels[`i'].text[1]="`.Graph.plotregion1.barlabels[`i'].text[1]'%"
			}
			.Graph.drawgraph
			graph export "$figures/FigureA1`fig'.pdf", as(pdf) replace
		}
	}		
	
	**
	*____________________________________________________________________________________________________________________________________*
	**
	*Figure A2
	*____________________________________________________________________________________________________________________________________*
	**
	
	{
		use "$final/child-labor-ban-brazil.dta" if year < 2007 & (zw >= -12 & zw < 12 ), clear	
			collapse (mean)eap pwork uwork schoolatt [pw = weight], by(year D)
		
			foreach var of varlist eap pwork uwork schoolatt {
				replace `var' = `var'*100
				format 	`var' %12.1fc
			}
			replace year = year - 1998 if year < 2001
			replace year = year - 1999 if year > 2000 
			
		
	 
			tw 	///
				(line pwork year		, msize(2) msymbol(T) lwidth(0.5) color(emidblue)  lp(solid) connect(direct) recast(connected) mlabel(pwork) 	 mlabcolor(black) mlabpos(12))   ///  
				(line uwork year		, msize(2) msymbol(D) lwidth(0.5) color(cranberry) lp(solid) connect(direct) recast(connected) mlabel(uwork) 	 mlabcolor(black) mlabpos(3)) 	///  
				(line eap year			, msize(2) msymbol(D) lwidth(0.5) color(erose) 	   lp(solid) connect(direct) recast(connected) mlabel(eap) 		 mlabcolor(black) mlabpos(3)) 	///  
				(line schoolatt year 	, by(D, note("")) msize(2) msymbol(O) lwidth(0.5) color(gs12) 	   lp(solid) connect(direct) recast(connected) mlabel(schoolatt) mlabcolor(black) mlabpos(12) 	///
				ylabel(, labsize(small) angle(horizontal) format(%2.0fc)) 																												///
				xscale(r(-1(1)7)) ///
				xlabel(0 `" "1998" "Age-13" "' 1 `" "1999" "Age-14" "' 2 `" "2001" "Age-16" "' 3 `" "2002" "Age-17" "' 4 `" "2003" "Age-18" "' 5 `" "2004" "Age-19" "' 6 `" "2005" "Age-20" "' 7 `" "2006" "Age-21" "', labsize(small) gmax angle(horizontal)) 											///
				ytitle("%", size(medsmall)) xtitle("") 			 																														///
				plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 																		///						
				legend(order(1 "Paid work" 2 "Unpaid work" 3 "Economically active" 4 "School attendance") pos(12) cols(2) region(lstyle(none) fcolor(none)) size(medsmall))  									///
				xsize(9) ysize(5) 	///
				note("Source: PNAD.", span color(black) fcolor(background) pos(7) size(small))) 
				graph export "$figures/FigureA2.pdf", as(pdf) replace
		}
		

	**
	*____________________________________________________________________________________________________________________________________*
	**
	*Figure A3
	*____________________________________________________________________________________________________________________________________*
	**
	{	
		use "$final/child-labor-ban-brazil.dta" if year < 2007 & (zw >= -12 & zw < 12 ), clear	
			collapse (mean) pwork_sch pwork_only study_only nemnem  [pw = weight], by(year D)
		
			foreach var of varlist pwork_sch pwork_only study_only nemnem {
				replace `var' = `var'*100
				format 	`var' %12.1fc
			}
			replace year = year - 1998 if year < 2001
			replace year = year - 1999 if year > 2000
	
			tw 	///
				(line pwork_sch year		, msize(2) msymbol(T) lwidth(0.5) color(emidblue)  lp(solid) connect(direct) recast(connected) mlabel(pwork_sch) 	mlabsize(vsmall) mlabcolor(black) mlabpos(11))   	///  
				(line pwork_only year		, msize(2) msymbol(D) lwidth(0.5) color(cranberry) lp(solid) connect(direct) recast(connected) mlabel(pwork_only) 	mlabsize(vsmall) mlabcolor(black) mlabpos(6)) 		///  
				(line study_only year		, msize(2) msymbol(d) lwidth(0.5) color(erose)     lp(solid) connect(direct) recast(connected) mlabel(study_only) 	mlabsize(vsmall) mlabcolor(black) mlabpos(3)) 		///  
				(line nemnem 	 year 	    , by(D, note("")) msize(2) msymbol(O) lwidth(0.5) color(gs12)	   lp(solid) connect(direct) recast(connected) mlabel(nemnem) 		mlabsize(vsmall) mlabcolor(black) mlabpos(4)	 ///
				ylabel(, labsize(small) angle(horizontal) format(%2.0fc)) 																															///																																									/// 
				xscale(r(-1(1)7)) ///
				xlabel(0 `" "1998" "Age-13" "' 1 `" "1999" "Age-14" "' 2 `" "2001" "Age-16" "' 3 `" "2002" "Age-17" "' 4 `" "2003" "Age-18" "' 5 `" "2004" "Age-19" "' 6 `" "2005" "Age-20" "' 7 `" "2006" "Age-21" "', labsize(small) gmax angle(horizontal)) 											///
				ytitle("%", size(medsmall)) xtitle("") 			 																																	///
				plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 																					///						
				legend(order(1 "Paid work and studying" 2 "Only paid work" 3 "Only school" 4 "Neither working or studying") cols(2) pos(12) region(lstyle(none) fcolor(none)) size(medsmall))  		///
				xsize(9) ysize(5) 	///
				note("Source: PNAD.", span color(black) fcolor(background) pos(7) size(small))) 
				graph export "$figures/FigureA3.pdf", as(pdf) replace	
			}

	**
	*____________________________________________________________________________________________________________________________________*
	**
	*Figure A4
	*____________________________________________________________________________________________________________________________________*
	**
	{
		use "$final/child-labor-ban-brazil.dta" if year == 1999 & xw >= - 12 & xw < 12 & urban == 1 & male == 1, clear	

		local outcomes pwork pwork_formal pwork_informal pwork_sch study_only nemnem
		
			foreach v of varlist `outcomes' {
				local `v'_label: var label `v'
			}
			collapse 			 `outcomes' [pw = weight], by(zw)
			foreach v of varlist `outcomes' {
				replace   `v' = `v'*100
				label var `v' `"``v'_label'"'
			}

			foreach var of varlist `outcomes' {
				tw  (lpolyci `var' zw if zw >= 0, kernel(triangle) degree(0) bw(12) acolor(gs12) fcolor(gs12) clcolor(gray) clwidth(0.3)) 		///
					(lpolyci `var' zw if zw <  0, kernel(triangle) degree(0) bw(12) acolor(gs12) fcolor(gs12) clcolor(gray) clwidth(0.3)) 		///
					(scatter `var' zw if zw >= -52 & zw <  0 ,  sort msymbol(circle) msize(small) mcolor(navy))         		 	///
					(scatter `var' zw if zw >=   0 & zw <= 51,  sort msymbol(circle) msize(small) mcolor(cranberry)), xline(0) 	///
					legend(off) 																								///
					plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 			///						
					title({bf:`: variable label `var''}, pos(11) color(navy) span size(medium))									///
					ytitle("%") xtitle("Age difference from the cutoff (in months)") 											/// 
					note("", color(black) fcolor(background) pos(7) size(small)) saving(short_`var'.gph, replace) 
			}
			
			graph combine short_pwork.gph short_pwork_formal.gph short_pwork_informal.gph short_pwork_sch.gph short_study_only.gph short_nemnem.gph, cols(2) graphregion(fcolor(white)) ysize(7) xsize(5) title(, fcolor(white) size(medium) color(cranberry))
			graph export "$figures/FigureA4.pdf", as(pdf) replace
			foreach var of varlist `outcomes' {
			erase short_`var'.gph
			}	
		}			
		
			
	**
	*____________________________________________________________________________________________________________________________________*
	**
	*Figure A5
	*____________________________________________________________________________________________________________________________________*
	**
	{			
		use "$final/child-labor-ban-brazil.dta" if year == 1999 & xw >= - 6 & xw < 6, clear	
		DCdensity zw, breakpoint(0) b(1) generate(Xj Yj r0 fhat se_fhat)
		graph export "$figures/FigureA5.pdf", as(pdf) replace
	}
			
	/*		
	*____________________________________________________________________________________________________________________________________*
	**
	*Overall descriptive statistics
	*We used these statistics to justify the choice of our sample of analysis: boys in urban areas. 
	*____________________________________________________________________________________________________________________________________*
	**
	
			
			*----------------------------------------------------------------------------------------------------------------------------*
			**Girls and Boys
			**Rural and Urban Areas
			*----------------------------------------------------------------------------------------------------------------------------*
			
			**
			*Households in which the head is younger than 18 or older than 60 years old 
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14, clear
			
			gen 	sample_hh_18_60 = hh_head_age < 18 | hh_head_age > 60
			replace sample_hh_18_60 = . if hh_head_age == .
			tab 	sample_hh_18_60 
			
			**
			*Children not listed as son/daughters of the head of the household
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14, clear
			tab hh_member //12% are not son/daughter of the head of the household
			
			
			**
			*Hours worked in paid and unpaid jobs
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14, clear
				bys unpaid_work: su hours_worked  	[w = weight]
				
			**
			*Among those working, % in paid jobs and in unpaid jobs
			replace pwork = . if working == 0
			replace uwork = . if working == 0
			collapse (mean)working pwork uwork 	[pw = weight]
			
			**
			*Unpaid jobs, agriculture
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14, clear
				tab 	agric_sector 	 if unpaid_work == 1 					 [w = weight], mis						//unpaid jobs in agriculture
				tab 	type_work_agric  if unpaid_work == 1 & agric_sector == 1 [w = weight], mis						//unpaid jobs in agriculture, % that are members of the household
			
			**
			*Unpaid jobs, non agriculture sector
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14 & agric_sector == 0 & unpaid_work == 1, clear
				tab type_work_noagric 		[w = weight], mis															//% that are members of the household
				tab place_work 		  		[w = weight], mis															//where do they work?
				tab activity90s		  		[w = weight], mis 															//5 = commerce, 6 = services
			
			**
			*Paid jobs
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14 & unpaid_work == 0, clear
				tab place_work 				[w = weight], mis															//40% working in stores, factories, offices
				tab type_work_noagric 		[w = weight], mis	
				tab type_work_agric 		[w = weight], mis	
				
			**
			*Girls and boys living in urban areas
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14, clear
				tab urban [w = weight]
				
				
			**
			*Member of the household, self-consumption, statistic for the APPENDIX
			use "$final/child-labor-ban-brazil.dta" if year == 1999 & age == 14 & unpaid_work == 1, clear
			tab working member_household_self_consu [w = weight], mis //% of 14-year-olds in unpaid work that are member of the household/self-consumption

			**
			*% of children in upaid jobs in rural areas
			use "$final/child-labor-ban-brazil.dta" if year == 1999 & age == 14 & urban == 0, clear
			tab working unpaid_work					[w = weight], mis
			
			
			**
			*ttest for a 9-month bandwidth
			use "$final/child-labor-ban-brazil.dta" if year == 1999 & cohort84_9 == 1, clear	
			
			foreach var of varlist $bargain_controls_our_def {
				ttest `var', by(D)
			}	
			
				
			*----------------------------------------------------------------------------------------------------------------------------*
			**
			*Girls
			*----------------------------------------------------------------------------------------------------------------------------*

			**
			*Among those working, % in paid jobs and in unpaid jobs, by urban/rural areas
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14 & male == 0, clear
			replace pwork = . if working == 0
			replace uwork = . if working == 0
			collapse (mean)working pwork uwork [pw = weight], by(urban)

			**
			**Girls paid work, urban areas
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14 & male == 0 & unpaid_work == 0 & urban == 1, clear
				tab working												[w = weight]
				tab agric_sector 										[w = weight], mis				//99% in non-agriculture sectors
				tab type_work_noagric, mis																//majority as housekeepers
				
				
				
				tab activity90s if type_work_noagric !=2 				[w = weight], mis				//activity sector for those not working as housekeepers
				tab place_work  if type_work_noagric !=2 				[w = weight], mis
			
			**
			**Girls unpaid work, rural areas. 
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14 & male == 0 & unpaid_work == 1 & urban == 0, clear
				tab 		agric_sector 								[w = weight], mis				//% of girls working in agriculture sector in rural areas
					tab 	type_work_agric   if agric_sector == 1 		[w = weight], mis				//% of these girls that are member of the household. 

			
			
			*----------------------------------------------------------------------------------------------------------------------------*
			**
			*Boys
			*----------------------------------------------------------------------------------------------------------------------------*

			**
			*Among those working, % in paid jobs and in unpaid jobs, by urban/rural areas
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14 & male == 1, clear
			replace pwork = . if working == 0
			replace uwork = . if working == 0
			collapse (mean)working pwork uwork [pw = weight], by(urban)
			
			**
			*Boys paid work, urban areas
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14 & male == 1 & unpaid_work == 0 & urban == 1, clear
				tab agric_sector	 									[w = weight], mis				//in urban areas, still we have some boys working with agriculture sector
				tab activity90s 	if agric_sector == 1	 			[w = weight], mis
				tab occupation90s 	if agric_sector == 1	 			[w = weight], mis
				tab type_work 											[w = weight], mis				//20% self-employee a, 60% employees
				tab activity90s 	if type_work_noagric != 3 			[w = weight], mis				//activity sector then the boy is not a self-employee

			**		
			**Boys unpaid work, rural areas. 
			use "$inter/Pooled_PNAD.dta" if year == 1999 & age == 14 & male == 1 & unpaid_work == 1 & urban == 0, clear
				tab 		agric_sector 								[w = weight], mis				//% of boys working in agriculture sector in rural areas
					tab 	type_work_agric   if agric_sector == 1 		[w = weight], mis				//% of these boys that are member of the household
		
				
				
	**
	*____________________________________________________________________________________________________________________________________*
	*
	*PNAD sample: out of labor market, employed (paid and unpaid), and unemployed children
	*____________________________________________________________________________________________________________________________________*
	**
		use "$final/child-labor-ban-brazil.dta" if year == 1999 & age == 14, clear
			tab  unpaid_work member_household_self_consu [w = weight], mis 																//majority of kids in nonpaid activities are member of the household/self consumption

			collapse (sum) member_household_self_consu-no_working_children employed unemployed out_labor paid_workers[pw = weight]

			*----------------------------------------------------------------------------------------------------------------------------*
			**
			*Out of the labor force, employed and unemployed
			*----------------------------------------------------------------------------------------------------------------------------*
				graph pie out_labor employed unemployed, pie(1, explode color(gs12))  pie(2, explode color(cranberry))  pie(3, explode color(navy*0.6)) 				///
				plabel(_all percent,   gap(-15) format(%2.1fc) size(small)) 																 							///
				plabel(1 "Out labor force",  	 color(black) gap(-1) format(%2.1fc) size(large)) 																 		///
				plabel(2 "Employed",  		 	 color(white) gap(2)  format(%2.1fc) size(large)) 																 		///
				plabel(3 "Unemployed",  		 color(black) gap(2)  format(%2.1fc) size(large)) 																 		///
				legend(off) 																																			///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 								///
				plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 								///
				note("Source: PNAD 1999. 14-year-olds.", span color(black) fcolor(background) pos(7) size(small))														///
				ysize(5) xsize(5) 	
				graph export "$figures/out-labor-market-employed-unemployed.pdf", as(pdf) replace	
				
				
			*----------------------------------------------------------------------------------------------------------------------------*
			**
			*Non-paid worker member of the household, other non-paid workers and paid workers
			*----------------------------------------------------------------------------------------------------------------------------*
				graph pie member_household_self_consu  others_unpaid paid_workers, pie(1, explode  color(emidblue)) pie(2, explode color(cranberry))  pie(3, explode color(gs12)) pie(4, explode color(gs8))  pie(5, explode color(cranberry)) pie(6, explode color(olive_teal*1.4))						   					///
				plabel(_all percent,   gap(10) format(%2.0fc) size(small)) 																 								///
				plabel(1 "Household member/self-consumption", 	color(black)  gap(-10) format(%2.0fc) size(small)) 														///
				plabel(2 "Other non-paid workers", 				color(black)  gap(-5)  format(%2.0fc) size(small)) 														///
				plabel(3 "Paid-workers", 						color(black)  gap(-2)  format(%2.0fc) size(small)) 														///
				legend(off) 																																			///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 								///
				plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 								///
				note("Source: PNAD 1999. 14-year-olds.", span color(black) fcolor(background) pos(7) size(small))														///
				ysize(5) xsize(5) 	
				graph export "$figures/member-household-self-consumption.pdf", as(pdf) replace	

			*----------------------------------------------------------------------------------------------------------------------------*
			**
			*Paid workers: boys, girls, rural and urban. 
			*----------------------------------------------------------------------------------------------------------------------------*
				graph pie paid_work_boys_urban paid_work_boys_rural paid_work_girls_urban paid_work_girls_rural, pie(1, explode  color(gs12)) pie(2, explode color(gs8))   pie(3, explode color(olive_teal))  pie(4, explode color(olive_teal*1.6)) pie(5, explode color(cranberry))						   					///
				plabel(_all percent,   gap(12) format(%2.0fc) size(small)) 																 								///
				plabel(1 "Boys, paid work, urban" 	,  color(black) gap(-10) format(%2.0fc) size(small)) 																///
				plabel(2 "Boys, paid work, rural" 	,  color(black) gap(-5)  format(%2.0fc) size(small)) 																///
				plabel(3 "Girls, paid work, urban" 	,  color(black) gap(-10) format(%2.0fc) size(small)) 																///
				plabel(4 "Girls, paid work, rural" 	,  color(black) gap(5)   format(%2.0fc) size(small)) 																///
				legend(off) 																																			///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 								///
				plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 								///
				note("Source: PNAD 1999. 14-year-olds.", span color(black) fcolor(background) pos(7) size(small))														///
				ysize(5) xsize(5) 	
				graph export "$figures/employed-by-type.pdf", as(pdf) replace	

		
	**
	*____________________________________________________________________________________________________________________________________*
	*
	*Safety in the workplace, available for 2001 wave
	*____________________________________________________________________________________________________________________________________*
	**		

			*Why are these children working?
			*----------------------------------------------------------------------------------------------------------------------------*
			use "$inter/Pooled_PNAD.dta" if year == 2001 & age == 14, clear
				
				tab reason_work  unpaid_work if working == 1 [w = weight], mis
				tab happy_work   unpaid_work if working == 1 [w = weight], mis
				
				gen childrens_want = reason_work == 1		//children wants to work
				gen parents_want   = reason_work == 2 		//parents want them to work
				
				label define 	unpaid_work 					1 "Unpaid work" 0 "Paid work"
				label val		unpaid_work unpaid_work
				
				graph pie childrens_want parents_want [w = weight], by(unpaid_work,   note("") legend(off) graphregion(color(white)) cols(3)) pie(1, explode  color(emidblue)) pie(2, explode color(gs8))   pie(3, explode color(olive_teal))  pie(4, explode color(olive_teal*1.6)) pie(5, explode color(cranberry))						   					///
				plabel(_all percent,   gap(12) format(%2.0fc) size(small)) 																 								///
				plabel(1 "They want to work" 			,  color(black) gap(-10) format(%2.0fc) size(large)) 															///
				plabel(2 "Parents want them to work" 	,  color(black) gap(-5)  format(%2.0fc) size(medsmall)) 														///
				legend(off) 																																			///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 								///
				plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 								///
				note("Source: PNAD 2001. 14-year-olds.", span color(black) fcolor(background) pos(7) size(small))														///
				ysize(3) xsize(5) 	
				graph export "$figures/reason-work.pdf", as(pdf) replace	


	**
	*____________________________________________________________________________________________________________________________________*
	*
	*Boutin/Bargain definition of visible/invisible work
	*____________________________________________________________________________________________________________________________________*
	**
		use "$final/child-labor-ban-brazil.dta" if year == 1999, clear

			tab visible_activities 				  if working == 1 [w = weight], mis									//percentage of children working on visible activities
			
			tab visible_activities work_home 	  if working == 1 [w = weight], mis									//visible actitivies & home/work in the same area
				
			tab member_household_self_consu		  if working == 1 &  visible_activities == 1 [w = weight], mis		//60% children in these defined visible actitivies are members of the household/self-consumption
				
								
				
	**
	*____________________________________________________________________________________________________________________________________*
	*
	*Time in service
	*____________________________________________________________________________________________________________________________________*
	**
			use "$final/child-labor-ban-brazil.dta" if urban == 1 & male == 1 & year == 1999 & xw >= - 1 & xw < 1, clear	

			gen 	time_job = 12*years_current_work + months_current_work if !missing(years_current_work)
	
			replace time_job = months_current_work 						 if  missing(years_current_work)
	
			su 		time_job, detail
			replace time_job = . if time_job > r(p95)
			
			gen 	got_work_bef_law = 1 if time_job >= 9 & !missing(time_job)
			replace got_work_bef_law = 0 if time_job <  9
						
			gen id = 1
			collapse (sum) id working pwork uwork formal informal  (mean)time_job got_work_bef_law age [pw = weight], by(D)	//70% of our unaffected cohort got the job before the law changed
	
	
