/* 
Project: Measuring poverty in the EU: Investigating empirical validity of deprivation scales
			Part of the thesis submitted by Selçuk Bedük for a DPhil in Social Policy at University of Oxford
			Full thesis is available here: https://ora.ox.ac.uk/objects/uuid:22f61b32-32a3-4fb3-b0ce-67b1b8fe8c00 

Published paper: Bedük, S. (2020). Missing dimensions of poverty? Calibrating deprivation scales using perceived financial situation. European Sociological Review, 36(4), 562-579.

Author: Selçuk Bedük 

Date of code: 5 May 2018

Purpose: Constructing key variables 

Inputs: BHPS918_P3_FE.dta  (from Miss_D1_Keyvars, using BHPS Waves 9-18, Study Number (SN) 5151 from UK Data Service https://doi.org/10.5255/UKDA-SN-5151-2)

Outputs: financialef.csv
		interactions.csv
		thresholdcp.csv
		xtlogit.csv
		laggender.csv
		reverse.csv	
		Figure1.gph  
		Figure2.gph
*/


clear all
set more off
global dir "C:\DPhil_dataanalysis\BHPS\stata8"
cd "C:\DPhil_dataanalysis\BHPS\stata8"
use BHPS918_P3_FE.dta

tsset pid wave 
xtdes
sort pid wave


/*
foreach i in 17 16 15 14 13 12 11 10 9 { 
	replace lrwghtr=lrwghtr[_n+1] if wave==`i'
	}
*/

global htcare hhf hhh hhi hhk hhhealthst
global chcare nch02 nch34
global ltcare elder hhdisab hhscaidout
global edu nch511 nch1215 ttch1618 ttch1922
global control loginc rented mortgage unemployed divorced separated widowed
global dimensions bnst salst durst 
global personality pe*

// Descriptives
/*
tabstat sin mda $htcare $chcare $ltcare $edu expen earnings futworse $control wave peconsc peneuro if inmiss==0 & miss==0, stats(mean median sd min max) columns(stats) format(%9.3f)
tabstat sin smda mda mda1 poor60 if inmiss==0 & miss==0, by(wave) format(%9.2f)
ciplot sin smda mda mda1 poor60 if inmiss==0 & miss==0, by(wave) recast(connect) ylabel(0(0.05)0.3)
tetrachoric sin smda mda mda1 poor60 if inmiss==0 & miss==0
*/

// Missing descriptives 
/*
misstable sum sin mda $htcare $chcare $ltcare $edu expen earnings futworse $control wave peconsc peneuro
*/

		
/*
global htcare hhf hhh hhi hhhealthst
global chcare ch02 ch34
global ltcare elder hhdisab scaid
global edu ch511 ch1215 ch1618 ch1924 hhstud
global control loghhinc rented mortgage hhsize hhune divorced separated sp i.soclass i.isced
global control loginc rented mortgage unemployed divorced separated widowed i.isced
*/


// Correlated Random Effect Model
// financial effect pathway and controlling for state dependence and anticipation
// keep if wyear==9
eststo clear 
eststo Model1: xtreg sin $htcare $chcare $ltcare $edu $control $men i.wave female age age2 if miss==0 & wave>wavefirst, re vce(robust)
eststo Model2: xtreg sin mda $htcare $chcare $ltcare $edu $control $men i.wave female age age2 men_mda if miss==0 & wave>wavefirst, re vce(robust)
eststo Model3: xtreg sin mda $htcare $chcare $ltcare $edu $control $men i.wave female age age2 men_mda Lsin sin1 if miss==0 & wave>wavefirst, re vce(robust)
eststo Model4: xtreg sin mda $htcare $chcare $ltcare $edu $control $men i.wave female age age2 men_mda Lsin sin1 futworse if miss==0 & wave>wavefirst, re vce(robust)
eststo Model5: xtreg sin mda $htcare $chcare $ltcare $edu $control $men i.wave female age age2 men_mda Lsin sin1 futworse expen if miss==0 & wave>wavefirst, re vce(robust)
eststo Model6: xtreg sin mda $htcare $chcare $ltcare $edu $control $men i.wave female age age2 men_mda Lsin sin1 futworse earnings if miss==0 & wave>wavefirst, re vce(robust)
eststo Model7: xtreg sin mda $htcare $chcare $ltcare $edu $control $men i.wave female age age2 men_mda Lsin sin1 futworse expen earnings if miss==0 & wave>wavefirst, re vce(robust)
esttab,   ///
	nonumbers mtitle wide compress b(3) se(3) star ///
   legend label varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))	
	
esttab using financialef.csv, replace   ///
	nonumbers mtitle wide compress b(3) se(3) star ///
   legend label varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))	


	
// PSYCHOLOGICAL NEGATIVITY BIAS 	
// personality interactions 

foreach x in hhh hhi hhk hhhealthst nch02 hhdisab ttch1922 {
	gen ne`x'=peneuro*`x'
	bysort pid: egen mne`x'= mean(ne`x')
	gen co`x'=peconsc*`x'
	bysort pid: egen mco`x'=mean(co`x')
	gen op`x'=peopen*`x'
	bysort pid: egen mop`x'=mean(op`x')
}

global htcare i.hhf i.hhh i.hhi i.hhk i.hhhealthst
global chcare nch02 nch34
global ltcare i.elder i.hhdisab i.hhscaidout
global edu nch511 nch1215 ttch1618 ttch1922
global control loginc i.rented i.mortgage i.unemployed i.divorced i.separated i.widowed 
global dimensions bnst salst durst 
global personality pe*

// Neuroticism
eststo clear 
eststo: xtreg sin $htcare $chcare $ltcare $edu $control $men i.wave i.female age age2 mda men_mda i.Lsin i.sin1 i.futworse i.hhh##c.peneuro mnehhh if miss==0 & wave>wavefirst, re vce(robust)
eststo: xtreg sin $htcare $chcare $ltcare $edu $control $men i.wave i.female age age2 mda men_mda i.Lsin i.sin1 i.futworse i.hhi##c.peneuro mnehhi if  miss==0 & wave>wavefirst, re vce(robust)
eststo: xtreg sin $htcare $chcare $ltcare $edu $control $men i.wave i.female age age2 mda men_mda i.Lsin i.sin1 i.futworse i.hhk##c.peneuro mnehhk if  miss==0 & wave>wavefirst, re vce(robust)
eststo: xtreg sin $htcare $chcare $ltcare $edu $control $men i.wave i.female age age2 mda men_mda i.Lsin i.sin1 i.futworse i.hhhealthst##c.peneuro mnehhhealthst if miss==0 & wave>wavefirst, re vce(robust)
eststo: xtreg sin $htcare $chcare $ltcare $edu $control $men i.wave i.female age age2 mda men_mda i.Lsin i.sin1 i.futworse c.nch02##c.peneuro mnench02 if miss==0 & wave>wavefirst, re vce(robust)
eststo: xtreg sin $htcare $chcare $ltcare $edu $control $men i.wave i.female age age2 mda men_mda i.Lsin i.sin1 i.futworse i.hhdisab##c.peneuro mnehhdisab if miss==0 & wave>wavefirst, re vce(robust)
eststo: xtreg sin $htcare $chcare $ltcare $edu $control $men i.wave i.female age age2 mda men_mda i.Lsin i.sin1 i.futworse c.ttch1922##c.peneuro mnettch1922 if miss==0 & wave>wavefirst, re vce(robust)
esttab,   ///
	nonumbers mtitle wide compress b(3) se(3) star ///
   legend label varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))	

// Conscentiousness
eststo: xtreg sin $htcare $chcare $ltcare $edu $control $men i.wave i.female age age2 i.mda men_mda i.Lsin i.sin1 i.futworse mcohhi mnehhi i.hhi##c.peneuro##c.peconsc if miss==0 & wave>wavefirst, re vce(robust)
margins, dydx(hhi) at(peneuro=(1(1)5) peconsc=(2(2)6)) post
marginsplot, noci ylabel(-0.01(0.01)0.04) name(anxiety)

eststo: xtreg sin $htcare $chcare $ltcare $edu $control $men i.wave i.female age age2 i.mda men_mda i.Lsin i.sin1 i.futworse mcohhk mnehhk i.hhk##c.peneuro##c.peconsc if miss==0 & wave>wavefirst, re vce(robust)
margins, dydx(hhk) at(peneuro=(1(1)5) peconsc=(2(2)6)) post
marginsplot, noci name(epilepsy, replace) ylabel(-0.03(0.03)0.12)

grc1leg anxiety epilepsy, name(Figure2, replace)
graph export Figure2.gph

esttab using interactions.csv, replace   ///
	nonumbers mtitle wide compress b(3) se(3) star ///
   legend label varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))	

// Predicted probabilities of each dimensions 

xtreg sin i.mda $htcare $chcare $ltcare $edu $control $men i.wave i.female age age2 men_mda i.Lsin i.sin1 i.futworse if  miss==0 & wave>wavefirst, re vce(robust)
predict yhat

xtreg sin i.mda $htcare $chcare $ltcare $edu $control $men i.wave i.female age age2 men_mda i.Lsin i.sin1 i.futworse if  miss==0 & wave>wavefirst & yhat>0, re vce(robust)
eststo base: margins, at(mda=0 nch02=0 nch34=0 nch1215=0 ttch1922=0 hhh=0 hhi=0 hhhealthst=0 elder=0 hhdisab=0) post 
xtreg sin i.mda $htcare $chcare $ltcare $edu $control $men i.wave i.female age age2 men_mda i.Lsin i.sin1 i.futworse if  miss==0 & wave>wavefirst & yhat>0, re vce(robust)
eststo eldhhh: margins, at(hhh=1 elder=1 mda=0) post
xtreg sin i.mda $htcare $chcare $ltcare $edu $control $men i.wave i.female age age2 men_mda i.Lsin i.sin1 i.futworse if  miss==0 & wave>wavefirst & yhat>0, re vce(robust)
eststo depress: margins, at(hhi=1 mda=0) post
xtreg sin i.mda $htcare $chcare $ltcare $edu $control $men i.wave i.female age age2 men_mda i.Lsin i.sin1 i.futworse if  miss==0 & wave>wavefirst & yhat>0, re vce(robust)
eststo kids: margins, at(nch02=1 nch34=1 ttch1922=1 mda=0) post
xtreg sin i.mda $htcare $chcare $ltcare $edu $control $men i.wave i.female age age2 men_mda i.Lsin i.sin1 i.futworse if  miss==0 & wave>wavefirst & yhat>0, re vce(robust)
eststo diss: margins, at(hhdisab=1 mda=0) post
xtreg sin i.mda $htcare $chcare $ltcare $edu $control $men i.wave i.female age age2 men_guiost3 i.Lsin i.sin1 i.futworse if  miss==0 & wave>wavefirst & yhat>0, re vce(robust)
eststo all: margins, at(nch02=1 ttch1922=1 hhh=1 hhi=1 hhhealthst=1 hhdisab=1 mda=0) post
xtreg sin i.mda $htcare $chcare $ltcare $edu $control $men i.wave i.female age age2 men_mda i.Lsin i.sin1 i.futworse if  miss==0 & wave>wavefirst & yhat>0, re vce(robust)
eststo dep: margins, at(mda=1 nch02=0 ttch1922=0 hhh=0 hhi=0 hhhealthst=0 hhdisab=0) post
coefplot base kids depress eldhhh diss all dep, vertical ylabel(0(0.03)0.21) scheme(s1manual) name(Figure1, replace)
graph export Figure1.gph


// SENSITIVITY ANAYLSIS - DIFFERENT THRESHOLDS FOR FINANCIAL ADEQUACY
eststo clear  
eststo Model1: xtreg sint1 $htcare $chcare $ltcare $edu $control $men i.wave female age age2 mda men_mda Lsint1 sint11 futworse if miss==0 & wave>wavefirst, re vce(robust)
eststo Model2: xtreg sint3 $htcare $chcare $ltcare $edu $control $men i.wave female age age2 mda men_mda Lsint3 sint33 futworse if miss==0 & wave>wavefirst, re vce(robust)
esttab, ///
	nonumbers mtitle wide compress b(3) se(3) star ///
   legend label mlabels(quitedifficult gettingby) varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))	
	
	
// SENSITIVITY ANALYSIS - DEPRIVATION THRESHOLDS AND OTHER MEASURES 
eststo clear 
eststo Model2: xtreg sin $htcare $chcare $ltcare $edu $control $men i.wave female age age2 smda men_smda Lsin sin1 futworse if miss==0 & wave>wavefirst, re vce(robust)
eststo Model3: xtreg sin $htcare $chcare $ltcare $edu $control $men i.wave female age age2 mda men_mda Lsin sin1 futworse if miss==0 & wave>wavefirst , re vce(robust)
eststo Model4: xtreg sin $htcare $chcare $ltcare $edu $control $men i.wave female age age2 mda1 men_guiost1 Lsin sin1 futworse if miss==0 & wave>wavefirst, re vce(robust)
eststo Model5: xtreg sin $htcare $chcare $ltcare $edu $control $men i.wave female age age2 mda0 men_guiost0 Lsin sin1 futworse if miss==0 & wave>wavefirst, re vce(robust)
eststo Model6: xtreg sin $htcare $chcare $ltcare $edu $control $men i.wave female age age2 $dimensions $depmen Lsin sin1 futworse if miss==0 & wave>wavefirst, re vce(robust)
eststo Model7: xtreg sin $htcare $chcare $ltcare $edu $control $men i.wave female age age2 dep_cpst2 men_cpst2 Lsin sin1 futworse if miss==0 & wave>wavefirst, re vce(robust)
eststo Model8: xtreg sin $htcare $chcare $ltcare $edu $control $men i.wave female age age2 dep_eu2020 men_eu2020 Lsin sin1 futworse if miss==0 & wave>wavefirst, re vce(robust)
esttab,   ///
	nonumbers mtitle wide compress b(3) se(3) star ///
   legend label mlabels(GUIO3 GUIO2 GUIO1 GUIO0 DIM CP2 EU2020) varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))	
	
esttab using thresholdcp.csv, replace   ///
	nonumbers mtitle wide compress b(3) se(3) star ///
   legend label mlabels(GUIO3 GUIO2 GUIO1 GUIO0 DIM CP2 EU2020) varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))	

// SENSITIVITY ANALYSIS - XTLOGIT 
eststo clear
eststo Model1: xtprobit sin $htcare $chcare $ltcare $edu $control $men i.wave female age age2 mda men_mda Lsin sin1 futworse if miss==0 & wave>wavefirst, re vce(robust)
eststo Model2: xtlogit sin $htcare $chcare $ltcare $edu $control $men i.wave female age age2 mda men_mda Lsin sin1 futworse if miss==0 & wave>wavefirst, re vce(robust) 
esttab using xtlogit.csv, replace   ///
	nonumbers mtitle wide compress b(3) se(3) star ///
   legend label varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))	


// SENSITIVITY ANALYSIS - LAGS / MEN vs WOMEN
global levar lag_hhf lag_hhh lag_hhi lag_hhk lag_hhhealthst lag_nch02 lag_nch34 lag_elder lag_hhdisab lag_hhscaidout lag_nch511 lag_nch1215 lag_ttch1618 lag_ttch1922 
eststo clear 
eststo Model1: xtreg sin $htcare $chcare $ltcare $edu $control $men i.wave female age age2 mda men_mda Lsin sin1 futworse if miss==0 & wave>wavefirst, re vce(robust)
eststo Model2: xtreg sin $htcare $chcare $ltcare $edu $control $men i.wave female age age2 mda men_mda $levar if miss==0 & wave>wavefirst, re vce(robust)
eststo Model3: xtreg sin $htcare $chcare $ltcare $edu $control $men i.wave female age age2 mda men_mda Lsin sin1 futworse if miss==0 & wave>wavefirst & female==1, re vce(robust)
eststo Model4: xtreg sin $htcare $chcare $ltcare $edu $control $men i.wave female age age2 mda men_mda Lsin sin1 futworse if miss==0 & wave>wavefirst & female==0, re vce(robust)

esttab,   ///
	nonumbers mtitle wide compress b(3) se(3) star ///
   legend label varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))	

esttab using laggender.csv,  replace ///
	nonumbers mtitle wide compress b(3) se(3) star ///
   legend label mlabels(Norm LAGS FEMALE MALE) varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))	
		

// REVERSE CAUSALITY 
eststo clear 
eststo Model2: xtreg mda sin Lsin futworse $htcare $chcare $ltcare $edu $control men_sin $men i.wave female age age2 if miss==0 & wave>wavefirst , re vce(robust)
eststo Model3: xtreg mda sin Lsin futworse expen $htcare $chcare $ltcare $edu $control men_sin $men i.wave female age age2 if miss==0 & wave>wavefirst, re vce(robust)
eststo Model4: xtreg mda sin Lsin futworse earnings $htcare $chcare $ltcare $edu $control men_sin $men i.wave female age age2 if miss==0 & wave>wavefirst, re vce(robust)
eststo Model5: xtreg mda sin Lsin futworse expen earnings $htcare $chcare $ltcare $edu $control men_sin $men i.wave female age age2 if miss==0 & wave>wavefirst, re vce(robust)
esttab,   ///
	nonumbers mtitle wide compress b(3) se(3) star ///
   legend label varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))	
		
esttab using reverse.csv,  replace ///
	nonumbers mtitle wide compress b(3) se(3) star ///
   legend label varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))	
		
