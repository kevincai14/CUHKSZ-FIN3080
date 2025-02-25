************************************************************************
*** This is a suggested solution to Homework 1 Question 2 (FIN 3080) ***
*** Date: Mar. 2024 Author: Sijie Wang (sijiewang@link.cuhk.edu.cn) ****
************************************************************************

*** 0. Set program options and specify raw data path ***

* Change the following path to your own path to this folder *
global path_to_sol_folder = "/Users/sjwang222/Desktop/Term8/FIN3080/hw1/package_for_hw1" 

* Set the following option off to enable uninterrupted screen outputs *
set more off  

*** Step 1. Load & process monthly individual stock return data ***
* Import raw individual stock return data *
insheet using $path_to_sol_folder/raw_data/monthly_stock_trading.csv, clear

*** Plot median PE ratio by market type over time ***

* Load merged stock-quarter panel data *
use $path_to_sol_folder/processed_data/processed_stock_return_with_ratios, clear

* Exclude empty P/E ratios * 
    drop if pe_ratio == .

* Keep necessary variables only *
    keep market_type trading_date_ym pe_ratio

* By market and quarter generate median pe ratio *
    bys market_type trading_date_ym: egen median_pe = median(pe_ratio)

* Drop unnecessary columns *
    drop pe_ratio 

* Collapse data to market-month panel *
    duplicates drop

* Label variables *
    label var median_pe "Median P/E Ratio"
    label var trading_date_ym "Date"


* Claim the data set as market_type - month panel *
    encode market_type, gen(market_type_code) // encode market_type (noting that xtset does not take string variables)
    xtset market_type_code trading_date_ym // claim data set as panel


* Plotting median PE ratio by market type *
    local dates "2000m1 2000m2 2000m3 ... 2023m9"
    disp ym(2000,1)
    disp ym(2023,9)
    xtline median_pe, xlabel(480(48)764)  overlay
    graph export "$path_to_sol_folder/median_pe_by_market.png", replace

* Save output data *
save $path_to_sol_folder/monthly_pe_by_market, replace

************************************************************************
************************** The end of stript ***************************
************************************************************************
