import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import random

def remove_outliers(df, param):
    mean = df[param].mean()
    std_dev = df[param].std()
    return df[(df[param] > mean - 5*std_dev) & (df[param] < mean + 5*std_dev)]

def plot_mles_and_cis(data, true_params, param, p, param_label):
    # Preprocess the data: select only rows with the specified 'p' and remove outliers
    data_p = data[data['p'] == p]
    data_p_no_outliers = data_p.groupby('n').apply(remove_outliers, param).reset_index(drop=True)
    
    # Get unique 'n' values in ascending order
    n_values = sorted(data_p_no_outliers['n'].unique())
    
    # Prepare the lower and upper bounds names
    param_lower = param.replace('.', '.lower.')
    param_upper = param.replace('.', '.upper.')
    
    # Create a figure
    plt.figure(figsize=(10, 8))
    
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
        plt.vlines(i, lower_q3, upper_q1, color='blue', alpha=0.5, label='Interquartile Range of CIs' if i == 0 else "")
        
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
        plt.plot(i, mean_mle, 'ro', label='Mean of MLEs' if i == 0 else "")
        plt.plot(i, median_mle, 'o', color='orange', label='Median of MLEs' if i == 0 else "")
   
    # Plot the true value of the parameter
    plt.plot(np.arange(len(n_values)), [true_params[param]] * len(n_values), 'g-', label=f'True Value of ${param_label}$')
    
    # Connect the means and medians of the MLEs with a line
    plt.plot(np.arange(len(n_values)), mean_mles, 'r--')
    plt.plot(np.arange(len(n_values)), median_mles, '--', color='orange')
    
    # Add confidence bands around the mean MLE line
    plt.fill_between(np.arange(len(n_values)), np.array(mean_mles) - np.array(std_errors), 
                     np.array(mean_mles) + np.array(std_errors), color='r', alpha=0.2, label='Confidence Bands')
    
    # Plot the coverage probability for each 'n' value
    for i, coverage_prob in enumerate(coverage_probs):
        plt.text(i, upper_q1 + random.uniform(-0.1, 0.1), f'CP: {coverage_prob:.2f}', 
                 horizontalalignment='center', fontsize=8)
    
    # Annotate the plot
    plt.xticks(np.arange(len(n_values)), n_values)
    plt.xlabel('Sample Size ($n$)')
    plt.ylabel(f'Interquartile Range of Confidence Intervals and Mean/Median MLE for ${param_label}$')
    plt.title(f'Confidence Intervals, Mean/Median MLEs, and Coverage Probabilities for ${param_label}$ (p = {p})')
    plt.grid(True)
    plt.legend()
    
    # Show the plot
    plt.tight_layout()
    plt.show()

# Define the true parameter values
true_params = {
    'shapes.1': 1.2576,
    'scales.1': 994.3661,
    'shapes.2': 1.1635,
    'scales.2': 908.9458,
    'shapes.3': 1.1308,
    'scales.3': 840.1141,
    'shapes.4': 1.1802,
    'scales.4': 940.1342,
    'shapes.5': 1.2034,
    'scales.5': 923.1631
}

# Load the data from a CSV file
data = pd.read_csv('/home/spinoza/github/private/proj/results/temp_csv/data.csv')

plot_mles_and_cis(data, true_params, 'shapes.4', 0.215, "k_4")

