/* 
Project: Measuring poverty in the EU: Investigating empirical validity of deprivation scales
			Part of the thesis submitted by Selçuk Bedük for a DPhil in Social Policy at University of Oxford
			Full thesis is available here: https://ora.ox.ac.uk/objects/uuid:22f61b32-32a3-4fb3-b0ce-67b1b8fe8c00 

Published paper: Bedük, S. (2020). Missing dimensions of poverty? Calibrating deprivation scales using perceived financial situation. European Sociological Review, 36(4), 562-579.

Author: Selçuk Bedük 

Date of code: 5 May 2018

Purpose:  Master file 
		1. Merging and constructing data  
		2. Constructing key variables 
		3. Running analysis  
		4. Running appendix 

Inputs: Do files 

Outputs: financialef.csv
		interactions.csv
		thresholdcp.csv
		xtlogit.csv
		laggender.csv
		reverse.csv	
		Figure1.gph  
		Figure2.gph
		financialvsbias.csv
		menwomen.csv
		withinbetweenboot.csv
		interactionsconsc.csv
*/

///  

clear all
set more off
capture log close
cd "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\Working files"
global codedir "C:\Users\selcuk.beduk\Dropbox\Research\Code\Missing dimensions"

run "${codedir}\Beduk2018_Miss_D1_Dataprep.do"
run "${codedir}\Beduk2018_Miss_D2_Keyvars.do"
run "${codedir}\Beduk2018_Miss_D3_Analysis.do"
run "${codedir}\Beduk2018_Miss_D4_Appendix.do"
