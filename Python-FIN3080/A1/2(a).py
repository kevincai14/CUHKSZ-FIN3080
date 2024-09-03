import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

df0 = pd.read_csv('P_E ratios.csv')
df0 = df0[['Stkcd', 'Trdmnt', 'Markettype', 'P/E ratios']]
df0['P/E ratios'] = df0['P/E ratios'].replace([np.inf, -np.inf], np.nan)

df1 = df0[df0['Markettype'].isin([1, 4, 64])]
df2 = df0[df0['Markettype'].isin([16, 32])]

df1['Trdmnt'] = pd.to_datetime(df1['Trdmnt'])
monthly_pe_median_1 = df1.groupby(df1['Trdmnt'].dt.to_period("M"))['P/E ratios'].median().reset_index()
monthly_pe_median_1['Trdmnt'] = monthly_pe_median_1['Trdmnt'].astype(str)

df2['Trdmnt'] = pd.to_datetime(df2['Trdmnt'])
monthly_pe_median_2 = df2.groupby(df2['Trdmnt'].dt.to_period("M"))['P/E ratios'].median().reset_index()
monthly_pe_median_2['Trdmnt'] = monthly_pe_median_2['Trdmnt'].astype(str)

plt.figure(figsize=(10, 6))
plt.plot(monthly_pe_median_1['Trdmnt'], monthly_pe_median_1['P/E ratios'], marker='o')
plt.title('Main Board Monthly Median P/E Ratio Over Time')
plt.xticks(monthly_pe_median_1['Trdmnt'][::6], rotation=45)
plt.ylabel('Median P/E Ratio')
plt.tight_layout()
plt.show()

plt.figure(figsize=(10, 6))
plt.plot(monthly_pe_median_2['Trdmnt'], monthly_pe_median_2['P/E ratios'], marker='o')
plt.title('GEM Board Monthly Median P/E Ratio Over Time')
plt.xticks(monthly_pe_median_2['Trdmnt'][::6], rotation=45)
plt.ylabel('Median P/E Ratio')
plt.tight_layout()
plt.show()
