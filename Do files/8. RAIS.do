	/*
													
													RAIS, Relação Anual de Informações Sociais

	Dataset with all formal workers in Brasil. 
	
	We will work with the employees born between a 12-week bandwidth around December 16, 1984. 
	
	The employee ID number is PIS or CPF. 
	
	*/
	*____________________________________________________________________________________________________________________________________*

	
	
		*________________________________________________________________________________________________________________________________*
		**
		**
		*Identifying date of birth 
		**
		*________________________________________________________________________________________________________________________________*
			
			
			*............................................................................................................................*
			**
			*Using PIS ID
			**
			
			/*
			
			In 1999 and 2001 waves, date of birth is not available. 
			
			We will work with RAIS from the years 2002, 2003, 2007, 2010, 2014, 2015 to identify the date of birth and merge with 1999 and 2001 waves using PIS ID number
			
			*/
			
			*.............................*
			
			*A1
			*.............................*
			
			/*
			
			Sometimes the same PIS are listed with different dates of birth depending on the year. 
		
			In this step, we order the PIS and select the ones that always have the same date of birth.
			
			*/
			
			**
			clear
			
			foreach ano in 2002 2003 2007 2010 2014 2015 {
				append using "$inter/RAIS/Rais_trabalhador_`ano'.dta", keep(pis ano data_nasc)
			}
			
			**
			keep if pis != ""
			sort 	pis 			
			
			
			**
			tempfile pis_list
			save    `pis_list'																//list of all PIS
			

			**
			sort    pis data_nasc
			gen 	dif_nasc = 1 if data_nasc[_n] != data_nasc[_n-1] & pis[_n] == pis[_n-1] //same pis, different dates of birth
			bys 	pis: egen total_nasc = sum(dif_nasc)									//number distinct dates of birth by CPF
			drop 	if total_nasc > 0														//dropping pis that have distinct dates of birth
		 
			**
			duplicates drop pis, force
			keep 			pis data_nasc													//employees for which the PIS ID always has the same date of birth in distinct RAIS waves
			
			**
			save "$inter/RAIS/dateofbirth.dta", replace
			
			
			*.............................*
			
			*A2
			*.............................*
			/*
			
			With the remaining PIS IDs, for a few cases, its only one time that there is a difference in the date of birth for the same PIS across distinct RAIS waves. 
			
			Lets replace date of birth with the mode of date of birth
			
			*/
			
			**
			use  `pis_list', clear
			
			**
			keep 		pis data_nasc
			
			**
			merge m:1 	pis 			using "$inter/RAIS/dateofbirth.dta", keep(1)		//keeping only the ones that we havent identified the date of birth yet
			
			**
			sort    	pis data_nasc
			
			**
			**If there are multiple modes, it means something is wrong
			**
			bys 		pis: egen moda 		= mode(data_nasc)
			bys 		pis: egen min_moda 	= mode(data_nasc), minmode
			bys 		pis: egen max_moda 	= mode(data_nasc), maxmode
			
			keep 		if min_moda == max_moda 	//keeping only the cases where the min_mode = max_mode
			
			**
			**Now lets order pis data_nasc and check the number of times where pis[_n] == pis[_n-1] but the datebirth[_n] != datebirth[_n-1]
			**
			sort 		pis data_nasc
			gen 		dif_nasc = 1 if data_nasc[_n] != data_nasc[_n-1] & pis[_n] == pis[_n-1] 	//same pis, different dates of birth
			bys 		pis: egen total_nasc = sum(dif_nasc)										//number distinct dates of birth by CPF
			keep 		if total_nasc == 1															//lets keep only when this difference occurs once
			
			**
			*Date of birth
			**
			replace 	data_nasc = moda if data_nasc != moda 
			
			**
			duplicates drop pis, force
			
			**
			keep 			pis data_nasc
			count
			
			
			**
			append using  "$inter/RAIS/dateofbirth.dta"
			
			**
			rename 			data_nasc data_nasc_pis
			
			**
			save  		  "$inter/RAIS/dateofbirth.dta", replace
			count
	
			
			*............................................................................................................................*
			**
			*Using CPF ID
			**
			
			
			*.............................*
			
			*B1
			*.............................*
			/*

			*We are going to do the same now with CPFs
			
			*/
			
			**
			clear
			
			foreach ano in 2007 2010 2014 2015 {
				append using "$inter/RAIS/Rais_trabalhador_`ano'.dta", keep(ano pis cpf data_nasc)
			}
			
			**
			**
			keep if cpf!= ""
			sort 	cpf
		
			**
			**
			tempfile cpf_list
			save    `cpf_list'																

			**
			**
			sort    cpf data_nasc
			gen 	dif_nasc = 1 if data_nasc[_n] != data_nasc[_n-1] & cpf[_n] == cpf[_n-1] //same pis, different dates of birth
			bys 	cpf: egen total_nasc = sum(dif_nasc)									//number distinct dates of birth by CPF
			drop 	if total_nasc > 0														//dropping pis that have distinct dates of birth
		
			**
			keep 			cpf data_nasc
			duplicates drop cpf, force

			**
			save "$inter/RAIS/dateofbirth_cpf.dta", replace

			
			*.............................*
			
			*B2
			*.............................*
			/*
			
		    With the remaining CPFs, for a few cases, its only one time that there is a difference in the date of birth for the same CPFs
			 
			Lets replace date of birth with the mode of date of birth
			  
			*/
			
			use  		`cpf_list'	, clear
			
			**
			keep 		cpf data_nasc
			
			**
			merge m:1 	cpf 			using "$inter/RAIS/dateofbirth_cpf.dta", keep(1)		//keeping only the ones that we havent identified the date of birth yet
			
			**
			sort    	cpf data_nasc
			
			**
			**If there are multiple modes, it means something is wrong
			**
			bys 		cpf: egen moda 		= mode(data_nasc)
			bys 		cpf: egen min_moda 	= mode(data_nasc), minmode
			bys 		cpf: egen max_moda 	= mode(data_nasc), maxmode
			
			keep 		if min_moda == max_moda 	//keeping only the cases where the min_mode = max_mode
			
			**
			**Now lets order pis data_nasc and check the number of times where pis[_n] == pis[_n-1] but the datebirth[_n] != datebirth[_n-1]
			**
			sort 		cpf data_nasc
			gen 		dif_nasc = 1 if data_nasc[_n] != data_nasc[_n-1] & cpf[_n] == cpf[_n-1] 	//same pis, different dates of birth
			bys 		cpf: egen total_nasc = sum(dif_nasc)										//number distinct dates of birth by CPF
			keep 		if total_nasc == 1															//lets keep only when this difference occurs once
			
			**
			*Date of birth
			**
			replace data_nasc = moda if data_nasc != moda 
			
			**
			duplicates drop cpf, force
			keep 			cpf  data_nasc

			**
			append using  "$inter/RAIS/dateofbirth_cpf.dta"
					
			**
			rename 		   data_nasc data_nasc_cpf

			**
			save  		  "$inter/RAIS/dateofbirth_cpf.dta", replace
			

			*............................................................................................................................*
			**
			*Checking errors with PIS
			**
			/*
			
			The same CPF ID can have distinct PIS IDS, but the reverse is not true. 

			*/
			
			**
			*Checking the error
			**
			use 		 pis cpf using `cpf_list', clear			
			sort 		 pis cpf
			gen 		 erro = pis[_n] == pis[_n-1] & cpf[_n] != cpf[_n-1]				//same pis, distinct CPFS
			bys 		 pis: egen max_erro = sum(erro)									//pis with errors
			
			**
			**Pis associados a mais de um cpf - > erro
			**
			preserve
			keep 		 if max_erro != 0
			duplicates 	 drop pis, force
			
			keep 		 pis
			save 		 "$inter/RAIS/Erro_PIS.dta", replace							//list of PIS with errors
			restore
			
			**
			**
			keep 		 if max_erro == 0			
			
			**
			*Now lets try to identify the CPF of the employees so we can merge with 1999 and 2001 (years in which the dataset do not have CPF available). 
			sort 		cpf pis
			gen 		dif = 		cpf[_n] 		== cpf[_n-1] & pis[_n] != pis[_n-1]
			replace 	dif = 1 if  cpf[_n] 		== cpf[_n+1] & pis[_n] != pis[_n+1]
			bys 		cpf: egen num_pis 	=  sum(dif)
			drop 		if 		  num_pis > 2 											//pessoas com + de 3 numeros de pis diferentes
			duplicates  drop pis, force
			keep 			 pis cpf		
			
			**
			save 		 "$inter/RAIS/CPF_PIS.dta", replace
	
			
			
			
		*________________________________________________________________________________________________________________________________*
		**
		**
		*RAIS waves 1999-2015

		*________________________________________________________________________________________________________________________________*

			*Getting birth date
			*............................................................................................................................*
			**
			**
			foreach ano in 1999 2001 2002 2003 2007 2010 2014 2015 {
				
				**
				use 	"$inter/RAIS/Rais_trabalhador_`ano'.dta", clear
								
				**
				cap 	noi rename data_nasc data_nasc_original
				
				**
				di 		as red "Ano analisado `ano'" 
				
				count

				**
				*Pis errado 
				**	
				merge 	m:1 pis using "$inter/RAIS/Erro_PIS.dta"				, keep(1  ) nogen 							//not keeping the PIS with errors

								
				**
				*Identificando o CPF
				**	
				merge 	m:1 pis using "$inter/RAIS/CPF_PIS.dta"					, keep(1 3) nogen keepusing(cpf) 			//trying to get the CPF of the person
								
				**
				*Date of birth by PIS
				**
				merge 	m:1 pis using  "$inter/RAIS/dateofbirth.dta"	    	, keep(1 3) gen(_merge1)
				
				**
				*Date of birth by CPF
				**
				merge 	m:1 cpf using  "$inter/RAIS/dateofbirth_cpf.dta"    	, keep(1 3) gen(_merge2)
				
				
				**
				*Final data for date of birth using PIS, CPF or original date of birth available
				**
				gen	 	data_nasc = ""
				
				replace data_nasc = data_nasc_pis	   if _merge1 == 3
				
				replace data_nasc = data_nasc_cpf 	   if _merge1 == 1 & _merge2 == 3

				**
				cap noi  {
				
				replace data_nasc = data_nasc_original if inlist(ano, 2007, 2010, 2014, 2015) & data_nasc == "" & data_nasc_original != ""
				drop 	_merge1 _merge2
				
				}
				
				**
				tempfile Rais_trabalhador_`ano'
				save    `Rais_trabalhador_`ano''	
				
				**
				di as red "Final do ano analisado"
				
			}
			
			*Appending years
			*............................................................................................................................*
			**
			**
			clear
			foreach ano in 1999 2001 2002 2003 2007 2010 2014 2015 {
				append using `Rais_trabalhador_`ano''
			}
	
				drop 		data_nasc_original data_nasc_cpf data_nasc_pis
				
				**
				keep 		if data_nasc != ""

				**
				gen 	  	birth_date = date(data_nasc,"DMY") 
				format    	birth_date %td

			 
				*==================================>>
				**********************************
				preserve
			 
				**
				*Bandwidth in weeks
				**
				gen 		zw   = wofd(birth_date  - mdy(12, 16, 1984))				//weeks between date of birth  and December 16th, 1984
				
				
				**
				*Bandwidth in days
				**
				gen 		dw   =		birth_date  - mdy(12, 16, 1984)					//days between date of birth  and December 16th, 1984
				
				
				**
				*Twelve weeks bandwidth 
				**
				keep 		if (zw >= - 12 & zw < 12) 
				
				
				**
				*Treatment status
				**
				gen 		D 	 = 1 		if zw  >= 0	& !missing(zw)					//children that turned 14 on December 16th, 1984 or after that 
				replace 	D	 = 0 		if zw  <  0	& !missing(zw)		

				gen 		amostra = 1

				tempfile 	mainsample
				save       `mainsample'
				
				
				restore
				**********************************
				*==================================>>
				
				keep 		if ano >= 2007												//placebo tests for year>=2010. We set up a 3 and 6-month bandwidth aroung december 16, 1983. So all the analyzed cohort turned 14 before the ban									
				
				**
				*Bandwidth in weeks
				**
				gen 		zw  = wofd(birth_date  - mdy(12, 16, 1983))					//weeks between date of birth  and December 16th, 1983
				gen 		dw  = 	   birth_date  - mdy(12, 16, 1983)					//days between date of birth  and December 16th, 1984
				
				
				**
				*Twelve weeks bandwidth 
				**
				keep 		if (zw >= -12 & zw < 12)
				
				
				**
				*Treatment status
				**
				gen 		D	 = 1 		if zw >= 0	& !missing(zw)				 	//Treatment status placebo
				replace 	D	 = 0 		if zw <  0	& !missing(zw)		
			
				**
				gen 		amostra = 0
				
				**
				append 		using `mainsample'
				
				
				**
				*Sometimes the same PIS appers with different genders in different years
				**
				bys 		pis: egen moda_gender = mode(sexo)
				replace 	sexo = moda_gender
				keep 		if nacionalidade == 10			//keeping only brazilians

				
				**
				*Sample definition
				**
				label 		define amostra 1 "Main sample" 0 "Placebo"
				label 		val    amostra amostra
				
	
				**
				*First job
				**
				gen 		primeiro_emprego = tipo_adm == 1
			
			
				**
				*Whether the employee started working before the ban
				**
				gen 		start_before_ban = 1 if    ano_admissao <= 1998 & ano == 1999  & amostra == 1
				replace 	start_before_ban = 0 if    ano_admissao == 1999 & ano == 1999  & amostra == 1
				tab	 		D start_before_ban
			
			
				**
				*Education
				**
				gen 		lowersec_degree 	= inrange(grau_instr, 5, 11)
				gen 		highschool_degree	= inrange(grau_instr, 7, 11)
				gen 		college_degree		= inrange(grau_instr, 9, 11)	
				foreach var of varlist lowersec_degree highschool_degree college_degree {
					replace `var' = . if grau_instr == .
				}

				
				**
				*Wage per hour
				**
				gen 		salario_hora = sal_med/horas_semanais
				replace 	salario_hora = sal_contratado/horas_semanais if salario_hora == .
				
				
				**
				*Outliers in terms of wage per hour
				**
				foreach 	ano in 1999 2001 2002 2003 2007 2010 2014 2015 {
				
				su 			salario_hora 		if amostra == 0 & ano == `ano', detail 
				replace 	salario_hora = . 	if amostra == 0 & ano == `ano' & (salario_hora <= r(p1) | salario_hora >= r(p99))
				
				su 			salario_hora 		if amostra == 1 & ano == `ano', detail 
				replace 	salario_hora = . 	if amostra == 1 & ano == `ano' & (salario_hora <= r(p1) | salario_hora >= r(p99))
				
				}
				
				
				**
				*Skin color
				*
				replace 	raca_cor = . if raca_cor == 9
				
				
				**
				*Type of work contract
				**
				recode 		tipo_vinculo 	(10 15 20 25 60 65 70 75 = 1 "CLT"		 )  (30 31 35 96 97 = 2 "Servidor") (55 = 3 "Aprendiz") ///
											(40 50 90 95 			 = 4 "Temporário")  (80 			= 5 "Diretor" ), gen(vinculo)		
											
				**
				*Labels
				**
				label 		define 	tipo_sal 			1 "Mensal"     			2 "Quinzenal" 		3 "Semanal" 4 "Diário"  5 "Horário" 6 "Tarefa" 
				label   	define  sexo     			1 "Homem"      			2 "Mulher"
				label   	define  raca_cor 			1 "Indígena"   			2 "Branco" 	  		4 "Preto"   6 "Amarelo" 8 "Pardo"
				label   	define 	lowersec_degree 	0 "Sem EF completo" 	1 "EF completo"
				label   	define 	highschool_degree	0 "Sem EM completo" 	1 "EM completo"
				label   	define 	college_degree		0 "Sem Ensino Superior" 1 "Ensino Superior"
				label  	 	define  D					0 "Controle"			1 "Tratamento"
				label   	define  tamanho_estab 		0 "Zero" 				1 "Até 4" 			2 "De 5 a 9" 		///
														3 "De 10 a 19" 			4 "de 20 a 49" 		5 "De 50 a 99"  	///
														6 "De 100 a 249" 		7 "De 250 a 499" 	8 "De 500 a 999" 	///
														9 "1000 ou mais" 
				
				
				**
				**
				gen 		mais100empreg = inrange(tamanho_estab,6,9)		//than than 10 employees
				

				**
				**
				foreach 	name of varlist tipo_sal sexo raca_cor *degree D tamanho_estab {
					label val `name' `name'
				}
				
				
				**
				*Ordering
				**
				format 		tempo_emprego %4.1fc

				**
				sort 		ano zw
				
				**
				order 		ano pis birth_date idade_trab primeiro_emprego zw D  amostra sexo lowersec_degree highschool_degree college_degree raca_cor vinculo data_admissao mes_admissao ano_admissao   	///
							horas_semanais tempo_emprego tamanho_estab po_3112 great_sectors																											///
							tipo_sal sal_med sal_dez sal_ultimo sal_contratado  salario_hora uf_estab municipio_estab tipo_estab natureza_juridica ctps cpf cnae20 cnae10
				drop 		cbo_1994-data_nasc
			
				save 	"$final/RAIS.dta", replace
			
			
		*________________________________________________________________________________________________________________________________*
		**
		
		*Data for regressions
		**
		*________________________________________________________________________________________________________________________________*
			
				use 		"$final/RAIS.dta" , clear									

				**
				*Workers in activity by December 31
				**
				keep 		if po_3112 == 1	
				
				**
				*Workers with no missing gender
				**
				keep 		if inlist(sexo, 1, 2)
				
				**
				*Number of jobs by employee
				**
				bys 		pis ano: gen 	num_empregos = _N
				su 					 		num_empregos		, detail
				drop if 			 		num_empregos 				 > r(p99)
				
				**
				*One employee per row per ano
				**
				collapse 	(mean) *degree salario_hora num_empregos tempo_emprego (max) mais100empreg, by(ano pis birth_date zw dw D sexo amostra)
				
				gen 	 	ln_salario_hora = ln(salario_hora)
				
				gen 	 	zw2 = zw^2 
				
				gen 	 	cohort84_1 = 1 if dw >= - 28 & dw < 28	//one-month bandwidth
				gen 	 	cohort84_3 = 1 if dw >= - 84 & dw < 84	//three-month bandwidth
 
				save 		"$final/RAIS-regressions.dta", replace
			
		/*
		
		*________________________________________________________________________________________________________________________________*
		**
		**
		*Local Randomization Inference
		**
		*________________________________________________________________________________________________________________________________*
				
		**
		*Regressions
		**
		*--------------------------------------------------------------------------------------------------------------------------------*
		estimates clear
		
		matrix results = (0,0,0,0,0,0,0,0,0,0) 											//storing dependent variable, group (all, boys, girls), observed statistic, lower bound and upper bounds, mean of the dependent outcome, cohort (1 or 3 month bandwidth) sample (main or placebo)
			
		local   dep_var = 1																//we attributed a model number for each dep var
				
			foreach variable in salario_hora {											//lowersec_degree highschool_degree ln_salario_hora salario_hora mais100empreg tempo_emprego
			
				foreach cohort in 3    {												//1 and 3-month bandwidth
				
					if `cohort' == 3   { 
					local wl = -12														//bandwith in weeks
					local wr =  11
					}
					else 			   {
					local wl = -4
					local wr =  3
					}
					
					foreach amostra in 0 1					{								//main sample and placebo
							
						foreach ano in 2007 2010 2014 2015	{	
							
							foreach grupo in 2		{								//testing the results with different samples
								
								if `grupo' == 1 		{
								use "$final/RAIS-regressions.dta" if			  ano == `ano'  & amostra == `amostra' & cohort84_`cohort' == 1, clear			//all sample
								}
								if `grupo' == 2 		{
								use "$final/RAIS-regressions.dta" if  sexo == 1 & ano == `ano ' & amostra == `amostra' & cohort84_`cohort' == 1, clear			//only boys
								} 
								if `grupo' == 3 		{ 
								use "$final/RAIS-regressions.dta" if  sexo == 2 & ano == `ano'  & amostra == `amostra' & cohort84_`cohort' == 1, clear			//only girls
								}
								
								di as red "`variable'" "-" "`amostra'" "-" "`ano'" "-" "`grupo'" 
									
								su `variable', detail
								local mean = r(mean)													//mean of the outcome
									
								rdrandinf `variable' zw,  wl(`wl') wr(`wr') interfci(0.05) seed(702443)	//seed generated at numbergenerator.org
								matrix results = results \ (`ano',`dep_var', `grupo', r(obs_stat), r(randpval), r(int_lb), r(int_ub), `mean', `cohort', `amostra')
								
							}	//grupo
								
						}		//ano
						
					}			//amostra
						
				}				//cohort
				local dep_var = `dep_var' + 1	
			}					//dep var

			**
			*Results
			**
			*--------------------------------------------------------------------------------------------------------------------------------*
			clear
			svmat 	results						//storing the results of our estimates so we can present the estimates in charts
			drop  	in 1
			rename	 (results1-results10) (ano dep_var grupo ATE pvalue lower upper mean_outcome cohort amostra)	
			
			
			**
			*Dep vars
			**
			*label 	 define dep_var 1 "Lower Secondary Education" 	2 "High school" 	3 "Ln Wage per hour" 	4 "Wage per hour"  5 "More than 500 employees" 6 "Time of service" 
			*label	 val    dep_var dep_var
			
			**
			*Amostra
			**
			label 	define amostra 	1 "Main sample" 				0 "Placebo"
			label 	val    amostra amostra
			
			**
			*Cohort
			**
			label 	define cohort 	1 "4-week bandwidth" 			3 "12-week bandwidth"
			label 	val    cohort cohort
			
			**
			*Grupo estudado
			**
			label 	define grupo 	1 "All" 						2 "Boys"  				3 "Girls"
			label 	val    grupo grupo
			
			save 	"$final/Local Randomization_RAIS.dta", replace
			
			

			**
			*Tables
			**
			*--------------------------------------------------------------------------------------------------------------------------------*			
			use 	"$final/Local Randomization_RAIS.dta", clear
		
			**
			*Vars in %
			**
			foreach var of varlist ATE lower upper mean_outcome	{
			replace `var'  = `var' *100 if inlist(dep_var, 1, 2, 5)
			}
			
			
			**
			*Impact of the ban as % of the mean outcome
			**
			gen 	 att_perc_mean = (ATE/mean_outcome)*100	 if pvalue  <= 0.05
			format   ATE-att_perc_mean %4.2fc
		
			
			**
			*CI
			**
			gen 	 CI  = "[" + substr(string(lower),1,4) + "," + substr(string(upper),1,4) + "]" if substr(string(lower),1,1) == "-" & substr(string(upper),1,1) == "-"
			replace  CI  = "[" + substr(string(lower),1,4) + "," + substr(string(upper),1,3) + "]" if substr(string(lower),1,1) == "-" & substr(string(upper),1,1) != "-"
			replace  CI  = "[" + substr(string(lower),1,3) + "," + substr(string(upper),1,3) + "]" if substr(string(lower),1,1) != "-" & substr(string(upper),1,1) != "-"
			replace  CI  = "[" + substr(string(lower),1,3) + "," + substr(string(upper),1,4) + "]" if substr(string(lower),1,1) != "-" & substr(string(upper),1,1) == "-"
			
			
			**
			*
			**
			tostring ATE, force replace
			replace  ATE = substr(ATE, 1, 5) 
			replace  ATE = ATE + "*"    if pvalue <= 0.10 & pvalue > 0.05
			replace  ATE = ATE + "**"   if pvalue <= 0.05 & pvalue > 0.01
			replace  ATE = ATE + "***"  if pvalue <= 0.01
			drop  	 lower upper pvalue
			
			
			**
			*Ordering
			**
			order 	 dep_var ano ATE CI mean_outcome att_perc_mean
			reshape  wide ATE CI mean_outcome att_perc_mean, i(ano dep_var amostra cohort) j(grupo)
			sort 	 amostra cohort dep_var ano
			drop     cohort
			
			
			
			**
			*--------------------> Setting up the table with main results
			**
			
			foreach amostra in 0 1 {
			preserve
				keep 	 if amostra == `amostra' 
				
				local 	 num_dp_var  = 6				//number of dependent variables
				local 	 number_rows = `num_dp_var'*4	//total number of rows in the table
					
				set 	 obs `number_rows'
				replace  ano 	 = 0 		if ano == .
				
				forvalues row = 1(1)`num_dp_var' {
					local 	n_row 	= `row' + `num_dp_var'*3
					replace dep_var = `row'  in `n_row'
				}
				
				sort     dep_var  ano
				decode   dep_var, gen(var)
				drop     dep_var
				replace  ano = . 		if ano == 0
				tostring ano, replace
				replace  ano = var 		if ano == "."
				drop     var
			
				gen 	 space1 = .
				gen 	 space2 = .
				gen 	 space3 = .
				order 	 ano *1 *2 *3 
				if `amostra' == 1 export   excel using "$tables/Table2.xlsx" ,  replace
				if `amostra' == 0 export   excel using "$tables/TableA8.xlsx",  replace
			restore	 
			}
			
		 
		 
		 
		*________________________________________________________________________________________________________________________________*
		**
		
		*Quantile Parametric RDD
		**
		*________________________________________________________________________________________________________________________________*
		
			estimates clear

			matrix results = (0, 0, 0, 0, 0, 0)
			
			set seed 577552 
			
			foreach sexo in 1 2 {
			
				use	"$final/RAIS-regressions.dta" if cohort84_3 == 1 & amostra == 1 & sexo == `sexo', clear 
			 
					**
					*2007
					**
					reg 	ln_salario_hora zw 	if ano == 2007
					predict		  resid, residuals

					eststo: sqreg ln_salario_hora  D 		if ano == 2007, quantile( .2 .4 .6 .8) reps(1000) 
					local 		i = 1
					forvalues 	quintil = 20(20)80 {
					matrix 		results = results  \ (2007, `quintil', el(r(table)',`i',1),  el(r(table)',`i',5),  el(r(table)',`i',6), `sexo')		//quantile of analysis, coefficient, lower and upper bound
					local 		i = `i' + 2 
					}
			
					drop resid
					
					
					**
					*2010
					**
					reg 	ln_salario_hora zw 	if ano == 2010
					predict		  resid, residuals

					eststo: sqreg ln_salario_hora D 		if ano == 2010, quantile(  .2 .4 .6 .8) reps(1000) 
					local 		i = 1
					forvalues 	quintil = 20(20)80 {
					matrix 		results = results  \ (2010, `quintil', el(r(table)',`i',1),  el(r(table)',`i',5),  el(r(table)',`i',6), `sexo')		//quantile of analysis, coefficient, lower and upper bound
					local 		i = `i' + 2 
					}
			
					drop resid
					
					
					**
					*Results
					**
					clear 
					svmat 	results
					drop 	in 1
					rename (results1-results6) (ano quintil b lower upper genero)
					replace b 	  = b*100
					replace lower = lower*100
					replace upper = upper*100
					save "$final/Quantile Regressions.dta", replace
			}
				
				**
				*Charts
				**
				use	"$final/Quantile Regressions.dta" if genero == 1, clear
								
				expand 2 if ano == 2007, gen(REP1)
				expand 2 if ano == 2010, gen(REP2)
				
				replace b = -0.65 	if REP1 == 1
				replace b =  0 		if REP2 == 1		
				gen 	REP = 1 	if REP1 == 1 | REP2 == 1
				drop	REP1 REP2

				twoway ///
								(rcap 	lower upper quintil , by(ano, note("")) color(navy) lwidth(medthick)) ///
								(scatter b quintil 	if REP == . , by(ano, note("")) msymbol(O) color(cranberry) yline(0,lpattern(dash) lcolor(gray))) ///
								(line b quintil 	if REP == 1, msize(4) msymbol(D) color(red) lwidth(medthick) lpattern(shortdash) ///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
				plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
				ylabel(, labsize(small) format(%4.2fc)) ///
				xlabel(20(20)80, labsize(small) gmax angle(horizontal)) ///
				ytitle("Wage variation, in %", size(medsmall)) ///
				xtitle("Quintiles", size(medsmall)) ///
				title("", pos(12) color(black) size(medsmall)) ///
				subtitle(, pos(12) size(medsmall)) ///
				ysize(5) xsize(7) ///
				legend(order(1 "95% CI"  2 "Point estimate by quintile" 3 "Average Effect" ) cols(3) region(lstyle(none) fcolor(none)) size(medsmall)) ///
				note("", color(black) fcolor(background) pos(7) size(small))) 
				graph export "$figures/rais-quintil_3bandwidth.pdf", as(pdf) replace		
		 
		 
		/*
		*________________________________________________________________________________________________________________________________*
		**
		**
		*Parametric RDD
		**
		*________________________________________________________________________________________________________________________________*
						
				foreach table in 1 2 3 4 5 6	{					//1: Controls D zw
																	//2: controls D zw zw2	
																
					if `table' == 1 		{
					local controls D zw 
					local amostra = 1
					}
					
					if `table' == 2     	{
					local controls D zw zw2
					local amostra = 1
					}
					
					if `table' == 3     	{
					local controls D 
					local amostra = 1
					}
					
					if `table' == 4			{
					local controls D zw 
					local amostra = 0
					}
					
					if `table' == 5  	 	{
					local controls D zw zw2
					local amostra = 0
					}	
					
					if `table' == 6 	 	{
					local controls D 
					local amostra = 0
					}		
					
						
					foreach variable in ln_salario_hora salario_hora {					//% of children's working and % of children in paid jobs
						
						foreach cohort in 1 3 {							//bandwidths
							
							estimates clear
							
							if "`variable'" == "lowersec_degree"   	& `cohort'  == 1  	 local title = "Lower Secondary, 4-week bandwidth"
							if "`variable'" == "highschool_degree" 	& `cohort'  == 1  	 local title = "High School, 4-week bandwidth"
							if "`variable'" == "college_degree" 	& `cohort'  == 1  	 local title = "Collegre Degree, 4-week bandwidth"
							if "`variable'" == "ln_salario_hora" 	& `cohort'  == 1  	 local title = "Ln wage per hour, 4-week bandwidth"
							if "`variable'" == "salario_hora" 		& `cohort'  == 1  	 local title = "Wage per hour, 4-week bandwidth"
							if "`variable'" == "mais100empreg" 		& `cohort'  == 1  	 local title = "More 100 employeed, 4-week bandwidth"
							if "`variable'" == "tempo_emprego" 		& `cohort'  == 1  	 local title = "Time in the current job, 4-week bandwidth"

							if "`variable'" == "lowersec_degree"   	& `cohort'  == 3  	 local title = "Lower Secondary, 12-week bandwidth"
							if "`variable'" == "highschool_degree" 	& `cohort'  == 3  	 local title = "High School, 12-week bandwidth"
							if "`variable'" == "college_degree" 	& `cohort'  == 3  	 local title = "Collegre Degree, 12-week bandwidth"
							if "`variable'" == "ln_salario_hora" 	& `cohort'  == 3  	 local title = "Ln wage per hour, 12-week bandwidth"
							if "`variable'" == "salario_hora" 		& `cohort'  == 3  	 local title = "Wage per hour, 12-week bandwidth"
							if "`variable'" == "mais100empreg" 		& `cohort'  == 3  	 local title = "More 100 employeed, 12-week bandwidth"
							if "`variable'" == "tempo_emprego" 		& `cohort'  == 3  	 local title = "Time in the current job, 12-week bandwidth"
														
								foreach ano in 2007 2010 {								//1 -> applying Bargain/Boutin sample exclusions. 2 -> Not applying exclusions suggested by Bargain/Boutin. 
									
									use "$final/RAIS-regressions.dta", clear
													
													
											reg `variable' `controls'  if ano == `ano' & amostra == `amostra' & cohort84_`cohort' == 1, 			 cluster(zw)			//all
											eststo, title("All")
											
											reg `variable' `controls'  if ano == `ano' & amostra == `amostra' & cohort84_`cohort' == 1 & sexo == 1, cluster(zw)			//boys
											eststo, title("Boys")
											
											reg `variable' `controls'  if ano == `ano' & amostra == `amostra' & cohort84_`cohort' == 1 & sexo == 2, cluster(zw)			//girls
											eststo, title("Girls" )
											
								} //ano
								
								if "`variable'" == "ln_salario_hora" & `cohort' == 1 {
								estout * using "$tables/rais-rdd-table`table'.xls",  keep(D*)  title("`title'") label mgroups("2007" "2010", pattern(1 0 0 1 0 0)) cells(b(star fmt(4)) se(fmt(4))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2, labels("Obs" "R2") fmt(%9.0g %9.3f %9.3f)) replace
								}
								else {
								estout * using "$tables/rais-rdd-table`table'.xls",  keep(D*)  title("`title'") label mgroups("2007" "2010", pattern(1 0 0 1 0 0)) cells(b(star fmt(4)) se(fmt(4))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2, labels("Obs" "R2") fmt(%9.0g %9.3f %9.3f)) append
								} //exporting
						}   //cohorts
					} 		//dep var
				}			//tables 
		 
		  
		 
		 
		 
		 /*
		 
		 
		 */
		 
		 ->  Tentei usando a data de nascimento sem "consertar" e o placebo tb ficou significativo. 
		 ->  fazendo o painel de pis e cpf para ajustes na data de nasc, o placebo tb fica significativo/
		 
		 
		 
		 
