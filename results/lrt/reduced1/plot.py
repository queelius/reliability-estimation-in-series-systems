# Consolidate the entire Python script for generating the refined plot

# Re-import necessary libraries (for completeness)
import pandas as pd
import matplotlib.pyplot as plt

# Load the new data from the uploaded CSV file again
new_file_path = 'data.csv'
new_data = pd.read_csv(new_file_path)

# Group the data by 'n' and compute the median for each group
grouped_by_n = new_data.groupby('n').median().reset_index()

# Group the data by 'n' and compute the 95% upper quantile for each group
grouped_by_n_95 = new_data.groupby('n').quantile(0.95).reset_index()

# Plot the median and 95% upper quantile p-values as functions of sample size n
plt.figure(figsize=(4, 4))
plt.plot(grouped_by_n['n'], grouped_by_n['p.value'], label='Median $p$-Value', marker='o', color='green')
plt.plot(grouped_by_n_95['n'], grouped_by_n_95['p.value'], label='95% Quantile of $p$-Value', marker='x', color='blue')
plt.axhline(y=0.05, color='black', linestyle='--', label='$p$-Value = $0.05$')

plt.xlim(1000, 30000)

# Plot labels and title
plt.xlabel('Sample Size ($n$)')
plt.ylabel('$p$-Value')
#plt.title('$p$-Value Vs of Sample Size for Well-Designed System')

# make the legend larger
plt.legend(fontsize=12)

# save the figure
plt.savefig('plot.pdf')

