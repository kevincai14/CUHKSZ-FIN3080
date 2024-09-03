global path = "C:\Users\Quan\StataProjects\FIN3080\A3" // save path

set more off
//////////////////////////////////// raw data
insheet using "$path/raw_data/TRD_Week1.csv", clear
save $path/processed_data/TRD_Week1, replace

insheet using "$path/raw_data/TRD_Week.csv", clear
append using $path/processed_data/TRD_Week1

rename wretnd weekly_return
rename trdwnt raw_trading_date
rename stkcd stock_code

keep if markettype == 1 | markettype == 4 | markettype == 64

gen trading_date_yw = weekly(raw_trading_date,"YW")
format trading_date_yw %tw

drop if trading_date_yw == .

bysort trading_date_yw: egen market_return = mean(weekly_return)

merge m:1 trading_date_yw using $path/raw_data/weekly_risk_free_rate
drop if _merge != 3
drop _merge

gen stock_premium = weekly_return - risk_free_return
gen market_premium = market_return - risk_free_return

keep stock_code trading_date_yw stock_premium market_premium

save $path/processed_data/stock-week_panel_data, replace

//////////////////////////////////// p1 data
keep if trading_date_yw >= yw(2017, 1) & trading_date_yw <= yw(2018, 52)

bysort stock_code: asreg stock_premium market_premium

keep stock_code _b_market_premium
rename _b_market_premium beta_i
drop if beta_i == .
duplicates drop

save $path/processed_data/p1_data, replace

//////////////////////////////////// p2 data
use $path/processed_data/stock-week_panel_data, clear
keep if trading_date_yw >= yw(2019, 1) & trading_date_yw <= yw(2020, 52)
merge m:1 stock_code using $path/processed_data/p1_data
drop _merge
drop if beta_i == .

bysort trading_date_yw: egen group = xtile(beta_i), nq(10)

bys group trading_date_yw: egen avg_return = mean(stock_premium)

keep group avg_return trading_date_yw market_premium
duplicates drop

bysort group: asreg avg_return market_premium

rename _b_cons intercept
rename _b_market_premium beta_p
rename _Nobs obs
rename _R2 r_squared

save $path/processed_data/replicate_table_2, replace

drop intercept _adjR2 r_squared obs

keep group beta_p
duplicates drop
drop if beta_p == .

save $path/processed_data/p2_data, replace

//////////////////////////////////// p3 data
use $path/processed_data/stock-week_panel_data, clear
keep if trading_date_yw >= yw(2021, 1) & trading_date_yw <= yw(2022, 52)
merge m:1 stock_code using $path/processed_data/p1_data
drop _merge
drop if beta_i == .

bysort trading_date_yw: egen group = xtile(beta_i), nq(10)
drop if group == .
bys group: egen avg_return = mean(stock_premium)

keep group avg_return
duplicates drop

merge 1:1 group using $path/processed_data/p2_data
drop _merge

reg avg_return beta_p





