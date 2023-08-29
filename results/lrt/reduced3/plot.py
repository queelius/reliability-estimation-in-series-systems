# Import necessary libraries
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Load the data from the uploaded CSV file
file_path = 'data-shape3-lt-3.csv'
data = pd.read_csv(file_path)

# Group the data by 'n' and 'shape3', and compute the median for each group
grouped_data = data.groupby(['n', 'shape3']).median().reset_index()

# Pivot the data to form a matrix suitable for contour plotting
pivot_data = grouped_data.pivot(index='shape3', columns='n', values='p.value')

# Extract the x, y, and z values for contour plotting
x = pivot_data.columns
y = pivot_data.index
z = pivot_data.values

# Create the contour plot using Matplotlib
plt.figure(figsize=(12, 8))
contour = plt.contourf(x, y, z, levels=np.linspace(0, 1, 11), cmap='viridis')
plt.colorbar(label='Median p-value')

# Add a contour line for the 0.05 cut-off using a contrasting color
contour_005 = plt.contour(x, y, z, levels=[0.05], colors='white', linestyles='--')
plt.clabel(contour_005, inline=True, fontsize=10, fmt='%1.2f', colors='white')

# Add a horizontal line at shape3 = 1.1308
plt.axhline(y=1.1308, color='orange', linestyle='--', label='$k_3 = 1.1308$')

# Plot labels and title
plt.xlabel('Sample Size ($n$)')
plt.ylabel('Shape Parameter of Component 3 ($k_3$)')
plt.title('Contour Plot of Median $p$-Value by Sample Size ($n$) and Shape Parameter of Component 3 ($k_3$)')
plt.legend()

plt.tight_layout()

# save the plot
plt.savefig('contour_plot.pdf', bbox_inches='tight')
plt.savefig('contour_plot.png', bbox_inches='tight')
