global path = "C:\Users\Quan\StataProjects\FIN3080\A2" // save path
set more off

use "$path/processed_data/output_of_q1.dta", clear

sum pb_ratio, detail
local pb_5th = r(p5)
local pb_95th = r(p95)

drop if pb_ratio < `pb_5th' | pb_ratio > `pb_95th'
drop volatility

xtset stock_code trading_date_ym
gen lagged_pb = l1.pb_ratio

bysort trading_date_ym: egen group = xtile(lagged_pb), nq(10)

bys group trading_date_ym: egen portfolio_return = mean(monthly_return)

drop if group == .
keep trading_date_ym group portfolio_return
duplicates drop

save $path/processed_data/monthly_returns_for_ten_portfolios, replace

bys group: egen avg_return = mean(portfolio_return)
keep avg_return group
duplicates drop

graph bar avg_return, over(group) ///
    title("Average returns for the ten portfolios from Jan. 2010 to Dec. 2023") ///
    ytitle("Average Return")
	
graph export "$path/Average_returns_for_ten_portfolios.png", replace
