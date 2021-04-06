		
														*SETTING UP PAPER DATASET*
	*________________________________________________________________________________________________________________________________*
	
	use "$inter/Pooled_PNAD.dta", clear		//harmonized PNAD

	
	*Bandwidths
	*--------------------------------------------------------------------------------------------------------------------------------*

		**
		*Months
		* 
		gen 	xw = mofd(dateofbirth  - mdy(12, 16, 1984)) 			//months between date of birth and December 15th  1984
	
		**
		*Weeks
		*
		gen 	zw = wofd(dateofbirth  - mdy(12, 16, 1984))				//weeks between date of birth  and December 15th 1984

		**
		*Days
		*
		gen 	dw = 	  dateofbirth  - mdy(12, 16, 1984)				//days between date of birth  and December 15th 1984
		
		
	*Treatment dummy
	*--------------------------------------------------------------------------------------------------------------------------------*
		gen 	D 	 = 1 		if zw >=  0
		replace D	 = 0 		if zw <   0			
		gen 	zwD  = zw*D
		gen 	zw2  = zw^2
		gen 	zw3  = zw^3
		gen 	zw2D = zw2*D
		gen 	dw2  = dw^2
		gen 	dw3  = dw^3
		
		format 	zw2* zw3* %20.0fc
		
	*--------------------------------------------------------------------------------------------------------------------------------*
		label var D   "ITT"
		label var xw  "Running variable, in months"
		label var zw  "Running variable, in weeks"
		label var dw  "Running variable, in days"
		label var zw2 "Square of the running variable"
		label var zw3 "Cubic of the running variable"
		label var dw2 "Square of the running variable"
		label var dw3 "Cubic of the running variable"
		label define D 0 "Control" 1 "Treatment"
		label val 	 D D
		
	*--------------------------------------------------------------------------------------------------------------------------------*
		drop 	age_31_march children_income labor_card spouse female_with_children social_security activity* kid* female occupation goes_public_school went_school civil_servant_federal civil_servant_state civil_servant_municipal
		compress
		save 	"$final/Child Labor Data.dta", replace
	
		sort zw month_birth day_birth
		*br year day_birth month_birth year_birth xw zw if year == 1999 & zw > -3 & zw < 3			
