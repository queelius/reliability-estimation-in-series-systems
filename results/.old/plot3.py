import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import random

def remove_outliers(group, param):
    mean, std = group[param].mean(), group[param].std()
    group['is_outlier'] = (group[param] < mean - 3 * std) | (group[param] > mean + 3 * std)
    inliers = group[~group['is_outlier']]
    return inliers

def plot_mles_and_cis(data, true_params, param, p, param_label, ax):
    # Preprocess the data: select only rows with the specified 'p' and remove outliers
    data_p = data[data['p'] == p]
    data_p_no_outliers = data_p.groupby('n').apply(remove_outliers, param).reset_index(drop=True)
    outliers = data_p_no_outliers[data_p_no_outliers['is_outlier']]

    # Get unique 'n' values in ascending order
    n_values = sorted(data_p_no_outliers['n'].unique())
    n_values = [100, 200]
    
    # Prepare the lower and upper bounds names
    param_lower = param.replace('.', '.lower.')
    param_upper = param.replace('.', '.upper.')
    
    # For each 'n' value, plot the interquartile range of confidence intervals, the mean and median of MLEs, and confidence bands
    mean_mles = []
    median_mles = []
    std_errors = []
    coverage_probs = []
    for i, n in enumerate(n_values):
        data_n = data_p_no_outliers[data_p_no_outliers['n'] == n]
        
        # Compute the interquartile range of confidence intervals
        lower_q3, upper_q1 = np.percentile(data_n[param_lower], 75), np.percentile(data_n[param_upper], 25)
        
        # Plot the interquartile range
        ax.vlines(i, lower_q3, upper_q1, color='blue', alpha=0.5, label='Interquartile Range of CIs' if i == 0 else "")
        
        # Compute and store the mean and median of the MLEs
        mean_mle = data_n[param].mean()
        mean_mles.append(mean_mle)
        median_mle = data_n[param].median()
        median_mles.append(median_mle)
        
        # Compute and store the standard error of the MLEs
        std_error = data_n[param].std() / np.sqrt(data_n.shape[0])
        std_errors.append(std_error)
        
        # Compute and store the coverage probability
        coverage_prob = ((data_n[param_lower] <= true_params[param]) & 
                         (data_n[param_upper] >= true_params[param])).mean()
        coverage_probs.append(coverage_prob)
        
        # Plot the mean and median of the MLEs
        ax.plot(i, mean_mle, 'ro', label='Mean of MLEs' if i == 0 else "")
        ax.plot(i, median_mle, 'o', color='orange', label='Median of MLEs' if i == 0 else "")
        
        # Plot the outliers as dots
        outliers_n = outliers[outliers['n'] == n]
        ax.plot([i]*len(outliers_n), outliers_n[param], 'ko', label='Outliers' if i == 0 else "")
    
    # Plot the true value of the parameter
    ax.plot(np.arange(len(n_values)), [true_params[param]] * len(n_values), 'g-', label=f'True Value of {param}')
    
    # Connect the means and medians of the MLEs with a line
    ax.plot(np.arange(len(n_values)), mean_mles, 'r--')
    ax.plot(np.arange(len(n_values)), median_mles, '--', color='orange')
    
    # Add confidence bands around the mean MLE line
    ax.fill_between(np.arange(len(n_values)), np.array(mean_mles) - np.array(std_errors), 
                     np.array(mean_mles) + np.array(std_errors), color='r', alpha=0.2, label='Confidence Bands')
    
    # Plot the coverage probability for each 'n' value
    for i, coverage_prob in enumerate(coverage_probs):
        ax.text(i, upper_q1 + random.uniform(-0.1, 0.1), f'CP: {coverage_prob:.2f}', 
                 horizontalalignment='center', fontsize=8)
    
    # Annotate the plot
    ax.set_xticks(np.arange(len(n_values)))
    ax.set_xticklabels(n_values)
    ax.set_xlabel('Sample Size (n)')
    #ax.set_ylabel(f'Interquartile Range of CI and Mean/Median MLE for ${param_label}$')
    #ax.set_title(f'Confidence Intervals, Mean/Median MLEs, and Coverage Probabilities for ${param_label}$ (p = {p})')
    ax.grid(True)
    #ax.legend(loc='upper right')

# Load your data
data = pd.read_csv('./github/private/proj/sims/data-boot-q-fixed-bca.csv')

# Define your true parameters
true_params = {
    'shapes.1': 1.2576, 
    'shapes.2': 1.1635, 
    'shapes.3': 1.1308, 
    'shapes.4': 1.1802, 
    'shapes.5': 1.2034,
    'scales.1': 994.3661,
    'scales.2': 908.9458,
    'scales.3': 840.1141,
    'scales.4': 940.1342,
    'scales.5': 923.1631
}
# Create a 5x2 grid of subplots
fig, axes = plt.subplots(5, 2, figsize=(10, 20))  # Adjust the figure size as needed

shape_params = [f'shapes.{i+1}' for i in range(5)]
shape_labels = [f'k_{i+1}' for i in range(5)]

for i, row_axes in enumerate(axes):
    # For the left column (shapes), use index 'i'
    ax = row_axes[0]
    plot_mles_and_cis(data, true_params, shape_params[i], 0.215, shape_labels[i], ax)
    ax.set_ylabel(f'CI / MLE distribution ${shape_labels[i]}$')
    ax.set_title(f'MLE for ${shape_labels[i]}$')

    # For the right column (shapes), also use index 'i'
    ax = row_axes[1]
    plot_mles_and_cis(data, true_params, shape_params[i], 0.333, shape_labels[i], ax)
    ax.set_ylabel(f'MLE for ${shape_labels[i]}$')
    ax.set_title(f'${shape_labels[i]}$')

# Create a single legend for the entire thing, since they are
# related. let's put the legend in the middle

handles, labels = ax.get_legend_handles_labels()
fig.legend(handles, labels, loc='upper right')


# Set a "master" title for the entire figure
fig.suptitle('Confidence Intervals, Mean/Median MLEs, and Coverage Probabilities', fontsize=16)

# Adjust the space between subplots as needed
plt.subplots_adjust(wspace=0.3, hspace=0.5)

#plt.tight_layout(rect=[0, 0, 0, 1.96])  # Adjust as needed to make space for the "master" title
plt.show()



plot_mles_and_cis(data, true_params, shape_params[0], 0.215, shape_labels[0], None)



def mles_and_cis(data, param, p, n):
    # Preprocess the data: select only rows with the specified 'p' and remove outliers
    data_p = data[data['p'] == p]
    data_p_no_outliers = data_p.groupby('n').apply(remove_outliers, param).reset_index(drop=True)
    data_n = data_p_no_outliers[data_p_no_outliers['n'] == n]
    return data_n

dat = mles_and_cis(data, "shapes.1", .215, 50)
dat
dat['shapes.1'].std()
dat.shape[0]
dat = mles_and_cis(data, "shapes.1", .215, 100)
dat['shapes.1'].std()
dat.shape[0]
dat = mles_and_cis(data, "shapes.1", .215, 200)
dat['shapes.1'].std()
dat.shape[0]
dat = mles_and_cis(data, "shapes.1", .215, 500)
dat['shapes.1'].std()
dat.shape[0]