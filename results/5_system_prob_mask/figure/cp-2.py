import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.ticker import FuncFormatter

# Load data
file_path = "data-small.csv"
x_col = 'p'
data = pd.read_csv(file_path)

# Extract columns
relevant_columns = [x_col] + [f'shape.{i}' for i in range(1, 6)] + [f'scale.{i}' for i in range(1, 6)] + \
                   [f'shape.lower.{i}' for i in range(1, 6)] + [f'shape.upper.{i}' for i in range(1, 6)] + \
                   [f'scale.lower.{i}' for i in range(1, 6)] + [f'scale.upper.{i}' for i in range(1, 6)]
relevant_data = data[relevant_columns].copy()

# Compute coverage
def compute_coverage(row, j):
    shape_within_ci = row[f'shape.lower.{j}'] <= row[f'shape.{j}'] <= row[f'shape.upper.{j}']
    scale_within_ci = row[f'scale.lower.{j}'] <= row[f'scale.{j}'] <= row[f'scale.upper.{j}']
    return pd.Series([shape_within_ci, scale_within_ci], index=[f'shape_coverage.{j}', f'scale_coverage.{j}'])

for j in range(1, 6):
    relevant_data[[f'shape_coverage.{j}', f'scale_coverage.{j}']] = relevant_data.apply(lambda row: compute_coverage(row, j), axis=1)

coverage_columns = [f'shape_coverage.{j}' for j in range(1, 6)] + [f'scale_coverage.{j}' for j in range(1, 6)]
coverage_probabilities = relevant_data.groupby(x_col)[coverage_columns].mean().reset_index()

# Mean coverage probabilities
mean_shape_coverage_prob = coverage_probabilities[[f'shape_coverage.{j}' for j in range(1, 6)]].mean(axis=1)
mean_scale_coverage_prob = coverage_probabilities[[f'scale_coverage.{j}' for j in range(1, 6)]].mean(axis=1)
coverage_probabilities['mean_shape_coverage_prob'] = mean_shape_coverage_prob
coverage_probabilities['mean_scale_coverage_prob'] = mean_scale_coverage_prob

# Plotting
plt.figure(figsize=[4, 4])

# Plot all individual shapes with a consistent style
for j in range(1, 6):
    plt.plot(coverage_probabilities[x_col], coverage_probabilities[f'shape_coverage.{j}'], color='blue', linestyle='-')
    plt.plot(coverage_probabilities[x_col], coverage_probabilities[f'scale_coverage.{j}'], color='red', linestyle='-')

# Plot mean coverage probabilities with distinct styles
plt.plot(coverage_probabilities[x_col], coverage_probabilities['mean_shape_coverage_prob'], color='darkblue', linewidth=2, linestyle='--', label='Mean Shape')
plt.plot(coverage_probabilities[x_col], coverage_probabilities['mean_scale_coverage_prob'], color='darkred', linewidth=2, linestyle='--', label='Mean Scale')

# 95% Level
plt.axhline(y=0.95, color='grey', linestyle='--', label='95% Level')

# Legend
shape_legend, = plt.plot([], [], color='blue', linestyle='-', label='Shape $k$')
scale_legend, = plt.plot([], [], color='red', linestyle='-', label='Scale $\lambda$')
plt.legend(handles=[shape_legend, scale_legend], loc='upper left', bbox_to_anchor=(0, -0.2), ncol=3, fontsize='small')

# Rest of the plot aesthetics...
plt.xlabel('Masking Probability ($p$)')
plt.ylabel('Coverage Probability (CP)')
plt.gca().yaxis.set_major_formatter(FuncFormatter(lambda y, _: '{:.2f}'.format(y))) 
plt.title('Coverage Probabilities for Parameters')
plt.tight_layout(rect=[0, 0.1, 1, 1])

plt.savefig('combined-cp.pdf')