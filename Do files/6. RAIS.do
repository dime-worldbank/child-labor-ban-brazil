
													*RAIS, Relação Anual de Informações Sociais*
	*Dataset with all formal workers in Brasil. 
	*We will work with the workers born between 1984 and 1985, our treatment and control groups. 
	*The identification number is the variable PIS. 
	*____________________________________________________________________________________________________________________________________*

	
	
		*________________________________________________________________________________________________________________________________*
		**
		**
		*Identifying date of birth 
		**
		*________________________________________________________________________________________________________________________________*
			*In 1999 and 2001 waves, date of birth is not available. 
			*We will work with RAIS from anos 2002, 2003 and 2007 to identify the date of birth and merge with 1999 and 2001 waves using PIS
			
			
			*=================================>
			**Sometimes the same PIS appers with different dates of birth
			*Ordering PIS and selecting the ones that always have the same date of birth
			clear
			
			foreach ano in 2002 2003 2007 2010 {
				append using "$inter/RAIS/Rais_trabalhador_`ano'.dta", keep(pis ano cpf data_nasc)
			}
			tempfile pis_list
			save    `pis_list'																//list of all PIS
			
			keep if pis != ""
			sort 	pis 

			sort    pis data_nasc
			gen 	dif_nasc = 1 if data_nasc[_n] != data_nasc[_n-1] & pis[_n] == pis[_n-1] //same pis, different dates of birth
			bys 	pis: egen total_nasc = sum(dif_nasc)									//number distinct dates of birth by CPF
			drop 	if total_nasc > 0														//dropping pis that have distinct dates of birth
		 
			duplicates drop pis, force
			keep 			pis data_nasc
			
			save "$inter/RAIS/dateofbirth.dta", replace
			
			
			*=================================>
			*With the remaining PIS, for a few cases, its only one time that there is a difference in the date of birth for the same PIS
			*Lets replace date of birth with the mode of date of birth
			
			use  `pis_list', clear
			
			keep if 	pis != ""
			
			keep 		pis data_nasc
			
			merge m:1 	pis 			using "$inter/RAIS/dateofbirth.dta", keep(1)		//keeping only the ones that we havent identified the date of birth yet
			
			sort    	pis data_nasc
			
			**
			**If there are multiple modes, it means something is wrong
			**
			bys 		pis: egen moda 		= mode(data_nasc)
			bys 		pis: egen min_moda 	= mode(data_nasc), minmode
			bys 		pis: egen max_moda 	= mode(data_nasc), maxmode
			
			keep 	if min_moda == max_moda 	//keeping only the cases where the min_mode = max_mode
			
			**
			**Now lets order pis data_nasc and check the number of times where pis[_n] == pis[_n-1] but the datebirth[_n] != datebirth[_n-1]
			**
			sort 	pis data_nasc
			gen 	dif_nasc = 1 if data_nasc[_n] != data_nasc[_n-1] & pis[_n] == pis[_n-1] //same pis, different dates of birth
			bys 	pis: egen total_nasc = sum(dif_nasc)									//number distinct dates of birth by CPF
			keep if total_nasc == 1															//lets keep only when this difference occurs once
			
			**
			*Date of birth
			**
			replace data_nasc = moda if data_nasc != moda 
			
			duplicates drop pis, force
			
			keep 			pis data_nasc
			count
			
			append using  "$inter/RAIS/dateofbirth.dta"
			save  		  "$inter/RAIS/dateofbirth.dta", replace
			count
			
			
		*________________________________________________________________________________________________________________________________*
		**
		**
		*1999-2010
		**
		*________________________________________________________________________________________________________________________________*

			clear
			
			foreach ano in 1999 2001 2002 2003 2007 2010 {
				append using "$inter/RAIS/Rais_trabalhador_`ano'.dta"
			}
			drop data_nasc
			
				**
				*Sometimes the same PIS appers with different genders in different years
				**
				bys pis: egen moda_gender = mode(sexo)
				replace sexo = moda_gender
				keep if nacionalidade == 10			//keeping only brazilians
			
			
				**
				*Date of birth by PIS
				**
				merge m:1 pis using  "$inter/RAIS/dateofbirth.dta", keep(3) nogen
				gen 	  birth_date = date(data_nasc,"DMY") 
				format    birth_date %td
			 
			 
				**
				*Bandwidth in weeks
				**
				gen 	zw   = wofd(birth_date  - mdy(12, 16, 1984))				//weeks between date of birth  and December 16th, 1984
				gen 	zwP  = wofd(birth_date  - mdy(12, 16, 1983))				//placebo bandwidth
				
				replace zw   = . if zw < -12
				replace zwP  = . if zwP > 11
	
	
				**
				*Treatment status
				**
				gen 	D 	 = 1 		if zw  >= 0	& !missing(zw)					//children that turned 14 on December 16th, 1984 or after that 
				replace D	 = 0 		if zw  <  0	& !missing(zw)		
				
				gen 	DP	 = 1 		if zwP >= 0	& !missing(zwP)				 	//Treatment status placebo
				replace DP	 = 0 		if zwP <  0	& !missing(zwP)		
				
				
				**
				*Twelve weeks bandwidth 
				**
				keep 					if (zw >= -12 & zw < 12) | (zwP >= -12 & zwP < 12)

				
				**
				*First job
				**
				gen primeiro_emprego = tipo_adm == 1
			
			
				**
				*Whether the employee started working before the ban
				**
				gen 	start_before_ban = 1 if   mes_admissao < 12 & ano_admissao <= 1998 & ano == 1999 
				replace start_before_ban = 0 if 					  ano_admissao == 1999 & ano == 1999
				tab	 	D start_before_ban
			
			
				**
				*Education
				**
				gen lowersec_degree 	= inrange(grau_instr, 5, 11)
				gen highschool_degree	= inrange(grau_instr, 7, 11)
				gen college_degree		= inrange(grau_instr, 9, 11)	
				foreach var of varlist lowersec_degree highschool_degree college_degree {
					replace `var' = . if grau_instr == .
				}

				
				**
				*Wage per hour
				**
				gen 	salario_hora = sal_med/horas_semanais
				replace salario_hora = sal_contratado/horas_semanais if salario_hora == .
				
				
				**
				*Outliers in terms of wage per hour
				**
				su 		salario_hora, detail
				replace salario_hora = . if salario_hora <= r(p1) | salario_hora >= r(p99)
				
				
				**
				*Skin color
				*
				replace raca_cor = . if raca_cor == 9
				
				
				**
				*Type of work contract
				**
				recode tipo_vinculo (10 15 20 25 60 65 70 75 = 1 "CLT"		 )  (30 31 35 96 97 = 2 "Servidor") (55 = 3 "Aprendiz") ///
									(40 50 90 95 			 = 4 "Temporário")  (80 			= 5 "Diretor" ), gen(vinculo)
				
				
			
				**
				*Labels
				**
				label 	define 	tipo_sal 			1 "Mensal"     			2 "Quinzenal" 		3 "Semanal" 4 "Diário"  5 "Horário" 6 "Tarefa" 
				label   define  sexo     			1 "Homem"      			2 "Mulher"
				label   define  raca_cor 			1 "Indígena"   			2 "Branco" 	  		4 "Preto"   6 "Amarelo" 8 "Pardo"
				label   define 	lowersec_degree 	0 "Sem EF completo" 	1 "EF completo"
				label   define 	highschool_degree	0 "Sem EM completo" 	1 "EM completo"
				label   define 	college_degree		0 "Sem Ensino Superior" 1 "Ensino Superior"
				label   define  D					0 "Controle"			1 "Tratamento"
				label   define  tamanho_estab 		0 "Zero" 				1 "Até 4" 			2 "De 5 a 9" 		///
													3 "De 10 a 19" 			4 "de 20 a 49" 		5 "De 50 a 99"  	///
													6 "De 100 a 249" 		7 "De 250 a 499" 	8 "De 500 a 999" 	///
													9 "1000 ou mais" 
				
				
				gen mais100empreg = inrange(tamanho_estab,6,9)		//than than 10 employees
				

				foreach name of varlist tipo_sal sexo raca_cor *degree D tamanho_estab {
					label val `name' `name'
				}
				
				
				**
				*Ordering
				**
				format tempo_emprego %4.1fc

				sort ano zw

				order ano pis birth_date idade_trab primeiro_emprego zw D zwP DP sexo lowersec_degree highschool_degree college_degree raca_cor vinculo data_admissao mes_admissao ano_admissao  	///
						  horas_semanais tempo_emprego tamanho_estab po_3112 great_sectors																										///
						  tipo_sal sal_med sal_dez sal_ultimo sal_contratado  salario_hora uf_estab municipio_estab tipo_estab natureza_juridica ctps cpf cnae20 cnae10

				drop cbo_1994-data_nasc
			
				save "$final/RAIS.dta", replace
			
			
		*________________________________________________________________________________________________________________________________*
		**
		*Local Randomization Inference
		**
		*________________________________________________________________________________________________________________________________*
		estimates clear
		matrix results = (0,0,0,0,0,0,0,0,0) 									//storing dependent variable, sample, observed statistic, lower bound and upper bounds, and mean of the dependent outcome

			foreach model in 1 2 {					//our model and placebo
			
				use "$final/RAIS.dta", clear
				
				if `model' == 1 {
				keep if (D  == 0 | D  == 1)			//our affected and unaffected cohorts
				local bandwidth  "zw" 
				}

				if `model' == 2 {
				keep if (DP == 0 | DP == 1)			//Placebo
				local bandwidth "zwP"
				}
				
				**
				*Workers in activity by December 31
				**
				keep if po_3112 == 1	
				
				**
				*Workers with no missing gender
				**
				keep if inlist(sexo, 1, 2)
				
				**
				*Number of jobs by employee
				**
				bys 	pis ano: gen num_empregos = _N
				su 					 num_empregos		, detail
				drop if 			 num_empregos 				 > r(p99)
				
				**
				*One employee per row per ano
				**
				collapse (mean) *degree salario_hora num_empregos tempo_emprego (max) mais100empreg, by(ano pis birth_date `bandwidth' sexo)

				tempfile rais
				save 	`rais'
				
				**
				*Estimates using Cattaneo
				**
				*----------------------------------------------------------------------------------------------------------------------------*
				local dep_var = 1													//we attributed a model number for each specification we tested
				foreach variable in lowersec_degree highschool_degree college_degree salario_hora mais100empreg tempo_emprego {					
					foreach ano in 2007 2010 {																					
						foreach sample in 1 2 3 {																							//testing the results with different samples
							
							if `sample' == 1 use `rais' if				ano == `ano', clear		//all sample
							if `sample' == 2 use `rais' if  sexo == 1 & ano == `ano', clear		//only boys
							if `sample' == 3 use `rais' if  sexo == 2 & ano == `ano', clear		//only girls
						
							su `variable', detail
							local mean = r(mean)												//mean of the outcome
						
							rdrandinf `variable' `bandwidth',  wl(-12) wr(11) interfci(0.05) seed(8378297)	
							matrix results = results \ (`ano',`dep_var', `sample', r(obs_stat), r(randpval), r(int_lb), r(int_ub), `mean', `model')
						}
					}
					local dep_var = `dep_var' + 1		
				}
			}
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			**
			*Results
			*----------------------------------------------------------------------------------------------------------------------------*
			clear
			svmat 	results						//storing the results of our estimates so we can present the estimates in charts
			drop  	in 1
			rename (results1-results9) (ano dep_var sample ATE pvalue lower upper mean_outcome model)	
			save "$final/Local Randomization_RAIS.dta", replace
			

			label 	define dep_var 1 "Lower Secondary Education"  2 "High School"  3  "College"  4 "Wage per hour"  5 "More than 500 employees" 6 "Time of service" 
			label	val    dep_var dep_var
		
			
			foreach var of varlist ATE lower upper mean_outcome	{
				replace `var'  = `var' *100 if inlist(dep_var, 1, 2, 3, 5)
			}
			gen 	 att_perc_mean = (ATE/mean_outcome)*100	 if pvalue  <= 0.05
			format   ATE-att_perc_mean %4.2fc
		
			gen 	 CI  = "[" + substr(string(lower),1,4) + "," + substr(string(upper),1,4) + "]" if substr(string(lower),1,1) == "-" & substr(string(upper),1,1) == "-"
			replace  CI  = "[" + substr(string(lower),1,4) + "," + substr(string(upper),1,3) + "]" if substr(string(lower),1,1) == "-" & substr(string(upper),1,1) != "-"
			replace  CI  = "[" + substr(string(lower),1,3) + "," + substr(string(upper),1,3) + "]" if substr(string(lower),1,1) != "-" & substr(string(upper),1,1) != "-"
			replace  CI  = "[" + substr(string(lower),1,3) + "," + substr(string(upper),1,4) + "]" if substr(string(lower),1,1) != "-" & substr(string(upper),1,1) == "-"
			tostring ATE, force replace
			replace  ATE = substr(ATE, 1, 5) 

			replace ATE = ATE + "*"    if pvalue <= 0.10 & pvalue > 0.05
			replace ATE = ATE + "**"   if pvalue <= 0.05 & pvalue > 0.01
			replace ATE = ATE + "***"  if pvalue <= 0.01

			drop  	lower upper pvalue
			
			order 	dep_var ano ATE CI mean_outcome att_perc_mean
			reshape wide ATE CI mean_outcome att_perc_mean, i(ano dep_var) j(sample)
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			********==> Setting up the table with main results
			local num_dp_var  = 9				//number of dependent variables
			local number_rows = `num_dp_var'*3	//total number of rows in the table
			
			set 	 obs `number_rows'
			replace  ano 	 = 0 		if ano == .
			
			forvalues row = 1(1)`num_dp_var' {
				local 	n_row 	= `row' + `num_dp_var'*2
				replace dep_var = `row'  in `n_row'
			}
			
			sort     dep_var  ano
			decode   dep_var, gen(var)
			drop     dep_var
			replace  ano = . 			if ano == 0
			tostring ano, replace
			replace  ano = var 		if ano == "."
			drop     var
		
			gen space1 = .
			gen space2 = .
			gen space3 = .
			order ano *1 *2 *3 *4
			export excel using "$tables/table2.xlsx",  replace
			*/
			
			
			
		*________________________________________________________________________________________________________________________________*
		**
		*Local Randomization Inference
		**
		*________________________________________________________________________________________________________________________________*

		

		 
		 
		 
		 
		 
		 
		 		
			
						cap program drop charts
			program define	 charts 
			syntax, model(string)

			matrix results = r(table)' 
			matrix A = (0, 0, 0, 0) 
			local  i = 1
			forvalues f = 10(10)90 {
				matrix A = A \ (`f', results[`i',1], results[`i',5], results[`i',6])		//quantile of analysis, coefficient, lower and upper bound
				local i = `i' + 2 
			}
			matrix list A
			clear
			svmat 	A 
			drop 	in 1
			rename (A1 A2 A3 A4) (quantile b lower upper)
			twoway ///
			(scatter b quantile, msymbol(O) msize(medium) color(cranberry) yline(0,lpattern(dash))) ///
			(rcap 	lower upper quantile, color(navy) ///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
			plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
			ylabel(, labsize(small) format(%4.2fc)) ///
			xlabel(0(10)90, labsize(small) gmax angle(horizontal)) ///
			ytitle("Standard deviation", size(medsmall)) ///
			xtitle("Deciles", size(medsmall)) ///
			title("", pos(12) color(black) size(medsmall)) ///
			subtitle(, pos(12) size(medsmall)) ///
			ysize(5) xsize(7) ///
			legend(off) ///
			note("", color(black) fcolor(background) pos(7) size(small))) 
			graph export "$figures/by-decil-2010.pdf", as(pdf) replace		

			end

			set seed 19283

			*Pooledr
				
			eststo: sqreg salario_hora D if ano == 2007, quantile(.1 .2 .3 .4 .5 .6  .7 .8 .9) reps(1000) 
			charts, model("Pooled")
	

		 
		 
			
			
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
