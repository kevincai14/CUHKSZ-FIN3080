global path = "C:\Users\Quan\StataProjects\FIN3080\A2" // save path
set more off

// 1 ///////////////////////////////////
insheet using "$path/raw_data/TRD_Mnth.csv", clear

rename stkcd stock_code
rename trdmnt trading_month
rename mclsprc closing_price
rename mretnd monthly_return

gen trading_date_ym = monthly(trading_month, "YM")
format trading_date_ym %tm
gen trading_date_yq = qofd(dofm(trading_date_ym))
format trading_date_yq %tq

drop trading_month
save $path/processed_data/price_return, replace


// 2 //////////////////////////////////
insheet using "$path/raw_data/FI_T9.csv", clear

rename stkcd stock_code
rename accper raw_accounting_date
rename typrep statement_type
rename f091001a net_asset_ps

drop if statement_type == "B"

gen accounting_date_ymd = date(raw_accounting_date, "YMD")
format accounting_date_ymd %td
gen accounting_date_yq = qofd(accounting_date_ymd)
format accounting_date_yq %tq

keep stock_code accounting_date_yq net_asset_ps
save $path/processed_data/net_asset_ps, replace


// 3 //////////////////////////////////
insheet using "$path/raw_data/STK_MKT_STKBTAL.csv", clear

rename symbol stock_code
rename tradingdate trading_date

gen trading_date_ymd = date(trading_date, "YMD")
format trading_date_ymd %td
gen trading_date_yq = qofd(trading_date_ymd)
format trading_date_yq %tq

keep stock_code volatility trading_date_yq
save $path/processed_data/volatility, replace


// 4 //////////////////////////////////
insheet using "$path/raw_data/FI_T5.csv", clear
rename stkcd stock_code
rename accper raw_accounting_date
rename typrep statement_type
rename f050504c roe

gen trading_date_ymd = date(raw_accounting_date, "YMD")
format trading_date_ymd %td
gen trading_date_yq = qofd(trading_date_ymd)
format trading_date_yq %tq


drop if statement_type == "B"

keep stock_code roe trading_date_yq
save $path/processed_data/roe, replace

// 5 //////////////////////////////////
use $path/processed_data/price_return, clear

gen accounting_date_yq = trading_date_yq - 1
format accounting_date_yq % tq

merge m:1 stock_code accounting_date_yq using $path/processed_data/net_asset_ps
drop if _merge == 2
drop _merge

gen pb_ratio = closing_price/net_asset_ps

merge m:1 stock_code trading_date_yq using $path/processed_data/roe
drop if _merge == 2
drop _merge

merge m:1 stock_code trading_date_yq using $path/processed_data/volatility
drop if _merge == 2
drop _merge

save $path/processed_data/output_of_q1, replace

drop if trading_date_ym < monthly("2010/01", "YM")

sum pb_ratio, detail
local pb_5th = r(p5)
local pb_95th = r(p95)

drop if pb_ratio < `pb_5th' | pb_ratio > `pb_95th'

drop if trading_date_ym != monthly("2010/12", "YM")

// keep stock_code trading_date_ym roe volatility pb_ratio
reg pb_ratio roe volatility

