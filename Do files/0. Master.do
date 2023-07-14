	/*
	*________________________________________________________________________________________________________________________________* 
	**
	**
	MASTER do file for Child Labor Ban Paper
	
	CHANGE ROW 287 > folder path
	**
	*________________________________________________________________________________________________________________________________* 
	
	Author: Vivian Amorim
	vivianamorim5@gmail.com/vamorim@worldbank.org
	Last Update: March 2023
	
	**
	**
	Short and Longer-term Effects of a Child Labor Ban in Brazil. 
	**
	
	**YOU NEED STATA 16 TO REPLICATE THE RESULTS**
	
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	The Policy
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		On December 15th, 1998, the Brazilian Federal Government increased the minimum age of employment from 14 to 16 years old.
		The law started being applied one day after that. 
		Children that were already employed were not affected. 
		Therefore, if the child turned 14 on December 16th, 1998, or after that, she/he could not start working legally 
		as opposed to before the law changed. 
		
		We work on regression discontinuity design and on a local randomization inference to explore the effects of this policy.
		
		Our Running variable (zw) is the number of weeks between the date of birth and December 16th, 1984. 
			zw = 0	 if the children turned 14 on December 16th 1998, or less than a week after this date.  
			zw = 1   if the children turned 14 one week  after  the law changed.
			zw = 2   if the children turned 14 two weeks after  the law changed, and so on. 
			zw = -1  if the children turned 14 one week  before the law changed,
			zw = -2  if the children turned 14 two weeks before the law changed, and so on. 
			We also defined the running variable (dw) which is the number of days between the date of birth and December 16, 1984. 
		
		We used the Brazilian Household Survey (Pesquisa Nacional por Amostra de Domicílios, PNAD) to assess the effect
		of the policy on the following outcomes:
		
			- Economically Active Children.
			- Share of children in paid jobs (formal and informal)
			- School attendance
			- Share of kids only attending school
			
					
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	Do files description
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		**
		**
		- 1. Importing Household Survey (PNAD).do
		
			-> How long it takes to run? 
				12 minutes. 
	
			-> What it does?
				The code imports the microdata of the Brazilian Household Survey (Pesquisa Nacional por Amostra de Domicílios). 
				This survey was collected annualy on a representative sample of Brazilian households. 
				
					**
					** The .txt files are available in IBGE (Brazilian Institute od Geography and Statistics) website. 
					
						Since  2001 waves, download the microdata in: https://www.ibge.gov.br/estatisticas/sociais/trabalho/19897-sintese-de-indicadores-pnad2.html?=&t=microdados
						Before 2001		 , download the microdata in: https://loja.ibge.gov.br/pnad-1987-a-1999-microdados.html

					**
					** We saved the raw data in our project folder: child-labor-ban-brazil/DataWork/Datasets/Raw

					**
					** The dictionaries to read .txt files: 
					
						Between 1998 to 2014: we used the DataZoom tool created by PUC/RIO University to import the data without having to manually create the dictionary of the variables. 
						For 2015, we created our own dictionary due to an error we identified in the tool. 
				
			-> What it It creates? 
				The code It creates sixteen .dta files saved in: child-labor-ban-brazil/DataWork/Datasets/Intermediate. 
				Each file is a wave of the household survey. 
				
			
		**
		**	
		- 2. Harmonizing Household Survey (PNAD).do
		
			-> How long does it take to run?
				23 minutes. 
	
			-> What it does?
				The code harmonizes the PNAD waves from 1998 to 2015, creating the dependent and independent variables of our analysis. 			
						
			-> What it It creates? 
				One .dta file named Pooled_PNAD saved in child-labor-ban-brazil/DataWork/Datasets/Intermediate.
			
		
		**
		**	
		- 3. Setting up Paper Data.do 
		
			-> How long does it take to run?
				Less than one minute. 
	
			-> What it does?
				The code It creates the running variable of our study. 
				The code defines the same covariates used in the Bargain/Boutin Paper (2021) 'Minimum Age Regulation and Child Labor'. 
				Therefore, we can compare our and their sample sizes, as well as explain why some results differ. 
				
						
			-> What it It creates? 
				One .dta file named Child Labor Ban saved in: child-labor-ban-brazil/DataWork/Datasets/Final.
		
		
		**
		**	
		- 4. Descriptives.do 
		
			-> How long does it take to run?
				Few minutes. 
	
			-> What it does?
				It creates descriptives statistics and figures used in the paper. 
						
			-> What it It creates? 
				Figures saved in child-labor-ban-brazil/DataWork/Output/Figures.
		
		
		**
		**	
		- 5. Rdrobust
		
			-> How long does it take to run?
				Few minutes. 
	
			-> What it does?
				RD robust estimations.
						
			-> What it It creates? 
				Tables saved in child-labor-ban-brazil/DataWork/Output/Tables
				
					
		**
		**	
		- 6. Continuity Based Design  
	
			-> What it does?
				Continuity based approach estimates and runs multiple hyphotesis tests
						
			-> What it It creates? 
				Tables saved in child-labor-ban-brazil/DataWork/Output/Tables
				
		**
		**	
		- 7. RDD using Local Randomization 
	
			-> What it does?
				Local Randomization estimates. 
						
			-> What it It creates? 
				Tables and Figures saved in child-labor-ban-brazil/DataWork/Output
				
				
		
		**
		**	
		- Globals. 
		
		The code sets globals with: 
			- The short and long term outcomes of the analysis.
			- The variables used for balance checks between comparison and treatment groups.
			- The covariates used in the regression 	

			
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	Folder Structure
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		
		It is possible to reproduce all the analysis using only the codes available in GitHub. 
		
		Set up the folder structure:
		
			- Create the folder "child-labor-ban-brazil". 
				- inside this folder, create "DataWork"
					- inside "DataWork", create "Datasets" 
						- inside "Datasets", create 3 folders: "Raw", "Intermediate" and "Final" 
							- inside "Raw", create 16 folders for each PNAD wave. The folders need to be named: 1998, 1999, 2001
							  2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2011, 2012, 2013, 2014, 2015. 
					
					- inside "DataWork", create "Output" 
						- inside "Output", create 2 folders: "Tables" and "Figures". 
						
		For each wave, save the PNAD microdata in the respective folder. For example, for 1999 wave, save the .txt files in the folder:
		child-labor-ban-brazil->DataWork->Datasets->Raw->1999. 
		
		Make sure that the .txt files are saved with the following names:
				- 1998 -> Pessoa98.txt Domicilio98.txt
				- 1999 -> Pessoa99.txt Domicilio99.txt
				- 2001 -> PES2001.txt  DOM2001.txt
				- 2002 -> PES2002.txt  DOM2002.txt			
				- 2003 -> PES2003.txt  DOM2003.txt			
				- 2004 -> PES2004.txt  DOM2004.txt			
				- 2005 -> PES2005.txt  DOM2005.txt			
				- 2006 -> PES2006.txt  DOM2006.txt			
				- 2007 -> PES2007.txt  DOM2007.txt			
				- 2008 -> PES2008.txt  DOM2008.txt			
				- 2009 -> PES2009.txt  DOM2009.txt			
				- 2011 -> PES2011.txt  DOM2011.txt			
				- 2012 -> PES2012.txt  DOM2012.txt			
				- 2013 -> PES2013.txt  DOM2013.txt			
				- 2014 -> PES2014.txt  DOM2014.txt			
				- 2015 -> PES2015.txt  DOM2015.txt			
		
		After setting up the folder structure and saving Household Survey Microdata (in .txt files), 
		you can run the codes and reproduce all the results. 

	
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Installing Packages and Standardize Settings
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
	   
	  *Installing packages needed to run all dofiles called by this master dofile. */
		version 16   	
	   set more off, permanently 
	   local user_commands ietoolkit rdrobust mat2txt qqvalue somersd parmest matvsort estout sumstats unique
	   foreach command of local user_commands   {
		   cap which `command'
		   if _rc == 111 {
			   ssc install `command' 
		   }
	   }		
		
		
		**Local Randomization Inference, RD densitity and LP density Packages
		net install rdlocrand,  from(https://github.com/rdpackages/rdlocrand/tree/master/stata) replace
		net install rddensity,  from(https://github.com/rdpackages/rddensity/tree/master/stata) replace
		net install lpdensity,  from(https://github.com/nppackages/lpdensity/tree/master/stata) replace

		/*
		*MC Crary test
		sysdir  //locations
		copy https://eml.berkeley.edu/~jmccrary/DCdensity/DCdensity.ado  `"`c(sysdir_plus)'/DCdensity.ado"', public replace
		discard   // you have to discard to see installed adofiles
		which DCdensity
		*/
		
		  set sslrelax on 
		  copy https://eml.berkeley.edu/~jmccrary/DCdensity/DCdensity.ado  `"`c(sysdir_plus)'/DCdensity.ado"', public replace
		  set sslrelax off

		
		**DataZoom Package
		net install datazoom_social, from("https://raw.githubusercontent.com/datazoompuc/datazoom_social_stata/master/") force
		
		
		**Figure settings
		graph set window fontface "Times"
		set scheme s1mono
		
		**Others
		set matsize 11000
        set level   95
		set seed    740592
		
		clear all
		mata: mata clear 
		
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Preparing Folder Paths
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
	   * Users
	   * -------------------------*
	   * Vivian                  1    
	   * Next User               2    

	   *Set this value to the user currently using this file
	   global user  1
	   
	   **
	   * Root folder globals
	   * -------------------------*
	   if $user == 1 {
		   global projectfolder "C:\Users\wb495845\OneDrive - WBG\III. Labor\child-labor-ban-brazil"				//project file path in your computer
	   }
	   
	   **
	   * Project folder globals
	   * -------------------------*
	   global datawork         	"$projectfolder\DataWork"
	   global datasets         	"$datawork\Datasets"
	   global raw	           	"$datasets\Raw"
	   global inter				"$datasets\Intermediate"
	   global final            	"$datasets\Final" 
	   global tables			"$datawork\Output\Tables"
	   global figures			"$datawork\Output\Figures"
	   
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Setting up Globals
	**
	*--------------------------------------------------------------------------------------------------------------------------------*

		global shortterm_outcomes  		"eap pwork pwork_formal pwork_informal schoolatt study_only"	//short-term outcomes
		global longterm_outcomes   		"college_degree working pwork_formal wage_hour"											//long-term outcomes
		global dep_vars1 				D gap84 	  																			//linear model
		global dep_vars2 				D gap84 gap84_2																			//quadratic model
		global dep_vars3 				D 																						//without including the running variable, just the treatment dummy
		global covariates1 				region1 region2  white	mom_yrs_school																				//covariates Piza/Portela used for balance tests						
		global bargain_controls			region1 region2 region3 region4 		 color_bargain2 color_bargain5 hh_head_edu_bargain hh_head_male hh_head_age_bargain adults_income_bargain 		hh_size_bargain //Covariates used by Bargain/Boutin (2021) Paper
		global bargain_controls_our_def region1 region2 region3 region4 region5  white		    pardo		   hh_head_edu 		   hh_head_male hh_head_age		   		 				  		hh_size         //Covariates used by Bargain/Boutin (2021) Paper
		  
	   
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Setting up Globals
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		*do "$datawork/Do files/1. Importing HouseHold Survey (PNAD).do" YOU NEED TO DOWNLOAD THE PNAD WAVES IN .TXT FORMAT TO REPLICATE THIS CODE- SEE ABOVE.
		*do "$datawork/Do files/2. Harmonizing Household Survey (PNAD)" You need to run do file 1. before running this one.
		 do "$datawork/Do files/3. Setting up Paper Data.do" 
		 do "$datawork/Do files/4. Descriptives.do" 
		 do "$datawork/Do files/5. Rdrobust.do" 
		 do "$datawork/Do files/6. Continuity Based Design.do" 
		 do "$datawork/Do files/7. RDD using Local Randomization.do" 
