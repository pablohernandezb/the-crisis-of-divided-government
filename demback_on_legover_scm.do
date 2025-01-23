/******************************************************************************
 * Title: demback_on_legover_scm.do											  *
 * Created by: Pablo Hernandez Borges 										  *
 * Created on: Sept 27 2022													  *
 * Last modified on: Sept 27 2022											  *
 *  Last modified by: Pablo Hernandez Borges								  *
 *  Purpose: This .do file is the main file to run the regression models and  *
 *          generate the necessary plots for the final project for the        * 
 *          POLS5382 Data Analysis course.									  *
 * Edits: 																	  *
 *	 - 09/27/22 - PCHB : data cleaning and the donors for the pool     		  *
 ******************************************************************************/

/* Installing aditional packages */
ssc inst unique
 
/* Setting up the workspace */

* Working directory
cd "C:\Users\pabherna.TTU.000\OneDrive - Texas Tech University\Fall 2022\POLS 8000 Doctoral Dissertation\Data"

* Loading dataset
use "vdem_v12.dta", clear

** Recalculating the Liberal Democracy Index

* Recalculating the Liberal Component Index without Legislative Constraints on the Executive Index
egen v2x_liberal_pchb = rownonmiss(v2xcl_rol v2x_jucon)

* Recalculating the LDI with the original formula and the newly calculated variable
generate v2x_libdem_pchb = (0.25*v2x_polyarchy^(1.585)) + (0.25* v2x_liberal_pchb) + (0.5*v2x_polyarchy^(1.585)*v2x_liberal_pchb)

* Removing previous years since the time range will be from 1959 to 2021
drop if year < 1959
unique country_name // There are 202 countries after dropping the years

* Sorting
sort country_name year

* Looking at countries that had not been Electoral or Closed Autocracies
* drop if v2x_libdem<.2
* unique country_name // There are 145 countries after dropping authocratic regimes

* Trying at alternative approach by looking at the Freedom House Status
xtset country_id year
gen backsliding = e_fh_status-L1.e_fh_status
gen backsliding_dummy = .
replace backsliding_dummy = 0 if backsliding >= 0
replace backsliding_dummy = 1 if backsliding < 0
 
* Saving the file
save "v_dem_v12_pchb.dta", replace 

* Looking at the countries that suffered backsliding
drop if backsliding_dummy == 0 
unique country_name
sort backsliding country_name year
collapse (count) backsliding_dummy, by(country_name)
sort backsliding_dummy country_name
* Since is the case of study we remove it from the drop list of countries that
* suffered at least 1 year of democratic backsliding
drop if country_name == "Venezuela" 
gen delete_backsliding = 1

* Saving the list of deleted countries due to backsliding
save "pool_refinement_backsliding_cases.dta", replace 
 
 * Counting the number of years (only will select cases with complete observations)
*collapse (count) year, by(country_name)
*sort year country_name
*drop if year != 31 // There are 70 countries that had some years with liberal index lower than 0.2

* The pool of donors are 75 countries, 20 of them are in Latin America and the Caribbean


/* Selecting the variables for the study */

** Dependent Variable: Legislative constraints on the executive index
* v2xlg_legcon

** Independent Variables: Democratic backsliding
* Liberal Democracy Index: v2x_libdem
* Liberal Component Index: v2x_liberal

* Electoral Democracy Index: v2x_polyarchy
* Deliberative Democracy Index: v2x_delibdem
* Egalitarian Democracy Index: v2x_egaldem
* Participatory Democracy Index: v2x_partipdem

** Other Independent Variables:

* CSO anti_system movements: v2csantimv

* Court packing: v2jupack
* Government attacks on the judiciary: v2jupoatck

* HOG proposes legislation in practice: v2exdfpphg
* HOG veto power in practice: v2exdfvthg

* Domestic autonomy: v2svdomaut
* International autonomy: v2svinlaut

* Legislature controls resources: v2lgfunds
* Lower chamber committeees: v2lgcomslo
* Lower chamber legislates in practice: v2lglegplo

* State ownership of economy: v2clstown

** Controls
* Population: e_pop e_mipopula e_miurbpop e_wb_pop
* GDP: e_gdp e_gdppc

** Others 
* COW Country Code: COWcode
* V-Dem country ID: country_id
* Country name: country_name
* Country name abbreviation: country_text_id
* Year: year

/* Creating the final dataset */
use "vdem_v12_pchb.dta", clear

* Selecting the countries that suffered Democratic Backsliding
merge m:1 country_name using "pool_refinement_backsliding_cases.dta", keepusing(delete_backsliding) nogenerate
drop if delete_backsliding==1

* Removing previous years since the time range will be from 1959 to 2021
drop if year < 1959

* Sorting
sort country_name year

keep v2xlg_legcon v2x_libdem v2x_liberal v2x_polyarchy v2csantimv v2jupack v2jupoatck v2exdfpphg v2exdfvthg v2svdomaut v2svinlaut v2lgfunds v2lgcomslo v2lglegplo v2clstown e_pop e_mipopula e_miurbpop e_wb_pop e_gdp e_gdppc COWcode country_id country_name country_text_id year

* Select the countries from the pool of donors
merge m:1 country_name using "final_donors_pool.dta", keepusing(latinamerica donor) nogenerate

drop if donor==. // Dropping the ones that are not donnors

generate no_miss = !missing(v2x_libdem, v2x_liberal, v2x_polyarchy, v2csantimv, v2jupack, v2jupoatck, v2svdomaut, v2svinlaut, v2lgfunds, v2lgcomslo, v2lglegplo, v2clstown, e_pop, e_wb_pop, e_gdp, e_gdppc, country_id, country_name, country_text_id, year)

generate no_miss_2 = !missing(v2x_libdem_pchb, v2xlg_legcon, e_pop, e_gdppc)

/* Setting some variables */

* Logged versions for Population and GDP per capita
generate ln_gdppc = ln(e_gdppc)
generate ln_wb_pop = ln(e_wb_pop)
generate ln_pop = ln(e_pop)
generate ln_v2xlg_legcon = ln(v2xlg_legcon)

* Dropping 2021 and 2020 due to missing values
drop if year==2021
drop if year==2020

collapse (sum) no_miss_2, by(country_name)
sort country_name no_miss_2
drop if no_miss_2 != 61 // 36 countries left
gen pool = 1 // 46 countries are the final pool

save "pool_refinement_final_donors.dta", replace

/* Loading the dataset */
use "vdem_v12_pchb_scm.dta", clear

merge m:1 country_name using "pool_refinement_final_donors.dta", keepusing(pool) nogenerate
drop if pool != 1

/* Running the experiment */

tsset country_id year

/* First try with all the donors */

* 1998, 1993, 1988, 1983, 1978, 1973, 1968, 1963

***** Test 1998 as treatment year: Arrive of Hugo Chavez *****

*** Using Legislative Contraints Index as DV
synth v2xlg_legcon v2x_libdem_pchb ln_gdppc ln_pop v2xlg_legcon(1998) v2xlg_legcon(1993) v2xlg_legcon(1988) v2xlg_legcon(1983) v2xlg_legcon(1978) v2xlg_legcon(1973) v2xlg_legcon(1968) v2xlg_legcon(1963), trunit(51) trperiod(1998) xperiod(1959(1)1998) nested fig unitnames(country_name) keep(results_v2xlg_legcon_final)

*** Using Liberal Democracy Index as DV
*synth v2x_libdem_pchb v2xlg_legcon ln_gdppc ln_pop v2x_libdem_pchb(1998) v2x_libdem_pchb(1993) v2x_libdem_pchb(1988) v2x_libdem_pchb(1983) v2x_libdem_pchb(1978) v2x_libdem_pchb(1973) v2x_libdem_pchb(1968) v2x_libdem_pchb(1963), trunit(51) trperiod(1998) xperiod(1959(1)1998) nested fig unitnames(country_name) //keep(results_v2x_libdem_pchb)

synth_runner v2xlg_legcon v2x_libdem_pchb ln_gdppc ln_pop v2xlg_legcon(1998) v2xlg_legcon(1993) v2xlg_legcon(1988) v2xlg_legcon(1983) v2xlg_legcon(1978) v2xlg_legcon(1973) v2xlg_legcon(1968) v2xlg_legcon(1963), trunit(51) trperiod(1998) gen_vars

** Robustness check: Dropping 3 largest countries with biggest RMSPE: DR of Congo and Cape Verde
drop if country_text_id=="LAO" | country_text_id=="COD" | country_text_id=="CPV"
drop pre_rmspe post_rmspe lead effect v2xlg_legcon_synth

synth_runner v2xlg_legcon v2x_libdem_pchb ln_gdppc ln_pop v2xlg_legcon(1998) v2xlg_legcon(1993) v2xlg_legcon(1988) v2xlg_legcon(1983) v2xlg_legcon(1978) v2xlg_legcon(1973) v2xlg_legcon(1968) v2xlg_legcon(1963), trunit(51) trperiod(1998) gen_vars

collapse pre_rmspe post_rmspe, by(country_name)
gen post_pre_demback_ratio = post_rmspe/pre_rmspe
sort post_pre_demback_ratio
histogram post_pre_demback_ratio, bin(50) frequency
// Venezuela is the largest with 46.38

* Placebo and donors 
single_treatment_graphs, trlinediff(-1) raw_gname(v2xlg_legcon1_raw) effects_gname(v2xlg_legcon1_effects) do_color("teal")

/* Saved the plot as v2xlg_legcon1_effects_rb1.gph with 34 countries*/

** Dropping 4 largest countries with biggest RMSPE: barbados, Cuba, Austria, and Morocco (using a thresholg of pre-RMSPE of 2 times larger than Venezuela's) and the ones from the previous round.

drop if country_text_id=="BRB" | country_text_id=="CUB" | country_text_id=="AUT" | country_text_id=="MAR" | country_text_id=="LAO" | country_text_id=="COD" | country_text_id=="CPV"

synth_runner v2xlg_legcon v2x_libdem_pchb ln_gdppc ln_pop v2xlg_legcon(1998) v2xlg_legcon(1993) v2xlg_legcon(1988) v2xlg_legcon(1983) v2xlg_legcon(1978) v2xlg_legcon(1973) v2xlg_legcon(1968) v2xlg_legcon(1963), trunit(51) trperiod(1998) gen_vars

* Placebo and donors 
single_treatment_graphs, trlinediff(-1) raw_gname(v2xlg_legcon1_raw) effects_gname(v2xlg_legcon1_effects) do_color("teal")

/* Saved the plot as v2xlg_legcon1_effects_rb2.gph with 30 countries*/


/* Plots */

* Effects
effect_graphs , trlinediff(-1) effect_gname(v2xlg_legcon1_effect) tc_gname(v2xlg_legcon1_gap)

* Placebo and donors 
single_treatment_graphs, trlinediff(-1) raw_gname(v2xlg_legcon1_raw) effects_gname(v2xlg_legcon1_effects) do_color("teal")

* P-values 
pval_graphs , pvals_gname(v2xlg_legcon1_pval) pvals_std_gname(v2xlg_legcon1_pval_t)

/* Trying with the cmoponents of Legislative Oversight */
* v2lgqstexp v2lgotovst v2lginvstp v2lgoppart

generate no_miss_legcon = !missing(v2lgotovst, v2lginvstp, v2lgoppart, v2lgqstexp)

** Executive Oversight (v2lgotovst)
synth v2lgotovst v2x_libdem_pchb ln_gdppc ln_pop v2lgotovst(1998) v2lgotovst(1993) v2lgotovst(1988) v2lgotovst(1983) v2lgotovst(1978) v2lgotovst(1973) v2lgotovst(1968) v2lgotovst(1963), trunit(51) trperiod(1998) xperiod(1959(1)1998) nested fig unitnames(country_name) keep(results_v2lgotovst_final)

synth_runner v2lgotovst v2x_libdem_pchb ln_gdppc ln_pop v2lgotovst(1998) v2lgotovst(1993) v2lgotovst(1988) v2lgotovst(1983) v2lgotovst(1978) v2lgotovst(1973) v2lgotovst(1968) v2lgotovst(1963), trunit(51) trperiod(1998) gen_vars

** Robustness check: 

synth_runner v2lgotovst v2x_libdem_pchb ln_gdppc ln_pop v2lgotovst(1998) v2lgotovst(1993) v2lgotovst(1988) v2lgotovst(1983) v2lgotovst(1978) v2lgotovst(1973) v2lgotovst(1968) v2lgotovst(1963), trunit(51) trperiod(1998) gen_vars

collapse pre_rmspe post_rmspe, by(country_name)
gen post_pre_demback_ratio = post_rmspe/pre_rmspe
sort post_pre_demback_ratio
histogram post_pre_demback_ratio, bin(400) frequency
// Venezuela is the 4rd largest with 56.12
// Germany is 1st with 397.24 and Belgium 2d with 227.1949

/* Plots */

* Effects
effect_graphs , trlinediff(-1) effect_gname(v2lgotovst_effect) tc_gname(v2lgotovst_gap)

* Placebo and donors 
single_treatment_graphs, trlinediff(-1) raw_gname(v2lgotovst_raw) effects_gname(v2lgotovst_effects) do_color("teal")

* P-values 
pval_graphs , pvals_gname(v2lgotovst_pval) pvals_std_gname(v2lgotovst_pval_t)

** Legislature investigates in practice (v2lginvstp)
synth v2lginvstp v2x_libdem_pchb ln_gdppc ln_pop v2lginvstp(1998) v2lginvstp(1993) v2lginvstp(1988) v2lginvstp(1983) v2lginvstp(1978) v2lginvstp(1973) v2lginvstp(1968) v2lginvstp(1963), trunit(51) trperiod(1998) xperiod(1959(1)1998) nested fig unitnames(country_name) keep(results_v2lginvstp_final)

synth_runner v2lginvstp v2x_libdem_pchb ln_gdppc ln_pop v2lginvstp(1998) v2lginvstp(1993) v2lginvstp(1988) v2lginvstp(1983) v2lginvstp(1978) v2lginvstp(1973) v2lginvstp(1968) v2lginvstp(1963), trunit(51) trperiod(1998) gen_vars

** Robustness check: 

synth_runner v2lginvstp v2x_libdem_pchb ln_gdppc ln_pop v2lginvstp(1998) v2lginvstp(1993) v2lginvstp(1988) v2lginvstp(1983) v2lginvstp(1978) v2lginvstp(1973) v2lginvstp(1968) v2lginvstp(1963), trunit(51) trperiod(1998) gen_vars

collapse pre_rmspe post_rmspe, by(country_name)
gen post_pre_demback_ratio = post_rmspe/pre_rmspe
sort post_pre_demback_ratio
histogram post_pre_demback_ratio, bin(1870) frequency
// Venezuela is the 9th largest with 18.16
// Australia is 1st with 1866.45 and Luxembourg 2d with 687.35

/* Plots */

* Effects
effect_graphs , trlinediff(-1) effect_gname(v2lginvstp_effect) tc_gname(v2lginvstp_gap)

* Placebo and donors 
single_treatment_graphs, trlinediff(-1) raw_gname(v2lginvstp_raw) effects_gname(v2lginvstp_effects) do_color("teal")

* P-values 
pval_graphs , pvals_gname(v2lginvstp_pval) pvals_std_gname(v2lginvstp_pval_t)

** Legislature opposition parties (v2lgoppart)

generate no_miss_v2lgoppart = !missing(v2lgoppart)

* Deleted Cape Verde, Cuba, Laos, Democratic Republic of the Congo, Morocco, and Malasya for missing observations
drop if country_name=="Cape Verde" 
drop if country_name=="Cuba" 
drop if country_name=="Laos" 
drop if country_name=="Democratic Republic of the Congo" 
drop if country_name=="Morocco" 
drop if country_name=="Malaysia" 

synth v2lgoppart v2x_libdem_pchb ln_gdppc ln_pop v2lgoppart(1998) v2lgoppart(1993) v2lgoppart(1988) v2lgoppart(1983) v2lgoppart(1978) v2lgoppart(1973) v2lgoppart(1968) v2lgoppart(1963), trunit(51) trperiod(1998) xperiod(1959(1)1998) nested fig unitnames(country_name) keep(results_v2lgoppart_final)

synth_runner v2lgoppart v2x_libdem_pchb ln_gdppc ln_pop v2lgoppart(1998) v2lgoppart(1993) v2lgoppart(1988) v2lgoppart(1983) v2lgoppart(1978) v2lgoppart(1973) v2lgoppart(1968) v2lgoppart(1963), trunit(51) trperiod(1998) gen_vars

** Robustness check: 

synth_runner v2lgoppart v2x_libdem_pchb ln_gdppc ln_pop v2lgoppart(1998) v2lgoppart(1993) v2lgoppart(1988) v2lgoppart(1983) v2lgoppart(1978) v2lgoppart(1973) v2lgoppart(1968) v2lgoppart(1963), trunit(51) trperiod(1998) gen_vars

collapse pre_rmspe post_rmspe, by(country_name)
gen post_pre_demback_ratio = post_rmspe/pre_rmspe
sort post_pre_demback_ratio
histogram post_pre_demback_ratio, bin(140000) frequency
// Venezuela is the 2nd largest with 27370.66
// Switzerland is the larges with 139953.50

/* Plots */

* Effects
effect_graphs , trlinediff(-1) effect_gname(v2lgoppart_effect) tc_gname(v2lgoppart_gap)

* Placebo and donors 
single_treatment_graphs, trlinediff(-1) raw_gname(v2lgoppart_raw) effects_gname(v2lgoppart_effects) do_color("teal")

* P-values 
pval_graphs , pvals_gname(v2lgoppart_pval) pvals_std_gname(v2lgoppart_pval_t)

** Legislature questions officials in practice (v2lgqstexp)

generate no_miss_v2lgqstexp = !missing(v2lgqstexp)

* Deleted Cape Verde, Cuba, Laos, Democratic Republic of the Congo, Morocco, and Malasya for missing observations
drop if country_name=="Cape Verde" 
drop if country_name=="Cuba" 
drop if country_name=="Laos" 
drop if country_name=="Democratic Republic of the Congo" 
drop if country_name=="Morocco" 
drop if country_name=="Malaysia" 

synth v2lgqstexp v2x_libdem_pchb ln_gdppc ln_pop v2lgqstexp(1998) v2lgqstexp(1993) v2lgqstexp(1988) v2lgqstexp(1983) v2lgqstexp(1978) v2lgqstexp(1973) v2lgqstexp(1968) v2lgqstexp(1963), trunit(51) trperiod(1998) xperiod(1959(1)1998) nested fig unitnames(country_name) keep(results_v2lgqstexp_final)

synth_runner v2lgqstexp v2x_libdem_pchb ln_gdppc ln_pop v2lgqstexp(1998) v2lgqstexp(1993) v2lgqstexp(1988) v2lgqstexp(1983) v2lgqstexp(1978) v2lgqstexp(1973) v2lgqstexp(1968) v2lgqstexp(1963), trunit(51) trperiod(1998) gen_vars

** Robustness check: 

synth_runner v2lgqstexp v2x_libdem_pchb ln_gdppc ln_pop v2lgqstexp(1998) v2lgqstexp(1993) v2lgqstexp(1988) v2lgqstexp(1983) v2lgqstexp(1978) v2lgqstexp(1973) v2lgqstexp(1968) v2lgqstexp(1963), trunit(51) trperiod(1998) gen_vars

collapse pre_rmspe post_rmspe, by(country_name)
gen post_pre_demback_ratio = post_rmspe/pre_rmspe
sort post_pre_demback_ratio
histogram post_pre_demback_ratio, bin(13000) frequency
// Venezuela is the 17th largest with 5.13
// Denmark is the largest with 12433.23

/* Plots */

* Effects
effect_graphs , trlinediff(-1) effect_gname(v2lgqstexp_effect) tc_gname(v2lgqstexp_gap)

* Placebo and donors 
single_treatment_graphs, trlinediff(-1) raw_gname(v2lgqstexp_raw) effects_gname(v2lgqstexp_effects) do_color("teal")

* P-values 
pval_graphs , pvals_gname(v2lgqstexp_pval) pvals_std_gname(v2lgqstexp_pval_t)


/*** Post-Estimation Calculations ***/

use "results_v2xlg_legcon_final.dta", clear
use "results_v2lgotovst_final.dta", clear
use "results_v2lginvstp_final.dta", clear
use "results_v2lgoppart_final.dta", clear
use "results_v2lgqstexp_final.dta", clear


* Period variable: 0 if pre-treatment, 1 if Chavez, and 2 if Maduro
gen period = .
replace period = 0 if _time < 1998
replace period = 1 if _time > 1997 & _time < 2013
replace period = 2 if _time > 2012

drop if period == 0

gen estimates = _Y_treated - _Y_synthetic

ttest estimates, by(period)
ttest _Y_treated, by(period)
ttest _Y_synthetic, by(period)


/** Plots **/ 

twoway (rspike min max pos if type=="S", sort lcolor(midblue)) (scatter mean pos if type=="S", sort mcolor(navy) msize(small) mlabel(type) mlabcolor(navy)) (rspike min max pos if type=="T", sort lcolor(red)) (scatter mean pos if type=="T", sort mcolor(cranberry) msize(small) mlabel(type) mlabcolor(cranberry)) 

graph box v2xlg_legcon, over(e_fh_status)
graph box v2x_libdem_pchb, over(e_fh_status)

twoway (scatter v2x_libdem_pchb v2xlg_legcon if e_fh_status==1, msize(vsmall)) (scatter v2x_libdem_pchb v2xlg_legcon if e_fh_status==2, msize(vsmall)) (scatter v2x_libdem_pchb v2xlg_legcon if e_fh_status==3, msize(vsmall))


/* Violin Plot */
// https://www.techtips.surveydesign.com.au/post/violin-plot-in-stata#:~:text=A%20violin%20plot%20is%20a,user%2Dwritten%20command%20called%20vioplot.
vioplot v2xlg_legcon, over(e_fh_status) ///
//title("Violin Plot of Mileage") subtitle("By repair record") ///
ytitle(Repair Record) ylab(, angle(0)) scheme(s2mono)


/* Scatterplot showing differences in DV: Pre and post-treatment */
sort country_name year
egen mean_pretreat_dv=mean(v2xlg_legcon) if year<1998, by(country_name)
egen mean_posttreat_dv=mean(v2xlg_legcon) if year>=1998, by(country_name)
gen diff_pre_post_treat = mean_posttreat_dv-mean_pretreat_dv


/* Trying with Latin America */ 
use "donors_latam_vdem_v12.dta", clear
use "donors_vdem_v12.dta", clear


tsset country_id year

synth v2xlg_legcon v2x_polyarchy ln_gdppc ln_pop v2xlg_legcon(2016) v2xlg_legcon(2011) v2xlg_legcon(2006) v2xlg_legcon(2001) v2xlg_legcon(1996) v2xlg_legcon(1991), trunit(51) trperiod(2016) xperiod(1991(1)2016) mspeperiod(1991(1)2016) nested allopt fig unitnames(country_name)

drop pre_rmspe post_rmspe lead effect v2xlg_legcon_synth
synth_runner v2xlg_legcon v2x_polyarchy v2lgfunds v2lglegplo v2lgcomslo v2jupoatck v2jupack v2clstown v2svdomaut v2svinlaut v2csantimv ln_gdppc ln_pop v2xlg_legcon(2016) v2xlg_legcon(2011) v2xlg_legcon(2006) v2xlg_legcon(2001) v2xlg_legcon(1996) v2xlg_legcon(1991), trunit(51) trperiod(2016) gen_vars
sort pre_rmspe	

drop if country_name=="Ecuador" 
drop pre_rmspe post_rmspe lead effect v2xlg_legcon_synth
synth_runner v2xlg_legcon v2x_polyarchy(1991(1)2019) ln_gdppc(1991(1)2019) ln_pop(1991(1)2019) v2xlg_legcon(2016) v2xlg_legcon(2011) v2xlg_legcon(2006) v2xlg_legcon(2001) v2xlg_legcon(1996), trunit(51) trperiod(2016) gen_vars

synth v2xlg_legcon v2x_polyarchy ln_gdppc ln_pop v2xlg_legcon(2016) v2xlg_legcon(2011) v2xlg_legcon(2006) v2xlg_legcon(2001) v2xlg_legcon(1996), trunit(51) trperiod(2016) xperiod(1991(1)2016) nested fig

/** Following the Time Series route */

use "vdem_v12.dta", clear

drop if year < 1991

keep v2xlg_legcon v2x_libdem v2x_liberal v2x_polyarchy v2csantimv v2jupack v2jupoatck v2exdfpphg v2exdfvthg v2svdomaut v2svinlaut v2lgfunds v2lgcomslo v2lglegplo v2clstown e_pop e_mipopula e_miurbpop e_wb_pop e_gdp e_gdppc COWcode country_id country_name country_text_id year

generate ln_v2xlg_legcon = ln(v2xlg_legcon)
egen mean_v2xlg_legcon2 = mean(v2xlg_legcon)
generate ln_v2xlg_legcon2 = ln(v2xlg_legcon+1/mean_v2xlg_legcon+1) //[1]
generate ln_gdppc = ln(e_gdppc)
generate ln_wb_pop = ln(e_wb_pop)
generate ln_pop = ln(e_pop)

xtset country_id year 

xtreg ln_v2xlg_legcon v2x_polyarchy v2csantimv v2jupack v2jupoatck v2svdomaut v2svinlaut v2lgfunds v2lgcomslo v2lglegplo v2clstown ln_gdppc ln_pop

xtreg ln_v2xlg_legcon2 v2x_polyarchy v2csantimv v2jupack v2jupoatck v2svdomaut v2svinlaut v2lgfunds v2lgcomslo v2lglegplo v2clstown ln_gdppc ln_pop


// References

// [1] http://seismo.berkeley.edu/~kirchner/eps_120/Toolkits/Toolkit_03.pdf