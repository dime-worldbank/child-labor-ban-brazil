			  
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

			*Identificação do domicílio
			*------------------------------------------------------------------------------------------------------------------------*
			if `year' < 2015 drop id_dom								//apenas excluí porque o primeiro comando abaixo irá fazer isso e não tenho ctza se a puc considera família = domicílio ou que um domicílio pode ser formado por mais de uma família. 
			
			egen 	id_dom   = group(uf v0101 v0102 v0103)				//identificação do domicílio

			gen 	inf      = v0301

			gen 	ninf_mae = v0407 									//número de ordem da mãe - vai ser últil para sabermos a escolaridade da mãe
			
			sort 	id_dom inf uf

			gen 	year     = v0101

			br 		year id_dom inf uf ninf_mae
		
		
			*------------------------------------------------------------------------------------------------------------------------*
			recode  v4728 (1 2 3 = 1) (4/8 = 0)																			, gen (urban)

			recode  v0302 (2 = 0) (4 = 1)																				, gen (female)

			recode  v4727 (1 = 1) (2 3 = 0) 																			, gen (metro)
			
			recode  v4704 (1 = 1) (2 = 0)																				, gen (pea)												//semana de ref. pessoas com 10 anos ou + 

			recode  v4805 (1 = 1) (2 = 0)																				, gen (ocupado)											//semana de ref. pessoas com 10 anos ou +. Ocupado leva em consideracao quem trabalhou para proprio consumo. 

			recode  v4805 (1 = 0) (2 = 1)																				, gen (desocupado)										//semana de ref. pessoas com 10 anos ou +

			recode  v4706 (1 2 3 4 6 7 = 1) (9 = 2) (10 = 3) (11/13 = 4) 												, gen (type_work)										//semana de ref. pessoas com 10 anos ou +					
			
			recode  v0602 (2 = 1) (4 = 0)   (9 = .)																		, gen (schoolatt)										//frequenta ou não a escola
			
			recode  v6002 (2 = 1) (4 = 0)																				, gen (goes_public_school)								//dquem frequenta a escola vai para escola pública;privada. 

			recode 	v9067 (1 = 1) (3 = 0)																				, gen (worked_last_year)								//trabalhadores com 10 anos ou +. teve algum trabalho no período de captação de 358 dias							//para as pessoas desocupadas na semana de referência, elas trabalharam no período de captação de 358 dias?						

			recode 	v9070 (2 = 1) (4 = 2) (6 = 3)																		, gen (n_jobs_last_year)								//para as pessoas desocupadas na semana de referência, elas trabalharam no período de captação de 358 dias? em 1, 2 ou 3 trabalhos?
						
			gen 	wage  		  		= v4718   		   	if v4718 < 999999999999														//rendimento no trabalho principal na semana de referência

			gen 	inc_household 		= v4721   		   	if v4721 < 999999999999
			
			gen 	per_capita_inc   	= v4742  			if v4742 < 999999999999 													//sem declaração
			
			gen 	wage_todos_trab   	= v4719  		   	if v4719 < 999999999999														//pessoas com 10 anos ou mais
			
			rename (v9058 v4729	v8005 v0401 v9892 v4809 v4810) (hours_worked  weight age c_household work_age activity occupation)		//horas de trabalho no trabalho principal na semana de referência
		
					
			*Identificação de quem já é mãe
			*------------------------------------------------------------------------------------------------------------------------*
			gen     filho         = 1   					if v1101 == 1 & female == 1													//se já é mãe ou não
			 
			replace filho         = 0   					if v1101 == 3 & female == 1

			
			*Carteira de trabalho e previdência social
			*------------------------------------------------------------------------------------------------------------------------*
			gen     CT_signed = 1       					if (v4706 == 1 | v4706 == 6) & ocupado == 1						

			replace CT_signed = 0       					if  v4706 ~= 1 & v4706 ~= 6  & ocupado == 1						//a pessoa está ocupada mas não é trabalhador com carteira assinada.

			gen     social_security = 1 					if  v4711 == 1 & ocupado == 1									//se contribui para previdência social

			replace social_security = 0 					if  v4711 == 2 & ocupado == 1									//a pessoa está ocupada mas não contribui para a previdência social

			
			*Funcionário público
			*------------------------------------------------------------------------------------------------------------------------*
			gen     civil_servant 			= 1        		if  (v4706 == 2 | v4706 == 3) 				& ocupado == 1  

			replace civil_servant 			= 0        		if   v4706 ~= 2 & v4706 ~= 3  				& ocupado == 1  

			gen 	civil_servant_federal 	= 1 	   		if   v9032 == 4 & v9033 == 1	 			& ocupado == 1	& civil_servant == 1 	//funcionário público federal
			
			gen 	civil_servant_state  	= 1 	   		if   v9032 == 4 & v9033 == 3	 			& ocupado == 1	& civil_servant == 1 	//funcionário público estadual

			gen 	civil_servant_municipal = 1 	   		if   v9032 == 4 & v9033 == 5  				& ocupado == 1	& civil_servant == 1 	//funcionário público municipal

			replace civil_servant_federal   = 0		  		if ((v9032 == 4 & v9033 != 1) | v9032 == 2) & ocupado == 1	& civil_servant == 1 	//trabalha no setor público mas não no federal ou está no setor privado
			
			replace civil_servant_state  	= 0				if ((v9032 == 4 & v9033 != 3) | v9032 == 2) & ocupado == 1	& civil_servant == 1  
			
			replace civil_servant_municipal = 0				if ((v9032 == 4 & v9033 != 5) | v9032 == 2) & ocupado == 1	& civil_servant == 1 
			
		
			*Educação
			*------------------------------------------------------------------------------------------------------------------------*
			recode  v0606 (2 = 1) (4 = 0)											   , gen (went_school)						//já frequentou a escola alguma vez na vida

			recode  v4745 (8 = .)													   , gen (edu_att)
							
			assert  v6007 == . | v6007 == 0  				if schoolatt == 1												    //6007 = último curso que frequentou para quem está fora da escola. a variável v6007 precisa ser igual a 0 ou . toda vez que schoolatt == 1

			assert  v6003 == . | v6003 == 0  				if schoolatt != 1												    //6003 = curso que frequenta para quem está na escola. a variável v6003 precisa ser igual a 0 ou . toda vez que schoolatt ~= 1
			
			assert  v6003 != . 								if schoolatt == 1

			gen     edu_att2   = 1        					if edu_att == 1														//sem instrução 

			replace edu_att2   = 2 							if edu_att == 2 | edu_att == 3										//primary

			replace edu_att2   = 3 							if edu_att == 4 | edu_att == 5										//upper secondary

			replace edu_att2   = 4 							if edu_att == 6 | edu_att == 7										//tertiary

			replace v4803 	   = . 							if v4803 == 17														//anos de escolaridade

			replace v4803 	   = v4803 - 1
		
			gen 	yrs_school = v4803																						
								
			gen 	edu_level_enrolled = 1 					if v6003 == 7
			
			replace edu_level_enrolled = 2 					if v6003 == 8 | v6003 == 9

			replace edu_level_enrolled = 3 					if v4801 >= 4  & v4801 <= 7						//séries iniciais do EF de 8 anos

			replace edu_level_enrolled = 3					if v4801 >= 12 & v4801 <= 16					//séries iniciais do EF de 9 anos

			replace edu_level_enrolled = 4 					if v4801 >= 8  & v4801 <= 11					//séries finais do EF de 8 anos

			replace edu_level_enrolled = 4 					if v4801 >= 17 & v4801 <= 20					//séries finais do EF de 9 anos

			replace edu_level_enrolled = 5 					if v4801 == 21									//ef eja
			
			replace edu_level_enrolled = 6					if v4801 == 22 
			
			replace edu_level_enrolled = 7 					if v6003 == 23
						
			replace edu_level_enrolled = 8 					if v4801 == 24									//pré-vestibular

			replace edu_level_enrolled = 9 					if v4801 == 25									//superior, inclusive mestrado ou doutorado
			
			replace edu_level_enrolled = 10 				if v4801 == 3									//alfabetização de adultos
			
			tab 	edu_level_enrolled v4801 

			*gen 	grade 	   = v0605

			*replace grade 	   = 9 	   						if v0605 == 0
			
			*rename v6030 du_ef 																			//duração do EF

			keep 	uf c_household age hours_worked weight activity occupation id_dom-edu_level_enrolled v3031 v3032 v3033 v0404 v0406
			
			
		}	//fim da harmonização se ano >= 2007

		**
		**
		if `year' >= 2002 & `year' <= 2006 {

			*Identificação do domicílio
			*------------------------------------------------------------------------------------------------------------------------*
			drop 	id_dom
			
			egen 	id_dom = group(uf v0101 v0102 v0103)				//identificação do domicílio

			gen 	inf      = v0301

			gen 	ninf_mae = v0407 									//número de ordem da mãe - vai ser últil para sabermos a escolaridade da mãe
			
			sort 	id_dom inf uf

			gen 	year     = v0101

			br 		year id_dom inf uf


			*
			*------------------------------------------------------------------------------------------------------------------------*
			rename (v9058 v4729 v8005 v0401 v9892) (hours_worked weight age c_household work_age)  
			
			replace age  				= . 		  		if age == 999 //idade ignorada
					
			replace hours_worked 		= . 				if hours_worked == 99 //sem declaração
			
			replace work_age 	  		= . 				if work_age 	== 99 

			gen 	wage  		  		= v4718   		   	if v4718 < 999999999999

			gen 	inc_household 		= v4721   		    if v4721 < 999999999999

			gen 	wage_todos_trab 	= v4719  		   	if v4719 < 999999999999										//pessoas com 10 anos ou mais

			replace v4705 = . if age < 10  //A partir de 2007, ocupado passou  a ser divulgado para crianças com 10 anos ou mais. Nas pesquisas de 2002 a 2006, a variável foi calculada para pessoas com 5 anos ou +
			
			recode v4728 (1 = 1) (2 = 1) (3 = 1) (4 = 0) (5 = 0) (6 = 0) (7 = 0) (8 = 0)								, gen (urban)

			recode v0302 (2 = 0) (4 = 1)																				, gen (female)

			recode v4727 (1 = 1) (2 = 0) (3 = 0)																		, gen (metro)
			
			recode v4704 (1 = 1) (2 = 0) (3 = .)																		, gen (pea)

			recode v4705 (1 = 1) (2 = 0)																				, gen (ocupado)

			recode v4705 (1 = 0) (2 = 1)																				, gen (desocupado)

			recode v4706 (1/8 = 1) (9 = 2) (10 = 3) (11/13 = 4) (14 = .)												, gen (type_work)
					
			recode v0602 (2 = 1) (4 = 0) (9 = .)																		, gen (schoolatt)			//frequenta ou não a escola
					
			recode v6002 (2 = 1) (4 = 0) (9 = .)																		, gen (goes_public_school)	//demanda de ensino público ou privado de quem edu_level_enrolled
			
			if `year'>= 2004 & `year' <= 2006 gen per_capita_inc  = v4742  	if v4742 < 999999999999 //sem declaração
				
			if `year'>= 2002 & `year' <= 2003 {
			
				gen 	id  = 1 if c_household < 6 //pessoas do domicílio exceto pensionistas, emprego doméstico e parente de empregado doméstico. 
				
				bysort id_dom: egen t_ind = sum(id)
				
				gen 	per_capita_inc = inc_household/t_ind 	
				
				drop 	id t_ind 
			}
			

			*Carteira de trabalho e previdência social
			*------------------------------------------------------------------------------------------------------------------------*
			gen     CT_signed = 1      						if (v4706 == 1 | v4706 == 6) & ocupado == 1

			replace CT_signed = 0       					if  v4706 ~= 1 & v4706 ~= 6  & ocupado == 1			//a pessoa está ocupada mas não é trabalhador com carteira assinada.

			gen     social_security = 1 					if  v4711 == 1 & ocupado == 1

			replace social_security = 0 					if  v4711 == 2 & ocupado == 1						//a pessoa está ocupada mas não contribui para a previdência social

			
			*Funcionário público
			*------------------------------------------------------------------------------------------------------------------------*
			gen     civil_servant  			= 1        		if  (v4706 == 2 | v4706 == 3) 				& ocupado == 1

			replace civil_servant  			= 0        		if   v4706 ~= 2 & v4706 ~= 3  				& ocupado == 1 
			
			gen 	civil_servant_federal 	= 1 			if   v9032 == 4 & v9033 == 1				& ocupado == 1 & civil_servant == 1 	//funcionário público federal
			
			gen 	civil_servant_state 	= 1 			if   v9032 == 4 & v9033 == 3				& ocupado == 1 & civil_servant == 1 	//funcionário público estadual

			gen 	civil_servant_municipal = 1 			if   v9032 == 4 & v9033 == 5				& ocupado == 1 & civil_servant == 1 	//funcionário público municipal

			replace civil_servant_federal  	= 0				if ((v9032 == 4 & v9033 != 1) | v9032 == 2) & ocupado == 1 & civil_servant == 1 
			
			replace civil_servant_state 	= 0				if ((v9032 == 4 & v9033 != 3) | v9032 == 2) & ocupado == 1 & civil_servant == 1 
			
			replace civil_servant_municipal = 0				if ((v9032 == 4 & v9033 != 5) | v9032 == 2) & ocupado == 1 & civil_servant == 1 
			
			
			*Educação
			*------------------------------------------------------------------------------------------------------------------------*		
			recode  v0606 (2 = 1) (4 = 0)										 , gen (went_school)				//já frequentou a escola alguma vez na vida
			
			assert  v0607 == . | v0607 == 0  				if schoolatt == 1							//a variável v0607 precisa ser igual a 0 ou . toda vez que schoolatt == 1
					
			assert  v0603 == . | v0603 == 0  				if schoolatt != 1							//a variável v0603 precisa ser igual a 0 ou . toda vez que schoolatt ~= 1
					
			assert  v0603 != . 								if schoolatt == 1
			
			gen 	edu_att = .
			
			replace edu_att = 1 							if v4703 == 1											//sem instrução.
		
			replace edu_att = 2								if inlist(v0607, 1, 2, 4)			 					//EF incompleto

			replace edu_att = 3 							if (v0607 == 2 | v0607 == 4) & v0611 == 1 				//EF completo, v0611 == 1 se concluiu a etapa anterior

			replace edu_att = 4 							if (v0607 == 3 | v0607 == 5) 							//Médio incompleto

			replace edu_att = 5 							if (v0607 == 3 | v0607 == 5) & v0611 == 1 				//Médio completo

			replace edu_att = 6 							if  v0607 == 6 											//Superior incompleto

			replace edu_att = 7 							if (v0607 == 6 & v0611 == 1) | v0607 == 7 				//Superior completo
			
			replace edu_att = 1 							if inlist(v0603, 6, 7, 8) 								//Sem instrução. Está matriculado na alfabetização, creche e pré-escola
		
			replace edu_att = 2 							if inlist(v0603, 1, 2, 3) 								//está cursando EF, portando, ef incompleto
				
			replace edu_att = 4 							if v0603 == 4											//está cursando EM, portando, em incompleto		
			
			replace edu_att = 5 							if v0603 == 9											//cursinho pre-vestibular. EM completo. tab v4703 = 12 (anos de estudo) quanto v0603 == 9
					
			replace edu_att = 6								if v0603 == 5											//está cursando ES, portanto, es incompleto
			
			replace edu_att = 7 							if v0603 == 10											//mestrado ou doutorado, portanto, es completo

			gen     edu_att2   = 1        					if edu_att == 1											//sem instrução 

			replace edu_att2   = 2 							if edu_att == 2 | edu_att == 3							//primary

			replace edu_att2   = 3 							if edu_att == 4 | edu_att == 5							//upper secondary

			replace edu_att2   = 4 							if edu_att == 6 | edu_att == 7							//tertiary
			
			replace v4703 = . 								if v4703 == 17

			replace v4703 = v4703 - 1
			
			gen 	yrs_school      = v4703
			
			gen 	edu_level_enrolled = 1 					if v0603 == 7								//creche
			
			replace edu_level_enrolled = 2 					if v0603 == 8								//pre-escola

			replace edu_level_enrolled = 3					if v4701 >= 3  & v4701 <= 6					//séries iniciais do EF de 8 anos

			replace edu_level_enrolled = 4					if v4701 >= 7  & v4701 <= 10				//séries finais do EF de 8 anos

			replace edu_level_enrolled = 5 					if v4701 == 12								//ef eja
			
			replace edu_level_enrolled = 6					if v4701 == 14 								//em 
			
			replace edu_level_enrolled = 7					if v4701 == 15 								//eja em
			
			replace edu_level_enrolled = 8 					if v4701 == 13								//pré-vestibular

			replace edu_level_enrolled = 9					if v4701 == 16								//superior, inclusive mestrado ou doutorado
			
			replace edu_level_enrolled = 10 				if v4701 == 2 								//alfabetização de adultos

			tab v4701 edu_level_enrolled
			
			*gen 	grade  = v0605

			*replace grade = . 	   							if v0605 == 9

			keep uf age c_household hours_worked weight id_dom-edu_level_enrolled v3031 v3032 v3033 v0404 v0406
		}
		
		**
		**
		if `year' <= 2001 {
		
			if 	`year' == 1998 replace v0101 = 1998
			if  `year' == 1999 replace v0101 = 1999
			
			*Identificação do domicílio
			*------------------------------------------------------------------------------------------------------------------------*
			drop 	id_dom												//Apenas excluí porque o primeiro comando abaixo irá fazer isso e não tenho ctza se a puc considera família = domicílio ou que um domicílio pode ser formado por mais de uma família. 
			
			egen 	id_dom   = group(uf v0101 v0102 v0103)				//identificação do domicílio

			gen 	inf      = v0301

			gen 	ninf_mae = v0407 									//número de ordem da mãe - vai ser últil para sabermos a escolaridade da mãe
			
			sort 	id_dom inf uf

			gen 	year     = v0101

			br 		year id_dom inf uf ninf_mae
		
			*------------------------------------------------------------------------------------------------------------------------*
			rename (v9058 v4729	v8005 v0401 v9892 v9611 v9612) (hours_worked weight age c_household work_age years_current_work months_current_work)	//horas de trabalho no trabalho principal na semana de referência
			
			replace years_current_work  = . if years_current_work  == 99 | years_current_work == -1
			
			replace months_current_work = . if months_current_work == 99 | months_current_work == -1
			
			replace age 				= . if age == 999
			
			replace hours_worked 		= . if hours_worked == 99 | hours_worked == - 1
			
			replace work_age 	  		= . if work_age 	== 99 | work_age     == - 1
					
			recode 	v4728 (1 = 1) (2 = 1) (3 = 1) (4 = 0) (5 = 0) (6 = 0) (7 = 0) (8 = 0)										, gen (urban)
				
			recode 	v0302 (2 = 0) (4 = 1)																						, gen (female)

			recode 	v4727 (1 = 1) (2 = 0) (3 = 0)																				, gen (metro)

			recode  v9115 (1 = 1) (3 = 0) (9 = .)																				, gen (looking_job)

			rename (v9002 v9003 v9004 v9001) (tar_2 tar_3 tar_4 ref_week)																					//v9001 = 1 se trab na sem de ref. 9002 trab rem que estava afastado na sem de ref. 			

			gen 	ocupado = 1 								if (ref_week == 1 | tar_2 == 2 | tar_3 == 1 | tar_4 == 2) 									//está ocupado na semana de referência se trabalhou, estava afastado ou exerceu tarefas de cultivo, construção
	 
			replace ocupado = 0 								if (looking_job == 1 & ocupado != 1)					  
			
			
			if `year' == 2001 {
			
				recode  v6002 (2 = 1) (4 = 0) (9 = .)																			, gen (goes_public_school)						//demanda de ensino público ou privado de quem edu_level_enrolled
					
				rename (v4754 v4756 v4759 v4760 v4768 v4769 v4761) ///
				///
					   (v4704 v4706 v4709 v4710 v4718 v4719 v4711)
			
			}
			
			
			recode  v4704 (1 = 1) (2 = 0) (3 = .)															  					, gen (pea)
			
			recode  v4706 (1/8 = 1) (9 = 2) (10 = 3) (11/13 = 4) (14 = .)									  					, gen (type_work)
				
			recode  v0602 	(2 = 1) (4 = 0) (9 = .)																				, gen (schoolatt)								//frequenta ou não a escola
				
			recode  ocupado (1 = 0) (0 = 1)																						, gen (desocupado)
				
			replace desocupado = . 							if pea == 0 & desocupado == 1	//error

			gen 	wage  			= v4718   				if v4718 < 999999999999  & v4718 != -1
			
			gen 	wage_todos_trab = v4719 				if v4719 < 999999999999  & v4719 != -1
			
			gen     CT_signed = 1       					if (v4706 == 1 | v4706 == 6) 		& ocupado == 1

			replace CT_signed = 0       					if  v4706 ~= 1 & v4706 ~= 6  		& ocupado == 1				//a pessoa está ocupada mas não é trabalhador com carteira assinada.

			gen     social_security = 1 					if  v4711 == 1 						& ocupado == 1

			replace social_security = 0 					if  v4711 == 2 						& ocupado == 1				//a pessoa está ocupada mas não contribui para a previdência social
										
			gen 	inc_household 		= v4721   		   	if v4721 < 999999999999

			gen 	id  = 1 if c_household < 6 																																	//pessoas do domicílio exceto pensionistas, emprego doméstico e parente de empregado doméstico. 
				
			bysort  id_dom: egen t_ind = sum(id)
				
			gen 	per_capita_inc = inc_household/t_ind 	
				
			drop 	id t_ind 
					
			foreach var of varlist pea type_work wage wage_todos_trab CT_signed social_security looking_job ocupado desocupado {
				
				replace `var' = . if age < 10 
				
			}

			*Identificação de quem já é mãe
			*------------------------------------------------------------------------------------------------------------------------*
			gen     filho         = 1   					if v1101 == 1 & female == 1						//se já é mãe ou não
			 
			replace filho         = 0   					if v1101 == 3 & female == 1

			
			*Carteira de trabalho e previdência social
			*------------------------------------------------------------------------------------------------------------------------*
			gen     civil_servant 			= 1        		if ( v4706 == 2 | v4706 == 3) 				& ocupado == 1

			replace civil_servant			= 0        		if   v4706 ~= 2 & v4706 ~= 3  				& ocupado == 1

			gen 	civil_servant_federal 	= 1 	   		if   v9032 == 4 & v9033 == 1	 			& ocupado == 1	& civil_servant == 1 	//funcionário público federal
			
			gen 	civil_servant_state  	= 1 	   		if   v9032 == 4 & v9033 == 3	 			& ocupado == 1	& civil_servant == 1 	//funcionário público estadual

			gen 	civil_servant_municipal = 1 	   		if   v9032 == 4 & v9033 == 5  				& ocupado == 1	& civil_servant == 1 	//funcionário público municipal

			replace civil_servant_federal   = 0		  		if ((v9032 == 4 & v9033 != 1) | v9032 == 2) & ocupado == 1	& civil_servant == 1 	//trabalha no setor público mas não no federal ou está no setor privado
			
			replace civil_servant_state  	= 0				if ((v9032 == 4 & v9033 != 3) | v9032 == 2) & ocupado == 1	& civil_servant == 1 
		
			replace civil_servant_municipal = 0				if ((v9032 == 4 & v9033 != 5) | v9032 == 2) & ocupado == 1	& civil_servant == 1 
			
					
			*Educação
			*------------------------------------------------------------------------------------------------------------------------*
			recode  v0606 (2 = 1) (4 = 0) (9 = .)			, gen (went_school)						//já frequentou a escola alguma vez na vida
			
			gen 	edu_att = .
			
			replace edu_att = 1 							if v4703 == 1							//sem instrucao
			
			replace edu_att = 2 							if inlist(v4702, 3, 4, 5)				//cursando ef - > ensino fundamental incompleto
			
			replace edu_att = 4 							if v4702 == 6							//cursando em - > ensino medio incompleto
			
			replace edu_att = 6 							if v4702 == 7							//es 
			
			replace edu_att = 2								if inlist(v0607, 1, 2, 4) 											//EF incompleto

			replace edu_att = 3 							if (v0607 == 2 | v0607 == 4) & v0611 == 1 							//EF completo, v0611 == 1 se concluiu a etapa anterior

			replace edu_att = 4 							if (v0607 == 3 | v0607 == 5) 										//Médio incompleto

			replace edu_att = 5 							if (v0607 == 3 | v0607 == 5) & v0611 == 1 							//Médio completo

			replace edu_att = 6 							if  v0607 == 6 														//Superior incompleto

			replace edu_att = 7 							if (v0607 == 6 & v0611 == 1) | v0607 == 7 							//Superior completo

			gen     edu_att2   = 1        					if edu_att == 1														//sem instrução 

			replace edu_att2   = 2 							if edu_att == 2 | edu_att == 3										//primary

			replace edu_att2   = 3 							if edu_att == 4 | edu_att == 5										//upper secondary

			replace edu_att2   = 4 							if edu_att == 6 | edu_att == 7										//tertiary
			
			replace v4703 	   = . 							if v4703 == 17														//anos de escolaridade

			replace v4703 	   = v4703 - 1
			
			gen 	yrs_school = v4703
			
			gen 	edu_level_enrolled = 1 					if v0603 == 7  								//creche
		
			replace edu_level_enrolled = 2 					if v0603 == 8								//pre-escola

			replace edu_level_enrolled = 3 					if v4701 >= 3  & v4701 <= 6					//séries iniciais do EF de 8 anos

			replace edu_level_enrolled = 4 					if v4701 >= 7  & v4701 <= 10				//séries finais do EF de 8 anos

			replace edu_level_enrolled = 5 					if v4701 == 12								//ef eja

			replace edu_level_enrolled = 6					if v4701 == 14 								//em ou eja em
			
			replace edu_level_enrolled = 7					if v4701 == 15								//em ou eja em
			
			replace edu_level_enrolled = 8					if v4701 == 13								//pré-vestibular

			replace edu_level_enrolled = 9 					if v4701 == 16								//superior, inclusive mestrado ou doutorado
			
			replace edu_level_enrolled = 10					if v4701 == 2  								//alfabetização de adultos

			tab v4701 edu_level_enrolled
			
			*gen 	grade 	   = v0605

			keep uf age c_household weight ref_week tar_3 tar_4 hours_worked years_current_work months_current_work id_dom-edu_level_enrolled v3031 v3032 v3033 v0404 v0406

		}
		
		
		**
		**
		*Igual para todos os anos

			*Crianças e adolescentes no domicílio
			*------------------------------------------------------------------------------------------------------------------------*
			gen 	kid6a 		  = 1 	    		   		if age < 6 
				
			gen 	kid13a 		  = 1       		   		if age >= 6 & age <= 13 

			gen		kid17a		  = 1 				   		if age >= 6 & age <= 17

			gen 	kid17fa		  = 1 				   		if age >= 6 & age <= 17 & female == 1			//meninas adolescentes no domicílio

			gen 	kid17ma		  = 1 				   		if age >= 6 & age <= 17 & female == 0			//meninos adolescentes no domicílio

			foreach name in kid6 kid13 kid17 kid17f kid17m {
			
				bysort id_dom: egen `name' = max(`name'a)
				
				replace 			`name' = 0  if missing(`name')
				
				drop `name'a
				
			}	
			
		
			*Concluiu EM
			*------------------------------------------------------------------------------------------------------------------------*
			*gen     highschool_degree = 1  						if schoolatt == 1 & (v6003 == 10 | v6003 == 5 | v6003 == 11)														//está fazendo ensino superior, mestrado ou doutorado ou fazendo cursinho

			*replace highschool_degree = 1 							if schoolatt == 0 & (v6007 == 8  | v6007 == 9)																	//o último curso que frequentou quando era estudante foi o ensino superior ou o mestrado ou doutorado

			*replace highschool_degree = 1  						if schoolatt == 0 & (v0611 == 1) & (v0610 == 3 | v0610 == 4) & (v6007 == 5 | v6007 == 7 | v6007 == 3)				//esse critério é mais rigoroso porque exige que haja resposta para a pergunta se concluiu com sucesso a última etapa de ensino cursada e que a resposta para as últimas séries concluídas com sucesso seja 3o ano do EM ou 4o ano do EM					

			gen 	highschool_degree = 1 							if inlist(edu_att, 5, 6, 7)
			
			replace highschool_degree = 0  							if edu_att     < 5

			
			*College degree
			*------------------------------------------------------------------------------------------------------------------------*
			gen 	 college_degree   = edu_att == 7  | edu_att == 6
			
			replace  college_degree   = . if edu_att == .
			
		
			*Idade em março (critério para determinar a entrada na escola)
			*------------------------------------------------------------------------------------------------------------------------*
			replace v3033 = .		 if v3033 <= 150 | v3033 == 9999				//entre 0 e 98 é porque é a idade presumida
			
			if `year' < 2001 replace v3033 = 1000 + v3033 if v3033 >= 800
			
			br 	 	year v3031 v3032 v3033 age 
			 
			egen 	v3031b=concat(v3031)								//ajuste para idade
				
			egen 	v3032b=concat(v3032)
				
			egen 	v3033b=concat(v3033)

			br 		year v3031 v3031b v3032 v3032b v3033 v3033b age

			replace v3031b = "0" + v3031b 					if length(v3031b) == 1
					
			replace v3032b = "0" + v3032b 					if length(v3032b) == 1

			br 		year v3031 v3031b v3032 v3032b v3033 v3033b age
				
			egen 	bd=concat(v3032b v3031b v3033b)

			br 		year v3031 v3031b v3032 v3032b v3033 v3033b age bd

			gen 	birth_date = date(bd,"MDY") 				//note that month is unknow, the Value is 20 and if the year is unknow the Value is the presumed age
				
			format 	birth_date %td

			br 		year v3031 v3031b v3032 v3032b v3033 v3033b age bd birth_date

			list 	birth_date bd v3031 v3032 v3033 age in 1/20
				
			ta 		v3031
				
			ta 		v3032
				
			ta 		v3033

			gen     base_date = mdy(3,31,1998) 				if year == 1998 		//be careful if year < 2000
			
			gen 	base_pnad = mdy(9,30,1998)				if year == 1998
			
			foreach wave in 1999 2001 2002 2003 2004 2005 2006 2007 2008 2009 2011 2012 2013 2014 2015 {
				
				replace base_date = mdy(3,31,`wave') 		if year == `wave'		//be careful if year < 2000
				
				replace base_pnad = mdy(9,31,`wave') 		if year == `wave'		//be careful if year < 2000
			
			}

			format  base_date %td

			g 		ageA = (base_date - birth_date)/365.25
				
			g 		age_31_march = trunc(ageA)
			
			gen		age_pnad	 = trunc((base_pnad - birth_date)/365.25)
			
			foreach var of varlist age_31_march age_pnad {
				
				replace `var' = age 						if v3032==20

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
				
				replace `var' = age							if v3033 <  99 
			
			}

			br 		year v3031 v3031b v3032 v3032b v3033 v3033b age ageA age_31_march bd birth_date base_date

			tab 	age_31_march
					
			rename (v3031 v3032 v3033) (day_birth month_birth year_birth)

			gen 	dateofbirth = mdy(month_birth, day_birth, year_birth)
			

			*------------------------------------------------------------------------------------------------------------------------*
			recode female (1 = 0) (0 = 1), gen (male)
			
			gen 	age2 		  		= age^2 
			
			gen 	wage_hour 		 	= wage/4													//salário por hora. 4 semanas em um mês +ou-

			replace wage_hour 	 	 	= wage_hour/hours_worked		

			gen 	out_labor  	  		= 1					if pea == 0

			replace out_labor 			= 0 				if pea == 1

						
			*Formalidade
			*------------------------------------------------------------------------------------------------------------------------*
			gen 	formal = 1          					if ocupado == 1 & ((CT_signed == 1 | civil_servant  == 1) | (type_work == 2 & social_security == 1) | (type_work == 3 & social_security == 1))
		
			replace formal = 0          					if ocupado == 1 & ((CT_signed == 0) 					  | (type_work == 2 & social_security == 0) | (type_work == 2 & social_security == 0))
		
			recode  formal (1 = 0) (0 = 1), gen (informal)
			
			
			*Trabalho não remunerado
			*------------------------------------------------------------------------------------------------------------------------*
 			gen 	nonpaid_work 		= 1 				if 				  type_work == 4
			
			replace nonpaid_work 		= 0 				if ocupado == 1 & type_work != 4
	
	
			*Status de trabalho e estudo
			*------------------------------------------------------------------------------------------------------------------------*
			gen 	working 		= ocupado == 1
					
			gen 	pwork 			= 1 		if  working == 1 & nonpaid_work == 0
				
			replace pwork 			= 0 		if (working == 1 & nonpaid_work == 1) 	| working == 0 
				
			gen 	uwork 			= 1 		if  working == 1 & nonpaid_work == 1						
				
			replace uwork 			= 0 		if (working == 1 & nonpaid_work == 0) 	| working == 0 
				
			gen 	pwork_formal 	= 1 		if (pwork   == 1 & formal == 1)
				
			replace pwork_formal 	= 0 		if (pwork   == 1 & formal == 0) 		| pwork == 0
				
			gen 	pwork_informal 	= 1 		if (pwork   == 1 & formal == 0)
				
			replace pwork_informal 	= 0 		if (pwork   == 1 & formal == 1) 		| pwork == 0
			
			gen 	work_formal		= 1 		if (working == 1 & formal == 1)
			
			replace work_formal     = 0			if (working == 1 & formal == 0) 		| working == 0
			
			gen 	work_informal	= 1 		if (working == 1 & formal == 0)
			
			replace work_informal   = 0			if (working == 1 & formal == 1) 		| working == 0
				
			gen 	pwork_sch  		= pwork   == 1 & schoolatt == 1
			
			gen 	uwork_sch  		= uwork   == 1 & schoolatt == 1

			gen 	pwork_only 		= pwork   == 1 & schoolatt == 0

			gen 	uwork_only 		= uwork   == 1 & schoolatt == 0

			gen 	study_only 		= working == 0 & schoolatt == 1

			gen 	nemnem	   		= working == 0 & schoolatt == 0

			foreach var of varlist pwork_sch uwork_sch pwork_only uwork_only study_only nemnem* {
				
				replace `var' = . if  working == . | schoolatt == .
					
			}

	
			*Educação, idade e status de ocupacao da mãe
			*------------------------------------------------------------------------------------------------------------------------*
			sort 	id_dom inf
			
			br 		id_dom inf c_household ninf_mae edu_att2
			
			***
			***

			foreach var of varlist edu_att2 yrs_school age working {
			
			levelsof ninf_mae, local(levels)
			
			di `levels'
			
			gen mom_`var' = .
		
				foreach i in `levels' {
					
					gen  	mom_aux   = `var' 				if inf == `i'
					
					egen 	mom_aux_2 = max(mom_aux), 		by (id_dom)
					
					replace	mom_`var' = mom_aux_2			if ninf_mae == `i'
					
					drop 	mom_aux*
					
				}
			
					gen		mom_aux   = `var' 				if 					    (c_household == 1 | c_household == 2) & female == 1				//para crianças que não temos o identifidor da mãe (porque não moram com elas ou a mãe é falecida, a escolaridade que vai nessa variável é a escolaridade da mulher que é chefe do domicílio ou cônjuge
								
					egen 	mom_aux2  = max(mom_aux), 		by (id_dom)
					
					replace mom_`var' = mom_aux2	 		if missing(mom_`var') & (c_household == 3 | c_household == 4)	
					
					drop 	mom_aux*
			}
			

			*Cor de pele
			*------------------------------------------------------------------------------------------------------------------------*
			gen		color    = v0404
			
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
		
		
			*Total de membros do domicílio
			*------------------------------------------------------------------------------------------------------------------------*
			gen 	hh_ind = 1 												if c_household < 5						//relevant hh members

			bysort 	id_dom: egen hh_members = total(hh_ind)	

			gen 	chefe_d = 1 											if c_household == 1 					//household head

			replace chefe_d = 0 											if mi(chefe_d) & ~mi(c_household)

			gen 	spouse 	= 1 											if c_household == 2						//spouse

			replace spouse 	= 0 											if mi(spouse) & ~mi(c_household)

			egen 	two_parent 	= total(spouse), by(id_dom year) miss												//two parent household

			tab		two_parent, mis
			drop 	hh_ind
			
			
			*Área
			*------------------------------------------------------------------------------------------------------------------------*
			gen 	area = 1 if urban == 1 & metro == 0		//Urbana

			replace area = 2 if urban == 0 & metro == 0		//Rural	

			replace area = 3 if metro == 1					//Metropolitana

			tab 	area
			
			
			*------------------------------------------------------------------------------------------------------------------------*
			replace wage 				= . if wage 			== 0
			
			replace wage_todos_trab 	= . if wage_todos_trab 	== 0
			
			replace wage_hour			= . if wage_hour 		== 0
	
			destring uf, replace
			
			
		save "$inter/pnad_harm_`year'.dta", replace
		*----------------------------------------------------------------------------------------------------------------------------*
		end

	**

	**
	*Pooled data
	*________________________________________________________________________________________________________________________________*
		
		foreach wave in 1998 1999 2001 2002 2003 2004 2005 2006 2007 2008 2009 2011 2012 2013 2014 2015 {
			harmonizar_pnad, year(`wave')
		}
		clear
		foreach wave in 1998 1999 2001 2002 2003 2004 2005 2006 2007 2008 2009 2011 2012 2013 2014 2015 {
			append using "$inter/pnad_harm_`wave'.dta"
			erase 		 "$inter/pnad_harm_`wave'.dta"
		}
		save "$inter/Pooled_PNAD.dta", replace

	
	**

	**
	*Formatting
	*________________________________________________________________________________________________________________________________*
		
		use 	"$inter/Pooled_PNAD.dta", clear
		
		drop 	v0404 v0406 ref_week tar_3 tar_4 looking_job v3031b-ageA
		
		tab 	activity, gen(activity)
		
		
			*Verificador de idade
			*------------------------------------------------------------------------------------------------------------------------*			
			gen  correto = 1 if (age == year - year_birth) | (age == year - year_birth  - 1) & year_birth > 1000 & !missing(year_birth) & !missing(age)
			br   month_birth day_birth year_birth year age if correto == . & !missing(year_birth) & !missing(age)
			drop correto
		
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
			
			
			foreach var of varlist wage per_capita_inc inc_household wage_hour wage_todos_trab { 
				gen real_`var' = .
					foreach wave in  1998 1999 2001 2007 2008 2009 2011 2012 2013 2014 2015 {
						replace real_`var' = `var'*`ipca`wave'' if year == `wave'
				}
			}
			
			
			*Variáveis em Ln
			*------------------------------------------------------------------------------------------------------------------------*
			foreach var of varlist *wage *per_capita_inc *inc_household *wage_hour *wage_todos_trab {
				gen ln`var' = ln(`var')
			}
			format wage per_capita_inc inc_household wage_hour hours_worked real* ln*  %12.2fc


			
			*Estado
			*------------------------------------------------------------------------------------------------------------------------*
			label define coduf     	11 "Rondônia" 			12 "Acre" 					13 "Amazonas" 			    14 "Roraima" 			15 "Pará" 			16 "Amapá" 		17 "Tocantins" 		21 "Maranhão" 	///
									22 "Piauí" 				23 "Ceará" 					24 "Rio Grande do Norte" 	25 "Paraíba" 		    26 "Pernambuco" 	27 "Alagoas" 	28 "Sergipe" ///
									29 "Bahia" 				31 "Minas Gerais" 			32 "Espírito Santo" 		33 "Rio de Janeiro" 	35 "São Paulo" 		41 "Paraná" ///
									42 "Santa Catarina" 	43 "Rio Grande do Sul" 	    50 "Mato Grosso do Sul" 	51 "Mato Grosso" 		52 "Goiás" 			53 "Distrito Federal" 
			rename uf 	 coduf

																	
			*Labels					
			*------------------------------------------------------------------------------------------------------------------------*
			label define type_work 					1 "Empregado"   					2 "Trabalhador por conta própria"   3 "Empregador"    4 "Trabalhador não remunerado" 
		
			label define edu_att    				1 "Sem instrução"  		 			2 "EF incompleto" 					3 "EF completo"   4 "EM incompleto" 			5 "EM completo"   6 "Ensino Superior incompleto"  7 "Ensino Superior completo"  

			label define edu_att2     				1 "Sem instrução"   				2 "Ensino Fundamental"  			3 "Ensino Médio"  4 "Ensino Superior"

			label define mom_edu 					1 "Sem instrução"  					2 "Ensino Fundamental"  			3 "Ensino Médio"  4 "Ensino Superior"

			label define two_parent 	    		0 "Somente chefe domicílio"  		1 "Chefe domicílio e cônjuge"

			label define c_household 				1 "Chefe domicílio" 				2 "Cônjuge" 						 3 "Filho"					  		4 "Outro parente"   5 "Agregado" 			 6 "Pensionista"    					7 "Trabalhador doméstico"  	8 "Parente de trabalhador doméstico" 

			label define activity 					1 "Agrícola"  						2 "Outras atividades industriais"	 3 "Indústria de transformação" 	4 "Construção" 		5 "Comércio e reparação" 6 "Alojamento e alimentação" 			7 "Transporte"   			8 "Administração pública"  9 "Educação, saúde e serviços sociais" 10 "Serviços domésticos" 11 "Outros serviços coletivos, sociais e pessoais" 12 "Outras atividades" 13 "Atividades maldefinidas" 

			label define occupation					1 "Dirigentes em geral"  			2 "Profissionais das ciências/artes" 3 "Técnicos de nível médio"        4 "Serviços adm."  	5 "Serviços" 			 6 "Vendedores" 						7 "Agrícolas"				8 "Bens e serviços"		   9 "Forças armadas"					  10 "Ocupações maldefinidas" 
				
			label define schoolatt      			0 "Não frequenta a escola" 			1 "Frequenta escola"  
				
			label define urban 		 				1 "Zona Urbana" 					0 "Zona Rural"

			label define metro 		 				1 "Área metropolitana" 				0 "Não metropolita"

			label define area 		 				1 "Urbana" 							2 "Rural area"  					  3 "Metropolitana"

			label define color           			2 "Branca" 	  						4 "Preta" 							  6 "Amarela" 						8 "Parda" 	 		0 "Índigena" 

			label define went_school      			1 "Já frequentou a escola" 			0 "Nunca frequentou"	//para as pessoas que não estão mais edu_level_enrolledndo

			label define filho           			1 "Mulher com filho" 				0 "Mulher sem filho"

			label define CT_signed       			1 "CT assinada" 			 		0 "Sem CT assinada"

			label define social_security 			1 "Paga previdência"    	 		0 "Não paga previdência"
		
			label define civil_servant      		1 "Servidor público"   		 		0 "Não é servidor público" 
						
			label define ocupado         			1 "Ocupado"        			 		0 "Desocupado"

			label define desocupado     			1 "Desocupado"    					0 "Ocupado"

			label define pea             			1 "Economicamente ativo/a" 			0 "Fora da força de trabalho"
			
			label define out_labor					0 "Economicamente ativo/a" 			1 "Fora da força de trabalho"

			label define edu_level_enrolled  		1 "Maternal ou jardim de infância"  2 "Pré-escola" 						  3 "Anos iniciais do EF" 			4 "Anos finais do EF" 5 "EF EJA" 6 "Ensino Médio"  7 "EM EJA"  8 "Vestibular" 9 "Ensino Superior" 10 "Alfabetização de adultos"

			label define female						0 "Homem"							1 "Mulher" 
			
			label define male						0 "Mulher"							1 "Homem" 
			
			label define formal						0 "Trabalhador informal"			1 "Trabalhador formal" 
			
			label define informal					1 "Trabalhador informal"			0 "Trabalhador formal" 
			
			label define nemnem 					1 "Não estuda e não trabalha"
			
			label define somente_trabalha 			1 "Não estuda, mas trabalha"
			
			label define somente_estuda				1 "Não trabalha, mas estuda"
			
			label define nemnem_des	            	1 "Nem-nem desocupado"
			
			label define nemnem_out					1 "Nem-nem fora da força de trabalho" 
			
			label define estuda_trabalha			1 "Estuda e trabalha" 
			
			label define goes_public_school			0 "Estuda em escola particular" 	1 "Estuda em escola pública" 
			
			label define chefe_d 					0 "Não é chefe do domicílio"		1 "É chefe do domicílio"
			
			label define spouse						0 "Não é o cônjuge"      			1 "É cônjuge" 
			
			label define highschool_degree			0 "Não concluiu o EM"				1 "Concluiu o EM" 
			
			label define college_degree				0 "Não concluiu a faculdade"		1 "Concluiu a faculdade" 
			
			label define kid6				    	0 "Sem criança menor de 6 anos" 	1 "Com criança menor de 6 anos"
			
			label define kid13				    	0 "Sem criança de 6 a 13" 			1 "Com criança de 6 a 13"

			label define kid17				   	 	0 "Sem criança de 6 a 17" 			1 "Com criança de 6 a 17"
			
			label define kid17m				    	0 "Sem criança de 6 a 17(homem)" 	1 "Com criança de 6 a 17 (homem)"
		
			label define kid17f				    	0 "Sem criança de 6 a 17(mulher" 	1 "Com criança de 6 a 17 (mulher)"
						
			label define civil_servant_federal  	0 "Servidor público, não federal"   1 "Servidor público federal" 
			
			label define civil_servant_state  		0 "Servidor público, não estadual"  1 "Servidor público estadual" 

			label define civil_servant_municipal 	0 "Servidor público, não municipal" 1 "Servidor público municipal" 

			foreach x in college_degree male informal kid6 kid13 kid17 kid17f kid17m civil_servant_federal civil_servant_state civil_servant_municipal highschool_degree out_labor chefe_d spouse goes_public_school formal female coduf type_work edu_att edu_att2 mom_edu_att2 two_parent c_household activity occupation schoolatt urban metro area color went_school filho CT_signed social_security civil_servant ocupado desocupado pea edu_level_enrolled {

				label val `x' `x'

			}
			
			label val mom_edu_att2 edu_att2
			
			label define simnao 0 "Não" 1 "Sim"
			foreach var of varlist white black pardo indigena yellow nonpaid_work working-nemnem {
				label val `var' simnao
			}
			
			*------------------------------------------------------------------------------------------------------------------------*
			format wage wage_todos_trab inc_household per_capita_inc real_wage-real_wage_hour %12.2fc
			
			order 	year coduf id_dom inf weight ninf_mae c_household  chefe_d spouse filho hh_members inc_household per_capita_inc age age2 age_31_march color white-yellow ///
			day_birth month_birth year_birth dateofbirth female male urban metro area pea out_labor ocupado desocupado CT_signed social_security informal formal schoolatt 	 ///
			goes_public_school  edu_level_enrolled yrs_school edu_att edu_att2 mom_edu_att2 mom_yrs_school mom_age
			
			
			*------------------------------------------------------------------------------------------------------------------------*
			label var working				"Working"
			label var pwork					"Paid work"
			label var pwork_formal			"Formal paid work"
			label var pwork_informal		"Informal paid work"
			label var work_formal			"Formal work"
			label var work_informal			"Informal work"
			label var uwork					"Unpaid work"
			label var schoolatt				"School attendance"
			label var pwork_sch				"Paid work and studying"
			label var uwork_sch				"Unpaid work and studying"	
			label var pwork_only			"Only paid work"
			label var uwork_only			"Only unpaid work"
			label var study_only			"Only studying"	
			label var nemnem				"Neither working or studying"
			label var per_capita_inc		"Household per capita income (current BRL)"			
			label var mom_yrs_school		"Mother's years of schooling"
			label var mom_age				"Mother's age"
			label var hh_members			"Household size"
			label var mom_working			"Mother's working"

			*------------------------------------------------------------------------------------------------------------------------*
			sort 	year id_dom
			compress
			save 	"$inter/Pooled_PNAD.dta", replace
