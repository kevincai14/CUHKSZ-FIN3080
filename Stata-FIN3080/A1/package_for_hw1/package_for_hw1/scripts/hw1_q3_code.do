************************************************************************
*** This is a suggested solution to Homework 1 Question 2 (FIN 3080) ***
*** Date: Mar. 2024 Author: Sijie Wang (sijiewang@link.cuhk.edu.cn) ****
************************************************************************

*** 0. Set program options and specify raw data path ***

* Change the following path to your own path to this folder *
global path_to_sol_folder = "/Users/sjwang222/Desktop/Term8/FIN3080/hw1/package_for_hw1" 

* Set the following option off to enable uninterrupted screen outputs *
set more off  

* Load raw roe/revenue data *
insheet using $path_to_sol_folder/raw_data/problem3_data.csv, clear


* Rename variables * 
    rename symbol stock_code

* Generate YMD dates from original date string *
    gen date_ymd = date(enddate, "YMD")
        format date_ymd %td
* Generate Y dates from YMD dates *
    gen year = year(date_ymd)

* Claim the data set as stock_code-year panel *
    xtset stock_code year
    gen total_revenue_growth = (totalrevenue-l.totalrevenue)/l.totalrevenue

* Focus on records between 2010 and 2022 *
    keep if year >= 2010
    keep if year <= 2022

* Exclude companies with incomplete observations over 2010 to 2022 * 
    bys stock_code: egen obs_roe_by_year = count(roe)
    bys stock_code: egen obs_revenue_by_year = count(total_revenue_growth)
        drop if obs_roe_by_year < 13
        drop if obs_revenue_by_year < 13
        drop obs_roe_by_year obs_revenue_by_year
    
* Calculate median ROE and revenue growth rate by year *
    bys year: egen median_roe = median(roe)
    bys year: egen median_revenue_growth = median(total_revenue_growth)


* Generate dummy variables to indicate whether a company has above-median ROE and revenue growth *
    gen high_roe = 0
        replace high_roe = 1 if roe >= median_roe
    gen high_revenue = 0
        replace high_revenue = 1 if total_revenue_growth >= median_revenue_growth

* Keep stock code and dummy variables only *
    keep stock_code year high_roe high_revenue

* Reshape long data into wide data *
    reshape wide high_roe high_revenue, i(stock_code) j(year) // check the documentations for 'reshape' at : https://www.stata.com/manuals/dreshape.pdf 

* Construct dummy variables that indicate whether a company has consecutively high ROE and revenue growth in each year of 2010, 2011, ..., 2020 *
    gen cons_high_roe2010 = high_roe2010
    gen cons_high_revenue2010 = high_revenue2010

    forvalue y =  2011/2022{
        local z = `y'-1
        gen cons_high_roe`y' = cons_high_roe`z'*high_roe`y'
        gen cons_high_revenue`y' = cons_high_revenue`z'*high_revenue`y'
    }
    summ cons_high_roe* cons_high_revenue*

    keep stock_code cons_high_roe* cons_high_revenue*


* Reshape the data set back to long data *
    reshape long cons_high_roe cons_high_revenue, i(stock_code) j(year) 

* Calculate number of companies with consecutively high ROE and revenue growth in each year *
    bys year: gen num_of_firms = _N
    bys year: egen num_of_cons_high_roe = total(cons_high_roe)
    bys year: egen num_of_cons_high_revenue = total(cons_high_revenue)

* Calculate total number of companies in each year *
    gen per_cons_high_roe = 100*num_of_cons_high_roe/num_of_firms
    gen per_cons_high_revenue = 100*num_of_cons_high_revenue/num_of_firms
    keep year per_cons_high_roe per_cons_high_revenue
    duplicates drop
    summ per_cons_high_roe per_cons_high_revenue


* Plot resulting curves * 
    label var per_cons_high_roe "% ROE"
    label var per_cons_high_revenue "% Revenue growth"
    label var year "Year"

* Check the documentations of twoway at https://www.stata.com/manuals/g-2graphtwoway.pdf  *
    twoway (line per_cons_high_roe year) (line per_cons_high_revenue year), xlabel(2010(3)2023) ytitle("Percentage")

    graph export $path_to_sol_folder/high_roe_revenue_ts.png, replace

************************************************************************
************************** The end of stript ***************************
************************************************************************
