# Importing required libraries
import pandas as pd
import matplotlib.pyplot as plt

# Loading the data from the CSV file
file_path = "n_vs_mle_p215_q825.csv"
data = pd.read_csv(file_path)

# Extracting relevant columns for shape, scale, and their confidence intervals
relevant_columns = ['n'] + [f'shape.{j}' for j in range(1, 6)] + [f'scale.{j}' for j in range(1, 6)] \
                   + [f'shape.lower.{j}' for j in range(1, 6)] + [f'shape.upper.{j}' for j in range(1, 6)] \
                   + [f'scale.lower.{j}' for j in range(1, 6)] + [f'scale.upper.{j}' for j in range(1, 6)]
relevant_data = data[relevant_columns].copy()  # Making a copy here

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

print(coverage_probabilities)

# Renaming columns for clarity
coverage_probabilities.columns = ['n'] + [f'shape_coverage.{j}' for j in range(1, 6)] + [f'scale_coverage.{j}' for j in range(1, 6)]

# Extracting the columns containing the coverage probabilities for shape and scale parameters
shape_coverage_columns = [f'shape_coverage.{j}' for j in range(1, 6)]
scale_coverage_columns = [f'scale_coverage.{j}' for j in range(1, 6)]

# Computing the mean coverage probabilities for shape and scale parameters
mean_shape_coverage_prob = coverage_probabilities[shape_coverage_columns].mean(axis=1)
mean_scale_coverage_prob = coverage_probabilities[scale_coverage_columns].mean(axis=1)

# Adding the mean coverage probabilities to the DataFrame
coverage_probabilities['mean_shape_coverage_prob'] = mean_shape_coverage_prob
coverage_probabilities['mean_scale_coverage_prob'] = mean_scale_coverage_prob
print(coverage_probabilities)

# Plotting coverage probabilities for shape parameters
plt.figure(figsize=[4,4])
for j in range(1, 6):
    plt.plot(coverage_probabilities['n'], coverage_probabilities[f'shape_coverage.{j}'], label=f'$k_{j}$')
plt.plot(coverage_probabilities['n'], coverage_probabilities['mean_shape_coverage_prob'], color='magenta', linewidth=3, label='Mean Shape')
plt.axhline(y=0.95, color='r', linestyle='--', label='Nominal 95% Level')
plt.xlabel('Sample Size ($n$)')
plt.ylabel('Coverage Probability (CP)')
plt.title('Coverage Probabilities for Shape Parameters')
plt.legend()
plt.grid(True)

# x range is from 0 to 1
plt.xlim(0.25, 1)
plt.ylim(0.7, 1)

# save
#plt.savefig('shapes-cp.png', dpi=150)
plt.savefig('shapes-cp.pdf')


# Plotting coverage probabilities for scale parameters
plt.figure(figsize=[4,4])
for j in range(1, 6):
    plt.plot(coverage_probabilities['n'], coverage_probabilities[f'scale_coverage.{j}'], label=f'$\lambda_{j}$')
plt.plot(coverage_probabilities['n'], coverage_probabilities['mean_scale_coverage_prob'], color='magenta', linewidth=3, label='Mean Scale')
plt.axhline(y=0.95, color='r', linestyle='--', label='Nominal 95% Level')
plt.xlabel('Sample Size ($n$)')
plt.ylabel('Coverage Probability (CP)')
plt.title('Coverage Probabilities for Scale Parameters')
plt.legend()
plt.grid(True)
plt.xlim(0.25, 1)
plt.ylim(0.7, 1)
#plt.savefig('scales-cp.png', dpi=150)
plt.savefig('scales-cp.pdf')
