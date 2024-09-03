global path = "C:\Users\Quan\StataProjects\FIN3080\A3" // save path
set more off

insheet using "$path/raw_data/TRD_Index.csv", clear
drop if indexcd != 000300
rename clsindex closing_index

gen date = date(trddt, "YMD")
format date %td

gen year = year(date)
gen month = month(date)
gen day = day(date)

bysort year month: egen max_day = max(day)
keep if day == max_day

gen year_month = mofd(date)
format year_month %tm
xtset indexcd year_month
gen lagged_price = l1.closing_index

gen return = closing_index / lagged_price - 1

drop year day max_day month lagged_price date trddt

histogram return, bin(50)
graph export "$path/monthly_return.png", replace

sum return
sktest return
swilk return

save $path/processed_data/monthly_return, replace