

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
		//1. Intro
		//
		{		
		    
		use "$final/child-labor-ban-brazil.dta" if year == 1999 & (zw1>= -39 & zw1<0) & urban == 1 & male == 1, clear	
		su pwork  [w = weight]
		
			
		use "$final/child-labor-ban-brazil.dta" if year == 1998 & age == 14, clear	

			su working [w = weight]
			su eap	   [w = weight]
			
			gen 	id = 1 if pwork == 1							//children in paid jobs, % boys in urban areas, %girls in urban areas, % boys in rural areas, % girls in rural areas
			collapse (sum) id [aw = weight], by(male urban)
			egen 	t = sum(id)
			gen 	p = id/t	

				
		use "$final/child-labor-ban-brazil.dta" if year == 1998 & age    == 14 & urban  == 0 & working   == 1, clear	
		
			tab uwork  							    [w = weight], mis
			tab working_for_household if uwork == 1 [w = weight], mis
		
		
		use "$final/child-labor-ban-brazil.dta" if year == 1998 & age    == 14 & urban  == 1 & working   == 1 & male == 0, clear	
			tab pwork  							    [w = weight], mis
			tab housekeeper if pwork == 1 			[w = weight], mis
		
		
		use "$final/child-labor-ban-brazil.dta" if year == 1998 & age    == 14 & urban  == 1 & male      == 1, clear	
			tab eap 							[w = weight], mis
			
			
		use "$final/child-labor-ban-brazil.dta" if year == 1999 & urban  == 1 & male    == 1 & cohort1_4 == 1, clear	
			su pwork [w = weight]
		}
		
				
		//-------------->>
		//2. Related Literature
		//
		{
		use "$final/child-labor-ban-brazil.dta" if year == 1999 & age == 14 & uwork == 1, clear	
			tab working_for_household  [w = weight], mis
			tab type_work_noagric 	   [w = weight], mis
			tab type_work_agric  	   [w = weight], mis
			
			tab type_work_noagric 	   [w = weight] 
			tab type_work_agric  	   [w = weight]
			
			keep if working_for_household == 1
			gen id1 = 1 if inlist(type_work_noagric, 5, 7) 
			gen id2 = 1 if inlist(type_work_agric, 4, 6)
			
			tab id1  [w = weight] 
			
			tab id2  [w = weight] 
			
			collapse (sum) id1 id2 [w = weight] 
		}
		
	
		//-------------->>
		//3. Institutional Setting and the Intervention
		//
		{
			**
			*The share of unaffected and affected 14-year-olds in formal sector in 1999
			**
				use "$final/child-labor-ban-brazil.dta" if year == 1999 & xw1 >= - 6 & xw1 < 6, clear		//6-month bandwidth
					tab working informal 	if D1 == 0 						[w = weight]					// 1/30  in formal sector
					tab working informal 	if D1 == 1 						[w = weight]					// 1/100 in formal sector
					**Thus, among those working, the unaffected 14-year-olds were 3 times more likely to be in the formal sector than the affected ones. 
			
			**
			*% of 14-year-olds in the formal market
			**
				use "$final/child-labor-ban-brazil.dta" if year == 1999 & age == 14, clear	
					su formal if working == 1 [w = weight], detail											//1.5% of 14-year-olds working were in the formal sector
				
			**
			*% of 14-year-olds that already finished lower secondary education (9th grade)
			**
				use "$final/child-labor-ban-brazil.dta" if year == 1999 & age == 14, clear	
					su lowersec_degree, detail																//Only 3.3% of 14-year-olds in 1999 had finished lower secondary education					
		}	
			
			
		//-------------->>
		//4. Empirical
		//
		use 	"$final/child-labor-ban-brazil.dta" if year == 1999 & zw1 >= -10 & zw1 < 10, clear	
			sort dateofbirth
			br   dateofbirth

			
		//-------------->>
		//5. Data
		//
		{
			**
			*Average number of individuals in PNAD
			**
				use	 	"$inter/Pooled_PNAD.dta", clear
				gen 			  id = 1
				collapse 	(sum) id, by(year)
				collapse 	(mean)id						//380.000
				
			**
			*Average number of households in PNAD
			**
				use 	"$inter/Pooled_PNAD.dta", clear
				duplicates drop hh_id year, force //
				gen 			  id = 1
				collapse 	(sum) id, by(year)
				collapse 	(mean)id						//110.0003*****3*
				
			**
			*% of the 10-week cohort that was still studying by the age of 19 
			**
				use "$final/child-labor-ban-brazil.dta" if year == 2004 & zw1 >= - 10 & zw1 < 10, clear	
				tab 		schoolatt 					[w = weight]
				
				use "$final/child-labor-ban-brazil.dta" if year == 2004 & zw1 >= - 10 & zw1 < 10 & schoolatt == 1, clear	
				tab 		edu_level_enrolled 			[w = weight]	
				bys D1: tab edu_level_enrolled 			[w = weight]									//the majority of them still in primary and secondary education, suggesting delays
			
			**
			*Unemployment rate in Brasil in 1998
			**
				use "$inter/Pooled_PNAD.dta", clear
				su unemployed 		[w = weight] 		if year == 1998 & inrange(age, 18,65)    		//unemployment rate in Brasil in 1998, 8,2%

			**
			*14-year-olds in urban areas (1998)
			**
				use "$final/child-labor-ban-brazil.dta" if year == 1998 & age == 14, clear	
				tab urban 			[w = weight]														//77%				
			
			**
			*14-year-olds in economically active population and unemployed (1998)
			**
				use "$final/child-labor-ban-brazil.dta" if year == 1998 & age == 14, clear	
				tab working 		[w = weight] if urban== 1
				tab working 		[w = weight] if urban== 0
				
				tab working 		[w = weight] if urban== 1 & male == 0
 				tab eap  			[w = weight]														//26,7%
				tab unemployed		[w = weight]														//18,2%		
				
			**
			*14-year-olds working in paid and unpaid activities (1998)
			**
				use "$final/child-labor-ban-brazil.dta" if year == 1998 & age == 14, clear	
				tab unpaid_work if working == 1 [w = weight]											//56,7%
				
			**
			*Share of children's income in total household income (1998)
			**
				use "$final/child-labor-ban-brazil.dta" if year == 1998 & age == 14, clear	
				gen share_chidren_income = children_income/hh_income
				su 	share_chidren_income [w = weight], detail											//5%
				
				
			**
			*14-year-olds attending school
			**				
				use "$final/child-labor-ban-brazil.dta" if year == 1998 & age == 14, clear	
				tab schoolatt									[w = weight]							//90%
				tab edu_level_enrolled 		if schoolatt == 1	[w = weight]							//21% no EF1 e 75% no EF2
				
				tab schoolatt  				if working   == 1 	[w = weight]							//82%						
				tab edu_att										[w = weight]						
			
			**
			*14-year-olds in unpaid activities and share of those working that also attend school
			**				
				use "$final/child-labor-ban-brazil.dta" if year == 1998 & age == 14 & working == 1, clear	
					tab uwork [w = weight]
					tab schoolatt
					
				
		}
		
		
		//-------------->>
		//6. Results
		//
		{
			
			use 	"$final/child-labor-ban-brazil.dta" 	    	if year == 1999 & cohort1_4 == 1 & D1== 0 & male == 1 & urban == 1, clear			//almost 50% of those working for pay were boys in urban areas. 
			su pwork [w=weight]
			
			
			**
			**Share of 14-year-olds in paid work in 1999 -> desaggregating by urban boys, urban girls, rural boys and rural girls
			**				
				use 	"$final/child-labor-ban-brazil.dta" 	    	if year == 1999 & age == 14, clear			//almost 50% of those working for pay were boys in urban areas. 
				keep 	if pwork == 1
				gen 	id = 1
				
				collapse (sum) id [w = weight], by(male urban)
				egen 	t = sum(id)
				gen 	p = id/t
				
			**
			**Educational attainment of the affected cohorts by 2003
			**				
				use "$final/child-labor-ban-brazil.dta" 	    if zw1 >= - 10 & zw1 < 10 & male == 1 & urban == 1, clear
				
				bys D1: tab edu_level_enrolled 	  [w = weight]  if year == 2003 
				bys D1: tab edu_att 			  [w = weight]  if year == 2004 
				bys D1: tab lowersec_degree		  [w = weight]  if year == 2004
				bys D1: tab highschool_degree	  [w = weight]  if year == 2004
				bys year: su goes_public_school 			    if schoolatt == 1 & inrange(edu_level_enrolled, 1,5) [w = weight]
			
				su working_for_household if uwork == 1 &   year == 1999 [w = weight]  
				
								
			**	
			**Educational level of those affected and unaffected within time
			**				
				use "$final/child-labor-ban-brazil.dta" 		if zw1 >= - 10 & zw1 < 10 & male == 1 & urban == 1 & year < 2005, clear
				
				bys year: su schoolatt			  [w = weight] 	if D1 == 1
				bys year: tab edu_level_enrolled  [w = weight]	if D1 == 1				
				bys year: tab edu_att 			  [w = weight] 	if D1 == 1 & schoolatt == 0	// a maior parte dos que estavam fora da escola tinha EF incompleto
				
				bys year: su schoolatt			  [w = weight]  if D1 == 0
				bys year: tab edu_level_enrolled  [w = weight]  if D1 == 0				
				bys year: tab edu_att 			  [w = weight]  if D1 == 0 & schoolatt == 0	// a maior parte dos que estavam fora da escola tinha EF incompleto
				
				use "$final/child-labor-ban-brazil.dta" 		if zw1 >= - 12 & zw1 < 12, clear
				bys D1: tab edu_level_enrolled 					if year == 2003, mis
				bys D1: tab edu_att 							if year == 2003
				bys D1: tab lowersec_degree
				bys D1: tab highschool_degree
				
				
			**	
			**% of 14 year old urban boys in unpaid activities in self consumption or working for the household they lived in
			**				
				use "$final/child-labor-ban-brazil.dta" 	    if male == 1 & urban == 1 & year == 1999 & uwork == 1 & age == 14, clear

				tab member_household_self_consu [w = weight], mis
			
			
			**	
			**Correl between household income and mother education
			**				
				use "$final/child-labor-ban-brazil.dta" if age == 14 & year == 1999, clear
				correl mom_yrs_school per_capita_inc
				
				
			**	
			**Children working -> by socioeconomic background
			**			
				use "$final/child-labor-ban-brazil.dta" if male == 1 & urban == 1 & year == 1999 & pwork == 1 & age == 14, clear
				
				tab mom_edu_att2 [w = weight], mis
				
				
				use "$final/child-labor-ban-brazil.dta" if male == 1 & urban == 1 & year == 1999 			  & age == 14, clear
				
				gen 	mom_highschool = 1 if inlist(mom_edu_att2,3,4)
				replace mom_highschool = 0 if inlist(mom_edu_att2,1,2)
				
				su 		mom_highschool [w = weight], 
				
				bys 	mom_highschool : su eap    [w = weight], 
				bys	 	mom_highschool : su pwork  [w = weight], 			
		}	
		
		
		
		//-------------->>
		//7. Submission comments
		//
		{
			use "$final/child-labor-ban-brazil.dta" if year == 1999 & cohort1_12 == 1, clear	
				tab	hh_head_age if  hh_member == 3
				tab	hh_spouse_age if  hh_member == 3
				
		}
	

	
	**
	*____________________________________________________________________________________________________________________________________*
	**
	*Table A1
	*____________________________________________________________________________________________________________________________________*
	**
	{
		estimates clear
		use "$final/child-labor-ban-brazil.dta" if year == 1999 & (xw1 >= -9 & xw1 < 9 ) & male == 1 & urban == 1, clear			//12 week bandwidth in 1999
		label var hh_head_male 		"Head of the household is male"
		label var oldest_person_hh "Age of the oldest person in the household"
		iebaltab  mom_yrs_school oldest_person_hh $bargain_controls_our_def [pw = weight],   pttest  format(%12.2fc) grpvar(D1) save("$tables/TableA1.xls") rowvarlabels 			///
	 replace
	}	
				
	
	**
	*____________________________________________________________________________________________________________________________________*
	**
	*Figure 1
	*____________________________________________________________________________________________________________________________________*
	**
	{
		cd "$figures"
		use 	"$final/child-labor-ban-brazil.dta" if year == 1999 & xw1 >= - 14 & xw1 < 14 & urban == 1 & male == 1, clear	

		local 	outcomes eap pwork pwork_informal study_only
		
			**
			foreach v of varlist `outcomes' {
				local `v'_label: var label `v'
			}
			collapse 			 `outcomes' [pw = weight], by(xw1)
			
			**
			foreach v of varlist `outcomes' {
				replace   `v' = `v'*100
				label var `v' `"``v'_label'"'
			}
			
			label define xw1 -10 "-42" -5 "-20" 0 "0" 5 "20" -10 "-42"
			label val    xw1 xw1

			foreach var of varlist `outcomes' {
				tw  (lpolyci `var' xw1 if xw1 >= 0, kernel(triangle) degree(0) bw(4) acolor(gs12) fcolor(gs12) clcolor(gray) clwidth(0.3)) 		///
					(lpolyci `var' xw1 if xw1 <  0, kernel(triangle) degree(0) bw(4) acolor(gs12) fcolor(gs12) clcolor(gray) clwidth(0.3)) 		///
					(scatter `var' xw1 if xw1 >= -12 & xw1 <  0 ,  sort msymbol(circle) msize(medium) mcolor(gs8))         		 	///
					(scatter `var' xw1 if xw1 >=   0 & xw1 <= 12, xlabel(-10 "-42" -5 "-20" 0 "0" 5 "20" 10 "42", valuelabel) sort msymbol(T) msize(medium) mcolor(gs8)), xline(0) 	///
					legend(off) 																									///
					plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 				///						
					title({bf:`: variable label `var''}, pos(11) color(black) span size(medsmall))										///
					ytitle("% of children") xtitle("Age difference from the cutoff (in weeks)", size(small)) saving(short_`var'.gph, replace) 	/// 
					note("", color(black) fcolor(background) pos(7) size(small)) 
			}
			
			graph combine short_eap.gph short_pwork.gph short_pwork_informal.gph short_study_only.gph, cols(2) graphregion(fcolor(white)) ysize(7) xsize(7) title(, fcolor(white) size(medium) color(cranberry))
			graph export "$figures/Figure1.tif", as(tif) replace
			foreach var of varlist `outcomes' {
			erase short_`var'.gph
			}	
		}			
	
	
	**
	*____________________________________________________________________________________________________________________________________*
	**
	*Figure C4
	*____________________________________________________________________________________________________________________________________*
	**
	{
	foreach band in 14 {
		use "$final/child-labor-ban-brazil.dta" if year == 1999 & (zw1 >= -`band' & zw1 < `band') & urban  == 1	& male == 1 & cohort1_12 == 1, clear	

		if `band' == 10 local fig = "a"
		if `band' == 12 local fig = "b"
		
			replace formal 		= 0  	if working == 0
			replace informal 	= 0 	if working == 0
			
			collapse (mean) eap pwork pwork_formal pwork_informal [pw = weight], by(D1 year)
		
			foreach var of varlist eap pwork_formal pwork_informal pwork  {
				replace `var' = `var'*100
				format 	`var' %12.2fc
				rename  `var' A_`var'
			}
		
			reshape long A_, i(year D1)  j(status) string
			reshape wide A_, i(year status) j(D1)
					
			graph bar (asis)A_0 A_1, bargap(5) bar(1, lw(0.5) lcolor(gs8) fcolor(gs12) fintensity(70))	bar(2, lw(0.5) lcolor(gs8) fcolor(gs10) )		///
			over(status, sort(status) label(labsize(medium)) relabel(1 `" "Economically" "active" "' 2 `" "Paid" "work" "' 3 `"Formal"'  4 `"Informal"' ))																			///
			blabel(bar, position(outside) orientation(horizontal) size(medsmall) color(black) format (%4.1fc))   																						///
			title("", pos(12) size(medsmall) color(black)) subtitle(, pos(12) size(medsmall) color(black)) 																								///
			ytitle("% of children", size(medsmall)) 																																								///
			 ylabel(,nogrid nogextend) 																																						///	
			plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 																							///						
			legend(order(1 "Unnafected cohort" 2 "Affected")  region(lwidth(none) color(white) fcolor(none)) cols(2) size(medium) position(12))      		            							///
			note("" , color(black) fcolor(background) pos(7) size(small)) 																											///
			xsize(6) ysize(5) 

			*local nb =`.Graph.plotregion1.barlabels.arrnels'
			*di `nb'
			*forval i = 1/`nb' {
			*  di "`.Graph.plotregion1.barlabels[`i'].text[1]'"
			*  .Graph.plotregion1.barlabels[`i'].text[1]="`.Graph.plotregion1.barlabels[`i'].text[1]'%"
			*}
			*.Graph.drawgraph
			graph export "$figures/FigureC4.tif", as(tif) replace
		}
	}		
		
	*
	*
	*____________________________________________________________________________________________________________________________________*
	**
	*Figure C2
	*____________________________________________________________________________________________________________________________________*
	**
	{
		**
		*
		use "$final/child-labor-ban-brazil.dta" if year == 1998 & age == 14, clear	
			gen 	w_urban 								= 1 	if working 			== 1 & urban == 1
			replace w_urban									= 0 	if working 			== 1 & urban == 0
			gen 	w_rural 								= 1 	if working 			== 1 & urban == 0
			replace w_rural									= 0 	if working 			== 1 & urban == 1
			gen 	w_urban_girls 							= 1 	if w_urban 			== 1 & male   == 0
			replace w_urban_girls 							= 0 	if w_urban 			== 1 & male   == 1
			gen 	w_urban_boys 							= 1 	if w_urban 			== 1 & male   == 1
			replace w_urban_boys 							= 0 	if w_urban 			== 1 & male   == 0	
			gen 	w_rural_girls 							= 1 	if w_rural 			== 1 & male   == 0
			replace w_rural_girls 							= 0 	if w_rural 			== 1 & male   == 1
			gen 	w_rural_boys 							= 1 	if w_rural 			== 1 & male   == 1
			replace w_rural_boys 							= 0 	if w_rural 			== 1 & male   == 0	
			
			foreach region    in urban rural {
				foreach group in girls boys  {
					
					gen 	pw_`region'_`group'  			= 1 	if w_`region'_`group' 	== 1 & pwork  == 1
					replace pw_`region'_`group'  			= 0 	if w_`region'_`group' 	== 1 & pwork  == 0
					
					gen 	uw_`region'_`group'  			= 1 	if w_`region'_`group' 	== 1 & uwork  == 1
					replace uw_`region'_`group'  			= 0 	if w_`region'_`group' 	== 1 & uwork  == 0

					gen 	pwformal_`region'_`group' 		= 1 	if pw_`region'_`group' 	== 1 & formal == 1
					replace pwformal_`region'_`group' 		= 0 	if pw_`region'_`group' 	== 1 & formal == 0
					
					gen 	pwinformal_`region'_`group' 	= 1 	if pw_`region'_`group' 	== 1 & formal == 0
					replace pwinformal_`region'_`group' 	= 0 	if pw_`region'_`group' 	== 1 & formal == 1
					
					gen 	uwformal_`region'_`group' 		= 1 	if uw_`region'_`group' 	== 1 & formal == 1
					replace uwformal_`region'_`group' 		= 0 	if uw_`region'_`group' 	== 1 & formal == 0
					
					gen 	uwinformal_`region'_`group' 	= 1 	if uw_`region'_`group' 	== 1 & formal == 0
					replace uwinformal_`region'_`group' 	= 0 	if uw_`region'_`group' 	== 1 & formal == 1
				}
			}
			
			foreach var of varlist working w_* pw* uw* {
			replace `var' = `var'*100	
			}
		
			collapse (mean) working w_urban ///
							w_urban_girls pw_urban_girls pwformal_urban_girls pwinformal_urban_girls uw_urban_girls uwformal_urban_girls uwinformal_urban_girls ///
							w_urban_boys  pw_urban_boys  pwformal_urban_boys  pwinformal_urban_boys  uw_urban_boys  uwformal_urban_boys  uwinformal_urban_boys	///
							w_rural_girls pw_rural_girls pwformal_rural_girls pwinformal_rural_girls uw_rural_girls uwformal_rural_girls uwinformal_rural_girls ///
							w_rural_boys  pw_rural_boys  pwformal_rural_boys  pwinformal_rural_boys  uw_rural_boys  uwformal_rural_boys  uwinformal_rural_boys	///
							[pw = weight]
		//I added these numbers in the excel that is saved in the replication package, datawork, output, figures	
		}
		
	
	**
	*____________________________________________________________________________________________________________________________________*
	**
	*Figure C3
	*____________________________________________________________________________________________________________________________________*
	**
	{
		use "$final/child-labor-ban-brazil.dta" if year < 2007 & (zw1 >= -14 & zw1 < 14 ) & urban  == 1	& male == 1 & cohort1_12 == 1, clear	
			collapse (mean)eap pwork schoolatt [pw = weight], by(year D1)
		
			foreach var of varlist eap pwork schoolatt {
				replace `var' = `var'*100
				format 	`var' %12.1fc
			}
			replace year = year - 1998 if year < 2001
			replace year = year - 1999 if year > 2000 
			br if D1 == 0
			
			tw 	///
				(line pwork year		, msize(2) msymbol(T) lwidth(0.5) color(gs8)  lp(solid) connect(direct) recast(connected) mlabel(pwork) 	 mlabcolor(black) mlabpos(12))   ///  
				(line eap year			, msize(2) msymbol(D) lwidth(0.5) color(gs12) 	   lp(dot) connect(direct) recast(connected) mlabel(eap) 		 mlabcolor(black) mlabpos(3)) 	///  
				(line schoolatt year 	, by(D1, note("")) msize(2) msymbol(O) lwidth(0.5) color(gs5) 	   lp(shortdash) connect(direct) recast(connected) mlabel(schoolatt) mlabcolor(black) mlabpos(12) 	///
				ylabel(, labsize(small) angle(horizontal) format(%2.0fc)) 																												///
				xscale(r(-1(1)7)) ///
				xlabel(0 `" "13-years" "old" "' 1 `" "14" "" "' 2 `" "16" "" "' 3 `" "17" "" "' 4 `" "18" "" "' 5 `" "19" "" "' 6 `" "20" "" "' 7 `" "21" "" "', labsize(medium) gmax angle(horizontal)) 											///
				ytitle("% of children", size(medsmall)) xtitle("") 			 																														///
				plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 																		///						
				legend(order(1 "Paid work" 2 "Economically active" 3 "Attending school") pos(12) cols(3) region(lstyle(none) fcolor(none)) size(large))  			///
				xsize(9) ysize(5) 	///
				note(, span color(black) fcolor(background) pos(7) size(small))) 
				graph export "$figures/FigureC3.tif", as(tif) replace
		}
		
	
	**
	*____________________________________________________________________________________________________________________________________*
	**
	*Figure C5
	*____________________________________________________________________________________________________________________________________*
	**
	{	
	local window = 39
	
		use "$final/child-labor-ban-brazil.dta" if year == 1999 & cohort1_9== 1 , clear	
		DCdensity zw1, breakpoint(0) b(1) generate(Xj Yj r0 fhat se_fhat)
			
		local breakpoint 0
		local cellmpname Xj
		local cellvalname Yj
		
		local evalname r0
		local cellsmname fhat
		local cellsmsename se_fhat
		
		drop if `cellmpname' <  -`window'  | `cellmpname' >  `window' 
		drop if `evalname'   <  -`window'  | `evalname'   >  `window'
		
		quietly gen hi = `cellsmname' + 1.96*`cellsmsename'
		quietly gen lo = `cellsmname' - 1.96*`cellsmsename'
		
		
		gr twoway (scatter `cellvalname' `cellmpname' if `cellmpname' > -31, msymbol(circle_hollow) mcolor(gray))             ///
		  (line `cellsmname' `evalname' if `evalname' < `breakpoint', lcolor(black) lwidth(medthick))   ///
		  (line `cellsmname' `evalname' if `evalname' > `breakpoint' & `evalname' < 31, lcolor(black) lwidth(medthick))   ///
		  (line hi `evalname' if `evalname' < `breakpoint', lcolor(black) lwidth(vthin))              ///
		  (line lo `evalname' if `evalname' < `breakpoint', lcolor(black) lwidth(vthin))              ///
		  (line hi `evalname' if `evalname' > `breakpoint' & `evalname' < 31, lcolor(black) lwidth(vthin))              ///
		  (line lo `evalname' if `evalname' > `breakpoint' & `evalname' < 31, lcolor(black) lwidth(vthin)),             ///
		  xline(`breakpoint', lcolor(black)) legend(off) ///
		  xlabel(-39(5)39) xtitle("Running variable, in weeks", size(large)) ytitle("Density", size(large)) 
			graph export "$figures/FigureC5.tif", as(tif) replace
	}
	*/
	
