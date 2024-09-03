import pandas as pd
import matplotlib.pyplot as plt

df1 = pd.read_csv('problem3_data.csv')

df1['EndDate'] = pd.to_datetime(df1['EndDate'], format='%Y-%m-%d')

start_date = pd.to_datetime('2011-01-01')
end_date = pd.to_datetime('2020-12-31')
df1 = df1[(df1['EndDate'] >= start_date) & (df1['EndDate'] <= end_date)]

annual_median_roe = df1.groupby(df1['EndDate'].dt.to_period("Y"))['ROEC'].median().reset_index()
annual_median_roe['EndDate'] = annual_median_roe['EndDate'].astype(str)

# plt.figure(figsize=(10, 6))
# plt.plot(annual_median_roe['EndDate'], annual_median_roe['ROEC'], marker='o')
# plt.title('Annual Median ROE Over Time')
# plt.xticks(annual_median_roe['EndDate'], rotation=45)
# plt.ylabel('Median ROE')
# plt.tight_layout()
# plt.show()

df_grouped = df1.groupby('Symbol')
df1['GrowthRate'] = df_grouped['TotalRevenue'].pct_change(fill_method=None) * 100

annual_median_growth = df1.groupby(df1['EndDate'].dt.to_period("Y"))['GrowthRate'].median().reset_index()
annual_median_growth['EndDate'] = annual_median_growth['EndDate'].astype(str)

# plt.figure(figsize=(10, 6))
# plt.plot(annual_median_growth['EndDate'], annual_median_growth['GrowthRate'], marker='o')
# plt.title('Annual Median Growth Over Time')
# plt.xticks(annual_median_growth['EndDate'], rotation=45)
# plt.ylabel('Median Growth')
# plt.tight_layout()
# plt.show()

annual_median_roe.rename(columns={'ROEC': 'ROEC median'}, inplace=True)
df1 = pd.merge(df1, annual_median_roe, left_on=df1['EndDate'].dt.to_period("Y").astype(str), right_on='EndDate', how='left')
df1.drop(columns=['EndDate_y', 'EndDate_x'], inplace=True)

annual_median_roe['EndDate'] = pd.to_datetime(annual_median_roe['EndDate'], errors='coerce')
df1['EndDate'] = pd.to_datetime(df1['EndDate'], errors='coerce')
annual_median_growth.rename(columns={'GrowthRate': 'GrowthRate median'}, inplace=True)
df1 = pd.merge(df1, annual_median_growth, left_on=df1['EndDate'].dt.to_period("Y").astype(str), right_on='EndDate', how='left')
df1.drop(columns=['EndDate_y', 'EndDate'], inplace=True)
df1.rename(columns={'EndDate_x': 'EndDate'}, inplace=True)
df1['GrowthRate'] = df1['GrowthRate'].fillna(0)
df1['GrowthRate median'] = df1['GrowthRate median'].fillna(0)
print(df1)
# df1.to_csv('output.csv')

total_companies = df1.groupby('EndDate')['Symbol'].nunique()
total_companies = pd.DataFrame(total_companies)

df1['roe_over_median'] = (df1['ROEC'] > df1['ROEC median'])
df1['grow_over_median'] = (df1['GrowthRate'] >= df1['GrowthRate median'])
total_companies = total_companies.iloc[-1, -1]

num = []
year = []
for i in range(1,11):
    consistent_above_median = df1.groupby('Symbol')['roe_over_median'].agg(lambda x: all(x.head(i))).reset_index()
    companies_consistently_above_median = consistent_above_median[consistent_above_median['roe_over_median']][
        'Symbol'].tolist()
    temp = len(companies_consistently_above_median)
    num.append(temp)
    year.append(2010 + i)

result = [value / total_companies for value in num]

plt.plot(year, result)
plt.title('above-median ROE')
plt.xlabel('year')
plt.ylabel('percentage')
plt.show()

num = []
year = []
for i in range(1,11):
    consistent_above_median = df1.groupby('Symbol')['grow_over_median'].agg(lambda x: all(x.head(i))).reset_index()
    companies_consistently_above_median = consistent_above_median[consistent_above_median['grow_over_median']][
        'Symbol'].tolist()
    temp = len(companies_consistently_above_median)
    num.append(temp)
    year.append(2010 + i)

result = [value / total_companies for value in num]

plt.plot(year, result)
plt.title('above-median growth')
plt.xlabel('year')
plt.ylabel('percentage')
plt.show()