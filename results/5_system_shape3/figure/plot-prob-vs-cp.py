import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.ticker import FuncFormatter

# Load data
file_path = "data.csv"
x_col = 'shape.3'
data = pd.read_csv(file_path)

# Extract columns
relevant_columns = [f'shape.{i}' for i in range(1, 6)] + [f'scale.{i}' for i in range(1, 6)] + \
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
plt.figure(figsize=[7, 4])

shape_cmap = plt.colormaps['Blues']
scale_cmap = plt.colormaps['Reds']

line_styles = ['-', '--', '-.', ':', '-']
markers = ['o', 's', '^', 'x', 'D']

# make the line for `shape.3` thicker and green
plt.plot(coverage_probabilities[x_col], coverage_probabilities['shape_coverage.3'], label='Shape $k_3$', color='darkgreen', linestyle='-', marker='o', linewidth=4)


for j, color, ls, mk in zip(range(1, 6), shape_cmap(np.linspace(0.4, 1, 5)), line_styles, markers):
    if (j == 3):
        continue
    plt.plot(coverage_probabilities[x_col], coverage_probabilities[f'shape_coverage.{j}'], label=f'Shape $k_{j}$', color=color, linestyle=ls, marker=mk)

for j, color, ls, mk in zip(range(1, 6), scale_cmap(np.linspace(0.4, 1, 5)), line_styles, markers):
    plt.plot(coverage_probabilities[x_col], coverage_probabilities[f'scale_coverage.{j}'], label=f'Scale $\lambda_{j}$', color=color, linestyle=ls, marker=mk)

plt.plot(coverage_probabilities[x_col], coverage_probabilities['mean_shape_coverage_prob'], color='darkblue', linewidth=4, linestyle='-', label='Mean Shape')
plt.plot(coverage_probabilities[x_col], coverage_probabilities['mean_scale_coverage_prob'], color='darkred', linewidth=4, linestyle='-', label='Mean Scale')

plt.axhline(y=0.95, color='grey', linestyle='--', label='Nominal 95% Level')
plt.xlabel('Probability of 3rd Component Failure ($\Pr\{K_i = 3\}$)')
plt.ylabel('Coverage Probability (CP)')
plt.gca().yaxis.set_major_formatter(FuncFormatter(lambda y, _: '{:.2f}'.format(y))) 
plt.title('Coverage Probabilities for Shape and Scale Parameters')


plt.legend(loc='best', bbox_to_anchor=(1, 1))
plt.tight_layout(rect=[0, 0, 0.85, 1])

#plt.legend(loc='best')
plt.tight_layout()
plt.savefig('combined-cp.pdf')




