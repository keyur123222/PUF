import pandas as pd
from scipy.stats import chisquare

df = pd.read_csv("fpga_output.csv")
df['Decimal'] = df['Binary Output'].astype(str).apply(lambda x: int(x, 2))
observed = df['Decimal'].value_counts().reindex(range(16), fill_value=0)
expected = [len(df) / 16] * 16
chi2, p = chisquare(f_obs=observed, f_exp=expected)

print("Chi-square value:", chi2)
print("p-value:", p)

if p < 0.05:
    print("Not uniform — may not be truly random.")
else:
    print("Looks uniform — good randomness!")
