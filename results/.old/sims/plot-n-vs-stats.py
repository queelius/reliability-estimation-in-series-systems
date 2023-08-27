import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import random

def remove_outliers(df, param):
    mean = df[param].mean()
    std_dev = df[param].std()
    return df[(df[param] > mean - 3*std_dev) & (df[param] < mean + 3*std_dev)]

def remove_outliers_iqr(df, param):
    q1 = df[param].quantile(0.25)
    q3 = df[param].quantile(0.75)
    iqr = q3 - q1
    return df[(df[param] > q1 - 1.5*iqr) & (df[param] < q3 + 1.5*iqr)]

def plot_mles_and_cis(ax, data_p, true_params, param, param_label, probmask=0.215):
    # Preprocess the data: select only rows with the specified 'p' and remove outliers
    data_p_no_outliers = data_p.groupby('n').apply(remove_outliers_iqr, param).reset_index(drop=True)
    
    # Get unique 'n' values in ascending order
    p_values = sorted(data_p_no_outliers['n'].unique())
    
    # Prepare the lower and upper bounds names
    param_lower = param.replace('.', '.lower.')
    param_upper = param.replace('.', '.upper.')
    
    # Create a figure
    #ax.figure(figsize=(10, 8))
    
    # For each 'p' value, plot the interquartile range of confidence intervals, the mean and median of MLEs, and confidence bands
    mean_mles = []
    #median_mles = []
    std_devs = []
    coverage_probs = []
    for i, p in enumerate(p_values):
        data_p = data_p_no_outliers[data_p_no_outliers['n']]
        data_p = data_p[data_p['p'] == pmask]
        
        # Show interquartile range of confidence intervals
        lower_q3, upper_q1 = np.percentile(data_p[param_lower], 75), np.percentile(data_p[param_upper], 25)
        ax.vlines(i, lower_q3, upper_q1, color='blue', alpha=0.5, label='Interquartile Range of CIs' if i == 0 else "")

        #mean_lower, mean_upper = np.mean(data_p[param_lower]), np.mean(data_p[param_upper])
        #plt.vlines(i, mean_lower, mean_upper, color='blue', alpha=0.5, label='Mean CIs' if i == 0 else "")

        
        # Compute and store the mean and median of the MLEs
        mean_mle = data_p[param].mean()
        mean_mles.append(mean_mle)
        #median_mle = data_p[param].median()
        #median_mles.append(median_mle)
        
        std_dev = np.std(data_p[param], ddof=1)
        std_devs.append(std_dev)

        # Compute and store the coverage probability
        coverage_prob = ((data_p[param_lower] <= true_params[param]) & 
                         (data_p[param_upper] >= true_params[param])).mean()
        coverage_probs.append(coverage_prob)
        
        # Plot the mean and median of the MLEs
        ax.plot(i, mean_mle, 'ro', label='Mean of MLEs' if i == 0 else "")
        #plt.plot(i, median_mle, 'o', color='orange', label='Median of MLEs' if i == 0 else "")
   
    # Plot the true value of the parameter
    ax.plot(np.arange(len(p_values)), [true_params[param]] * len(p_values), 'g-', label=f'True Value')
    
    # Connect the means and medians of the MLEs with a line
    ax.plot(np.arange(len(p_values)), mean_mles, 'r--')
    #plt.plot(np.arange(len(p_values)), median_mles, '--', color='orange')
    
    # Add confidence bands around the mean MLE line
    ax.fill_between(np.arange(len(p_values)), np.array(mean_mles) - np.array(std_devs), 
                     np.array(mean_mles) + np.array(std_devs), color='blue', alpha=0.25, label='Confidence Bands')

    # Plot the coverage probability for each 'n' value
    #for i, coverage_prob in enumerate(coverage_probs):
    #    plt.text(i, upper_q1 + random.uniform(-0.01, 0), f'CP: {coverage_prob:.2f}', 
    #             horizontalalignment='center', fontsize=8)
    for i, coverage_prob in enumerate(coverage_probs):
        ax.text(i + random.uniform(-0.1, 0.1), lower_q3 + random.uniform(0, 0.01), f'CP: {coverage_prob:.2f}', 
                 horizontalalignment='center', fontsize=8)


    # Annotate the plot
    #ax.xticks(np.arange(len(p_values)), p_values)
    ax.set_xticks(np.arange(len(p_values)))
    ax.set_xticklabels(p_values)


    #ax.xlabel('Masking Probability ($p$)')
    #ax.ylabel(f'Interquartile Range of Confidence Intervals and Mean/Median MLE for ${param_label}$')
    ax.set_xlabel('Sample Size ($n$)')
    #ax.set_ylabel(f'Interquartile Range of Confidence Intervals and Mean/Median MLE for ${param_label}$')    
    ax.set_ylabel(f'MLE statistics for ${param_label}$')    
    ax.set_title(f'CI, Mean MLEs, and Coverage Probabilities for ${param_label}$ (p = ${probmask}$)')
    #ax.title(f'Confidence Intervals, Mean/Median MLEs, and Coverage Probabilities for ${param_label}$ (n = 200)')
    #ax.grid(True)
    #ax.legend()
    
    # Show the plot
    #ax.tight_layout()
    #ax.show()
    ax.figure.canvas.draw()

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
data = pd.read_csv('/home/spinoza/github/private/proj/results/data.csv')

fig, axes = plt.subplots(nrows=3, ncols=2, figsize=(14, 18))
plt.subplots_adjust(wspace=0.4, hspace=0.6)
# Define the parameters
shape_params = ['shapes.1', 'shapes.2', 'shapes.3', 'shapes.4', 'shapes.5']
shape_param_labels = ["k_1", "k_2", "k_3", "k_4", "k_5"]

# Plot each parameter
for ax, param, param_label in zip(axes.flatten()[:-1], shape_params, shape_param_labels, .215):
    plot_mles_and_cis(ax, data, true_params, param, param_label)

# Remove the last subplot
axes[-1, -1].axis('off')

# Add a common legend to the bottom right subplot
handles, labels = axes[0, 0].get_legend_handles_labels()


#fig.legend(handles, labels, loc='lower right', bbox_to_anchor=(0.05, 0.1), fontsize='large')
#fig.legend(handles, labels, loc='lower right')
fig.legend(handles, labels, loc=(0.65, 0.1), fontsize='large')

#fig.text(0.5, 0.05, 'Your really long caption goes here...', ha='center', va='center')


# Adjust the layout
plt.tight_layout(h_pad=8.0, w_pad=5.0)

# Show the plot
#plt.show()
#plt.savefig('plot-n-vs-stats.pdf', dpi=300)
plt.savefig('plot-n-vs-stats-shape-p215.png', dpi=300)
