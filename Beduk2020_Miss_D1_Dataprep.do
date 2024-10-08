/* 
Project: Measuring poverty in the EU: Investigating empirical validity of deprivation scales
			Part of the thesis submitted by Selçuk Bedük for a DPhil in Social Policy at University of Oxford
			Full thesis is available here: https://ora.ox.ac.uk/objects/uuid:22f61b32-32a3-4fb3-b0ce-67b1b8fe8c00 

Published paper: Bedük, S. (2020). Missing dimensions of poverty? Calibrating deprivation scales using perceived financial situation. European Sociological Review, 36(4), 562-579.

Author: Selçuk Bedük 

Date of code: 5 May 2018

Purpose: Merging all waves, constructing data and relevant variables 

Inputs: BHPS Waves 9-18, Study Number (SN) 5151 from UK Data Service https://doi.org/10.5255/UKDA-SN-5151-2

University of Essex, Institute for Social and Economic Research. (2021). British Household Panel Survey: Waves 1-18, 1991-2009. [data collection]. 8th Edition. UK Data Service. SN: 5151, DOI: http://doi.org/10.5255/UKDA-SN-5151-2

These data are safeguarded. Safeguarded datasets can be downloaded by registering and accepting our End User Licence (PDF). Some safeguarded data may have additional conditions attached.

See for more information: https://ukdataservice.ac.uk/find-data/access-conditions/

Outputs: BHPS9_18_dep.dta 
*/




// Creating personality traits variables for each wave 

foreach w in f g h i j k l m n p q r {
		use $dir/`w'indresp
		foreach x in a1 a2 a3 c1 c2 c3 e1 e2 e3 n1 n2 n3 o1 o2 o3 {
				gen `w'ptrt5`x'=. 
		}
		save $dir/`w'indresp, replace
	}
	
use $dir/iindresp
gen ilewtsw2=.
gen iptrt5a1=.
gen iptrt5c1=.
gen iptrt5e1=.
gen iptrt5n1=.
gen iptrt5o1=.
gen iptrt5a2=.
gen iptrt5c2=.
gen iptrt5e2=.
gen iptrt5n2=.
gen iptrt5o2=.
gen iptrt5a3=.
gen iptrt5c3=.
gen iptrt5e3=.
gen iptrt5n3=.
gen iptrt5o3=.
save $dir/iindresp.dta, replace 
*/ 


clear all
global dir "C:\DPhil_dataanalysis\BHPS\stata8"
cd "C:\DPhil_dataanalysis\BHPS\stata8"
foreach w in i n {
	use $dir/`w'indresp
	gen `w'hllt=.
	gen `w'hllta=.
	gen `w'hhltb=.
	gen `w'hhltc=.
	gen `w'hhltd=. 
	gen `w'hhlte=. 
	gen `w'hhltw=. 
	gen `w'hlendw=.
	gen `w'hlltwa=. 
	gen `w'adla=.
	gen `w'adlad=.
	gen `w'adlb=. 
	gen `w'adlbd=. 
	gen `w'adlc=.
	gen `w'adlcd=.
	gen `w'adld=.
	gen `w'adldd=. 
	gen `w'adle=.
	gen `w'adled=. 
	gen `w'adlf=. 
	gen `w'adlfd=. 
	save $dir/`w'indresp.dta, replace 
	}
foreach x in i j k {
	use $dir/`x'indresp
	gen `x'hldsbl1=. 
	save $dir/`x'indresp, replace 
	}

use $dir/iindresp
gen ihlstat=. 
save $dir/iindresp, replace 	

	
clear all
global dir "C:\DPhil_dataanalysis\BHPS\stata8"
cd "C:\DPhil_dataanalysis\BHPS\stata8"


foreach w in i j k l m n o p q r {
	use `w'hid `w'psu `w'strata `w'region using $dir/`w'hhsamp
		gen wave = strpos("abcdefghijklmnopqr","`w'")
		lab var wave "wave of BHPS interview"
		sort `w'hid 
		save `w'bhpsha6_18.dta, replace
	clear
	use $dir/`w'_neta.dta 
		drop wave
		gen wave = strpos("abcdefghijklmnopqr","`w'")
		lab var wave "wave of BHPS interview"
		sort `w'hid 
		save `w'bhpsnetinc6_18.dta, replace
	clear 
	use `w'hid `w'hhtype `w'xphsdb `w'xphp `w'xphpdf `w'xphsdf `w'xphsd1 `w'xphsd2 `w'hscnta-`w'hscntf `w'hscana-`w'hscanf ///
		`w'cd1use `w'cd2use `w'cd3use `w'cd4use `w'cd6use `w'cd7use `w'cd8use `w'cd9use `w'cd12use `w'ncars `w'nch02 `w'nch34 `w'nch511 `w'nch1215 `w'nch1618 `w'nkids ///
		`w'na75pl `w'nonepar `w'xphsn `w'hsownd `w'mghave `w'xhwght using $dir/`w'hhresp
		recode `w'xphpdf (2 3 -8=0) (-9 -7=.), pre(b)
		replace b`w'xphpdf=. if `w'xphp==-1 | `w'xphp==-2 | `w'xphp==-7 | `w'xphp==-9
		recode `w'xphsdb `w'xphsd1 `w'xphsd2 (2 -8=0) (-9 -7 -2=.), pre(b) test
		recode `w'hscnta `w'hscntb `w'hscntc `w'hscntd `w'hscnte `w'hscntf (2 -8 =0 "no") (1=1 "yes"), pre(b) label(de) 
		recode `w'hscana `w'hscanb `w'hscanc `w'hscand `w'hscane `w'hscanf (1=0 "not deprived") (2=1 "deprived"), pre(b) label(dep)
		foreach z in a b c d e f {
			replace b`w'hscan`z'=0 if b`w'hscnt`z'!=1 & b`w'hscnt`z'!=.  // enforced deprivation criterion 
		}
		renvars b`w'hscana-b`w'hscanf b`w'xphpdf b`w'xphsdb / `w'warm `w'holiday `w'furniture `w'cloth `w'meat `w'visitors `w'loans `w'housing 
		rename b`w'xphsd1 `w'hoborr
		rename b`w'xphsd2 `w'hocutb
		recode `w'cd* (1=0 "have") (0=1 "don't have") (-8 -9=.), pre(b) test label(dep1)
		recode `w'ncars (1 2 3= 0 "have") ( 0 = 1 "don't have"), pre(b) test label(dep2)
		renvars b`w'cd1use-b`w'cd9use b`w'ncars b`w'cd12use / `w'tv `w'vcr `w'freezer `w'washing `w'dish `w'micro `w'homepc `w'cdplay `w'car `w'tel
		drop b`w'hscnt*
		gen wave = strpos("abcdefghijklmnopqr","`w'")
		lab var wave "wave of BHPS interview"
		sort `w'hid 
		save `w'bhpshh6_18.dta, replace
	merge 1:1 `w'hid using `w'bhpsha6_18
	tab _merge
	keep if _merge==3
	drop _merge 
	sort `w'hid
	save `w'bhpsh_6_18.dta, replace 
	merge 1:1 `w'hid using `w'bhpsnetinc6_18
	tab _merge
	keep if _merge==3
	drop _merge 
	save `w'bhpshhinc6_18.dta, replace 
	clear
		use `w'hid pid `w'jspno `w'jhgold using `w'jobhist.dta, clear 
		sort pid `w'hid
		replace `w'jhgold=`w'jhgold[_n-1] if `w'jhgold<0 & `w'jhgold[_n-1]>0 & pid==pid[_n-1]
		replace `w'jhgold=`w'jhgold[_n+1] if `w'jhgold<0 & `w'jhgold[_n+1]>0 & pid==pid[_n+1]
		keep if `w'jspno==1
		drop `w'jspno
		sort pid `w'hid
		save `w'bhpsjhist.dta, replace	
	clear 
	capture noisily use pid `w'hid `w'sex `w'age `w'hhsize `w'hoh `w'mastat `w'isced `w'casmin `w'fisit `w'fisitc `w'fisitx `w'fisity `w'fimn `w'fihhmn `w'lrwght ///
		`w'aidhrs `w'aidhh `w'aidxhh `w'aidhu1 `w'aidhu2 `w'jbstat `w'jbhas `w'jboff `w'jbgold `w'mrjgold `w'jlgold `w'j1gold `w'jbrgsc `w'jlrgsc ///
		`w'j1rgsc `w'jbttwm `w'jsttwm `w'xpchcf `w'jbchc1 `w'fetype `w'feend `w'mrjrgsc `w'mrjhgs `w'jbiscon `w'mrjisco `w'mrjseg `w'jbsec `w'mrjsec ///
		`w'hlghq1 `w'hlghq2 `w'hlprba-`w'hlprbm `w'ptrt5a1-`w'ptrt5o3 `w'scnow `w'fenow `w'school `w'trfeeb1 `w'trfeeb2 `w'trfeee1 `w'trfeee2 `w'trfeeg1 `w'trfeeg2 ///
		`w'edfeeb1 `w'edfeee1 `w'edfeeg1 `w'edfeeb2 `w'edfeee2 `w'edfeeg2 `w'jssize `w'jbmngr `w'mrjmngr `w'jbsoc `w'mrjisco `w'jbsemp `w'mrjsemp `w'lewtsw2 ///
		`w'hlendw `w'hlltwa `w'adla `w'adlad `w'adlb `w'adlbd `w'adlc `w'adlcd `w'adld `w'adldd `w'adle `w'adled `w'adlf `w'adlfd `w'hldsbl1 `w'hlstat using $dir/`w'indresp
		rename `w'lrwght `w'lrwght`w'
		gen wave = strpos("abcdefghijklmnopqr","`w'")
		lab var wave "wave of BHPS interview"
		sort `w'hid
		save `w'bhpsind6_18, replace
	merge m:1 `w'hid using `w'bhpshhinc6_18
	tab _merge
	keep if _merge==3
	drop _merge
	sort pid `w'hid
	merge 1:1 pid `w'hid using `w'bhpsjhist.dta
	tab _merge 
	keep if _merge!=2
	drop _merge 
	sort pid `w'hid 
	renpfix `w'
	capture rename id pid
	save $dir/durindhh`w'.dta, replace 
 	}
	
clear 		
foreach w in i j k l m n o p q r {
	append using $dir/durindhh`w' 
	}
	
label variable warm "Keep home adequately warm"
label variable holiday "Pay for annual holiday"
label variable furniture "Replace furniture"
label variable visitors "Feed visitors once a month"
label variable loans "Debt repayment burden"
label variable housing "Housing repayment burden"
label variable tv "TV"
label variable vcr "VCR"
label variable washing "Washing machine" 
label variable dish "Dishwasher" 
label variable micro "Microwave" 
label variable homepc "Home PC"
label variable cdplay "CD player" 
label variable car "Car"
label variable cloth "Buy new clothes" 
label variable meat "Eat meat alternately"
	
save BHPS9_18_dep.dta, replace 	
