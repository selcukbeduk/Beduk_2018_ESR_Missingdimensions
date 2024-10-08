
/* 
Project: Measuring poverty in the EU: Investigating empirical validity of deprivation scales
			Part of the thesis submitted by Selçuk Bedük for a DPhil in Social Policy at University of Oxford
			Full thesis is available here: https://ora.ox.ac.uk/objects/uuid:22f61b32-32a3-4fb3-b0ce-67b1b8fe8c00 

Published paper: Bedük, S. (2020). Missing dimensions of poverty? Calibrating deprivation scales using perceived financial situation. European Sociological Review, 36(4), 562-579.

Author: Selçuk Bedük 

Date of code: 5 May 2018

Purpose: Constructing key variables 

Inputs: BHPS918_P3_FE.dta  (from Miss_D1_Keyvars, using BHPS Waves 9-18, Study Number (SN) 5151 from UK Data Service https://doi.org/10.5255/UKDA-SN-5151-2)

Outputs: financialvsbias.csv
		menwomen.csv
		withinbetweenboot.csv
		interactionsconsc.csv
*/



clear all
set more off
global dir "C:\DPhil_dataanalysis\BHPS\stata8"
cd "C:\DPhil_dataanalysis\BHPS\stata8"
use BHPS918_P3_FE.dta

tsset pid wave 
xtdes
bysort pid: gen wyear= [_N]

keep if wyear==10  // 10 year balanced panel 

sort pid wave
foreach i in 17 16 15 14 13 12 11 10 9 { 
	replace lrwghtr=lrwghtr[_n+1] if wave==`i'
	}
global htcare hhc hhf hhh hhi hhl 
global chcare ch02 
global ltcare scaid hhdisab hhdomestic 
global edu hhstud hhcolkid
global control hhune loghhinc divorced 
global housing mortgage rented 
global dimensions bnst salst durst 
global personality pe*


misstable summarize $htcare $chcare $ltcare $edu $housing $control $personality isced expen earnings futworse guiost3

gen miss=0	
foreach x of varlist $htcare $chcare $ltcare $edu $housing $control $personality {
	replace miss=1 if `x'==.
	}
replace miss=1 if sin==. | isced==. | expen==. | earnings==. | futworse==. | guio==.

keep if miss==0
bysort pid: gen xyear= [_N]
keep if xyear==10

	

// Type I and II error over time 
tab poor60 wave [aw=xhwght] , col 
gen typei=(sin==0 & guiost3==1)
gen typeii=(sin==1 & guiost3==0)
gen typeI=(sin==0 & guiost2==1)
gen typeII=(sin==1 & guiost2==0)

// DESCRIPTIVES 

separate sin, by(sex==1)
collapse guiost2 guiost3 sin sin0 sin1 hhdisab scaid hhstud ch02 ch34 typei typeii typeI typeII, by(wave)
line sin0 sin1 wave, xlabel(8(1)18) scheme(s2mono)
line sin guiost2 guiost3 wave, xlabel(8(1)18) scheme(s2mono)
line hhdisab hhstud scaid wave, xlabel(8(1)18) scheme(s2mono)
line typei typeii typeI typeII wave, xlabel(8(1)18) scheme(s2mono)
bysort pid : egen sdsin= sd(sin) 
gen varsin=sdsin^2

// Fixed effect logit - reporting semielasticities

global htcare i.hha-hhl 
global chcare i.ch02 i.ch34 
global ltcare i.scaid i.hhdisab i.elder
global edu i.hhstud
global control i.hhune loghhinc i.divorced i.sp hhsize i.isced i.wave 
global housing i.house  
global dimensions i.bnst i.salst i.durst 

eststo clear 
eststo: aextlogit sin i.guiost3 $htcare $ltcare $chcare $edu $housing $control [iweight=lrwghtr] if wyear==10
eststo: aextlogit sin i.guiost2 $htcare $ltcare $chcare $edu $housing $control [iweight=lrwghtr] if wyear==10
eststo: aextlogit sin i.guiost1 $htcare $ltcare $chcare $edu $housing $control [iweight=lrwghtr] if wyear==10
eststo: aextlogit sin $dimensions $htcare $ltcare $chcare $edu $housing $control [iweight=lrwghtr] if wyear==10
esttab, cells(b(star fmt(2)) se(par fmt(2))) ///
   legend label mtitles(balanced unbalanced) varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))
eststo: aextlogit sin i.guiost3 $htcare $ltcare $chcare $edu $housing $control if wyear==10, vce(boot)
eststo: aextlogit sin i.guiost3 $htcare $ltcare $chcare $edu $housing $control if wyear==10 [aw=lrwghtr], vce(boot, rep(200) seed(10101))


// Comparisons between models
eststo clear 
eststo: xtreg sin guiost3 $htcare $ltcare $chcare $edu $housing $control i.isced i.wave, fe vce(robust)					// fixed-effect lpm
eststo: xtreg sin guiost3 $htcare $ltcare $chcare $edu $housing $control i.isced i.wave [pw=lrwghtr], fe vce(robust)	// fixed-effect lpm weighted
eststo: xtreg sin d_guiost3 $dem $men i.isced i.wave i.sex age, re vce(robust)											// within-between estimator 
eststo: xtreg sin d_guiost3 $dem $men i.isced i.wave i.sex age, re vce(boot, seed(12))									// within-between estimator 
eststo: xtreg sin d_guiost3 $dem $men $ll i.isced i.wave i.sex age, re vce(boot, seed(11))								// within-between estimator with lagged significant variables
eststo: xtreg sin d_guiost3 $dem $men $ll i.isced i.wave i.sex age, re vce(robust)										// within-between estimator with lagged significant variables
eststo: xtreg sin d_guiost3 $dem $men $ll i.isced i.wave i.sex age [pw=lrwghtr], re vce(boot, seed(11))					// within-between estimator with lagged significant variables

eststo: xtreg sin i.guiost3 $htcare $ltcare $chcare $edu $housing $control $ll, fe vce(robust)							// fixed-effect lpm with lagged significant variables
eststo: xtreg sin i.guiost3 $htcare $ltcare $chcare $edu $housing $control $ll [pw=lrwghtr], fe vce(robust)				// fixed-effect lpm with lagged significant variables weighted
eststo: xtreg sin i.guiost3 $htcare $ltcare $chcare $edu $housing $control $lvar [pw=lrwghtr], fe vce(robust)			// fixed-effect lpm with lagged all variables weighted

esttab, cells(b(star fmt(3)) se(par fmt(2))) ///
   legend label varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))

	
// Financial effect pathway and controlling for future expectations
// fixed effect 
eststo clear 
eststo Model1: xtreg sin guiost3 $htcare $chcare $ltcare $edu $housing $control i.isced i.wave, fe vce(robust)
eststo Model2: xtreg sin guiost3 $htcare $chcare $ltcare $edu $housing $control i.isced i.wave expen, fe vce(robust)
eststo Model3: xtreg sin guiost3 $htcare $chcare $ltcare $edu $housing $control i.isced i.wave earnings, fe vce(robust)
eststo Model4: xtreg sin guiost3 $htcare $chcare $ltcare $edu $housing $control i.isced i.wave expen earnings, fe vce(robust)
eststo Model5: xtreg sin guiost3 $htcare $chcare $ltcare $edu $housing $control i.isced i.wave expen earnings futworse, fe vce(robust)
eststo Model6: xtreg sin guiost3 $htcare $chcare $ltcare $edu $housing $control i.isced i.wave finance futworse, fe vce(robust)
eststo Model7: xtreg sin guiost3 $htcare $chcare $ltcare $edu $housing $control i.isced i.wave i.finance i.finance#c.peneuro, fe vce(robust)
eststo Model8: xtreg sin guiost3 $htcare $chcare $ltcare $edu $housing $control i.isced i.wave i.finance i.finance#c.peconsc, fe vce(robust)
esttab using financialvsbias.csv, replace   ///
	nonumbers mtitle wide compress b(3) se(3) star ///
   legend label varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))
	

// Different thresholds and index specifications 
eststo clear 
eststo Model1: xtreg sin guiost3 $htcare $chcare $ltcare $edu $housing $control i.isced i.wave, fe vce(robust)
eststo Model2: xtreg sin guiost2 $htcare $chcare $ltcare $edu $housing $control i.isced i.wave, fe vce(robust)
eststo Model3: xtreg sin guiost1 $htcare $chcare $ltcare $edu $housing $control i.isced i.wave, fe vce(robust)
eststo Model4: xtreg sin cpst3 $htcare $chcare $ltcare $edu $housing $control i.isced i.wave, fe vce(robust)
eststo Model5: xtreg sin cpst2 $htcare $chcare $ltcare $edu $housing $control i.isced i.wave, fe vce(robust)
eststo Model6: xtreg sin $dimensions $htcare $chcare $ltcare $edu $housing $control i.isced i.wave, fe vce(robust)
esttab,   ///
	nonumbers mtitle wide compress b(3) se(3) star ///
   legend label varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))
	
	
// Lags and leads
eststo clear 
eststo Model1: xtreg sin guiost3 $htcare $chcare $ltcare $edu $housing $control i.isced i.wave, fe vce(robust)
eststo Model2: xtreg sin guiost3 $htcare $chcare $ltcare $edu $housing $control i.isced i.wave $lead, fe vce(robust)
eststo Model3: xtreg sin guiost3 $htcare $chcare $ltcare $edu $housing $control i.isced i.wave $lvar, fe vce(robust)
esttab,   ///
	nonumbers mtitle wide compress b(3) se(3) star ///
   legend label varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))


// Men and women 
eststo clear 
eststo Model1: xtreg sin guiost3 $htcare $chcare $ltcare $edu $housing $control i.isced i.wave, fe vce(robust)
eststo Model2: xtreg sin guiost3 $htcare $chcare $ltcare $edu $housing $control i.isced i.wave if female==1, fe vce(robust)
eststo Model3: xtreg sin guiost3 $htcare $chcare $ltcare $edu $housing $control i.isced i.wave if female==0, fe vce(robust)
esttab using menwomen.csv, replace   ///
	nonumbers mtitle wide compress b(3) se(3) star ///
   legend label varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))

	
// fixed effect LPM - bootstrap
eststo clear 
eststo: xtreg sin guiost3 $htcare $chcare $ltcare $edu $housing $control i.isced i.wave, fe vce(boot, rep(200) seed(1010))
esttab, cells(b(star fmt(3)) se(par fmt(2))) ///
   legend label varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))
esttab using withinbetweenboot.csv, replace cells(b(star fmt(3)) se(par fmt(2))) ///
   legend label varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))


xtreg sin $dem $men i.isced i.wave i.female age age2 $personality dep_guiost3 men_guiost3 i.finance i.futworse i.finance#c.peneuro mnefinance, re vce(robust)
eststo fineu: margins, dydx(finance) at(peneuro=(0(1)6)) post
marginsplot, ytitle("Average marginal effect") xtitle("Neuroticism") ylabel(0.5(0.1)1) legend(rows(1)) noci scheme(s1mono) name(neuro, replace)

xtreg sin $dem $men i.isced i.wave i.female age age2 $personality dep_guiost3 men_guiost3 i.finance i.futworse i.finance#c.peconsc mcofinance, re vce(robust)
eststo ficon: margins, dydx(finance) at(peconsc=(0(1)6)) post
marginsplot, ytitle("Average marginal effect") xtitle("Conscientiousness") ylabel(0.5(0.1)1) legend(rows(1)) noci scheme(s1mono) name(consc, replace)
graph combine neuro consc, name(conscm, replace)


coefplot fineu, vertical recast(connected) ylabel(0.5(0.1)1) ytitle("Average marginal effect") xtitle("Neuroticism") noci nooffsets scheme(s1mono) name(neufin, replace)
coefplot ficon, vertical recast(connected) ylabel(0.5(0.1)1) ytitle("Average marginal effect") xtitle("Conscientiousness") noci nooffsets scheme(s1mono) name(confin, replace)
grc1leg neufin confin


// Conscentiousness
eststo clear 
eststo: xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female age age2 guiost3 men_guiost3 $personality i.hhf#c.peconsc mcohhf, re vce(robust)
eststo: xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female age age2 guiost3 men_guiost3 $personality i.hhh#c.peconsc mcohhh, re vce(robust)
eststo: xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female age age2 guiost3 men_guiost3 $personality i.hhi#c.peconsc mcohhi, re vce(robust)
eststo: xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female age age2 guiost3 men_guiost3 $personality i.hhcolkid#c.peconsc mcohhcolkid, re vce(robust)
eststo: xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female age age2 guiost3 men_guiost3 $personality i.ch02#c.peconsc mcoch02, re vce(robust)
eststo: xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female age age2 guiost3 men_guiost3 $personality i.scaid#c.peconsc mcoscaid, re vce(robust)
eststo: xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female age age2 guiost3 men_guiost3 $personality i.hhdomestic#c.peconsc mcohhdomestic, re vce(robust)
eststo: xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female age age2 guiost3 men_guiost3 $personality i.hhdisab#c.peconsc mcohhdisab, re vce(robust)
eststo: xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female age age2 guiost3 men_guiost3 $personality i.hhune#c.peconsc mcohhune, re vce(robust)
eststo: xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female age age2 guiost3 men_guiost3 $personality i.divorced#c.peconsc mcodivorced, re vce(robust)

esttab using interactionsconsc.csv, replace   ///
	nonumbers mtitle wide compress b(3) se(3) star ///
   legend label varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))	

 // Conscentiousness
  xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female age age2 guiost3 men_guiost3 $personality i.hhf#c.peconsc mcohhf, re vce(robust)
  eststo chhf: margins, dydx(hhf) at(peconsc=(0(1)4)) post
  xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female age age2 guiost3 men_guiost3 $personality i.hhh#c.peconsc mcohhh, re vce(robust)
  eststo chhh: margins, dydx(hhh) at(peconsc=(0(1)4)) post
  xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female age age2 guiost3 men_guiost3 $personality i.hhi#c.peconsc mcohhi, re vce(robust)
  eststo chhi: margins, dydx(hhi) at(peconsc=(0(1)4)) post
  xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female age age2 guiost3 men_guiost3 $personality i.hhcolkid#c.peconsc mcohhcolkid, re vce(robust)
  eststo ccolkid: margins, dydx(hhcolkid) at(peconsc=(0(1)4)) post
  xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female age age2 guiost3 men_guiost3 $personality i.ch02#c.peconsc mcoch02, re vce(robust)
  eststo cch02: margins, dydx(ch02) at(peconsc=(0(1)4)) post
  xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female age age2 guiost3 men_guiost3 $personality i.scaid#c.peconsc mcoscaid, re vce(robust)
  eststo cscaid: margins, dydx(scaid) at(peconsc=(0(1)4)) post
    xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female age age2 guiost3 men_guiost3 $personality i.hhdomestic#c.peconsc mcohhdomestic, re vce(robust)
  eststo cdom: margins, dydx(hhdomestic) at(peconsc=(0(1)4)) post
    xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female age age2 guiost3 men_guiost3 $personality i.hhdisab#c.peconsc mcohhdisab, re vce(robust)
  eststo cdis: margins, dydx(hhdisab) at(peconsc=(0(1)4)) post
  xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female age age2 guiost3 men_guiost3 $personality i.hhune#c.peconsc mcohhune, re vce(robust)
  eststo chhune: margins, dydx(hhune) at(peconsc=(0(1)4)) post
  xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female age age2 guiost3 men_guiost3 $personality i.divorced#c.peconsc mcodivorced, re vce(robust)
  eststo cdiv: margins, dydx(divorce) at(peconsc=(0(1)4)) post
  
coefplot cdis chhi chhh chhf ccolkid cdom cch02 cscaid, vertical recast(connected) legend(rows(2)) ylabel(0(0.02)0.08) noci ytitle("Average marginal effect") xtitle("Conscientiousness") nooffsets scheme(s1mono) name(conscf, replace)
coefplot cdis chhh ccolkid cscaid, vertical recast(connected) ylabel(0(0.02)0.08) noci ytitle("Average marginal effect") xtitle("Conscientiousness") nooffsets scheme(s1mono) name(conscf, replace)

 /*  
// Openness

  xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female guiost3 men_guiost3 $personality i.hhi#c.peopen mophhi, re vce(robust)
  eststo ohhi: margins, dydx(hhi) at(peopen=(0(1)6)) post
  xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female guiost3 men_guiost3 $personality i.hhstud#c.peopen mophhstud, re vce(robust)
  eststo ostud: margins, dydx(hhstud) at(peopen=(0(1)6)) post
  xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female guiost3 men_guiost3 $personality i.ch02#c.peopen mopch02, re vce(robust)
  eststo och02: margins, dydx(ch02) at(peopen=(0(1)6)) post
  xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female guiost3 men_guiost3 $personality i.mortgage#c.peopen mopmortgage, re vce(robust)
  eststo omort: margins, dydx(mortgage) at(peopen=(0(1)6)) post
  xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female guiost3 men_guiost3 $personality i.hhune#c.peopen mophhune, re vce(robust)
  eststo ohhune: margins, dydx(hhune) at(peopen=(0(1)6)) post
  xtreg sin $htcare $chcare $ltcare $edu $housing $control $men i.isced i.wave i.female guiost3 men_guiost3 $personality i.divorced#c.peopen mopdivorced, re vce(robust)
  eststo odiv: margins, dydx(divorce) at(peopen=(0(1)6)) post

coefplot ohhune odiv ohhi ostud och02 omort , vertical recast(connected) ylabel(0(0.02)0.08) noci nooffsets scheme(s1mono) name(Open, replace) 
*/

	