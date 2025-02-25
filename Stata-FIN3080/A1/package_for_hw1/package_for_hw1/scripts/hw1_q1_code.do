************************************************************************
*** This is a suggested solution to Homework 1 Question 1 (FIN 3080) ***
*** Date: Mar. 2024 Author: Sijie Wang (sijiewang@link.cuhk.edu.cn) ****
************************************************************************

*** 0. Set program options and specify raw data path ***

* Change the following path to your own path to this folder *
global path_to_sol_folder = "/Users/sjwang222/Desktop/Term8/FIN3080/hw1/package_for_hw1" 

* Set the following option off to enable uninterrupted screen outputs *
set more off

*** Step 1. Load & process monthly individual stock return data ***
* Import raw individual stock return data *
insheet using "$path_to_sol_folder/raw_data/monthly_stock_trading.csv", clear


* Rename variables *
    rename stkcd stock_code // 'stkcd' stands for the stock code
    rename trdmnt raw_trading_date // 'trdmnt' stands for the trading date
    rename mclsprc closing_price // 'mclsprc' stands for monthly closing price
    renam mretnd monthly_return // 'mretnd' stands for monthly return
    rename markettype market // 'markettype' stands for the market type

* Exculde B-share stocks *
    drop if market == 2 | market == 8 // as per CSMAR's documentation on market type

* Generate market type indicator for main board,  *
    gen market_type = "Main"
        replace market_type = "GEM" if market == 16| market == 32 // As per CSMAR's documentation
        /* replace market_type = "SME" if stock_code >= 2000 & stock_code < 3000 */ // Note that you do not have to differenciate SME stocks with other stocks within the mainboard

* Convert original string dates to Stata Year-Month dates *
    gen trading_date_ym = monthly(raw_trading_date, "YM")
        format trading_date_ym %tm // Format year-month dates as "YYYYMM"

* Construct Stata year-quarter dates from Stata year-month dates *
    gen trading_date_yq = qofd(dofm(trading_date_ym))
        format trading_date_yq %tq // Format year-quarter dates as "YYYYQ"

* Scale stock return by 100 (to report it in %) *
    replace monthly_return = monthly_return * 100

* Keep observations of our interest  *
    keep stock_code monthly_return market_type trading_date_ym trading_date_yq closing_price

* Save processed data *
save $path_to_sol_folder/processed_data/processed_stock_return, replace


** Export stock code to market type mapping **
use $path_to_sol_folder/processed_data/processed_stock_return, clear
    keep stock_code market_type
    duplicates drop // collapse data into stock_code - market_type unique mappings
save $path_to_sol_folder/processed_data/processed_stock_to_market_type, replace


*** Step 2. Load & process quarterly balance sheet data *** 

* Import raw balance sheet data *
insheet using "$path_to_sol_folder/raw_data/quarterly_balance_sheet.csv", clear

* Rename variables *
    rename stkcd stock_code
    rename accper raw_accounting_date
    rename typrep statement_type
    rename a001000000 total_asset
    rename a002000000 total_liabilities

* Convert original string dates to Year-Month-Day dates *
    gen accounting_date_ymd = date(raw_accounting_date, "YMD")
        format accounting_date_ymd %td // Format year-month-day dates as "YYYY-MM-DD"

* Construct year-quarter dates from year-month dates *
    gen accounting_date_yq = qofd(accounting_date_ymd)
        format accounting_date_yq %tq // Format year-quarter dates as "YYYYQQ"

* Exclude parent statements *
    keep if statement_type == "A"

* Keep obs at end of quarters only (in other words, the last obs for each stock in each quarter)  *
    keep if mod(month(accounting_date_ymd), 3) == 0 

* Keep necessary variables *
    keep stock_code accounting_date_yq total_asset total_liabilities

* Save processed balance sheet data *
save $path_to_sol_folder/processed_data/processed_balance_sheet, replace



*** Step 3. Load & process quarterly income statement data ***

* Import raw income statement data *
insheet using $path_to_sol_folder/raw_data/quarterly_income_statement.csv, clear


* Rename variables *
    rename stkcd stock_code
    rename accper raw_accounting_date
    rename typrep statement_type
    rename b001216000 rd_expense

* Exclude parent statements *
    drop if statement_type == "B"

* Convert original string dates to Year-Month-Day dates *
    gen accounting_date_ymd = date(raw_accounting_date, "YMD")
        format accounting_date_ymd %td  // Format year-month dates as yyyymmdd

* Construct year-quarter dates from year-month dates *
    gen accounting_date_yq = qofd(accounting_date_ymd)
        format accounting_date_yq %tq // Format year-quarter dates as yyyyqq

* Keep obs at end of quarters only (in other words, the last obs for each stock in each quarter)  *
    keep if mod(month(accounting_date_ymd), 3) == 0 

* Keep necessary variables *
    keep stock_code accounting_date_yq rd_expense

* Save processed balance sheet data *
save $path_to_sol_folder/processed_data/processed_income_statement, replace



*** Step 4. Load & process quarterly earning capacity data ***
* Import raw earning capacity data *
insheet using "$path_to_sol_folder/raw_data/quarterly_earning_capacity.csv", clear

* Rename variables *
    rename stkcd stock_code
    rename accper raw_accounting_date
    rename typrep statement_type
    rename f050204c roa
    rename f050504c roe

* Exclude parent statements *
    drop if statement_type == "B"

* Convert original string dates to Year-Month-Day dates *
    gen accounting_date_ymd = date(raw_accounting_date, "YMD")
        format accounting_date_ymd %td  // Format year-month dates as yyyymmdd

* Construct year-quarter dates from year-month dates *
    gen accounting_date_yq = qofd(accounting_date_ymd)
        format accounting_date_yq %tq // Format year-quarter dates as yyyyqq

* Report ROA and ROE in percentage (i.e., scale by 100) * 
    replace roe = roe*100
    replace roa = roa*100

* Keep necessary variables *
    keep stock_code accounting_date_yq roa roe

* Save processed quarterly earning capacity data *
save $path_to_sol_folder/processed_data/processed_earning_capacity, replace




*** Step 5. Load & process quarterly index per share data ***

* Import raw quarterly index per share data *
insheet using "$path_to_sol_folder/raw_data/quarterly_index_per_share.csv", clear


* Rename variables *
    rename stkcd stock_code
    rename accper raw_accounting_date
    rename typrep statement_type
    rename f090101c earning_ps
    rename f091001a net_asset_ps

* Exclude parent statements *
    drop if statement_type == "B"

* Convert original string dates to Year-Month-Day dates *
    gen accounting_date_ymd = date(raw_accounting_date, "YMD")
        format accounting_date_ymd %td  // Format year-month dates as yyyymmdd

* Construct year-quarter dates from year-month dates *
    gen accounting_date_yq = qofd(accounting_date_ymd)
        format accounting_date_yq %tq // Format year-quarter dates as yyyyqq

* Keep necessary variables *
    keep stock_code accounting_date_yq earning_ps net_asset_ps

* Save processed quarterly index per share data *
save $path_to_sol_folder/processed_data/processed_index_per_share, replace




*** Step 6. Load & process cross-sectional company profile data ***

* Import raw company profile data *
insheet using $path_to_sol_folder/raw_data/company_profile.csv, clear

* Rename variables *
    rename stkcd stock_code
    rename estbdt raw_est_date

* Convert original string dates to Year-Month-Day dates *
    gen est_date_ymd = date(raw_est_date, "YMD")
        format est_date_ymd %td // Format year-month dates as yyyymmdd

* Construct year-quarter dates from year-month dates *
    gen est_date_yq = qofd(est_date_ymd)
        format est_date_yq %tq // Format year-quarter dates as yyyyqq

* Keep necessary variables *
    keep stock_code est_date_yq

* Drop duplicated records (if any) *
    duplicates drop stock_code, force

* Save processed company profile data *
save $path_to_sol_folder/processed_data/processed_company_profile, replace



*** Step 5. Merge all data sets to stock return data set ***

** 5.1 Merge quarterly data together **

* Load processed balance sheet data *
use $path_to_sol_folder/processed_data/processed_balance_sheet, clear


* Merge other data to current data set *
    merge 1:1 stock_code accounting_date_yq using $path_to_sol_folder/processed_data/processed_income_statement
        drop if _merge == 2
        drop _merge 
    
    merge 1:1 stock_code accounting_date_yq using $path_to_sol_folder/processed_data/processed_earning_capacity
        drop if _merge == 2
        drop _merge 

    merge m:1 stock_code using $path_to_sol_folder/processed_data/processed_company_profile
        drop if _merge == 2
        drop _merge 

    merge m:1 stock_code using $path_to_sol_folder/processed_data/processed_stock_to_market_type
        drop if _merge == 2
        drop _merge 

* Derive firm age over time (in quarter) *
    gen firm_age = accounting_date_yq - est_date_yq

* Derive R&D expense ratio (in percentage) *
    gen rd_ratio = 100*rd_expense/total_asset

* Scale large numbers by 10^-9 *
    replace total_asset = total_asset/(10^6)
    replace total_liabilities = total_liabilities/(10^6)
    replace rd_expense = rd_expense/(10^6)

* Save merged quarterly data *
save $path_to_sol_folder/processed_data/processed_all_quarterly_data, replace


** 5.2 Construct monthly P/E, P/B ratios **

* Load processed stock return data *
use $path_to_sol_folder/processed_data/processed_stock_return, clear
    
* Lag date_yq with one quarter as the latest report date *
    gen accounting_date_yq = trading_date_yq - 1
        format accounting_date_yq % tq

* Merge quarterly EPS and net assets per share to monthly stock return data  *
    merge m:1 stock_code accounting_date_yq using $path_to_sol_folder/processed_data/processed_index_per_share
        drop if _merge == 2
        drop _merge

* Generate P/B and P/E ratios *
    gen pb_ratio = closing_price/net_asset_ps
    gen pe_ratio = closing_price/earning_ps

* Save stock data with P/B, P/E ratios *
save $path_to_sol_folder/processed_data/processed_stock_return_with_ratios, replace



*** Step 6. Summarize variables of interest ***

** Monthly records **
use $path_to_sol_folder/processed_data/processed_stock_return_with_ratios, clear

* Label variables *
    label var monthly_return "Stock return"
    label var closing_price "Stock price"
    label var pe_ratio "P/E ratio"
    label var pb_ratio "P/B ratio"

* By market summarize variables of interest *
* Main board summary *
    estpost summarize monthly_return closing_price pe_ratio pb_ratio if market_type == "Main", detail
    eststo ss_main_monthly
    esttab ss_main_monthly, cell(b(fmt(2)) "count mean p25 p50 p75 sd" ), using $path_to_sol_folder/ss_main_monthly.csv, replace
* GEM board summary *
    estpost summarize monthly_return closing_price pe_ratio pb_ratio if market_type == "GEM", detail
    eststo ss_gem_monthly
    esttab ss_gem_monthly, cell(b(fmt(2)) "count mean p25 p50 p75 sd" ), using $path_to_sol_folder/ss_gem_monthly.csv, replace


** Quarterly records **
use $path_to_sol_folder/processed_data/processed_all_quarterly_data, clear

* Label variables *
    label var total_asset "Total assets"
    label var total_liabilities "Total liabilities"
    label var rd_expense "R \& D expenses"
    label var roe "ROE"
    label var roa "ROA"
    label var firm_age "Firm age"
    label var rd_ratio "R \& D ratios"

* By market summarize variables of interest *
* Main board summary *
    estpost summarize total_asset total_liabilities rd_ratio roa roe firm_age if market_type == "Main", detail
    eststo ss_main_quarterly
    esttab ss_main_quarterly, cell(b(fmt(2)) "count mean p25 p50 p75 sd" ), using $path_to_sol_folder/ss_main_quarterly.csv, replace
* GEM board summary *
    estpost summarize total_asset total_liabilities rd_ratio roa roe firm_age if market_type == "GEM", detail
    eststo ss_gem_quarterly
    esttab ss_gem_quarterly, cell(b(fmt(2)) "count mean p25 p50 p75 sd" ), using $path_to_sol_folder/ss_gem_quarterly.csv, replace





************************************************************************
************************** The end of stript ***************************
************************************************************************
