import pandas as pd

TRD_Mnth = pd.read_csv('TRD_Mnth.csv')
FS_Comins = pd.read_csv('FS_Comins.csv')
FI_T9 = pd.read_csv('FI_T9.csv')
FS_Combas = pd.read_csv('FS_Combas.csv')
TRD_Co = pd.read_csv('TRD_Co.csv')

merged_df = pd.merge(FS_Combas, TRD_Co, on=['Stkcd'], how='left')
merged_df['firm ages'] = pd.to_datetime(merged_df['Accper']) - pd.to_datetime(merged_df['Estbdt'])
# merged_df.to_csv('firm ages.csv', index=False)

FS_Comins['Accper'] = pd.to_datetime(FS_Comins['Accper']).dt.to_period('Q')
FI_T9['Accper'] = pd.to_datetime(FI_T9['Accper']).dt.to_period('Q')
FS_Combas['Accper'] = pd.to_datetime(FS_Combas['Accper']).dt.to_period('Q')
TRD_Mnth['Accper'] = pd.to_datetime(TRD_Mnth['Trdmnt']).dt.to_period('Q') - 1

merged_df = pd.merge(TRD_Mnth, FS_Comins, on=['Stkcd', 'Accper'], how='left')
merged_df['P/E ratios'] = merged_df['Mclsprc'] / (merged_df['B003000000']/3)
# merged_df.to_csv('P_E ratios.csv', index=False)

merged_df = pd.merge(TRD_Mnth, FI_T9, on=['Stkcd', 'Accper'], how='left')
merged_df['P/B ratios'] = merged_df['Mclsprc'] / merged_df['F091001A']
# merged_df.to_csv('P_B ratios.csv', index=False)

merged_df = pd.merge(FS_Comins, FS_Combas, on=['Stkcd', 'Accper'])
merged_df['R&D/total asset'] = merged_df['B001216000'] / merged_df['A001000000']
# merged_df.to_csv('R&D_total asset.csv', index=False)

print(merged_df.describe())