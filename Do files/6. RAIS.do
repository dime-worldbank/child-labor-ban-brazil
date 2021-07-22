
													*RAIS, Relação Anual de Informações Sociais*
	*Dataset with all formal workers in Brasil. 
	*We will work with the workers born between 1984 and 1985, our treatment and control groups. 
	*____________________________________________________________________________________________________________________________________*

	
	
		*________________________________________________________________________________________________________________________________*
		**
		**
		*Identifying wrong PIS numbers
		**
		*________________________________________________________________________________________________________________________________*
		
		
		**=================================================================>>
		**======================================================>>
		**
		*The same PIS can not have more than one CPF
			clear
			
			foreach year in 2002 2003 2007 {
				append using "$inter/RAIS/Rais_trabalhador_`year'.dta", keep(pis ano cpf data_nasc)
			}
			
			keep if pis != ""
			sort 	pis 

			sort    pis data_nasc
			gen 	dif_nasc = 1 if data_nasc[_n] != data_nasc[_n-1] & pis[_n] == pis[_n-1] //same pis, different dates of birth
			bys 	pis: egen total_nasc = sum(dif_nasc)									//number distinct dates of birth by CPF
			drop 	if total_nasc > 0
		 
		**
		**Date of birth
			bys pis: egen 			moda_nasc  = mode(data_nasc)
			gen dif_moda = 1 if 	moda_nasc !=      data_nasc
						
			gen data_nasc_correta = moda_nasc

			
			
			keep if cpf != "" & pis != "" 
				
			bys 	pis: egen moda_cpf = mode(cpf)		//the same pis is associated to only one CPF
			gen 	aerro = 1 if cpf  != moda_cpf
			bys 	pis: egen erro = max(aerro)
			keep 			  if erro == 1
			duplicates drop pis, force
			keep pis erro
			save    "$inter/RAIS/error_pis.dta", replace
		
		
		*________________________________________________________________________________________________________________________________*
		**
		**
		*Identifying correct dates of birth
		**
		*________________________________________________________________________________________________________________________________*
		
			clear
			
			foreach year in 2002 2003 2007 {
				append using "$inter/RAIS/Rais_trabalhador_`year'.dta", keep(pis ano cpf data_nasc)
			}
		
			keep if cpf != "" 
			

			**
			**The same CPF has different dates of birth
				sort    cpf data_nasc
				gen 	dif_nasc = 1 if data_nasc[_n] != data_nasc[_n-1] & cpf[_n] == cpf[_n-1] & data_nasc[_n] != "" & data_nasc[_n-1] != "" //same cpf, different dates of birth
				bys 	cpf: egen total_nasc  = sum(dif_nasc)																				  //number distinct dates of birth by CPF
				drop 	if 		  total_nasc > 2
				
			**
			**Date of birth
				bys cpf: egen 			moda_nasc  = mode(data_nasc)
				gen dif_moda = 1 if 	moda_nasc !=      data_nasc
				gen data_nasc_correta = moda_nasc
				
			sort cpf pis 
			duplicates drop cpf pis, force
			keep cpf pis data_nasc_correta
			
			merge m:1 pis using   "$inter/RAIS/error_pis.dta", keep(1 3) nogen
			
			replace pis = "" if erro == 1
			
			
				
				/*
				duplicates drop cpf, force
				keep 			cpf pis data_nasc_correta
				
			/*
		save "$inter/RAIS/dateofbirth_cpf.dta", replace 

		
		
		**
		**One PIS can not have more than one CPF
			drop if   pis == ""
			sort 	  pis
			
			preserve
			keep 	  if erro == 1
			duplicates  drop pis, force
			keep 		pis erro
			
			restore

			drop 	  if erro == 1
			assert    cpf == moda_cpf 	
			
		 **
		 **List of identifiers
			duplicates drop pis, force
			keep 			pis cpf data_nasc_correta
			save "$inter/RAIS/dateofbirth_cpf.dta", replace

		 
		**=================================================================>>
		**======================================================>>
		**
		*Using PIS
		clear
		
		foreach year in 2002 2003 2007 {
			append using    "$inter/RAIS/Rais_trabalhador_`year'.dta", keep(pis ano cpf data_nasc)
		}
		
		drop if   pis == ""
		merge m:1 pis using "$inter/RAIS/dateofbirth_cpf.dta"		 , keep(1  ) nogen 	keepusing(pis)	//keeping only the individuals that we do not have the date of birth
		merge m:1 pis using "$inter/RAIS/error_pis.dta"				 , keep(1  ) nogen 	keepusing(pis)  //excluding wrong information for pis-> the same pis has more than one CPF
		

		sort    pis data_nasc
		gen 	dif_nasc = 1 if data_nasc[_n] != data_nasc[_n-1] & pis[_n] == pis[_n-1] //same pis, different dates of birth
		bys 	pis: egen total_nasc = sum(dif_nasc)									//number distinct dates of birth by CPF
		drop 	if total_nasc > 0
		 
		**
		**Date of birth
			bys pis: egen 			moda_nasc  = mode(data_nasc)
			gen dif_moda = 1 if 	moda_nasc !=      data_nasc
						
			gen data_nasc_correta = moda_nasc
			
			duplicates drop pis, force
		 	keep 			pis data_nasc_correta
			
			compress
			save 		  "$inter/RAIS/dateofbirth_pis.dta", replace
			
			
			
		*________________________________________________________________________________________________________________________________*
		**
		**
		*Merging data
		**
		*________________________________________________________________________________________________________________________________*
		
		**
		*1999
		
			use "$inter/RAIS/Rais_trabalhador_1999.dta", clear
			
			merge m:1 pis using "$inter/RAIS/dateofbirth_pis.dta", keep (1 3)
		 
		**
		*2001
		
			use "$inter/RAIS/Rais_trabalhador_2001.dta", clear
			
			merge m:1 pis using "$inter/RAIS/dateofbirth_pis.dta", keep (1 3)
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
