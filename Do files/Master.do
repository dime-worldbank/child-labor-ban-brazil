/*

	*MASTER do file for Child Labor Ban Paper*
	*________________________________________________________________________________________________________________________________* 
	
	Author: Vivian Amorim
	vivianamorim5@gmail.com/vamorim@worldbank.org
	Last Update: April 2021
	
	**
	**
	Short and Long-term effects of a Child Labor Ban in Brazil. 
	**
	
	In December 15th 1998, the Brazilian Federal Government increased the minimum age of employement
	from 14 to 16 years old. Children that were already employed were not affected. 
	We employed a regression discontinuity design to explore the effects of this policy.
	
	Our Running variable (zw) is equal to 0 if the children was born after December 15th 1984, therefore, turned 14
	after the law changed. zw = 1 if the children turned 14 one week after the law changed, zw = 2 if she/he turned
	14 two weeks after the law changed, so on. zw = - 1 if the children turned 14 one week before the law changed,
	zw = -2 if she/he turned 14 two weeks before the law changed, and so on. 
	
	We used the Brazilian Household Survey (Pesquisa Nacional por Amostra de Domicílios, PNAD) to assess the effect
	of the policy on the following outcomes:
	
		- Economically Active Population.
		- Share of children in paid jobs.
		- Share of children in unpaid jobs.
		- School attendance. 
		- Wages. 
			
	We used the PNAD from 1998 to 2015, except 2000 and 2010, years of the Demographic Census. 
	
	This master do file runs the following codes: 
		
		**
		**
		- 1. Importing Household Survey (PNAD).do
		
			-> How long it takes to run? 
				12 minutes. 
	
			-> What it does?
				The code imports the microdata of the Brazilian Household Survey. 
				The raw data in .txt is saved in the project folder: 6child-labor-ban-brazil/DataWork/Datasets/Raw
				
				From 1998 to 2014, we used the DataZoom tool created by PUC/RIO University to import the data without having to manually create
				the dictionary of the variables. 
				
				For 2015, we created our own dictionary due to an error we identified in the tool. 
				
						
			-> What it creates? 
				The code creates sixteen .dta files saved in: child-labor-ban-brazil/DataWork/Datasets/Intermediate. 
				Each file is a wave of the survey. 
				
			
		**
		**	
		- 2. Harmonizing Household Survey (PNAD).do
		
			-> How long it takes to run?
				23 minutes. 
	
			-> What it does?
				The code harmonizes the PNAD waves from 1998 to 2015, creating the dependent and independent variables of our analysis. 			
						
			-> What it creates? 
				One .dta file named Pooled_PNAD saved in child-labor-ban-brazil/DataWork/Datasets/Intermediate.
			
		
		**
		**	
		- 3. Setting up Paper Data.do 
		
			-> How long it takes to run?
				Less than one minute. 
	
			-> What it does?
				The code creates the running variable of our study. 
				The cutoff is 0 if the children was born in December 16th 1994. We have the running variable specified in weeks (as defined 
				above), months or days. 
						
			-> What it creates? 
				One .dta file named Child Labor Ban saved in: child-labor-ban-brazil/DataWork/Datasets/Final.
		
		**
		**	
		- Globals. 
		
		The code specifies: 
			- The short and long term outcomes of the analysis.
			- The variables used for balance checks between control and treatment groups.
			- The dependent variables used in the regression. 
		

	
	*/

   * PART 0:  INSTALL PACKAGES AND STANDARDIZE SETTINGS
   *________________________________________________________________________________________________________________________________*
	   * - Install packages needed to run all dofiles called by this master dofile. 	 
	   *(Note that this never updates outdated versions of already installed commands, to update commands use adoupdate)
	   * - Use ieboilstart to harmonize settings across users
	 
	   local user_commands ietoolkit labutil   
	   foreach command of local user_commands  {
		   cap which `command'
		   if _rc == 111 {
			   ssc install `command'
		   }
	   }
		net install rdlocrand, from(https://raw.githubusercontent.com/rdpackages/rdlocrand/master/stata) replace
		net from http://www.econ.puc-rio.br/datazoom/portugues  
		ieboilstart, version(15)          	
		`r(version)' 
	   
		set scheme economist
		set matsize 11000
		graph set window fontface "Times"
        set level 95
		set seed 108474
		
		
   * PART 1:  PREPARING FOLDER PATH GLOBALS
   *________________________________________________________________________________________________________________________________*
	   * Users
	   * -----------
	   * Vivian                  1    
	   * Next User               2    

	   *Set this value to the user currently using this file
	   global user  1

	   * Root folder globals
	   * ---------------------
	   if $user == 1 {
		   global dofiles       "/Users/vivianamorim/Documents/GitHub/child-labor-ban-brazil/Do files"
		   global projectfolder	"/Users/vivianamorim/OneDrive/world-bank/Labor/child-labor-ban-brazil"		//Do not use folder's names with spaces, for example "World Bank" 
	   }

	   if $user == 2 {
		   global projectfolder ""  
	   }
	   
	   * Project folder globals
	   * ---------------------
	   global datawork         	"$projectfolder/DataWork"
	   global datasets         	"$datawork/Datasets"
	   global raw	           	"$datasets/Raw"
	   global inter				"$datasets/Intermediate"
	   global final            	"$datasets/Final" 
	   global tables			"$datawork/Output/Tables"
	   global figures			"$datawork/Output/Figures"
	   
   
   * PART 2:  SETTING UP GLOBALS
   *________________________________________________________________________________________________________________________________*
		do "$dofiles/Globals.do"
		  
	 
/*
   * PART 3:  RUN DOFILES CALLED BY THIS MASTER DOFILE
   *________________________________________________________________________________________________________________________________*
		do "$dofiles/1. Importing Household Survey (PNAD).do"
		do "$dofiles/2. Harmonizing Household Survey (PNAD).do"
		do "$dofiles/3. Setting up Paper Data.do"
		do "$dofiles/4. Tables.do"
		do "$dofiles/5. Figures.do"
		
	
