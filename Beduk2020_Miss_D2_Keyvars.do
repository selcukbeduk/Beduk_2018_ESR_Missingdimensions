/* 
Project: Measuring poverty in the EU: Investigating empirical validity of deprivation scales
			Part of the thesis submitted by Selçuk Bedük for a DPhil in Social Policy at University of Oxford
			Full thesis is available here: https://ora.ox.ac.uk/objects/uuid:22f61b32-32a3-4fb3-b0ce-67b1b8fe8c00 

Published paper: Bedük, S. (2020). Missing dimensions of poverty? Calibrating deprivation scales using perceived financial situation. European Sociological Review, 36(4), 562-579.

Author: Selçuk Bedük 

Date of code: 5 May 2018

Purpose: Constructing key variables 

Inputs: BHPS9_18_dep.dta (from Miss_D1_Dataprep, using BHPS Waves 9-18, Study Number (SN) 5151 from UK Data Service https://doi.org/10.5255/UKDA-SN-5151-2)

Outputs: BHPS918_P3_FE.dta 
*/


clear all
set more off
global dir "C:\DPhil_dataanalysis\BHPS\stata8"
cd "C:\DPhil_dataanalysis\BHPS\stata8"
use BHPS9_18_dep.dta

tsset pid wave 


// Subjective income inadequacy - binary 
mvdecode fisit, mv(-9/-1)
gen sin= (fisit>3)
replace sin=. if fisit==.
label variable sin "Subj. income inadequacy"

gen sint1= (fisit>4)
gen sint3= (fisit>2)
replace sin=. if fisit==.


// why financial situation changed - expenses 
gen expen=(fisity==14 | fisity==15)
label variable expen "More expense"
gen futworse=(fisitx==2)
label variable futworse "Fut. fs worse than now"
/*
gen badman=(fisity==15 | fisity==25)
replace badman=0 if sin==0
gen windfall=(fisity==5)
gen oneoff=(fisity==15)
replace oneoff=0 if sin==0
*/

gen earnings=(fisity==11)
gen benefits=(fisity==12)

replace expen=0 if sin==0
replace earnings=0 if sin==0 
replace benefits=0 if sin==0 
replace futworse=0 if sin==0

gen finance=(expen==1 | earnings==1)

// Deprivation index - 7 item / binary cut-off at 0 (1+)
mvdecode car washing tv housing loan, mv(-9/-1)
gen arrears=[(housing==1) | (loan==1)]
label variable arrears "Loan/housing payments"

* BASIC NEEDS
gen bn=warm+cloth+meat
gen bnst=(bn>0)		

* SOCIAL ACTIVITIES & LEISURE
gen sal=holiday+furniture+visitors
gen salst=(sal>0)

* DURABLES
gen durables=tv+vcr+washing+dish+micro+cdplay+homepc+car
gen durst=(durables>3)

* POVERTY INDEX - UNION, INTERSECTION, THRESHOLD
gen depindex=warm+holiday+furniture+cloth+meat+visitors 
gen depstu=(depindex>0)				//union
gen depsti=[(bn>0) & (sal>0)]		//intersection
gen depst2=(depindex>2)				//threshold
gen depst1=(depindex>1)
gen guio= warm+holiday+furniture+cloth+meat+visitors+car+washing+arrears
gen guiost0=(guio>0)
gen guiost1=(guio>1)
gen guiost2=(guio>2)					//guio threshold
gen guiost3=(guio>3)

gen xarrears=(arrears==1 |  hoborr==1 | hocutb==1)
gen guio9a=warm+holiday+meat+car+washing+xarrears+tv+tel+furniture+cloth+visitors
gen mda=(guio9a>2)
gen smda=(guio9a>3)
gen mda1=(guio9a>1)
gen mda0=(guio9a>0)

gen punexp=(furniture==1 | cloth==1 | visitors==1 | hoborr==1 | hocutb==1) if furniture!=. & cloth!=. & visitors!=.
gen guio9b=warm+holiday+meat+car+washing+arrears+tv+tel+punexp
gen MDst=(guio9b>2)
gen SMDst=(guio9b>3)

ciplot sin depstu depsti depst2, by(wave) recast(connect) 
ciplot sin bnst salst depsti, by(wave) recast(connect)
ciplot sin guiost2 depsti depst2, by(wave) recast(connect)
ciplot sin guiost2 depst1 bnst, by(wave) recast(connect)

// Age
gen age2=age*age

gen ageg=. 
replace ageg=1 if age>=0 & age<15
replace ageg=2 if age>14 & age<25
replace ageg=3 if age>24 & age<45
replace ageg=4 if age>44 & age<65
replace ageg=5 if age>64 & age<80
replace ageg=6 if age>=80
label define ag 1 "0-14" 2 "15-24" 3 "25-44" 4 "45-64" 5 "65-80" 6 "80+", replace 
label values ageg ag
tab ageg, m


// Social care 
recode aidhh (2 -8=0 "No") (3=1) (-9 -1 =.), pre(b) label(ai)
recode aidxhh (2 = 0 "No") (-9/-1=.), pre(b) label(ais)
gen ltaid=(baidhh==1 | baidxhh==1) if baidhh!=. & baidxhh!=. 
egen hhltaid=total(ltaid), by(wave hid) 
gen scaid=(hhltaid>0) 
replace scaid=. if scaid==0 & ltaid==. 

egen ttscaid=total(baidhh), by(wave hid)
gen hhscaidin=(ttscaid>0) 
replace hhscaidin=. if hhscaidin==0 & baidhh==.

gen scaidout=(baidxhh==1 & (aidhu1!=7 | aidhu1!=8 | aidhu2!=7 | aidhu2!=8)) if baidxhh!=.
egen ttaidout=total(scaidout), by(wave hid) m 
gen hhscaidout=(ttaidout>0) if ttaidout!=.  
 
gen ltcarer=(aidhrs>0) 
replace ltcarer=. if aidhrs<0
replace ltcarer=0 if aidhrs==-8
egen hhltcarer=total(ltcarer), by(wave hid)
replace hhltcarer=. if ltcarer==. & hhltcarer==0

gen aid20=[(aidhrs>3 & aidhrs<8) | (aidhrs==9)]
replace aid20=. if aidhrs==-9 | aidhrs==-1 | aidhrs==-2
egen ttaid20=total(aid20), by(wave hid)
gen hhaid20=(ttaid20>0)
replace hhaid20=. if hhaid20==0 & aid20==. 

gen domestic=(jbstat==6)
egen hhdomestic=total(domestic), by(wave hid)
replace hhdomestic=1 if hhdomestic>0

gen elder=(na75pl>0) if na75pl!=.
label variable elder "Elderly (75+) in the HH" 
replace elder=0 if hhtype==2 | hhtype==8

gen eld80=(age>79)
egen tteld80=total(eld80), by(wave hid)
gen hheld80=(tteld80>0) if tteld80!=.

gen disabled=(jbstat==8) if jbstat>0
egen hhdi= total(disabled), by(wave hid) m 
replace hhdi=2 if hhdi>=2
gen hhdisab=(hhdi>0) if hhdi!=.
label variable hhdisab "Disability in HH"

gen limitedwork=(hlltwa==1) if hlltwa!=-1 & hlltwa!=-9
label variable limitedwork "Health-related limited work in HH"
egen ttlwork=total(limitedwork), by(wave hid)
replace ttlwork=. if limitedwork==.
gen hhlwork=(ttlwork>0) if ttlwork!=. 

 gen sipar=(hhtype==6) if hhtype!=.
 

// Health care 
gen healthst=(hlstat==4 | hlstat==5) if hlstat>0
egen tthealthst=total(healthst), by(wave hid) m 
gen hhhealthst=(tthealthst>0) if tthealthst!=. 
label variable hhhealthst "Unhealthy in HH"

recode hlprba-hlprbm (-9 -7=.) (-8=0), pre(b)
foreach x in a b c d e f g h i j k l m{
	egen hh`x'=total(bhlprb`x'), by(wave hid) m
	replace hh`x'=1 if hh`x'>0
	}
		
label variable hha "arms,legs,hands"
label variable hhb "sight"
label variable hhc "hearing"
label variable hhd "skin/allergy" 
label variable hhe "chest/breathing"
label variable hhf "heart/blood pres"
label variable hhg "stomach/digestion"
label variable hhh "diabetes" 
label variable hhi "anxiety, depression"
label variable hhj "alcohol/drugs"
label variable hhk "epilepsy" 
label variable hhl "migraine"
label variable hhm "other"

gen stairs=(adla==2 | adla==3 | adlad==4) if adla!=-9 & adla!=-7 & adla!=-1
gen inhouse=(adlb==2 | adlb==3 | adlbd==4) if adlb!=-9 & adlb!=-7 & adlb!=-1
gen bed=(adlc==2 | adlc==3 | adlcd==4) if adlc!=-9 & adlc!=-7 & adlc!=-1
gen cut=(adld==2 | adld==3 | adldd==4) if adld!=-9 & adld!=-7 & adld!=-1
gen bath=(adle==2 | adle==3 | adled==4) if adle!=-9 & adle!=-7 & adle!=-1
gen walk=(adlf==2 | adlf==3 | adlfd==4) if adlf!=-9 & adlf!=-7 & adlf!=-1
gen totlda=stairs+inhouse+bed+cut+bath+walk
gen lda=(totlda>0) if totlda!=.

egen ttlda=total(lda), by(wave hid) 
replace ttlda=. if wave==14
gen hhlda=(ttlda>0) if ttlda!=. 
label variable hhlda "Limited daily activities in HH"


// Education 
gen student=(jbstat==7)
egen hhst= total(student), by(wave hid)
gen hhstud=(hhst>0)
label variable hhstud "Adult student"

gen colkid=(age>18 & age<24)
egen ttcolkid=total(colkid), by(wave hid) 
gen ch1924=(ttcolkid>0)
label variable ch1924 "Child aged 19-24"
gen ch511=(nch511>0) 
label variable ch511 "Child aged 5-11"
gen ch1215=(nch1215>0) 
label variable ch1215 "Child aged 12-15"
gen c1618=(age>15 & age<19)
egen ttch1618=total(c1618), by(wave hid)
gen ch1618=(ttch1618>0) if c1618!=.
label variable ch1618 "Child aged 16-18"
replace ttch1618=4 if ttch1618>4
gen c1922=(age>18 & age<23)
egen ttch1922=total(c1922), by(wave hid)
gen ch1922=(ttch1922>0)
replace ttch1922=4 if ttch1922>4
label variable ch1922 "Child aged 19-22"


/* Training trfeeb1 `w'trfeeb2 `w'trfeef1 `w'trfeef2 `w'trfeeg1 `w'trfeeg2 */
gen young=(ageg==1)
egen ttyoung=total(young), by(wave hid) 
gen hhyoung=(ttyoung>0) 
label variable hhyoung "Young(15-24)in HH"
	

// Child care 
gen ch02=(nch02>0) if nch02!=.
label variable ch02 "Child aged 0-2"
gen ch34=(nch34>0) if nch34!=.
label variable ch34 "Child aged 3-4"
gen ch04=(ch02==1 | ch34==1) 
gen chpaid=(xpchcf==2)
replace chpaid=. if xpchcf==-1
label variable chpaid "Paid childcare"


// Housing
recode hsownd (1 2=1) (5 -8=5), gen(house) 
replace house=2 if mghave==2
label def ho 1 "Owned" 2 "Mortgage" 3 "Rented" 4 "Rented free" 5 "Other" 
label value house ho
label variable house "House tenure"
mvdecode house, mv(-9/-1)
label variable xphsn "Net housing cost (monthly)"
gen loghc=log(xphsn) 

gen mortgage=(house==2) if house!=.  // pooled-average housing cost is around 400 pounds a month
gen rented=(house==3) if house!=.   // pooled-average housing cost is around 200 pounds a month
 
ciplot xphsn, by(house) 
gen logxp=log(xphsn)


// Transportation 
gen trans=(jbttwm<4 & jbttwm>0)
replace trans=1 if jsttwm<4 & jsttwm>0
egen hhtrans=total(trans), by(wave hid)
replace hhtrans=. if trans==. & hhtrans==0

gen tra=(jbttwm<7 & jbttwm>0)


// Controls

* Social class 


gen egp=. 
replace egp=jbgold 
replace egp=mrjgold if (egp<0) & (mrjgold>0)
replace egp=12 if mrjgold==-3 | mrjrgsc==-3
replace egp=jlgold if (egp<0) & (jlgold>0)
replace egp=jhgold if (egp<0) & (jhgold>0) 
replace egp=j1gold if (egp<0) & (j1gold>0)
replace egp=. if egp<0

recode egp (1 2 = 1 "Service class") (3 4 =2 "Routine non-manual") (5 6 7 =3 "Petty buorgeoisie") (8 9 = 4 "Skilled manual") (10 11 =5 "Non-skilled manual") (12 = 6 "Never worked"), ///
	gen(soclass) label(egp)


replace jbrgsc=mrjrgsc if jbrgsc<0 & mrjrgsc>0 & mrjrgsc!=.

/*
replace jbrgsc=jlrgsc if (jbrgsc==-8 | jbrgsc==-9) & (jlrgsc!=-8 | jlrgsc!=-9)
replace jbrgsc=. if jbrgsc==-9
replace jbrgsc=7 if jbrgsc==-8 & (jbstat==1 | jbstat==2 | jbstat==3 | jbstat==5 | jbstat==9 | jbstat==10)
replace jbrgsc=8 if jbrgsc==-8 & (jbstat==4)
replace jbrgsc=9 if jbrgsc==-8 & (jbstat==6 | jbstat==7 | jbstat==8)

replace mrjrgsc=7 if mrjrgsc==-3
replace mrjrgsc=. if mrjrgsc==-9 | mrjrgsc==-8 | mrjrgsc==-2
rename mrjrgsc soclass

replace soclass=jbrgsc if soclass==. & (jbrgsc<7 & jbrgsc>0)
replace soclass=jlrgsc if soclass==. & (jlrgsc<7 & jlrgsc>0)

replace mrjseg=20 if mrjseg==-3
replace mrjsec=136 if mrjsec==-3
replace mrjseg=. if mrjseg<0
replace mrjsec=. if mrjsec<0
*/

* Unemployed
gen unemployed=(jbstat==3)	if jbstat>0			
egen hhun= total(unemployed), by(wave hid) m
replace hhun=2 if hhun>2
gen hhune=(hhun>0)

 egen ttun= total(unemployed), by(wave hid)

* retired 
gen retired=(jbstat==4)
egen ttretired=total(retired), by(wave hid)
gen hhretired=(ttretired>0) if ttretired!=. 

* Self-employed
gen selfemp=(jbstat==1)
egen hhse=total(selfemp), by(wave hid) 
gen hhself=(hhse>0) 

* Annual HH income	
gen eqscale=sqrt(hhsize) // OECD scale
gen eqinc=hhyneti/eqscale
gen loghhinc=log(hhyneti/eqscale)
gen loginc=log(hhyneti)

* Marital status
tab mastat, m
replace mastat=. if mastat<0
replace mastat=7 if mastat>7

gen married=(mastat==1) if mastat!=. 
gen widowed=(mastat==3) if mastat!=. 
gen divorced=(mastat==4) if mastat!=. 
gen separated=(mastat==5) if mastat!=. 
gen single=(mastat==6) if mastat!=. 
gen cohab=(mastat==2) if mastat!=. 

foreach x in married widowed divorced separated single cohab {
	egen tt`x'=total(`x'), by(wave hid) m
	gen hh`x'=(tt`x'>0) if tt`x'!=. 
	}

* Single parent 
gen sp=(nonepar>0) if nonepar!=.
label variable sp "Single parent" 

* Education 
tab isced
replace isced=. if isced==0 | isced==-7

* HHsize
replace hhsize=8 if hhsize>8

* Gender
recode sex (2=1 "female") (1=0 "male"), gen(female) lab(gender) 

* Personality 
mvdecode ptrt5a1-ptrt5o3, mv(-9/-1)


// Personality traits 

replace ptrt5a1=7+1-ptrt5a1
replace ptrt5c2=7+1-ptrt5c2
replace ptrt5e3=7+1-ptrt5e3
replace ptrt5n3=7+1-ptrt5n3

gen open=(ptrt5o1+ptrt5o2+ptrt5o3-3)/3
gen consc=(ptrt5c1+ptrt5c2+ptrt5c3-3)/3  
gen extra=(ptrt5e1+ptrt5e2+ptrt5e3-3)/3 
gen agree=(ptrt5a1+ptrt5a2+ptrt5a3-3)/3
gen neuro=(ptrt5n1+ptrt5n2+ptrt5n3-3)/3

bysort pid: egen peopen= min(open)
bysort pid: egen peconsc= min(consc)
bysort pid: egen peextra= min(extra)
bysort pid: egen peagree= min(agree)
bysort pid: egen peneuro= min(neuro)


// Model specification 

global htcare hhf hhh hhi hhk hhhealthst
global chcare nch02 nch34
global ltcare elder hhdisab hhscaidout
global edu nch511 nch1215 ttch1618 ttch1922
global control loginc rented mortgage unemployed divorced separated widowed 
global dimensions bnst salst durst 
global personality pe*


// Dealing with missings 

misstable summarize $htcare $chcare $ltcare $edu $control $personality expen earnings futworse guiost3 sin


tab soclass wave, m
foreach i in 18 17 16 15 14 13 12 11 10 {
	tab jbstat if wave==`i' & soclass==.
	tab ageg if wave==`i' & soclass==.
	}

	
foreach i in 18 17 16 15 14 13 12 11 10 {
	by pid (wave), sort: replace soclass=soclass[_n-1] if (wave==`i') & (soclass==. & soclass[_n-1]!=.) & (jbiscon==jbiscon[_n-1]) & (jbstat==jbstat[_n-1])
}
foreach i in 18 17 16 15 14 13 12 11 10 {
	by pid (wave), sort: replace soclass=soclass[_n-1] if (wave==`i') & (soclass==. & soclass[_n-1]!=.) & (mrjisco==mrjisco[_n-1]) & (jbstat==jbstat[_n-1])
}

foreach i in 18 17 16 15 14 13 12 11 10 {
	by pid (wave), sort: replace soclass=soclass[_n-1] if (wave==`i') & (soclass==. & soclass[_n-1]!=.) & (jbstat==jbstat[_n-1]) & (jbstat>3 & jbstat<9)
	}

/* or 
foreach i in 18 17 16 15 14 13 12 11 {
	replace soclass=L.soclass if (wave==`i') & (soclass==.) & (jbstat==jbstat[_n-1]) & (jbstat==4 | jbstat==8)
	}
	*/

misstable summarize $htcare $chcare $ltcare $edu $control expen earnings futworse guio9a sin 

gen inmiss=0
foreach var of varlist $htcare $chcare $ltcare $edu $control {
	replace inmiss=1 if `var'==.
	}
	

* INCOME POVERTY
gen median=.
foreach t in wave { 
	sum eqinc [aw=xhwght] if wave==`t', detail
	replace median=r(p50) if wave==`t'
	}
	
gen thresh60=0.6*median
gen poor60=(eqinc<thresh60)
	
* CONSISTENT POVERTY 
gen cpst2=[(mda==1) & (poor60==1)]
gen cpst3=[(smda==1) & (poor60==1)]
gen eu2020=(mda==1 | poor60==1) 
	
	
* WITHIN BETWEEN MODEL 

foreach var of varlist $htcare $chcare $ltcare $edu $control {
	bysort pid: egen mean_`var'= mean(`var') 
	gen d_`var'=`var'-mean_`var'
	gen l_`var'=`var'-l.`var'
	gen lag_`var'=L.`var'
	gen lead`var'=F.`var'
	gen ld`var'=lag_`var'-mean_`var'
	}
	
	global men mean_*
	global dem d_*
	global ldiff l_*
	global lvar lag_* i.lag_isced i.lag_soclass
	global ll lag_hhh lag_hhi lag_ch02 lag_hhstud lag_mortgage lag_hhune lag_loghhinc lag_divorced
	global ldvar ldhhi ldch02 ldhhstud ldmortgage ldhhune ldloghhinc lddivorced
	global lead lead*


foreach var of varlist sin mda smda mda1 mda0 guiost3 guiost2 guiost1 guiost0 $dimensions cpst2 cpst3 poor60 eu2020 {
	bysort pid: egen men_`var'= mean(`var') 
	gen dep_`var'=`var'-men_`var'
	gen la_`var'=`var'-l.`var'
	gen lag`var'=L.`var'
	}
	global depdem dep_bnst dep_salst dep_durst
	global depmen men_bnst men_salst men_durst
	
	
// lag dependent and Wooldridge initial condition 	
bysort pid: egen wavefirst=min(wave)
gen sina=. 
replace sina=sin if wave==wavefirst
bysort pid: egen sin1 = min(sina)
gen sint1a=.
replace sint1a=sint1 if wave==wavefirst
bysort pid: egen sint11= min(sint1a)
gen sint3a=.
replace sint3a=sint3 if wave==wavefirst
bysort pid: egen sint33= min(sint3a)

sort pid wave
bysort pid: gen Lsin=L.sin
bysort pid: gen Lsint1=L.sint1
bysort pid: gen Lsint3=L.sint3
sort pid wave 
replace Lsin=sin[_n-2] if Lsin==.
replace Lsint1=sint1[_n-2] if Lsint1==. 
replace Lsint3=sint3[_n-2] if Lsint3==. 
bysort pid: gen wyear= [_N] 

save BHPS918_SA.dta, replace 

drop if wave==9 

misstable summarize $htcare $chcare $ltcare $edu $control expen earnings futworse guio9a sin if wave>wavefirst
	
gen miss=0	
replace miss=1 if expen==. | earnings==. | futworse==. | guio9a==. | Lsin==. | sin1==.


// Weighting 

foreach i in 17 16 15 14 13 12 11 10 9 { 
	replace lewtsw2=lewtsw2[_n+1] if wave==`i'
	}
	
svyset psu [pweight=xhwght], strata(strata)


save BHPS918_P3_FE.dta, replace 

