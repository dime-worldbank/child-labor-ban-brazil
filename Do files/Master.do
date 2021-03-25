
	*MASTER do file for Child Labor Ban Paper*
	*________________________________________________________________________________________________________________________________*

	*Author: Vivian Amorim
	*vivianamorim5@gmail.com


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
		ieboilstart, version(15)          	
		`r(version)' 
	   
		set scheme economist
		set matsize 11000
		graph set window fontface "Times"
        set level 95
		
		
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
		   global projectfolder	"/Users/vivianamorim/OneDrive/World Bank/Labor/Child Labor"
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
		do "$dofiles/1. Importing HouseHold Survey (PNAD).do"
		do "$dofiles/2. Harmonizing Household Survey (PNAD).do"
		do "$dofiles/3. Setting up Paper Data.do"
		do "$dofiles/4. Tables.do"
		do "$dofiles/5. Figures.do"
		
	
