import pandas as pd
import numpy as np

df1 = pd.read_csv('TRD_Mnth.csv')
df2 = pd.read_csv('P_B ratios.csv')
df3 = pd.read_csv('P_E ratios.csv')

df1 = df1[['Stkcd', 'Trdmnt', 'Mretwd', 'Markettype']]
df2 = df2[['Stkcd', 'Trdmnt', 'P/B ratios']]
df3 = df3[['Stkcd', 'Trdmnt', 'P/E ratios']]

df4 = pd.merge(df1, df2, on=['Stkcd', 'Trdmnt'])
df4 = pd.merge(df4, df3, on=['Stkcd', 'Trdmnt'])
# df4.to_csv('monthly return.csv', index=False)
df4.rename(columns={'Mretwd': 'stock returns'}, inplace=True)

main_board = df4[df4['Markettype'].isin([1, 4, 64])]
GEM_board = df4[df4['Markettype'].isin([16, 32])]

main_board['P/B ratios'] = main_board['P/B ratios'].replace([np.inf, -np.inf], np.nan)
main_board['P/E ratios'] = main_board['P/E ratios'].replace([np.inf, -np.inf], np.nan)
GEM_board['P/B ratios'] = GEM_board['P/B ratios'].replace([np.inf, -np.inf], np.nan)
GEM_board['P/E ratios'] = GEM_board['P/E ratios'].replace([np.inf, -np.inf], np.nan)
# main_board.to_csv('main_board.csv')
# GEM_board.to_csv('GEM_board.csv')

describe = ['stock returns', 'P/B ratios', 'P/E ratios']
print()
print(main_board[describe].describe().round(3))
print()
print(GEM_board[describe].describe().round(3))


df1 = pd.read_csv('FI_T5.csv')
df1 = df1[['Stkcd', 'Accper', 'F050201B', 'F050501B']]
df1['Accper'] = pd.to_datetime(df1['Accper']).dt.to_period('Q')
df1['Accper'] = df1['Accper'].astype(str)

df2 = pd.read_csv('R&D_total asset.csv')
df2 = df2[['Stkcd', 'Accper', 'R&D/total asset']]

df3 = pd.read_csv('firm ages.csv')
df3['Accper'] = pd.to_datetime(df3['Accper']).dt.to_period('Q')
df3['Accper'] = df3['Accper'].astype(str)

df3 = df3[['Stkcd', 'Accper', 'firm ages', 'Markettype']]

df4 = pd.merge(df2, df1, on=['Stkcd', 'Accper'], how='left')
df4 = pd.merge(df4, df3, on=['Stkcd', 'Accper'], how='left')
df4['firm ages'] = df4['firm ages'].str.extract('(\d+)').astype(float)

df4.rename(columns={'F050201B': 'ROA', 'F050501B': 'ROE'}, inplace=True)

main_board = df4[df4['Markettype'].isin([1, 4, 64])]
GEM_board = df4[df4['Markettype'].isin([16, 32])]
describe = ['ROA', 'ROE', 'firm ages', 'R&D/total asset']

print()
print(main_board[describe].describe().round(3))
print()
print(GEM_board[describe].describe().round(3))


