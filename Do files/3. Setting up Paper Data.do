		
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

		
	*Treatment dummy
	*--------------------------------------------------------------------------------------------------------------------------------*
		gen 	D 	 = 1 		if zw >=  0
		replace D	 = 0 		if zw <   0			
		gen 	zwD  = zw*D
		gen 	zw2  = zw^2
		gen 	zw3  = zw^3
		gen 	zw2D = zw2*D
		format 	zw2* zw3* %12.2fc
		label 	var D "ITT"
		
		
	*--------------------------------------------------------------------------------------------------------------------------------*
		drop 	age_31_march CT_signed spouse filho social_security activity* kid* female occupation goes_public_school went_school civil_servant_federal civil_servant_state civil_servant_municipal
		compress
		save 	"$final/Child Labor Data.dta", replace
	
		sort zw month_birth day_birth
		*br year day_birth month_birth year_birth xw zw if year == 1999 & zw > -3 & zw < 3			
