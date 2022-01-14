				  
												*HARMONIZING BRAZILIAN HOUSEHOLD SURVEY (PNAD)*
		*________________________________________________________________________________________________________________________________*

		**

		**
		*Program to harmonize PNAD. The program runs from 1998 to 2015. 
		*________________________________________________________________________________________________________________________________*
			cap program drop harmonizar_pnad

			program define   harmonizar_pnad

			syntax, year(string)

			clear 

			use "$inter/pnad`year'.dta", clear

			**
			**
			if `year' >= 2007 {

				*Household Id
				*------------------------------------------------------------------------------------------------------------------------*
				if `year' < 2015 drop id_dom																																		//apenas excluí porque o primeiro comando abaixo irá fazer isso e não tenho ctza se a puc considera família = domicílio ou que um domicílio pode ser formado por mais de uma família. 
				
				egen 	hh_id   = group(uf v0101 v0102 v0103)																														//household id																								

				gen 	inf      = v0301																																			//identification of the member of the household

				gen 	ninf_mom = v0407 																																			//número de ordem da mãe - vai ser últil para sabermos a escolaridade da mãe
				
				sort 	hh_id inf uf

				gen 	year     = v0101

				*br 		year hh_id inf uf ninf_mom
			
			
				*------------------------------------------------------------------------------------------------------------------------*
				recode  v4728 (1 2 3 = 1) (4/8 = 0)																			, gen (urban)

				recode  v0302 (2 = 0) (4 = 1)																				, gen (female)

				recode  v4727 (1 = 1) (2 3 = 0) 																			, gen (metro)
				
				recode  v4704 (1 = 1) (2 = 0)																				, gen (eap)												//semana de ref. pessoas com 10 anos ou + 

				recode  v4805 (1 = 1) (2 = 0)																				, gen (employed)										//semana de ref. pessoas com 10 anos ou +. Employed leva em consideracao quem trabalhou para proprio consumo. 

				recode  v4805 (1 = 0) (2 = 1)																				, gen (unemployed)										//semana de ref. pessoas com 10 anos ou +

				recode  v4706 (1 2 3 4 6 7 = 1) (9 = 2) (10 = 3) (11/13 = 4) 												, gen (type_work)										//semana de ref. pessoas com 10 anos ou +					
				
				recode  v0602 (2 = 1) (4 = 0)   (9 = .)																		, gen (schoolatt)										//frequenta ou não a escola
				
				recode  v6002 (2 = 1) (4 = 0)																				, gen (goes_public_school)								//dquem frequenta a escola vai para escola pública;privada. 

				recode 	v9067 (1 = 1) (3 = 0)																				, gen (worked_last_year)								//trabalhadores com 10 anos ou +. teve algum trabalho no período de captação de 358 dias							//para as pessoas desocupadas na semana de referência, elas trabalharam no período de captação de 358 dias?						

				recode 	v9070 (2 = 1) (4 = 2) (6 = 3)																		, gen (n_jobs_last_year)								//para as pessoas desocupadas na semana de referência, elas trabalharam no período de captação de 358 dias? em 1, 2 ou 3 trabalhos?
							
				gen 	wage  		  		= v4718   		   	if v4718 < 999999999999																								//rendimento no trabalho principal na semana de referência

				gen 	hh_income 			= v4721   		   	if v4721 < 999999999999
				
				gen 	per_capita_inc   	= v4742  			if v4742 < 999999999999 																							//sem declaração
				
				gen 	wage_all_jobs   	= v4719  		   	if v4719 < 999999999999																								//pessoas com 10 anos ou mais
				
				rename (v9058 v4729	v8005 v0401 v9892 v4809 v4810) (hours_worked  weight age hh_member work_age activity occupation)												//horas de trabalho no trabalho principal na semana de referência
			
						
				*Women that are mothers
				*------------------------------------------------------------------------------------------------------------------------*
				gen     female_with_children = 1   				if v1101 == 1 & female == 1																							//se já é mãe ou não
				 
				replace female_with_children = 0   				if v1101 == 3 & female == 1

				
				*Labor Card and social security 
				*------------------------------------------------------------------------------------------------------------------------*
				gen     labor_card 				= 1       		if (v4706 == 1 | v4706 == 6) & employed == 1						

				replace labor_card 				= 0       		if  v4706 ~= 1 & v4706 ~= 6  & employed == 1																		//a pessoa está ocupada mas não é trabalhador com carteira assinada.

				gen     social_security 		= 1 			if  v4711 == 1 & employed == 1																						//se contribui para previdência social
		
				replace social_security 		= 0 			if  v4711 == 2 & employed == 1																						//a pessoa está ocupada mas não contribui para a previdência social

				
				*Civil Servants
				*------------------------------------------------------------------------------------------------------------------------*
				gen     civil_servant 			= 1        		if  (v4706 == 2 | v4706 == 3) 				& employed == 1  

				replace civil_servant 			= 0        		if   v4706 ~= 2 & v4706 ~= 3  				& employed == 1  

				gen 	civil_servant_federal 	= 1 	   		if   v9032 == 4 & v9033 == 1	 			& employed == 1	& civil_servant == 1 									//funcionário público federal
				
				gen 	civil_servant_state  	= 1 	   		if   v9032 == 4 & v9033 == 3	 			& employed == 1	& civil_servant == 1 									//funcionário público estadual

				gen 	civil_servant_municipal = 1 	   		if   v9032 == 4 & v9033 == 5  				& employed == 1	& civil_servant == 1 									//funcionário público municipal

				replace civil_servant_federal   = 0		  		if ((v9032 == 4 & v9033 != 1) | v9032 == 2) & employed == 1	& civil_servant == 1 									//trabalha no setor público mas não no federal ou está no setor privado
				
				replace civil_servant_state  	= 0				if ((v9032 == 4 & v9033 != 3) | v9032 == 2) & employed == 1	& civil_servant == 1  
				
				replace civil_servant_municipal = 0				if ((v9032 == 4 & v9033 != 5) | v9032 == 2) & employed == 1	& civil_servant == 1 
				
			
				*Education
				*------------------------------------------------------------------------------------------------------------------------*
				recode  v0606 (2 = 1) (4 = 0)											   , gen (went_school)																		//já frequentou a escola alguma vez na vida

				recode  v4745 (8 = .)													   , gen (edu_att)
								
				assert  v6007 == . | v6007 == 0  				if schoolatt == 1												   													//6007 = último curso que frequentou para quem está fora da escola. a variável v6007 precisa ser igual a 0 ou . toda vez que schoolatt == 1

				assert  v6003 == . | v6003 == 0  				if schoolatt != 1												   							 						//6003 = curso que frequenta para quem está na escola. a variável v6003 precisa ser igual a 0 ou . toda vez que schoolatt ~= 1
				
				assert  v6003 != . 								if schoolatt == 1

				gen     edu_att2   = 1        					if edu_att   == 1																									//sem instrução 

				replace edu_att2   = 2 							if edu_att == 2 | edu_att == 3																						//primary

				replace edu_att2   = 3 							if edu_att == 4 | edu_att == 5																						//upper secondary

				replace edu_att2   = 4 							if edu_att == 6 | edu_att == 7																						//tertiary

				replace v4803 	   = . 							if v4803 == 17																										//anos de escolaridade

				replace v4803 	   = v4803 - 1
			
				gen 	yrs_school = v4803																						
									
				gen 	edu_level_enrolled = 1 					if v6003 == 7
				
				replace edu_level_enrolled = 2 					if v6003 == 8 | v6003 == 9

				replace edu_level_enrolled = 3 					if v4801 >= 4  & v4801 <= 7																							//séries iniciais do EF de 8 anos

				replace edu_level_enrolled = 3					if v4801 >= 12 & v4801 <= 16																						//séries iniciais do EF de 9 anos

				replace edu_level_enrolled = 4 					if v4801 >= 8  & v4801 <= 11																						//séries finais do EF de 8 anos

				replace edu_level_enrolled = 4 					if v4801 >= 17 & v4801 <= 20																						//séries finais do EF de 9 anos

				replace edu_level_enrolled = 5 					if v4801 == 21																										//ef eja
				
				replace edu_level_enrolled = 6					if v4801 == 22 
				
				replace edu_level_enrolled = 7 					if v6003 == 23
							
				replace edu_level_enrolled = 8 					if v4801 == 24																										//pré-vestibular

				replace edu_level_enrolled = 9 					if v4801 == 25																										//superior, inclusive mestrado ou doutorado
				
				replace edu_level_enrolled = 10 				if v4801 == 3																										//alfabetização de adultos
				
				tab 	edu_level_enrolled v4801 

				keep 	uf hh_member age hours_worked weight activity occupation hh_id-edu_level_enrolled v3031 v3032 v3033 v0404 v0406
				
				
			}	//fim da harmonização se ano >= 2007

			**
			**
			if `year' >= 2002 & `year' <= 2006 {

				*Household Id
				*------------------------------------------------------------------------------------------------------------------------*
				drop 	id_dom
				
				egen 	hh_id = group(uf v0101 v0102 v0103)																															//identificação do domicílio

				gen 	inf      = v0301

				gen 	ninf_mom = v0407 																																			//número de ordem da mãe - vai ser últil para sabermos a escolaridade da mãe
				gen 	ninf_mom = v0407 																																			//número de ordem da mãe - vai ser últil para sabermos a escolaridade da mãe
				
				sort 	hh_id inf uf

				gen 	year     = v0101


				*
				*------------------------------------------------------------------------------------------------------------------------*
				rename (v9058 v4729 v8005 v0401 v9892) (hours_worked weight age hh_member work_age)  
				
				replace age  				= . 		  		if age == 999 				//idade ignorada
						
				replace hours_worked 		= . 				if hours_worked == 99	 	//sem declaração
				
				replace work_age 	  		= . 				if work_age 	== 99 

				gen 	wage  		  		= v4718   		   	if v4718 < 999999999999

				gen 	hh_income 			= v4721   		   	if v4721 < 999999999999

				gen 	wage_all_jobs 		= v4719  		   	if v4719 < 999999999999																							//pessoas com 10 anos ou mais

				replace v4705 = . if age < 10  																																	//A partir de 2007, a var ocupado passou  a ser divulgado para crianças com 10 anos ou mais. Nas pesquisas de 2002 a 2006, a variável foi calculada para pessoas com 5 anos ou +
				
				recode v4728 (1 = 1) (2 = 1) (3 = 1) (4 = 0) (5 = 0) (6 = 0) (7 = 0) (8 = 0)								, gen (urban)

				recode v0302 (2 = 0) (4 = 1)																				, gen (female)

				recode v4727 (1 = 1) (2 = 0) (3 = 0)																		, gen (metro)
				
				recode v4704 (1 = 1) (2 = 0) (3 = .)																		, gen (eap)

				recode v4705 (1 = 1) (2 = 0)																				, gen (employed)

				recode v4705 (1 = 0) (2 = 1)																				, gen (unemployed)

				recode v4706 (1/8 = 1) (9 = 2) (10 = 3) (11/13 = 4) (14 = .)												, gen (type_work)
						
				recode v0602 (2 = 1) (4 = 0) (9 = .)																		, gen (schoolatt)									//frequenta ou não a escola
						
				recode v6002 (2 = 1) (4 = 0) (9 = .)																		, gen (goes_public_school)							//demanda de ensino público ou privado de quem edu_level_enrolled
				
				if `year'>= 2004 & `year' <= 2006 gen per_capita_inc  = v4742  	if v4742 < 999999999999 																		//sem declaração
					
				if `year'>= 2002 & `year' <= 2003 {
				
					gen 	id  = 1 											if hh_member < 6 																				//pessoas do domicílio exceto pensionistas, emprego doméstico e parente de empregado doméstico. 
					
					bysort hh_id: egen t_ind = sum(id)
					
					gen 	per_capita_inc = hh_income/t_ind 	
					
					drop 	id t_ind 
				}
				
				
				*Women that are mothers
				*------------------------------------------------------------------------------------------------------------------------*
				gen     female_with_children = 1   				if v1101 == 1 & female == 1																						//se já é mãe ou não
				 
				replace female_with_children = 0   				if v1101 == 3 & female == 1
				

				*Labor Card and social security 
				*------------------------------------------------------------------------------------------------------------------------*
				gen     labor_card 		= 1      				if (v4706 == 1 | v4706 == 6) & employed == 1

				replace labor_card 		= 0       				if  v4706 ~= 1 & v4706 ~= 6  & employed == 1																	//a pessoa está ocupada mas não é trabalhador com carteira assinada.

				gen     social_security = 1 					if  v4711 == 1 & employed == 1

				replace social_security = 0 					if  v4711 == 2 & employed == 1																					//a pessoa está ocupada mas não contribui para a previdência social

				
				*Civil servants
				*------------------------------------------------------------------------------------------------------------------------*
				gen     civil_servant  			= 1        		if  (v4706 == 2 | v4706 == 3) 				& employed == 1

				replace civil_servant  			= 0        		if   v4706 ~= 2 & v4706 ~= 3  				& employed == 1 
				
				gen 	civil_servant_federal 	= 1 			if   v9032 == 4 & v9033 == 1				& employed == 1 & civil_servant == 1 								//funcionário público federal
				
				gen 	civil_servant_state 	= 1 			if   v9032 == 4 & v9033 == 3				& employed == 1 & civil_servant == 1 								//funcionário público estadual

				gen 	civil_servant_municipal = 1 			if   v9032 == 4 & v9033 == 5				& employed == 1 & civil_servant == 1 								//funcionário público municipal

				replace civil_servant_federal  	= 0				if ((v9032 == 4 & v9033 != 1) | v9032 == 2) & employed == 1 & civil_servant == 1 
				
				replace civil_servant_state 	= 0				if ((v9032 == 4 & v9033 != 3) | v9032 == 2) & employed == 1 & civil_servant == 1 
				
				replace civil_servant_municipal = 0				if ((v9032 == 4 & v9033 != 5) | v9032 == 2) & employed == 1 & civil_servant == 1 
				
				
				*Education
				*------------------------------------------------------------------------------------------------------------------------*		
				recode  v0606 (2 = 1) (4 = 0)										 , gen (went_school)																		//já frequentou a escola alguma vez na vida
				
				assert  v0607 == . | v0607 == 0  				if schoolatt == 1																								//a variável v0607 precisa ser igual a 0 ou . toda vez que schoolatt == 1
						
				assert  v0603 == . | v0603 == 0  				if schoolatt != 1																								//a variável v0603 precisa ser igual a 0 ou . toda vez que schoolatt ~= 1
						
				assert  v0603 != . 								if schoolatt == 1
				
				gen 	edu_att = .
				
				replace edu_att = 1 							if v4703 == 1																									//sem instrução.
			
				replace edu_att = 2								if inlist(v0607, 1, 2, 4)			 																			//EF incompleto

				replace edu_att = 3 							if (v0607 == 2 | v0607 == 4) & v0611 == 1 																		//EF completo, v0611 == 1 se concluiu a etapa anterior

				replace edu_att = 4 							if (v0607 == 3 | v0607 == 5) 																					//Médio incompleto

				replace edu_att = 5 							if (v0607 == 3 | v0607 == 5) & v0611 == 1 																		//Médio completo

				replace edu_att = 6 							if  v0607 == 6 																									//Superior incompleto

				replace edu_att = 7 							if (v0607 == 6 & v0611 == 1) | v0607 == 7 																		//Superior completo
				
				replace edu_att = 1 							if inlist(v0603, 6, 7, 8) 																						//Sem instrução. Está matriculado na alfabetização, creche e pré-escola
			
				replace edu_att = 2 							if inlist(v0603, 1, 3) 																							//está cursando EF, portando, ef incompleto
					
				replace edu_att = 4 							if inlist(v0603, 2,	4)																							//está cursando EM, portando, em incompleto		
				
				replace edu_att = 5 							if v0603   == 9																									//cursinho pre-vestibular. EM completo. tab v4703 = 12 (anos de estudo) quanto v0603 == 9
						
				replace edu_att = 6								if v0603   == 5																									//está cursando ES, portanto, es incompleto
				
				replace edu_att = 7 							if v0603   == 10																								//mestrado ou doutorado, portanto, es completo

				gen     edu_att2   = 1        					if edu_att == 1																									//sem instrução 

				replace edu_att2   = 2 							if edu_att == 2 | edu_att == 3																					//primary

				replace edu_att2   = 3 							if edu_att == 4 | edu_att == 5																					//upper secondary

				replace edu_att2   = 4 							if edu_att == 6 | edu_att == 7																					//tertiary
				
				replace v4703 = . 								if v4703 == 17

				replace v4703 = v4703 - 1
				
				gen 	yrs_school      = v4703
				
				gen 	edu_level_enrolled = 1 					if v0603 == 7																									//creche
				
				replace edu_level_enrolled = 2 					if v0603 == 8																									//pre-escola

				replace edu_level_enrolled = 3					if v4701 >= 3  & v4701 <= 6																						//séries iniciais do EF de 8 anos

				replace edu_level_enrolled = 4					if v4701 >= 7  & v4701 <= 10																					//séries finais do EF de 8 anos

				replace edu_level_enrolled = 5 					if v4701 == 12																									//ef eja
				
				replace edu_level_enrolled = 6					if v4701 == 14 																									//em 
				
				replace edu_level_enrolled = 7					if v4701 == 15 																									//eja em
				
				replace edu_level_enrolled = 8 					if v4701 == 13																									//pré-vestibular

				replace edu_level_enrolled = 9					if v4701 == 16																									//superior, inclusive mestrado ou doutorado
				
				replace edu_level_enrolled = 10 				if v4701 == 2 																									//alfabetização de adultos

				tab v4701 edu_level_enrolled

				keep uf age hh_member hours_worked weight hh_id-edu_level_enrolled v3031 v3032 v3033 v0404 v0406
			
			} //fim da harmonização de 2002 a 2006
			
			**
			**
			if `year' <= 2001 {
			
				if 	`year' == 1997 replace v0101 = 1997
				if 	`year' == 1998 replace v0101 = 1998
				if  `year' == 1999 replace v0101 = 1999
				
				
				*Household Id
				*------------------------------------------------------------------------------------------------------------------------*	
				if `year' >  1997 drop 	id_dom																																					//apenas excluí porque o primeiro comando abaixo irá fazer isso e não tenho ctza se a puc considera família = domicílio ou que um domicílio pode ser formado por mais de uma família. 
				
				egen 	hh_id   = group(uf v0101 v0102 v0103)																													//identificação do domicílio

				gen 	inf      = v0301

				gen 	ninf_mom = v0407 																																		//número de ordem da mãe - vai ser últil para sabermos a escolaridade da mãe
				 
				sort 	hh_id inf uf

				gen 	year     = v0101
			
			
				*------------------------------------------------------------------------------------------------------------------------*				
				rename  (v4729  v8005  v0401	  v9892    v9611              v9612 			  ) ///
						///
						(weight age    hh_member  work_age years_current_work months_current_work )										//horas de trabalho -> trabalho principal na semana de referência
				
				gen 	hours_worked = v9058
				
				replace years_current_work  = . 				if years_current_work  == 99 | years_current_work  == -1
				
				replace months_current_work = . 				if months_current_work == 99 | months_current_work == -1
				
				replace age 				= . 				if age == 999
				
				replace hours_worked 		= . 				if hours_worked == 99 | hours_worked == - 1
				
				replace work_age 	  		= .		 			if work_age 	== 99 | work_age     == - 1
						
				recode 	v4728 (1 = 1) (2 = 1) (3 = 1) (4 = 0) (5 = 0) (6 = 0) (7 = 0) (8 = 0)										, gen (urban)
					
				recode 	v0302 (2 = 0) (4 = 1)																						, gen (female)

				recode 	v4727 (1 = 1) (2 = 0) (3 = 0)																				, gen (metro)

				recode  v9115 (1 = 1) (3 = 0) (9 = .)																				, gen (looking_job)

				recode  v9054 (5/8 = 5)(9 = .)																						, gen (place_work)
				
				recode  v9055 (1 = 1)  (3 = 0) (9 = .)																				, gen (work_home)								// morava em domicílio que estava no mesmo terreno ou área do estabelecimento em que tinha esse trabalho
				
				recode  v9008 (1/4 = 1) (5/7 = 2) (8/10 = 3) (11 = 4) (12 = 5) (13 = 6) (88 89 = .)									, gen (type_work_agric) 						//para trabalhadores do setor agrícula. 1: empregado, 2: conta própria...	

				gen     type_work_noagric = v9029 																																		//para trabalhadores do setor não agrícola. 1: empregado, 2: conta própria...	
				
				gen 	employed = 1 							if (v9001 == 1 | v9002 == 2 | v9003 == 1 | v9004 == 2) 																	//está ocupado na semana de referência se trabalhou, estava afastado ou exerceu tarefas de cultivo, construção
		 
				replace employed = 0 							if (looking_job == 1 & employed != 1)					  
				
				if `year' == 2001 {
				
					recode  v6002 (2 = 1) (4 = 0) (9 = .)																			, gen (goes_public_school)						//demanda de ensino público ou privado de quem edu_level_enrolled
						
					rename (v4754 v4756 v4759 v4760 v4768 v4769 v4761) 	///	
					///
						   (v4704 v4706 v4709 v4710 v4718 v4719 v4711)																												//em 2001, o nome das variáveis é um pouco diferente porque engloba trabalhadores com ou acima de 5 anos
				
				}
				
				gen 	work_household_consumption =  v9003 == 1  | v9004 == 2  																										//trabalha na produção de alimentos ou na construção para uso próprio
				
				recode  v4704 (1 = 1) (2 = 0) (3 = .)															  					, gen (eap)
				
				recode  v4706 (1/8 = 1) (9 = 2) (10 = 3) (11/13 = 4) (14 = .)									  					, gen (type_work)
					
				recode  v0602 	(2 = 1) (4 = 0) (9 = .)																				, gen (schoolatt)								//frequenta ou não a escola
					
				recode  employed (1 = 0) (0 = 1)																					, gen (unemployed)
					
				replace unemployed = . 							if eap == 0 & unemployed == 1	//error
				
				gen 	wage  			= v4718   				if  v4718 < 999999999999  & v4718 != -1
				
				gen 	wage_all_jobs 	= v4719 				if  v4719 < 999999999999  & v4719 != -1
											
				gen 	hh_income 		= v4721   		   		if  v4721 < 999999999999

				gen 	id  = 1 								if hh_member < 6 																									//pessoas do domicílio exceto pensionistas, emprego doméstico e parente de empregado doméstico. 
					
				bysort  hh_id: egen t_ind = sum(id)
					
				gen 	per_capita_inc = hh_income/t_ind 	
					
				drop 	id t_ind 
				
				if `year' < 2001 rename (v4709 v4710) (activity90s occupation90s)																									//atividade e setor de ocupação, definições usadas em 1998 e 1999.

				gen 	agric_sector = 1 if !missing(type_work_agric)																												//dummy para identificar quem trabalha ou não com agricultura																					
				
				replace agric_sector = 0 if  missing(type_work_agric) & employed == 1
				
				
				
				
				*Labor Card and social security 
				*------------------------------------------------------------------------------------------------------------------------*
				gen     labor_card 		= 1       				if (v4706 == 1 | v4706 == 6) 		& employed == 1

				replace labor_card 		= 0       				if  v4706 ~= 1 & v4706 ~= 6  		& employed == 1																	//a pessoa está ocupada mas não é trabalhador com carteira assinada.

				gen     social_security = 1 					if  v4711 == 1 						& employed == 1

				replace social_security = 0 					if  v4711 == 2 						& employed == 1																	//a pessoa está ocupada mas não contribui para a previdência social
				
				foreach var of varlist eap type_work wage wage_all_jobs labor_card social_security looking_job employed unemployed {
					
					replace `var' = . if age < 10 																																	//normalmente, as informações sobre trabalho são coletadas para pessoas com 10 anos ou +. Em 2001, foram coletadas para 5 anos ou +. Apenas para padronizar com os demais anos, vamos colocar missing quando idade < 10
					
				}
				

				*In 2001, there is a series of questions regarding the work safety for children/teenagers and also education
				*------------------------------------------------------------------------------------------------------------------------*
				if `year' == 2001 { 
						
						recode  v1605 (1 = 1) (3 = 0) (9 = .), gen (happy_work)
						
						rename (v1606 v1607 v1504 v1562 v1507 v1508) (reason_not_like_work reason_work hours_school missing_school_days reason_not_go_school reason_not_attend_school)
						
						replace reason_not_like_work= . 		if reason_not_like_work == 9 
						
						replace reason_work			= . 		if reason_work 			== 9
						
						replace reason_work         = 2 		if reason_work 			== 3
						
						replace hours_school		= . 		if hours_school 		== 9
						
						foreach var of varlist missing_school_days reason_not_go_school reason_not_attend_school {
						
							replace `var' = . 		if `var' 	== 99
						}
						
						replace reason_not_go_school 	 = 0 if reason_not_go_school 	 != 2
						
						replace reason_not_go_school 	 = 1 if reason_not_go_school 	 == 2 
						
						replace reason_not_attend_school = 0 if reason_not_attend_school != 2
						
						replace reason_not_attend_school = 1 if reason_not_attend_school == 2 
					
						gen 	more4hours_school 		 = 1 if schoolatt 				 == 1 & (hours_school == 4 | hours_school == 6)
				
						replace more4hours_school 		 = 0 if schoolatt 				 == 1 & (hours_school == 2)
				
						gen 	more6hours_school 		 = 1 if schoolatt 			     == 1 & (hours_school == 6)
					
						replace more6hours_school 	     = 0 if schoolatt 				 == 1 & (hours_school == 4 | hours_school == 2 )
												
				} 
				
					
				*Women that are mothers
				*------------------------------------------------------------------------------------------------------------------------*
				gen     female_with_children         = 1   		if v1101 == 1 & female == 1																							//se já é mãe ou não
				 
				replace female_with_children         = 0   		if v1101 == 3 & female == 1

				
				*Civil servants
				*------------------------------------------------------------------------------------------------------------------------*
				gen     civil_servant 			= 1        		if ( v4706 == 2 | v4706 == 3) 				& employed == 1

				replace civil_servant			= 0        		if   v4706 ~= 2 & v4706 ~= 3  				& employed == 1

				gen 	civil_servant_federal 	= 1 	   		if   v9032 == 4 & v9033 == 1	 			& employed == 1	& civil_servant == 1 									//funcionário público federal
				
				gen 	civil_servant_state  	= 1 	   		if   v9032 == 4 & v9033 == 3	 			& employed == 1	& civil_servant == 1 									//funcionário público estadual

				gen 	civil_servant_municipal = 1 	   		if   v9032 == 4 & v9033 == 5  				& employed == 1	& civil_servant == 1 									//funcionário público municipal

				replace civil_servant_federal   = 0		  		if ((v9032 == 4 & v9033 != 1) | v9032 == 2) & employed == 1	& civil_servant == 1 									//trabalha no setor público mas não no federal ou está no setor privado
				
				replace civil_servant_state  	= 0				if ((v9032 == 4 & v9033 != 3) | v9032 == 2) & employed == 1	& civil_servant == 1 
			
				replace civil_servant_municipal = 0				if ((v9032 == 4 & v9033 != 5) | v9032 == 2) & employed == 1	& civil_servant == 1 
				
						
				*Education
				*------------------------------------------------------------------------------------------------------------------------*
				recode  v0606 (2 = 1) (4 = 0) (9 = .)			, gen (went_school)																									//já frequentou a escola alguma vez na vida
				
				gen 	edu_att = .
				
				replace edu_att = 1 							if v4703 == 1																										//sem instrucao
				
				replace edu_att = 2 							if inlist(v4702, 3, 4, 5)																							//cursando ef - > ensino fundamental incompleto
				
				replace edu_att = 4 							if v4702 == 6																										//cursando em - > ensino medio incompleto
				
				replace edu_att = 6 							if v4702 == 7																										//es 
				
				replace edu_att = 2								if inlist(v0607, 1, 2, 4) 																							//EF incompleto

				replace edu_att = 3 							if (v0607 == 2 | v0607 == 4) & v0611 == 1 																			//EF completo, v0611 == 1 se concluiu a etapa anterior

				replace edu_att = 4 							if (v0607 == 3 | v0607 == 5) 																						//Médio incompleto

				replace edu_att = 5 							if (v0607 == 3 | v0607 == 5) & v0611 == 1 																			//Médio completo

				replace edu_att = 6 							if  v0607 == 6 																										//Superior incompleto

				replace edu_att = 7 							if (v0607 == 6 & v0611 == 1) | v0607 == 7 																			//Superior completo

				gen     edu_att2   = 1        					if edu_att == 1																										//sem instrução 
		
				replace edu_att2   = 2 							if edu_att == 2 | edu_att == 3																						//primary

				replace edu_att2   = 3 							if edu_att == 4 | edu_att == 5																						//upper secondary

				replace edu_att2   = 4 							if edu_att == 6 | edu_att == 7																						//tertiary
				
				replace v4703 	   = . 							if v4703 == 17																										//anos de escolaridade

				replace v4703 	   = v4703 - 1
				
				gen 	yrs_school = v4703
				
				gen 	edu_level_enrolled = 1 					if v0603 == 7  																										//creche
			
				replace edu_level_enrolled = 2 					if v0603 == 8																										//pre-escola

				replace edu_level_enrolled = 3 					if v4701 >= 3  & v4701 <= 6																							//séries iniciais do EF de 8 anos

				replace edu_level_enrolled = 4 					if v4701 >= 7  & v4701 <= 10																						//séries finais do EF de 8 anos

				replace edu_level_enrolled = 5 					if v4701 == 12																										//ef eja

				replace edu_level_enrolled = 6					if v4701 == 14 																										//em
				
				replace edu_level_enrolled = 7					if v4701 == 15																										//em ou eja em
				
				replace edu_level_enrolled = 8					if v4701 == 13																										//pré-vestibular

				replace edu_level_enrolled = 9 					if v4701 == 16																										//superior, inclusive mestrado ou doutorado
				
				replace edu_level_enrolled = 10					if v4701 == 2  																										//alfabetização de adultos

				tab v4701 edu_level_enrolled
	
				if `year' == 2001 keep 	hours_school missing_school_days reason_not_go_school reason_not_attend_school happy_work reason_not_like_work reason_work	 		 												 work_home place_work type* work_household_consumption   uf age hh_member weight hours_worked years_current_work months_current_work hh_id-edu_level_enrolled v3031 v3032 v3033 v0404 v0406
				
				*if `year' <  2001 keep   v0404 v0101 v0102 v0103 v0301 v0602 v0603 v0605 v0606 v0607 v0610 v0601 v4718 v4719 v4720  v9001 v9004 v9002 v9003 v9008 v9029 v9054 activity90s occupation90s  					 work_home place_work type* work_household_consumption   uf age hh_member weight hours_worked years_current_work months_current_work hh_id-edu_level_enrolled v3031 v3032 v3033 v0404 v0406

			
			} //fim da harmonização até 2001
			
			
			**
			**
			*Other variables

				*Children in the household
				*------------------------------------------------------------------------------------------------------------------------*
				gen 	kid6a 		  = 1 	    		   		if age < 6 
					
				gen 	kid13a 		  = 1       		   		if age >= 6 & age <= 13 

				gen		kid17a		  = 1 				   		if age >= 6 & age <= 17

				gen 	kid17fa		  = 1 				   		if age >= 6 & age <= 17 & female == 1																						//meninas adolescentes no domicílio

				gen 	kid17ma		  = 1 				   		if age >= 6 & age <= 17 & female == 0																						//meninos adolescentes no domicílio

				foreach name in kid6 kid13 kid17 kid17f kid17m {
				
					bysort hh_id: egen `name' = max(`name'a)
					
					replace 			`name' = 0  if missing(`name')
					
					drop `name'a
				
				}	
				
			
				*Finished high school
				*------------------------------------------------------------------------------------------------------------------------*
				gen 	highschool_degree = 1 							if inlist(edu_att, 5, 6, 7)
				
				replace highschool_degree = 0  							if edu_att     < 5

				gen 	lowersec_degree   = 1							if inlist(edu_att, 3, 4, 5, 6, 7)
				
				replace lowersec_degree   = 0							if edu_att     < 3
				
				*College degree
				*------------------------------------------------------------------------------------------------------------------------*
				gen 	 college_degree   = edu_att == 7  | edu_att == 6
				
				replace  college_degree   = . if edu_att == .
				
			
				*Age of the child in March. This is important as it is the age of the child in march that determines when she/he has to enroll school
				*------------------------------------------------------------------------------------------------------------------------*
				replace v3031 = . 		 if v3031 == 0 	 | v3031 == 99
				
				replace v3032 = . 		 if v3032 == 20  | v3032 == 99
				
				replace v3033 = .		 if v3033 < 100  | v3033 == 9999																													//entre 0 e 98 é porque é a idade presumida
				
				if `year' < 2001 replace v3033 = 1000 + v3033 if v3033 >= 800
				
				*br 	 	year v3031 v3032 v3033 age 
				 
				egen 	v3031b=concat(v3031)																																				//ajuste para idade
					
				egen 	v3032b=concat(v3032)
					
				egen 	v3033b=concat(v3033)

				*br 		year v3031 v3031b v3032 v3032b v3033 v3033b age

				replace v3031b = "0" + v3031b 					if length(v3031b) == 1
						
				replace v3032b = "0" + v3032b 					if length(v3032b) == 1

				*br 		year v3031 v3031b v3032 v3032b v3033 v3033b age
					
				egen 	bd=concat(v3032b v3031b v3033b)

				*br 		year v3031 v3031b v3032 v3032b v3033 v3033b age bd

				gen 	birth_date = date(bd,"MDY") 																																		//note that month is unknow, the Value is 20 and if the year is unknow the Value is the presumed age
					
				format 	birth_date %td

				*br 		year v3031 v3031b v3032 v3032b v3033 v3033b age bd birth_date

				list 	birth_date bd v3031 v3032 v3033 age in 1/20
					
				ta 		v3031
					
				ta 		v3032
					
				ta 		v3033

				gen     base_date = mdy(3,31,1998) 				if year == 1998 		//be careful if year < 2000
				
				foreach wave in 1999 2001 2002 2003 2004 2005 2006 2007 2008 2009 2011 2012 2013 2014 2015 {
					
					replace base_date = mdy(3,31,`wave') 		if year == `wave'		//be careful if year < 2000
				
				}

				format  base_date %td

				g 		ageA = (base_date - birth_date)/365.25
					
				g 		age_31_march = trunc(ageA)
				
				
				foreach var of varlist age_31_march {
					
					replace `var' = age 						if v3033 < 1895 & year == 2015

					replace `var' = age 						if v3033 < 1890 & year == 2014

					replace `var' = age 						if v3033 < 1893 & year == 2013

					replace `var' = age 						if v3033 < 1890 & year == 2012

					replace `var' = age 						if v3033 < 1890 & year == 2011

					replace `var' = age 						if v3033 < 1887 & year == 2009

					replace `var' = age 						if v3033 < 1887 & year == 2008

					replace `var' = age 						if v3033 < 1885 & year == 2007
					
					replace `var' = age 						if v3033 < 1885 & year == 2006

					replace `var' = age							if v3033 < 1884 & year == 2005

					replace `var' = age 						if v3033 < 1883 & year == 2004

					replace `var' = age							if v3033 < 1882 & year == 2003

					replace `var' = age 						if v3033 < 1882 & year == 2002
					
					replace `var' = age							if missing(age_31_march)
				
				}

				*br 		year v3031 v3031b v3032 v3032b v3033 v3033b age ageA age_31_march bd birth_date base_date

				tab 	age_31_march
						
				rename (v3031 v3032 v3033) (day_birth month_birth year_birth)

				gen 	dateofbirth = mdy(month_birth, day_birth, year_birth)
						
				gen 	no_dateofbirth = day(dateofbirth) == .


				*------------------------------------------------------------------------------------------------------------------------*
				recode female (1 = 0) (0 = 1), gen (male)
				
				gen 	age2 		  		= age^2 
				
				gen 	wage_hour 		 	= wage/4													//salário por hora. 4 semanas em um mês +ou-

				replace wage_hour 	 	 	= wage_hour/hours_worked		

				gen 	out_labor  	  		= 1					if eap == 0

				replace out_labor 			= 0 				if eap == 1

							
				*Formal/informal job
				*------------------------------------------------------------------------------------------------------------------------*
				gen 	formal = 1          					if employed == 1 & ((labor_card == 1 | civil_servant  == 1) | (type_work == 2 & social_security == 1) | (type_work == 3 & social_security == 1))
			
				replace formal = 0          					if employed == 1 & ((labor_card == 0) 					    | (type_work == 2 & social_security == 0) | (type_work == 2 & social_security == 0))
			
				recode  formal (1 = 0) (0 = 1), gen (informal)
				
				
				*Non paid work, Work and study status
				*------------------------------------------------------------------------------------------------------------------------*
				gen 	working 		= employed ==  1 //employed is a variable that is only defined for people in economically active population

				gen 	unpaid_work 	= type_work == 4 
				
				replace unpaid_work 	= 1 if  working  == 1 & type_work  != 4 & wage_all_jobs == 0

				gen 	pwork 			= working == 1  & unpaid_work 	== 0
										
				gen 	uwork 			= working == 1  & unpaid_work 	== 1						
										
				gen 	pwork_formal 	= pwork   == 1  & formal 		== 1
										
				gen 	pwork_informal 	= pwork   == 1  & formal 		== 0
									
				gen 	work_formal		= working == 1  & formal 		== 1
								
				gen 	work_informal	= working == 1  & formal 		== 0
									
				gen 	pwork_sch  		= pwork   == 1  & schoolatt 	== 1
				
				gen 	uwork_sch  		= uwork   == 1  & schoolatt 	== 1

				gen 	pwork_only 		= pwork   == 1  & schoolatt 	== 0

				gen 	uwork_only 		= uwork   == 1  & schoolatt 	== 0

				gen 	study_only 		= working == 0  & schoolatt 	== 1

				gen 	nemnem	   		= working == 0  & schoolatt 	== 0

				foreach var of varlist pwork_sch uwork_sch pwork_only uwork_only study_only nemnem* {
					
					replace `var' = . if  working == . | schoolatt == .
						
				}
					
		
				*Education, age and working status of the mom
				*------------------------------------------------------------------------------------------------------------------------*
				sort 	hh_id inf
				
				*br 		hh_id inf hh_member ninf_mom edu_att2
				
				***
				***

				foreach var of varlist edu_att2 yrs_school age working {
				
				levelsof ninf_mom, local(levels)
				
				di `levels'
				
				gen mom_`var' = .
			
					foreach i in `levels' {
						
						gen  	mom_aux   = `var' 				if inf == `i'
						
						egen 	mom_aux_2 = max(mom_aux), 		by (hh_id)
						
						replace	mom_`var' = mom_aux_2			if ninf_mom == `i'
						
						drop 	mom_aux*
						
					}
				
						gen		mom_aux   = `var' 				if 					    (hh_member == 1 | hh_member == 2) & female == 1				//para crianças que não temos o identifidor da mãe (porque não moram com elas ou a mãe é falecida, a escolaridade que vai nessa variável é a escolaridade da mulher que é chefe do domicílio ou cônjuge
									
						egen 	mom_aux2  = max(mom_aux), 		by (hh_id)
						
						replace mom_`var' = mom_aux2	 		if missing(mom_`var') & (hh_member == 3 | hh_member == 4)	
						
						drop 	mom_aux*
				}
				

				*Color of the skin
				*------------------------------------------------------------------------------------------------------------------------*
				gen		color = v0404
				
				replace color = . 												if color == 9
				
				gen     white    = 1 											if v0404 == 2
				
				replace white    = 0 											if v0404 ~= 2 & v0404 ~= 9 & !missing(v0404)

				gen     black    = 1 											if v0404 == 4

				replace black    = 0 											if v0404 ~= 4 & v0404 ~= 9 & !missing(v0404)

				gen     pardo    = 1 											if v0404 == 8

				replace pardo    = 0 											if v0404 ~= 8 & v0404 ~= 9 & !missing(v0404)

				gen     indigena = 1 											if v0404 == 0
				
				replace indigena = 0 											if v0404 ~= 0 & v0404 ~= 9 & !missing(v0404)

				gen     yellow   = 1 											if v0404 == 6 

				replace yellow   = 0  											if v0404 ~= 6 & v0404 ~= 9 & !missing(v0404)
			
			
				*Number of relevant household members
				*------------------------------------------------------------------------------------------------------------------------*
				gen 	hh_ind = 1 												if hh_member < 6						//relevant hh members

				bysort 	hh_id: egen hh_size = total(hh_ind)	

				gen 	hh_head = hh_member == 1 																		//household head

				gen 	spouse 	= hh_member == 2																		//spouse

				egen 	two_parent 	= total(spouse), by(hh_id year) miss												//two parent household

				tab		two_parent, mis
				drop 	hh_ind
				
				
				*Adults income
				*------------------------------------------------------------------------------------------------------------------------*
				//we see hh_income variable = - 1 when hh_member > 5
					
				tab 	hh_income 										if hh_member == 7 | hh_member == 8 | hh_member == 6	//domestic worker or relative of domestic worker, ou "pensionista" (the person that pays rent, its not a parent of the members of the household).
				
				replace hh_income = . 									if hh_income == -1
				
				gen 	temp = wage_all_jobs if age < 18
				
				bys	 	hh_id: egen children_income = sum(temp) 		if hh_member < 6 			
				
				replace children_income = 0 if missing(children_income) &  hh_member < 6 		
				
				gen 	adults_income = hh_income - children_income		if hh_member < 6
				
				drop 	temp
				
				
				*Area
				*------------------------------------------------------------------------------------------------------------------------*
				gen 	area = 1 										if urban == 1 & metro == 0		//Urbana

				replace area = 2 										if urban == 0 & metro == 0		//Rural	

				replace area = 3 										if metro == 1					//Metropolitana

				tab 	area
				
				
				*Region
				*------------------------------------------------------------------------------------------------------------------------*
				destring uf, replace
				
				recode uf (11/19 = 1) (20/29 = 2) (30/39 = 3) (40/49 = 4) (50/59 = 5), gen (region)
				
				
				*Years of schooling, gender, and age of the head of the household
				*------------------------------------------------------------------------------------------------------------------------*
				gen 	temp = yrs_school 			if hh_head == 1
				
				bys 	hh_id: egen hh_head_edu = max(temp)
				
				drop 	temp
				
				gen 	temp = age 					if hh_head == 1
				
				bys 	hh_id: egen hh_head_age = max(temp)
				
				drop 	temp
				
				gen 	temp = male 				if hh_head == 1
				
				bys 	hh_id: egen hh_head_male = max(temp)
				
				drop 	temp
				
				gen 	temp = yrs_school			if spouse == 1 & male == 0
				
				bys 	hh_id year: egen hh_spouse_edu = max(temp)
				
				drop 	temp				
				
				*------------------------------------------------------------------------------------------------------------------------*
				replace wage 				= . 	if wage 			== 0
				
				replace wage_all_jobs 		= . 	if wage_all_jobs 	== 0
				
				replace wage_hour			= . 	if wage_hour 		== 0
					
			save "$inter/pnad_harm_`year'.dta", replace
			*----------------------------------------------------------------------------------------------------------------------------*
			end

			
		**
		**
		*Pooled data
		*___________________________________________________________________________________________________________ _____________________*
			
			foreach wave in 1998 1999 2001 2002 2003 2004 2005 2006 2007 2008 2009 2011 2012 2013 2014 {
				harmonizar_pnad, year(`wave')
			}
			clear
			foreach wave in 1998 1999 2001 2002 2003 2004 2005 2006 2007 2008 2009 2011 2012 2013 2014 {
				append using "$inter/pnad_harm_`wave'.dta"
				erase 		 "$inter/pnad_harm_`wave'.dta"
			}
			save "$inter/Pooled_PNAD.dta", replace

		
		**
		**
		*Formatting
		*________________________________________________________________________________________________________________________________*
			
			use 	"$inter/Pooled_PNAD.dta", clear
			
			drop 	 v0406 looking_job v3031b-ageA
			
			*tab 	activity	, gen(activity)
			tab 	place_work	, gen(place_work)
			tab 	region      , gen(region)
							
				*Variáveis monetárias em R$ de 2020
				*------------------------------------------------------------------------------------------------------------------------*
				local ipca1998 = 3.77586272757493
				local ipca1999 = 3.46600885666878
				local ipca2000 = 3.27060359219336
				local ipca2001 = 3.03752132477299
				local ipca2002 = 2.69929258515612
				local ipca2003 = 2.46960651509976
				local ipca2004 = 2.29518409507185
				local ipca2005 = 2.17163486209267
				local ipca2006 = 2.10549053721717
				local ipca2007 = 2.01564018031416
				local ipca2008 = 1.90329398220092
				local ipca2009 = 1.824622639043
				local ipca2010 = 1.72282620157445
				local ipca2011 = 1.61762625982371
				local ipca2012 = 1.5283897751397
				local ipca2013 = 1.4430931156772
				local ipca2014 = 1.35619529801985
				local ipca2015 = 1.2254072387238
				local ipca2016 = 1.15289043063675
				local ipca2017 = 1.1198547165
				local ipca2018 = 1.07937804
				local ipca2019 = 1.0452
				local ipca2020 = 1
				
				foreach var of varlist wage per_capita_inc hh_income wage_hour wage_all_jobs { 
					gen real_`var' = .
						foreach wave in  1998 1999 2001 2007 2008 2009 2011 2012 2013 2014 2015 {
							replace real_`var' = `var'*`ipca`wave'' if year == `wave'
					}
				}
				*/
				
				*Variáveis em Ln
				*------------------------------------------------------------------------------------------------------------------------*
				foreach var of varlist *wage *per_capita_inc *hh_income *wage_hour *wage_all_jobs {
					gen ln`var' = ln(`var')
				}
				format wage per_capita_inc hh_income wage_hour hours_worked real* ln*  %12.2fc

				
				*Estado
				*------------------------------------------------------------------------------------------------------------------------*
				label define coduf     	11 "Rondônia" 			12 "Acre" 					13 "Amazonas" 			    14 "Roraima" 			15 "Pará" 			16 "Amapá" 		17 "Tocantins" 		21 "Maranhão" 	///
										22 "Piauí" 				23 "Ceará" 					24 "Rio Grande do Norte" 	25 "Paraíba" 		    26 "Pernambuco" 	27 "Alagoas" 	28 "Sergipe" ///
										29 "Bahia" 				31 "Minas Gerais" 			32 "Espírito Santo" 		33 "Rio de Janeiro" 	35 "São Paulo" 		41 "Paraná" ///
										42 "Santa Catarina" 	43 "Rio Grande do Sul" 	    50 "Mato Grosso do Sul" 	51 "Mato Grosso" 		52 "Goiás" 			53 "Distrito Federal" 
				rename uf 	 coduf

																		
				*Labels					
				*------------------------------------------------------------------------------------------------------------------------*				
				label define type_work 					1 "Empregado"   					2 "Trabalhador por conta própria"    3 "Empregador"    4 "Trabalhador não remunerado" 
			
				label define edu_att    				1 "Sem instrução"  		 			2 "EF incompleto" 					 3 "EF completo"   4 "EM incompleto" 			5 "EM completo"   6 "Ensino Superior incompleto"  7 "Ensino Superior completo"  

				label define edu_att2     				1 "Sem instrução"   				2 "Ensino Fundamental"  			 3 "Ensino Médio"  4 "Ensino Superior"

				label define mom_edu 					1 "Sem instrução"  					2 "Ensino Fundamental"  			 3 "Ensino Médio"  4 "Ensino Superior"

				label define two_parent 	    		0 "Somente chefe domicílio"  		1 "Chefe domicílio e cônjuge"

				label define hh_member 					1 "Chefe domicílio" 				2 "Cônjuge" 						 3 "Filho"					  		4 "Outro parente"   5 "Agregado" 			 6 "Pensionista"    					7 "Trabalhador doméstico"  	8 "Parente de trabalhador doméstico" 

				label define activity 					1 "Agrícola"  						2 "Outras atividades industriais"	 3 "Indústria de transformação" 	4 "Construção" 		5 "Comércio e reparação" 6 "Alojamento e alimentação" 			7 "Transporte"   			8 "Administração pública"  9 "Educação, saúde e serviços sociais" 10 "Serviços domésticos" 11 "Outros serviços coletivos, sociais e pessoais" 12 "Outras atividades" 13 "Atividades maldefinidas" 

				label define occupation					1 "Dirigentes em geral"  			2 "Profissionais das ciências/artes" 3 "Técnicos de nível médio"        4 "Serviços adm."  	5 "Serviços" 			 6 "Vendedores" 						7 "Agrícolas"				8 "Bens e serviços"		   9 "Forças armadas"					  10 "Ocupações maldefinidas" 
					
				label define schoolatt      			0 "Não frequenta a escola" 			1 "Frequenta escola"  
					
				label define urban 		 				1 "Zona Urbana" 					0 "Zona Rural"

				label define metro 		 				1 "Área metropolitana" 				0 "Não metropolita"

				label define area 		 				1 "Urbana" 							2 "Rural area"  					 3 "Metropolitana"

				label define color           			2 "Branca" 	  						4 "Preta" 							 6 "Amarela" 						8 "Parda" 	 		0 "Índigena" 

				label define went_school      			1 "Já frequentou a escola" 			0 "Nunca frequentou"					//para as pessoas que não estão mais edu_level_enrolledndo

				label define female_with_children       1 "Mulher com filho" 				0 "Mulher sem filho"

				label define labor_card       			1 "CT assinada" 			 		0 "Sem CT assinada"

				label define social_security 			1 "Paga previdência"    	 		0 "Não paga previdência"
			
				label define civil_servant      		1 "Servidor público"   		 		0 "Não é servidor público" 
							
				label define employed         			1 "Ocupado"        			 		0 "Desocupado"

				label define unemployed     			1 "Desocupado"    					0 "Ocupado"

				label define eap             			1 "Economicamente ativo/a" 			0 "Fora da força de trabalho"
				
				label define out_labor					0 "Economicamente ativo/a" 			1 "Fora da força de trabalho"

				label define edu_level_enrolled  		1 "Maternal ou jardim de infância"  2 "Pré-escola" 						 3 "Anos iniciais do EF" 			4 "Anos finais do EF" 5 "EF EJA" 6 "Ensino Médio"  7 "EM EJA"  8 "Vestibular" 9 "Ensino Superior" 10 "Alfabetização de adultos"

				label define female						0 "Homem"							1 "Mulher" 
				
				label define male						0 "Mulher"							1 "Homem" 
				
				label define formal						0 "Informal"						1 "Formal" 
				
				label define informal					1 "Informal"						0 "Formal" 
				
				label define nemnem 					1 "Não estuda e não trabalha"
				
				label define somente_trabalha 			1 "Não estuda, mas trabalha"
				
				label define somente_estuda				1 "Não trabalha, mas estuda"
				
				label define nemnem_des	            	1 "Nem-nem unemployed"
				
				label define nemnem_out					1 "Nem-nem fora da força de trabalho" 
				
				label define estuda_trabalha			1 "Estuda e trabalha" 
				
				label define goes_public_school			0 "Estuda em escola particular" 	1 "Estuda em escola pública" 
				
				label define hh_head 					0 "Não é chefe do domicílio"		1 "É chefe do domicílio"
				
				label define spouse						0 "Não é o cônjuge"      			1 "É cônjuge" 
				
				label define highschool_degree			0 "Não concluiu o EM"				1 "Concluiu o EM" 
				
				label define lowersec_degree			0 "Não concluiu o EF"				1 "Concluiu o EF" 
				
				label define college_degree				0 "Não concluiu a faculdade"		1 "Concluiu a faculdade" 
				
				label define kid6				    	0 "Sem criança menor de 6 anos" 	1 "Com criança menor de 6 anos"
				
				label define kid13				    	0 "Sem criança de 6 a 13" 			1 "Com criança de 6 a 13"

				label define kid17				   	 	0 "Sem criança de 6 a 17" 			1 "Com criança de 6 a 17"
				
				label define kid17m				    	0 "Sem criança de 6 a 17(homem)" 	1 "Com criança de 6 a 17 (homem)"
			
				label define kid17f				    	0 "Sem criança de 6 a 17(mulher" 	1 "Com criança de 6 a 17 (mulher)"
							
				label define civil_servant_federal  	0 "Servidor público, não federal"   1 "Servidor público federal" 
				
				label define civil_servant_state  		0 "Servidor público, não estadual"  1 "Servidor público estadual" 

				label define civil_servant_municipal 	0 "Servidor público, não municipal" 1 "Servidor público municipal" 

				label define type_work_agric 			1 "Empregado" 						2 "Conta-própria" 				3 "Empregador"    4 "Não-remunerado membro do domicílio" 5 "Não remunerado, outros" 			6 "Trabalhador na produção para o próprio consumo"
				
				label define type_work_noagric 			1 "Empregado" 						2 "Trabalhador doméstico" 		3 "Conta-própria" 4 "Empregador"						 5 "Não-remunerado membro do domicílio" 6 "Não remunerado, outros" 7 "Trabalhador na construção para o próprio uso"

				label define place_work 				1 "Loja, oficina, fábrica, escritório, escola, repartição pública, galpão, etc." ///
														2 "Fazenda, sítio, granja, chácara, etc." 										 ///
														3 "No domicílio em que morava"													 ///
														4 "Em domicílio de empregador, patrão, sócio ou freguês" 						 ///
														5 "Outros"

				label define actitity90s 				1  "Agrícola" 						 2 "Indústria de transformação"	     3  "Indústria de construção" 			///
														4  "Outras atividades industriais"	 5 "Comércio de mercadorias"		 6  "Prestação de serviços"      	 	/// 
														7  "Serviços auxiliares da atividade econômica"							 										///  
														8  "Transporte e comunicação"		 9 "Social"						     10 "Adm pública"						/// 
														11 "Atividades mal definidas"
																							
				label define occupation90s 				1  "Técnica, científica, artística"  2 "Administrativa"	   				  3  "Agropecuária e produção extrativa vegetal e animal" 			///
														4  "Indústria de transformação "	 5 "Comércio e atividades auxiliares" 6  "Transporte e comunicação"      	 							/// 
														7  "Prestação de serviços"							 																						///  
														8  "Outra ocupação, ocupação mal definida ou não declarada"		 
				
						
				label define reason_not_like_work		1 "Trabalho cansativo" 				 2 "Não tinha tempo para estudar"	  3 "Ganhava pouco" 												///
														4 "Não tinha um bom relacionamento com o empregador ou responsável nesse trabalho" 															///
														5 "Não gostava de trabalhar" 		 6 "Pagamento atrasava" 			  7 "Outro motivo" 
														 
				label define reason_work				1 "Querer trabalhar"   			 	 2 "Os pais ou responsáveis querem que trabalhe"
						
				
				label define region						1 "Norte" 2 "Nordeste" 3 "Sudeste" 4 "Sul" 5 "Centro-Oeste" 
				
				label define hours_school				 2 "Até 4 horas"  4 "Entre 4 e 6 horas" 6 "Mais de 6 horas"
			
				label define reason_not_attend_school	 0 "Outro motivo" 1 "Precisa trabalhar ou procurar trabalho" 
				
				label define reason_not_go_school 		 0 "Outro motivo" 1 "Precisa trabalhar ou procurar trabalho" 


				foreach x in hours_school region reason_not_attend_school reason_not_go_school  reason_not_like_work reason_work activity90s occupation90s work_household_consumption place_work type_work_agric type_work_noagric region goes_public_school   female college_degree male informal kid6 kid13 kid17 kid17f kid17m civil_servant_federal civil_servant_state civil_servant_municipal highschool_degree out_labor hh_head spouse formal female coduf type_work edu_att edu_att2 mom_edu_att2 two_parent hh_member  schoolatt urban metro area color went_school female_with_children labor_card social_security civil_servant employed unemployed eap edu_level_enrolled {

					label val `x' `x'

				}
				
				*label val activity   activity
				*label val occupation occupation
			
				label val mom_edu_att2 edu_att2 
				
				label define simnao 0 "Não" 1 "Sim"
				foreach var of varlist no_dateofbirth agric_sector happy_work work_home mom_working white black pardo indigena yellow unpaid_work working-nemnem work_household_consumption {
					label val `var' simnao
				}
				
				*------------------------------------------------------------------------------------------------------------------------*
				format wage wage_all_jobs hh_income per_capita_inc real_wage-real_wage_hour *income* %12.2fc
				
				order 	year coduf hh_id inf weight ninf_mom hh_member  hh_head spouse female_with_children hh_size hh_income per_capita_inc age age2 age_31_march color white-yellow ///
				day_birth month_birth year_birth dateofbirth female male urban metro area eap out_labor employed unemployed labor_card social_security informal formal schoolatt 	  ///
				  edu_level_enrolled yrs_school edu_att edu_att2 mom_edu_att2 mom_yrs_school mom_age
				
				
				*------------------------------------------------------------------------------------------------------------------------*
				label var hh_id										"Household id"
				label var spouse									"Spouse of the head of the household"
				label var female_with_children						"1: mothers, 0 otherwise" 
				label var labor_card 								"Labor Card"
				label var social_security							"Social Security"
				label var civil_servant_federal						"Federal civil servant"
				label var civil_servant_state 						"State civil servant"
				label var civil_servant_municipal					"Municipal civil servant"
				label var year										"Survey year" 
				label var went_school								"Already attended school"
				label var coduf										"Brazilian state"
				label var children_income							"Total wage for children < 18"
				label var kid6 										"Household with children below 6 years-old"
				label var kid13 									"Household with children between 6 and 13 years-old"
				label var kid17 									"Household with children between 6 and 17 years-old"	
				label var kid17f									"Household with girls between 6 and 17 years-old"
				label var kid17m 									"Household with boys between 6 and 17 years-old"
				label var two_parent 								"1 for household with both parents and 0, otherwise"
				label var adults_income 							"Household income without wages of people < 18 years-old"
				label var hh_head_edu 								"Years of schooling of the head of the household"
				label var age_31_march								"Age in March 31th" 
				label var inf 										"Household member identification"
				label var weight 									"Sample weight, person"
				label var ninf_mom 									"Identification number of the mother (if she lives in the same house)"
				label var hh_member 								"Household condition"
				label var hh_head 									"Head of the household"
				label var hh_size 									"Household size, relevant members"
				label var hh_income 								"Household total income (current BRL)"
				label var per_capita_inc 							"Household per capita income (current BRL)"
				label var age 										"Age"
				label var age2 										"Squared Age"
				label var color 									"Color of the skin"
				label var female									"Female"
				label var white 									"White"
				label var black 									"Black"
				label var pardo 									"Pardo"
				label var indigena 									"Indigenous"
				label var yellow 									"Yellow"
				label var day_birth 								"Day of birth"
				label var month_birth 								"Month of birth"
				label var year_birth 								"Year of birth"
				label var dateofbirth 								"Date of birth (number of days between birth and January 1st 1960)"
				label var male 										"Male"
				label var urban 									"Urban"
				label var metro 									"Metropolitan"
				label var area 										"1: Urban, 2: Rural and 3: Metropolitan"
				label var eap 										"Economically active population"
				label var out_labor 								"Out of the labor force"
				label var employed	 								"Employed"
				label var unemployed 								"Unemployed"
				label var informal 									"Informal employee"
				label var formal 									"Formal employee"
				label var schoolatt 								"Attending school"
				label var edu_level_enrolled	 					"Level student is enrolled"
				label var yrs_school 								"Years of schooling"
				label var edu_att 									"Educational attainment"
				label var edu_att2 									"Educational attainment"
				label var mom_edu_att2 								"Mother's educational attainment"
				label var mom_yrs_school 							"Mother's years of schooling"
				label var mom_age 									"Mother's age"
				label var hours_worked 								"Number of hours worked in the reference week"
				label var years_current_work 						"Number of years in the current job"
				label var months_current_work 						"Number of months in the current job"
				label var type_work 								"1: employee. 2: self-employed. 3: employeer. 4: non-paid employee"
				label var wage 										"Wage (current BRL)"
				label var wage_all_jobs 							"Wage of all jobs (current BRL)"
				label var civil_servant 							"Civil Servant"
				label var highschool_degree 						"High school degree"
				label var college_degree 							"Reached college"
				label var lowersec_degree							"Finished lower secondary education"
				label var wage_hour 								"Wage per hour (current BRL)"
				label var unpaid_work 								"Unpaid work"
				label var working 									"Working"
				label var pwork 									"Paid work"
				label var uwork 									"Unpaid work"
				label var pwork_formal 								"Formal paid work"
				label var pwork_informal						 	"Informal paid work"
				label var work_formal 								"Formal work"
				label var work_informal 							"Informal work"
				label var pwork_sch 								"Paid work and attending school"
				label var uwork_sch 								"Unpaid work and attending school"
				label var pwork_only 								"Only paid work"
				label var uwork_only 								"Only unpaid work"
				label var study_only 								"Only attending school"
				label var nemnem 									"Neither working nor attending school"
				label var mom_working 								"Mother's working"
				label var hh_head_edu								"Years of schooling of the head of the household"
				label var hh_head_age 								"Age of the head of the household "
				label var hh_head_male 								"1 if head of the household is male and 0, otherwise"
				label var region 									"Brazilian region"
				label var real_wage 								"Wage (2020 BRL)"
				label var real_per_capita_inc 						"Household per capita income (2020 BRL)"
				label var real_hh_income 							"Household total income (2020 BRL)"
				label var real_wage_hour 							"Wage per hour (2020 BRL)"
				label var real_wage_all_jobs 						"Wage of all jobs (2020 BRL)"
				label var lnwage 									"Ln of wage"
				label var lnreal_wage 								"Ln of real wage"
				label var lnper_capita_inc 							"Ln of household per capita income"
				label var lnreal_per_capita_inc 					"Ln of real household per capita income"
				label var lnhh_income 								"Ln of household total income"
				label var lnreal_hh_income 							"Ln of real household total income"
				label var lnwage_hour 								"Ln of wage per hour"
				label var lnreal_wage_hour 							"Ln of real wage per hour"
				label var lnwage_all_jobs 							"Ln of wage of all jobs"
				label var lnreal_wage_all_jobs 						"Ln of real wage of all jobs"
				label var place_work								"Where the person works"
				label var type_work_agric							"Position in the agricultural sector"
				label var type_work_noagric							"Position in the non-agricultural sector"
				label var work_household_consumption				"Atividade de cultivo/construção para alimentação de moradores do domicílio" 
				label var agric_sector								"Agricultural sector"
				label var no_dateofbirth							"Data of birth not available"
				label var work_home									"The job was in the same land/area of the household"
				label var reason_not_like_work						"Reason the children do not like their work"
				label var reason_work								"Reason to work"
				label var activity 									"Activity sector (after 2006)"
				label var occupation								"Occupation sector (after 2006)"
				label var activity90s								"Actitivity sector, (1998-1999)"
				label var occupation90s								"Occupation sector, (1998-1999)"
				label var goes_public_school						"Public school"
				label var happy_work								"Children is happy with their work"
				label var hours_school 								"Number of hours in school, available 2001"
				label var missing_school_days  						"Missing school days between August 1 and September 30, available 2001"
				label var reason_not_attend_school  				"Couldnt attend school because of work, available 2001"
				label var reason_not_go_school						"Couldnt go to school because of work, available 2001"
				label var more4hours_school			 				"Children spends more than 4 hours in school, available in 2001"
				label var more6hours_school 						"Children spends more than 6 hours in school, available in 2001"
						
				label var region1									"North"
				label var region2									"Northeast"
				label var region3									"Southeast"
				label var region4									"Midwest"
				label var region5									"South"
				
				*------------------------------------------------------------------------------------------------------------------------*
				sort 	year hh_id
				compress
				save 	"$inter/Pooled_PNAD.dta", replace

				clear
				unicode encoding set ISO-8859-1 
				cd "$inter"
				unicode translate Pooled_PNAD.dta
