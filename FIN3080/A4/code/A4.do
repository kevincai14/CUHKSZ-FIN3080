global path = "C:\Users\Quan\StataProjects\FIN3080\A4" // save path
set more off

//////////////////////////////////// return 2021-2023 raw data
insheet using "$path/raw_data/Daily Stock Price  Returns2021-2023/TRD_Dalyr3.csv", clear
save $path/processed_data/TRD_Dalyr3, replace

insheet using "$path/raw_data/Daily Stock Price  Returns2021-2023/TRD_Dalyr2.csv", clear
save $path/processed_data/TRD_Dalyr2, replace

insheet using "$path/raw_data/Daily Stock Price  Returns2021-2023/TRD_Dalyr1.csv", clear
save $path/processed_data/TRD_Dalyr1, replace

insheet using "$path/raw_data/Daily Stock Price  Returns2021-2023/TRD_Dalyr.csv", clear
append using $path/processed_data/TRD_Dalyr1
append using $path/processed_data/TRD_Dalyr2
append using $path/processed_data/TRD_Dalyr3
save $path/processed_data/return_2021-2023, replace

//////////////////////////////////// return 2016-2020 raw data
insheet using "$path/raw_data/Daily Stock Price  Returns2016-2020/TRD_Dalyr4.csv", clear
save $path/processed_data/TRD_Dalyr4, replace

insheet using "$path/raw_data/Daily Stock Price  Returns2016-2020/TRD_Dalyr3.csv", clear
save $path/processed_data/TRD_Dalyr3, replace

insheet using "$path/raw_data/Daily Stock Price  Returns2016-2020/TRD_Dalyr2.csv", clear
save $path/processed_data/TRD_Dalyr2, replace

insheet using "$path/raw_data/Daily Stock Price  Returns2016-2020/TRD_Dalyr1.csv", clear
save $path/processed_data/TRD_Dalyr1, replace

insheet using "$path/raw_data/Daily Stock Price  Returns2016-2020/TRD_Dalyr.csv", clear
append using $path/processed_data/TRD_Dalyr1
append using $path/processed_data/TRD_Dalyr2
append using $path/processed_data/TRD_Dalyr3
append using $path/processed_data/TRD_Dalyr4

//////////////////////////////////// return 2016-2023 merge data
append using $path/processed_data/return_2021-2023

rename dretnd daily_return
rename stkcd stock_code

gen trading_date_ymd = date(trddt, "YMD")
format trading_date_ymd %td
drop trddt

save $path/processed_data/return_2016-2023, replace

//////////////////////////////////// market return data
insheet using "$path/raw_data/Daily Market Returns122320187/TRD_Dalym.csv", clear

keep if markettype == 1

rename dretmdeq market_return

gen trading_date_ymd = date(trddt, "YMD")
format trading_date_ymd %td
drop trddt markettype

save $path/processed_data/market_return, replace

//////////////////////////////////// EPS data
insheet using "$path/raw_data/Index per Share122817898/FI_T9.csv", clear

drop if typrep == "B"

drop if strpos(shortname_en, "ST ") == 1 | strpos(shortname_en, "*ST ") | strpos(shortname_en, "SST ")

drop if substr(indcd, 1, 1) == "J"

rename stkcd stock_code
rename f090101b eps

gen ending_date_ymd = date(accper, "YMD")
format ending_date_ymd %td

gen month = month(ending_date_ymd)
keep if mon == 6 | mon == 12

gen ending_date_yh = yh(year(ending_date_ymd), halfyear(ending_date_ymd))
format ending_date_yh % th

keep stock_code ending_date_yh eps mon

xtset stock_code ending_date_yh

replace eps = eps - l.eps if mon == 12
gen ue = eps - l2.eps

bys stock_code: asrol ue, stat(sd) window(ending_date_yh 4)

gen sue = ue / ue_sd4

sum sue, detail
local sue_5th = r(p5)
local sue_95th = r(p95)

drop if sue < `sue_5th' | sue > `sue_95th'

drop if ending_date_yh < 112

bys ending_date_yh: egen sue_decile_ = xtile(sue), nq(10)

keep stock_code ending_date_yh sue_decile_

reshape wide sue_decile_, i(stock_code) j(ending_date_yh)

save $path/processed_data/sue_decile_data, replace

//////////////////////////////////// announcemnet data
insheet using "$path/raw_data/Statements Release Dates143950320/IAR_Rept.csv", clear

rename stkcd stock_code

keep if reptyp == 2 | reptyp == 4

gen ending_date_ymd = date(accper, "YMD")
format ending_date_ymd %td

gen ann_date_ = date(annodt, "YMD")
format ann_date_ %td

gen ending_date_yh = yh(year(ending_date_ymd), halfyear(ending_date_ymd))
format ending_date_yh % th

keep ending_date_yh ann_date_ stock_code

reshape wide ann_date_, i(stock_code) j(ending_date_yh)

save $path/processed_data/announcement_data, replace

//////////////////////////////////// data merging
use $path/processed_data/return_2016-2023, clear

merge m:1 trading_date_ymd using $path/processed_data/market_return
drop _merge

merge m:1 stock_code using $path/processed_data/sue_decile_data
drop _merge

merge m:1 stock_code using $path/processed_data/announcement_data
drop _merge

gen ab_ret = daily_return - market_return

drop daily_return market_return

save $path/processed_data/code_ab_date_decile, replace

//////////////////////////////////// event study
forvalues i = 112/125 {
	use $path/processed_data/code_ab_date_decile, clear
    gen event_date = trading_date_ymd - ann_date_`i'
	sort stock_code trading_date_ymd
	keep if event_date >= - 60 & event_date <= 60
	keep stock_code event_date ab_ret sue_decile_`i'
	bys event_date sue_decile_`i': egen portfolio_ab_ret_`i' = mean(ab_ret)
	bys event_date sue_decile_`i': gen dup = cond(_N==1,0,_n)
	drop if dup > 1
	drop dup
	rename sue_decile_`i' sue_decile
	bys sue_decile (event_date): gen portfolio_car_`i' = sum(portfolio_ab_ret_`i')
	keep sue_decile event_date portfolio_car_`i'
	save $path/processed_data/sue_decile_car_`i', replace
}

use $path/processed_data/sue_decile_car_112, clear
save $path/processed_data/sue_decile_car, replace

forvalues i = 113/125 {
	use $path/processed_data/sue_decile_car, clear
    merge 1:1 sue_decile event_date using $path/processed_data/sue_decile_car_`i'
	drop _merge
	save $path/processed_data/sue_decile_car, replace
}

local var_list ""

forvalues i = 112/125 {
    local var_list "`var_list' portfolio_car_`i'"
}

egen mean_portfolio_car = rowmean(`var_list')

keep sue_decile event_date mean_portfolio_car

xtset sue_decile event_date

xtline mean_portfolio_car, overlay xtitle("Event time") ytitle("Cumulative abnormal return") legend(order(10 "SUE 10" 9 "SUE 9" 8 "SUE 8" 7 "SUE 7" 6 "SUE 6" 5 "SUE 5" 4 "SUE 4" 3 "SUE 3" 2 "SUE 2" 1 "SUE 1"))

graph export $path/Cumulative_abnormal_returns_by_SUE_deciles.jpg, replace
