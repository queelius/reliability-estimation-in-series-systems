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
plt.figure(figsize=(4, 4))

levels=np.concatenate([np.linspace(0, 0.05, 1),
                       np.linspace(0.05, 0.1, 1),
                       np.linspace(0.1, 1, 2)])

print(levels)

# Use the 'autumn' colormap and adjust the color range from 0 to 0.55
#contour = plt.contourf(x, y, z, levels=levels, cmap='tab20c')
contour = plt.contourf(x, y, z, levels=levels, cmap='tab20c')
plt.colorbar(label='Median $p$-Value')

# Add a contour line for the 0.05 cut-off using a contrasting color
# make it thicker by setting the linewidth to 3
# the contour level labels need to be adjusted to be more visible
contour_005 = plt.contour(x, y, z, levels=[.05, .1], colors='black', linestyles='--', linewidths=1)
plt.clabel(contour_005, inline=True, fmt='%1.2f', colors='black', fontsize=8)

# Add a horizontal line at shape3 = 1.1308
plt.axhline(y=1.1308, color='black', linestyle='-', label='$k_3 = 1.1308$', linewidth=2)

# Plot labels and title
plt.xlabel('Sample Size ($n$)')
plt.ylabel('Shape of Component $3$ ($k_3$)')
#plt.title('$p$-Value Vs Sample Size and Shape of Component 3')
plt.legend()

plt.tight_layout()
plt.savefig('contour_plot.pdf')
