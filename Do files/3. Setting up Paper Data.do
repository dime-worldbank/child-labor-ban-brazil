		
														*SETTING UP PAPER DATASET*
	*________________________________________________________________________________________________________________________________*
	
	*
	*Using Pooled PNAD to set up our bandw1idths. 
	*________________________________________________________________________________________________________________________________*
		
	use "$inter/Pooled_PNAD.dta" , clear		//harmonized PNAD

	**
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	**
	*Running variables 
	*--------------------------------------------------------------------------------------------------------------------------------*
		
		
		*---------------------------->> (sample 1)
		***Months
		gen 	xw1 = mofd(dateofbirth  -  mdy(12, 16, 1984)) 			//months between date of birth and December 16th, 1984
	
		**
		*Weeks
		gen 	zw1 = wofd(dateofbirth  -  mdy(12, 16, 1984))			//weeks between date of birth  and December 16th, 1984

		**
		*Days
		gen 	dw1 = 	   dateofbirth  -  mdy(12, 16, 1984)			//days between date of birth   and December 16th, 1984

		
		*---------------------------->> (sample 2) - placebo
		*
		*Months
		gen 	xw2 = mofd(dateofbirth  -  mdy(12, 16, 1983)) 			//months between date of birth and  December 16th, 1983
		
		**
		*Weeks
		gen 	zw2 = wofd(dateofbirth  -  mdy(12, 16, 1983))			//weeks between date of birth  and  December 16th, 1983

		**
		*Day
		gen 	dw2 = 	   dateofbirth  -  mdy(12, 16, 1983)			//days between date of birth   and  December 16th, 1983
	
		
		*---------------------------->> (sample 3) - placebo
		*
		*Months
		gen 	xw3 = mofd(dateofbirth  -  mdy(3, 16, 1984)) 			//months between date of birth and  March 3rd, 1984
		
		**
		*Weeks
		gen 	zw3 = wofd(dateofbirth  -  mdy(3, 16, 1984))			//weeks between date of birth  and  March 3rd, 1984

		**
		*Day
		gen 	dw3 = 	   dateofbirth  -  mdy(3, 16, 1984)				//days between date of birth   and  March 3rd, 1984
	
	
		*---------------------------->> (sample 4) - placebo
		*
		*Months
		gen 	xw4 = mofd(dateofbirth  -  mdy(12, 16, 1982)) 			//months between date of birth and   December 16th, 1982
		
		**
		*Weeks
		gen 	zw4 = wofd(dateofbirth  -  mdy(12, 16, 1982))			//weeks between date of birth  and   December 16th, 1982

		**
		*Day
		gen 	dw4 = 	   dateofbirth  -  mdy(12, 16, 1982)			//days between date of birth   and  December 16th, 1982
	
	
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	**
	*Treatment dummy
	*--------------------------------------------------------------------------------------------------------------------------------*
		gen 	D1 	 	= 1 		if dw1 >= 0 						//children that turned 14 on December 16th, 1984 or after that 
		replace D1	 	= 0 		if dw1 <  0			
		gen 	D2 	 	= 1 		if dw2 >= 0 					
		replace D2	 	= 0 		if dw2 <  0				
		gen 	D3 	 	= 1 		if dw3 >= 0 					
		replace D3	 	= 0 		if dw3 <  0				
		gen 	D4	 	= 1 		if dw4 >= 0 					
		replace D4	 	= 0 		if dw4 <  0				
		gen 	zw1D1  	= zw1*D1										//running variable interacted with treatment
		gen 	zw12   	= zw1^2											//running variable ^ 2
		gen 	zw2D2  	= zw2*D2										//running variable interacted with treatment
		gen 	zw22   	= zw2^2											//running variable ^ 2
		
		
		format 	zw* dw* xw* %20.0fc
		
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	**
	*Children in our sample	
	*--------------------------------------------------------------------------------------------------------------------------------*
		gen  	member_household_self_consu  = 1 if inlist(type_work_noagric, 5, 7) |  inlist(type_work_agric, 4, 6)
		gen  	others_unpaid			 	 = 1 if unpaid_work == 1 & member_household_self_consu != 1 & working == 1
		gen  	paid_work_girls_urban		 = 1 if unpaid_work == 0 & female == 1 & urban == 1 & working == 1
		gen  	paid_work_girls_rural		 = 1 if unpaid_work == 0 & female == 1 & urban == 0 & working == 1
		gen  	paid_work_boys_urban		 = 1 if unpaid_work == 0 & female == 0 & urban == 1 & working == 1
		gen  	paid_work_boys_rural		 = 1 if unpaid_work == 0 & female == 0 & urban == 0 & working == 1
		gen  	no_working_children		 	 = 1 if working 	== 0 
		egen 	paid_workers				 = rsum(paid_work_girls_urban paid_work_girls_rural paid_work_boys_urban paid_work_boys_rural)  

		
		**Each row must have the value 1 for at least of variable we defined
			**If the children has a non-paid job and is member of the household
			**If the children has a non-paid job and it is not member of the household
			**Girls in paid jobs in urban areas
			**Girls in paid jobs in rural areas
			**Boys in paid jobs in urban areas
			**Boys  in paid jobs in rural areas
			**No employed children
		
		**
		**
		*Testing with we gave a classification for each child of the household according to the disaggregation we presented above
		*preserve
		*keep 	if zw1 > -13 & zw1 < 13 & year == 1999
		*egen   	test = rsum(member_household_self_consu-no_working_children) 
		*assert 	test == 1
		*tab    	test, mis //okkkk
		*drop   	test
		*restore
		
		**
		**
		*% of unpaid workers in activities for their own household
		gen	 	working_for_household = 1 if member_household_self_consu == 1 & unpaid_work == 1
		replace working_for_household = 0 if missing(working_for_household)   & unpaid_work == 1 //among those unpaid, percentage that worked for their household. 
		
		**
		** 
		*% of paid workers as housekeepers
		gen 	housekeeper 		  = 1 if type_work_noagric == 2		 	  & pwork   == 1
		replace housekeeper 		  = 0 if missing(housekeeper)  		      & pwork   == 1

	**
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	**
	*Labels
	*--------------------------------------------------------------------------------------------------------------------------------*
		label 	var D2    							"ITT"											//affected cohort
		label 	var D1    							"ITT"											//affected cohort
		label 	var xw1   							"Running variable, in months"
		label 	var zw1   							"Running variable, in weeks"
		label 	var zw2   							"Running variable, in weeks"
		label 	var dw1   							"Running variable, in days"
		label 	var zw12  							"Square of the running variable"
		label 	var zw1D1  							"Running variable interacted with treatment"
		label 	var zw22  							"Square of the running variable"
		label 	var zw2D2 							"Running variable interacted with treatment"
		label 	var member_household_self_consu 	"Unpaid work, member of the household/self-consumption"
		label 	var others_unpaid					"Other unpaiworkers"
		label 	var paid_work_girls_urban		 	"Paid work, girl, urban"
		label 	var paid_work_girls_rural			"Paid work, girl, rural"
		label 	var paid_work_boys_urban  			"Paid work, boy, urban"
		label	var paid_work_boys_rural  			"Paid work, boy, rural"
		label 	var paid_workers					"Paid work"
		label 	var no_working_children				"Not working"
		label 	var working_for_household 			"Working for their household (unpaid)" 
		label 	var housekeeper						"Working as housekeepers (paid)" 

		label 	drop 	urban male
		label 	define 	D1    0 "Unnafected cohort" 1 "Affected cohort"
		label 	define 	urban 1 "Urban"   0 "Rural"
		label 	define 	male  1 "Boys"    0 "Girls"
		label 	val		urban urban
		label 	val 	male  male
		label 	val 	D1    D1
	
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Bandwidths
	*--------------------------------------------------------------------------------------------------------------------------------*
		local 		dist12	= 365     	   	// window: +/- one year
		local 		dist6	= 365/2        	// window: +/- 6 mois 
		local 		dist3	= 365/4        	// window: +/- 3 mois 
		local 		dist4	=  (365/12)*4   // window: +/- 9 mois 
		local 		dist5	=  (365/12)*5   // window: +/- 9 mois 
		local 		dist7	=  (365/12)*7   // window: +/- 9 mois 
		local 		dist8	=  (365/12)*8  	// window: +/- 9 mois 
		local 		dist9	=  (365/12)*9   	// window: +/- 9 mois 
		
		foreach sample in 1 2 3 4 { 
		
			**Cutoff dates based on studied samples
			if `sample' == 1 gen str 	tresholdi`sample'	=	"1984 12 16"
			if `sample' == 2 gen str 	tresholdi`sample'	=	"1983 12 16"
			if `sample' == 3 gen str 	tresholdi`sample'	=	"1984 3  16"
			if `sample' == 4 gen str 	tresholdi`sample'	=	"1982 12 16"
			
			gen 		threshold`sample'	=	date(tresholdi`sample', "YMD")
			format 		threshold* %td
			drop 		tresholdi*
						
			*Distance to cutoff (in days)
			gen 		gap`sample'			= dateofbirth-threshold`sample'
			
			foreach bandwidth in 3 4 5 6 7 8 9 12 {
			gen 		cohort`sample'_`bandwidth' 	= (abs(gap`sample') <= `dist`bandwidth'')		
			}
			
			*Cluster for standard errors
			gen 		cluster_bargain`sample'		= round((gap`sample'/365)*12) 				//standard errors clustered at the level of variability of age, i.e. cohort x day of birth (default)
		}
			
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	**
	*Defining variables as in Bargain and Boutin Paper
	*--------------------------------------------------------------------------------------------------------------------------------*

	**
		*Preserving PNAD waves, expect 1999, 98
		preserve
		drop  		v*
		keep 		if year != 1999 & year != 2001 & year != 1998 & year != 1997
		tostring 	uf	 , replace     			 		//  unidade da federacao: uf
		tempfile 	data
		save 	   `data'
		restore
		
		**
		*Working with 1999 wave as the authors did
		keep 		if year == 1999 | year == 2001 | year == 1998 | year == 1997
		
	**	
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	**Household Id and Id of the respondent as defined by Bargain/Boutin. 
	**Using the variables "id_dom" and "id_pes", we merged our and theirs datasets to compare: sample size and treatment status
	*--------------------------------------------------------------------------------------------------------------------------------*
		destring  	v0102 v0103 v0301, replace
		replace  	v0101 = 99 if v0101 == 1999
		tostring 	v0101, replace
		tostring 	uf	 , replace     			 		//  unidade da federacao: uf
		tostring 	v0102, replace   					//  control: v0102
		tostring 	v0103, replace   					//  serie: v0103
		tostring 	v0301, replace  					//  ordem : v0301
		gen 		id_dom 		= v0101  + "00"  + uf + "00" + v0102 + "00" + v0103
		gen 		str id_pes 	= id_dom + "000" + v0301
		*drop  		uf v0102 v0103 v0301 
			
		format  	dateofbirth %td
		*sort 		dw1
		*br 	 		dateofbirth dw1 gap1 zw1 xw1 D1  cohort1* threshold1*

			
	**	
	*--------------------------------------------------------------------------------------------------------------------------------*
	*
	*Child employment according to Bargain/Boutin paper
	*--------------------------------------------------------------------------------------------------------------------------------*
		*Employment
		gen 	 employ_bargain   		= (v9001 == 1  | v9004 == 2 | v9002  == 2 | v9003 == 1) 
		replace  employ_bargain   		= 0 														if v9008 == 13  | v9029 == 7
			
		*Visible, "invisible" (hard to inspect) activities	
		gen	 	 visible_activities	   	= (employ_bargain == 1) & (v9054 == 1 | v9054 == 2 | v9054 == 5) 																// shop+school+manufacture, farm, local
		gen 	 invisible_activities   = (employ_bargain == 1) & (v9054 == 3 | v9054 == 4 | v9054 == 6 | v9054 == 7) 													// "domicile" (residence), employer's redidence, motor, vehicule, public area
		label 	 var visible_activities				"Visible activities, according to Bargain/Boutin, 2019"
		label 	 var invisible_activities			"No visible activities, according to Bargain/Boutin, 2019"
		label 	 var employ_bargain 				"EAP according to Bargain/Boutin Paper"

	**
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	**Age of the head of the household
	*========================================*
	**Difference between Bargain/Bouting and our paper: they set up the survey date as September 1st (however, the survey takes
	**place in the last week of September. 
	**The authors defined a new variable "ageyear" which is the difference between survey date and date of birth. 
	**By doing this, we lost a few observations as some respondents do not have a date of birth available. These people can still
	**have information in the variable age (variable v8005 of the PNAD questionnaire), which is the estimated age of the respondent. 
	**We opted for working with the age variable as defined in PNAD (v8005). 
	**Our variable hh_head_age (age of the head of the household) is equal to the variable age (v8005) available in PNAD.
	**Bargain/Boutin variable is defined below.
	*========================================*
	*--------------------------------------------------------------------------------------------------------------------------------*

		gen str  surveyi="1999 09 01" if year==1999
		replace  surveyi="1998 09 01" if year==1998
		replace  surveyi="2001 09 01" if year==2001
		replace  surveyi="1997 09 01" if year==1997

		
		gen 	 survey = date(surveyi, "YMD")
		format   survey %td 
		gen  	 agenew    =(survey-dateofbirth) 
		gen  	 ageweek   = int(agenew/52)
		gen  	 ageyear   = int(agenew/365)  //we see that errors in age were just rounding problems
		gen  	 ihead_age = ageyear if hh_member == 1
		bys  	 year hh_id: egen hh_head_age_bargain =max(ihead_age)
	    drop 	 ihead_age 
			 
		*=============================================================*
		*Now we have two variables for Age of the Head of the Household
		** -> "hh_head_age" 		as defined in our paper
		** -> "hh_head_age_bargain" as defined in Bargain/Boutin Paper
		*=============================================================*

	**	
	*--------------------------------------------------------------------------------------------------------------------------------*
	**Household with head/spouse, only with female head, or only with male head
	**One potential problem with the definition adopted by Bargain/Boutin are the cases in which the head of the household/spouse
	**have the same gender.
	*--------------------------------------------------------------------------------------------------------------------------------*

		gen 	m = ((hh_member == 1 | hh_member == 2) & male == 1) //male ,  head of the household or spouse 
		gen 	f = ((hh_member == 1 | hh_member == 2) & male == 0) //female, head of the household or spouse 

		foreach v in  "f" "m"  {
				bys year hh_id: egen hh_`v'=sum(`v')
		}

		bys 	year hh_id: gen couple = (hh_m==1 & hh_f==1)        //both parents present
		bys 	year hh_id: gen singm  = (hh_m==1 & hh_f==0)        //single mother ***** Wouldnt this one be single mother ?
		bys 	year hh_id: gen singf  = (hh_m==0 & hh_f==1)        //single father ***** Wouldnt this one be single father?
		drop 	hh_m hh_f											
				
		egen 	 	 test = rsum(couple singm singf)				//test = 0 when the head of the household and spouse have the same gender. 
		tab 	year test 
		drop 	 	 test	
			
	**	
	*--------------------------------------------------------------------------------------------------------------------------------*
	**Household size
	*========================================*
	**Difference between Bargain/Bouting and our paper: they defined as a member of the household all the respondents, regardless of
	**the relation with the head of the household (which includes, housekeepers, relatives of housekeepers)
	**We opted to consider as members of the household: head, spouse, son/daughter, and another relative. 
	*========================================*
	*--------------------------------------------------------------------------------------------------------------------------------*
		bys 	year hh_id: gen hh_size_bargain = _N 			

		*=============================================================*
		*Now we have two variables for household size
		** -> "hh_size" 		as defined in our paper
		** -> "hh_size_bargain" as defined in Bargain/Boutin Paper
		*=============================================================*

	**	
	*--------------------------------------------------------------------------------------------------------------------------------*
	**Years of schooling
	*========================================*
	**Difference between Bargain/Bouting and our paper: they calculated the years of schooling based on education variables 
	**available in the survey. We reproduced their code below. 
	**We opted to use the variable "years of schooling" available in the survey (v4703). 
	*========================================*
	*--------------------------------------------------------------------------------------------------------------------------------*
		 rename     v0602 asist
		 rename 	v0603 curso
		 rename 	v0605 cserie
		 rename 	v0606 asisant
		 rename 	v0607 ultcurso
		 rename 	v0610 ultiseri
		 destring 	asist		, replace
		 destring 	asisant		, replace
		 destring 	curso		, replace
		 destring 	ultcurso	, replace
		 destring 	cserie		, replace
		 destring 	ultiseri	, replace
		 gen 		lerescr		=	1 				if v0601		==	1
		 replace 	lerescr		=	0 				if v0601		==	3
		 replace 	lerescr		=	. 				if age			<	5
		 gen 		escola		=	0 				if asist		==	4
		 replace 	escola		=	1 				if asist		==	2
		 gen 		jaescola	=	0 				if asisant		==	4 	& asist		==	4
		 replace 	jaescola	=	1 				if asisant		==	2 
		 replace 	jaescola	=	0 				if asisant		==	2 	& (ultcurso ==	8 | ultcurso==9  )
		 replace 	jaescola	=	0 				if escola		==	1
		 replace 	jaescola	=	0 				if jaescola		==	.
		 replace 	jaescola	=	. 				if (asist		==	. 	| asisant 	==	9)
		 gen 		preescol	=	(curso==7)
		 replace 	preescol	=	. 				if escola==.
		 *Year of schooling
		 *1st grade
		 gen 		yschl		=	cserie 			if (curso		==	1 	| curso		==	3)  
		 replace 	yschl		=	4 				if (curso		==	1 	| curso		==	3) 	& cserie    ==.     & escola	==	1
		 replace 	yschl		=	ultiseri 		if (ultcurso	==	4 	| ultcurso	==	2)   
		 replace 	yschl		=	4		 		if  ultcurso	==	1 
		 replace 	yschl		=	4 				if (ultcurso	==	4 	| ultcurso	==	2 	| ultcurso 	==	1)  & ultiseri	==. & jaescola	==	1
		 *2nd grade
		 replace 	yschl		=	cserie + 8 		if (curso		==	2 	| curso		==	4) 
		 replace 	yschl		=	8 				if (curso		==	2 	| curso		==	4) 	& cserie    ==. 	& escola==1
		 replace 	yschl		=	ultiseri + 8 	if (ultcurso	==	3 	| ultcurso	==	5)  
		 replace 	yschl		=	8 				if (ultcurso	==	3 	| ultcurso	==	5) 	& ultiseri 	==. 	& jaescola==1
		 *Superior
		 replace 	yschl		=	cserie   + 11 	if curso		==	5   
		 replace 	yschl		=	ultiseri + 11 	if ultcurso		==	6  
		 replace 	yschl		= 	11 				if curso		== 	5 	& cserie	==. 	& escola	==	1
		 replace 	yschl		= 	11 				if ultcurso		== 	6 	& ultiseri	==. 	& jaescola	==	1	
		 *Master and PhD
		 replace 	yschl		=	15 				if curso		==	9  
		 replace 	yschl		=	15 				if ultcurso		==	7  
		 *No education
		 replace 	yschl		=	0  				if (curso		==	6 	| curso		==	7 | curso==8)
		 replace 	yschl		=	0  				if (ultcurso	==	8 	| ultcurso	==	9)
		 replace 	yschl		=	0  				if (escola		==. 	| jaescola	==	.)
		 replace 	yschl		=	0  				if (escola		==	0 	& jaescola	==	0)
		 replace 	yschl		=	15 				if yschl		>	15	& yschl!=.
		 replace 	yschl		=	.  				if age			<	5
		 *ta yschl if age>=5, m
		 rename  	yschl yrs_school_bargain
		 drop 		asist curso cserie asisant ultcurso ultiseri
		
		 gen  		ihead_edu = yrs_school_bargain if hh_member == 1
		 bys  		year hh_id: egen hh_head_edu_bargain =max(ihead_edu)
		 drop 		ihead_edu
			 
			*=============================================================*
			*Now we have two variables for years of schooling of head of the household
			** -> "hh_head_edu" 		as defined in our paper
			** -> "hh_head_edu_bargain" as defined in Bargain/Boutin Paper
			*=============================================================*

	**	
	*--------------------------------------------------------------------------------------------------------------------------------*
	**Household income (adults income)
	*========================================*
	**Difference between Bargain/Bouting and our paper: they defined household income as the sum of wages
	**of the head of the household and spouse. 
	**We opted to calculate adult household income by subtracting from the variable household income available in PNAD (v4721)
	**children's wages (age < 18). 
	*========================================*
	*--------------------------------------------------------------------------------------------------------------------------------*
		destring 	v9121, replace
		gen 		trab_dom	=(v9121==1)
		replace 	trab_dom		=. 	if (v9121==9 | v9121==.)
	
		destring    v4718, replace
		destring    v4719, replace
		destring    v4720, replace
		egen 		prendtr1	=	rsum(v4718)
		replace		prendtr1	=. if v4718	==	999999999999 
		replace 	prendtr1	=. if v4719	==	999999999999
		replace 	prendtr1	=. if v4720	==	999999999999

		destring 	v9058, replace
		destring 	v9101, replace
		destring 	v9105, replace
		gen 		work	=	(v9001==1 | v9002==2 | v9003==1 | v9004==2) 
		*
		gen 		htrab1	=	v9058 				if v9058>0 & v9058<99
	    gen 		htrab2	=	v9101 				if v9101>0 & v9101<99 
		replace 	htrab2	=	0	 				if v9005==1
		replace 	htrab2	=	0 					if (htrab2==. & htrab1!=.)
		gen 		htrab3	=	v9105 				if v9105>0 & v9105<99 
		replace 	htrab3	=	0 					if v9005==1 | v9005==2 
		replace 	htrab3	=	0 					if (htrab3==. & htrab2!=.)
		*
		gen 		htrabT	= htrab1+htrab2+htrab3
		replace 	htrabT	=	98 					if htrabT	>	98 & htrabT!=.
		replace 	htrabT	=. 						if work	!=1

		gen 		whours	= htrabT // all jobs
		replace 	whours	=. 						if trab_dom	==1 & employ_bargain==0
		replace 	whours	=0 						if employ_bargain	==0
		replace 	whours	=80 					if whours	>80 & employ_bargain==1
			
		gen 		salario	=	prendtr1/(htrab1*4.33) 	if age >= 10
		replace 	salario	=	0 						if salario==. 	& age	>=	10 & employ_bargain ==	1
		gen 		CPI		=	0.798136175968766 		if year	==	1998
		replace 	CPI		=	0.849501390026204 		if year	==	1999
		replace 	salario	=	salario/CPI
				
		gen	   		mm_inc	=	salario*(employ_bargain==1)	 		if m==1 
		gen    		ff_inc	=	salario*(employ_bargain==1) 		if f==1 
			
		bys    		hh_id year: egen m_inc = sum(mm_inc)
		bys    		hh_id year: egen f_inc = sum(ff_inc)
		drop   		mm_inc ff_inc
			
		egen   		adults_income_bargain = rowtotal(m_inc f_inc)
			
			*=============================================================*
			*Now we have two variables for adults income
			** -> "adults_income" 		  as defined in our paper
			** -> "adults_income_bargain" as defined in Bargain/Boutin Paper
			*=============================================================*
			
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Per capita income, considering only adults income
	*--------------------------------------------------------------------------------------------------------------------------------*
		gen 	 per_cap_adults_income = adults_income/hh_size
		
		forvalues year = 1999(1)1999 {
		su  	 per_cap_adults_income 		if year == `year', detail
		replace  per_cap_adults_income = .  if  year == `year' & (per_cap_adults_income <= r(p1) | per_cap_adults_income >= r(p99))
		}
					
		
	**	
	*--------------------------------------------------------------------------------------------------------------------------------*
	**Color of the skin
	*========================================*
	**Difference between Bargain/Bouting and our paper: small difference because we considered as missing when the respondent 
	**did not answer the color of his/her skin
	*========================================*
	*--------------------------------------------------------------------------------------------------------------------------------*
		quiet destring v0404, replace
		quiet gen 	color_bargain = v0404
		tab 		color_bargain, gen(color_bargain)
			
	**	
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Sample weight
	*--------------------------------------------------------------------------------------------------------------------------------*
		gen 	weightdd			=	weight
		bys 	year: egen sweight	=	mean(weight)
		gen 	weight_bargain		=	weight/sweight
		drop 	sweight
			
	**	
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Appending PNAD waves
	*--------------------------------------------------------------------------------------------------------------------------------*
		drop  	v*
		append 	using `data'
	

	**
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Reducing size
	*--------------------------------------------------------------------------------------------------------------------------------*
		keep 	if ((zw1 >= -52 &  zw1 <= 52) | (zw2 >= -52 & zw2 <= 52) | (zw3 >= -52 & zw3 <= 52) | (zw4 >= -52 & zw4 <= 52)) ///
											  | (year == 1998 & age == 14)	/// 
											  | (year == 1999 & age == 14)  /// 
											  | (year == 1997 & age == 14)

	**	
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Wage outliers
	*--------------------------------------------------------------------------------------------------------------------------------*
		foreach year in 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2011 2012 2013 2014 {
		su  	 wage_hour 		if year == `year', detail
		replace  wage_hour = .  if year == `year' & (wage_hour< r(p5) | wage_hour > r(p95))
		}
		*tab region, gen(region)
	save 	"$final/child-labor-ban-brazil.dta", replace

	
	
	/*
	*________________________________________________________________________________________________________________________________*
	
	*Comparing our data size and covariates with the ones of Bargain/Boutin Paper (2021). 
	*________________________________________________________________________________________________________________________________*
				
	**Checking if our sample size and treatment status are the same as those used in their paper. 
		* -> Applying the same exclusions the authors did, we got the same number of observations. 
		* -> Treatment status is the same. 
		
	**Checking the definitions of the variables. 
		* -> The variables: years of education, household size, age of the respondent, and household income are defined differently. 
		**We highlight the differences below. 
		
		**The replication package for Bargain/Boutin Paper is available for download: https://academic.oup.com/wber/article-abstract/35/1/234/5681375
	*________________________________________________________________________________________________________________________________*
		
	**	
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	**Affected and unaffected cohorts
	*========================================*
	**Difference between Bargain/Bouting and our paper: they restricted the analysis to household members defined as 
	**"daughter/son" of the head of the household. 
	**We considered any 14-year-old that lives in the household. 
	*========================================*
	*--------------------------------------------------------------------------------------------------------------------------------*
	use "$final/child-labor-ban-brazil.dta" if year == 1999 & cohort1_3 == 1, clear

			*------------------------------------------------------------------------------------------------------------------------*		
			*===========================*
			*Sample exclusions
			*===========================*
				**Son/daughter of the head of the household
				keep if hh_member ==  3

				*Date of birth
				gen 	ppb	=	(no_dateofbirth	==	1)
				bys 	year	 hh_id: egen spb=sum(ppb)
				drop 	if  spb > 0
				drop 	spb ppb			
				keep 	if no_dateofbirth == 0
				
				**Age of the head of the household
				drop 	if hh_head_age_bargain < 18 | hh_head_age_bargain > 60
				
					*Affected and unaffected cohorts
					gen   treat = (gap1 >= 0)

					*Comparing the sample size using ours and theirs treatment dummy
					tab   D1 treat if year == 1999 & hh_member == 3	& cohort1_3 == 1			//same number of observations! GOOD
		
			
			*===========================*
			*Bargain and Boutin dta file
			*===========================*
				
				/*
				-> We downloaded Bargain/Boutin data for replication "lhz047_supplemental_files". 
				-> The files .dta are saved inside the folder data_for_replication
				-> Below we compared our data (with the controls defined the same way the authors did) and their dataset. 
				-> We can see that we were able to perform the same harmonization Bargain/Boutin did.
				*/
				
				global bargaindata "C:\Users\wb495845\OneDrive - WBG\III. Labor\child-labor-ban-brazil\Documentation\Literature\Bargain, Boutin\lhz047_supplemental_files\data_for_replication"
				
				preserve
					use "$bargaindata\PNAD_same_cohort.dta" if year == 1999 & cohort84_3 == 1, clear
					egen hhinc = rowtotal(m_inc f_inc)
					tab  region, gen(reg)
					tab  ethnie, gen(eth) 
									
					tempfile bargain
					save	`bargain'
				restore
				
				
				*merge 1:1 id_dom id_pes using `bargain', force	//most of merge for id_dom and id_pes work. the merge = 1 or 2 are probably due to .txt differences???
				 merge 1:1 id_dom id_pes using `bargain', force keep (3)	//for variables merged, there is no difference in variable's definition. 
				
				
				**
				**We can see that all variables match:
				
				*===================================================*
				*Child Labor
				tab employ employ_bargain, mis			
				*===================================================*
				/*
				*===================================================*
				*Region
				tab region1 reg1, mis
				tab region2 reg2, mis
				tab region3 reg3, mis
				tab region4 reg4, mis
				*===================================================*
				*/
				*===================================================*
				*Skin color
				tab color_bargain2 eth2, mis			
				tab color_bargain5 eth5, mis
				*===================================================*
				
				*===================================================*
				*Household head education
				gen  teste  = hh_head_edu_bargain - head_edu
				br 	 hh_head_edu_bargain head_edu  if teste == . 
				tab  teste, mis	
				drop teste
				*===================================================*

				*===================================================*
				*Household head gender 
				tab   hh_head_male head_moth, mis
				*===================================================*
				
				*===================================================*
				*Household head age
				gen  teste  = hh_head_age_bargain - head_age
				tab  teste, mis			
				drop teste
				*===================================================*
		
				*===================================================*
				*Rural
				tab urban rural, mis
				*===================================================*
				
				*===================================================*
				*Household size
				gen  teste  = hh_size_bargain - hhsize
				tab  teste, mis			
				drop teste
				*===================================================*
				
				*===================================================*
				*Household income
				gen  teste  = int(adults_income_bargain -  hhinc)
				tab  teste, mis	
				drop teste
				*===================================================*
				
