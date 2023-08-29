import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter
from matplotlib.cm import get_cmap
import numpy as np

# Loading the data from the CSV file
file_path = "cleaned-theta-small-2.csv"
data = pd.read_csv(file_path)

# Extracting relevant columns for shape, scale, and their confidence intervals
relevant_columns = ['n'] + [f'shape.{j}' for j in range(1, 6)] + [f'scale.{j}' for j in range(1, 6)] \
                   + [f'shape.lower.{j}' for j in range(1, 6)] + [f'shape.upper.{j}' for j in range(1, 6)] \
                   + [f'scale.lower.{j}' for j in range(1, 6)] + [f'scale.upper.{j}' for j in range(1, 6)]
relevant_data = data[relevant_columns].copy()

# Function to compute the coverage for shape and scale parameters
def compute_coverage(row, j):
    shape_within_ci = row[f'shape.lower.{j}'] <= row[f'shape.{j}'] <= row[f'shape.upper.{j}']
    scale_within_ci = row[f'scale.lower.{j}'] <= row[f'scale.{j}'] <= row[f'scale.upper.{j}']
    return pd.Series([shape_within_ci, scale_within_ci], index=[f'shape_coverage.{j}', f'scale_coverage.{j}'])

# Computing coverage for each component
for j in range(1, 6):
    relevant_data[[f'shape_coverage.{j}', f'scale_coverage.{j}']] = relevant_data.apply(lambda row: compute_coverage(row, j), axis=1)

# Grouping by 'n' and computing the average coverage probability
coverage_columns = [f'shape_coverage.{j}' for j in range(1, 6)] + [f'scale_coverage.{j}' for j in range(1, 6)]
coverage_probabilities = relevant_data.groupby('n')[coverage_columns].mean().reset_index()

# Compute mean coverage probabilities
mean_shape_coverage_prob = coverage_probabilities[[f'shape_coverage.{j}' for j in range(1, 6)]].mean(axis=1)
mean_scale_coverage_prob = coverage_probabilities[[f'scale_coverage.{j}' for j in range(1, 6)]].mean(axis=1)

# Add mean coverage probabilities to DataFrame
coverage_probabilities['mean_shape_coverage_prob'] = mean_shape_coverage_prob
coverage_probabilities['mean_scale_coverage_prob'] = mean_scale_coverage_prob

# Plotting
plt.figure(figsize=[6,6])

shape_cmap = get_cmap('Blues')
scale_cmap = get_cmap('Reds')

for j, color in zip(range(1, 6), shape_cmap(np.linspace(0.4, 1, 5))):
    plt.plot(coverage_probabilities['n'], coverage_probabilities[f'shape_coverage.{j}'], label=f'Shape $k_{j}$', color=color)

for j, color in zip(range(1, 6), scale_cmap(np.linspace(0.4, 1, 5))):
    plt.plot(coverage_probabilities['n'], coverage_probabilities[f'scale_coverage.{j}'], label=f'Scale $\lambda_{j}$', color=color)

plt.plot(coverage_probabilities['n'], coverage_probabilities['mean_shape_coverage_prob'], color='darkblue', linewidth=3, label='Mean Shape')
plt.plot(coverage_probabilities['n'], coverage_probabilities['mean_scale_coverage_prob'], color='darkred', linewidth=3, label='Mean Scale')

plt.axhline(y=0.95, color='grey', linestyle='--', label='Nominal 95% Level')

plt.xlabel('Sample Size ($n$)')
plt.ylabel('Coverage Probability (CP)')
plt.gca().yaxis.set_major_formatter(FuncFormatter(lambda y, _: '{:.1f}'.format(y))) 
plt.title('Coverage Probabilities for Shape and Scale Parameters')

plt.legend(loc='best', fontsize='small')
plt.tight_layout()
plt.savefig('combined-cp.pdf', bbox_inches='tight')
