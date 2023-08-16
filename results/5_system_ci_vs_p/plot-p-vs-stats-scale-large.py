import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import random

def remove_outliers_iqr(df, param):
    q1 = df[param].quantile(0.25)
    q3 = df[param].quantile(0.75)
    iqr = q3 - q1
    return df[(df[param] > q1 - 1.5*iqr) & (df[param] < q3 + 1.5*iqr)]

def plot_mles_and_cis(ax, data_p, true_params, param, param_label):

    # remove `p` > 0.9
    #data_p = data_p[data_p['p'] <= 0.9]

    # Preprocess the data: select only rows with the specified 'p' and remove outliers
    data_p_no_outliers = data_p.groupby('p').apply(remove_outliers_iqr, param).reset_index(drop=True)
    
    # Get unique 'n' values in ascending order
    p_values = sorted(data_p_no_outliers['p'].unique())
    
    # Prepare the lower and upper bounds names
    param_lower = param.replace('.', '.lower.')
    param_upper = param.replace('.', '.upper.')
    
    mean_mles = []
    coverage_probs = []
    lower_quantile = []
    upper_quantile = []

    for i, p in enumerate(p_values):
        data = data_p_no_outliers[data_p_no_outliers['p'] == p]
        
        # Show interquartile range of confidence intervals
        lower_q3, upper_q1 = np.percentile(data[param_lower], 75), np.percentile(data[param_upper], 25)
        ax.vlines(i, lower_q3, upper_q1, color='blue', alpha=0.5, label='Interquartile Range of CIs' if i == 0 else "")

        # Compute and store the mean and median of the MLEs
        mean_mle = data[param].mean()
        mean_mles.append(mean_mle)

        lower_quantile.append(np.percentile(data[param], 5))
        upper_quantile.append(np.percentile(data[param], 95))
        
        # Compute and store the coverage probability
        coverage_prob = ((data[param_lower] <= true_params[param]) & 
                         (data[param_upper] >= true_params[param])).mean()
        coverage_probs.append(coverage_prob)
        ax.plot(i, mean_mle, 'ro', label='Mean of MLEs' if i == 0 else "")
   
    # Plot the true value of the parameter
    ax.plot(np.arange(len(p_values)), [true_params[param]] * len(p_values), 'g-', label=f'True Value')
    
    # Connect the means and medians of the MLEs with a line
    ax.plot(np.arange(len(p_values)), mean_mles, 'r--')
    for i, coverage_prob in enumerate(coverage_probs):
        ax.text(i + random.uniform(-0.1, 0.1), lower_q3 + random.uniform(0, 0.01), f'CP: {coverage_prob:.2f}', 
                 horizontalalignment='center', fontsize=8)
        
    ax.fill_between(
        np.arange(len(p_values)),
        lower_quantile, upper_quantile,
        color='blue', alpha=0.15, label='95% Quantile Range')

    ax.set_xticks(np.arange(len(p_values)))
    ax.set_xticklabels(p_values)

    ax.set_xlabel('Masking Probability ($p$)')
    ax.set_ylabel(f'Statistics for ${param_label}$')    
    ax.set_title(f'CI, Mean MLEs, and Coverage Probabilities for ${param_label}$ (n = 90)')
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

fig, axes = plt.subplots(nrows=2, ncols=2, figsize=(14, 18))
plt.subplots_adjust(wspace=0.4, hspace=0.6)
# Define the parameters
shape_params = ['scales.3', 'scales.4', 'scales.5']
shape_param_labels = ["\lambda_3", "\lambda_4", "\lambda_5"]

# Load the data from a CSV file
data = pd.read_csv('./results/5_system_ci_vs_p/data-boot-tau-fixed-bca-p-vs-ci-large-b.csv')
# print the number of rows in data
print("Number of rows in data =", data.shape[0])

# Plot each parameter
for ax, param, param_label in zip(axes.flatten()[:-1], shape_params, shape_param_labels):
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
plt.savefig('plot-p-vs-stats-scale-n90-large.pdf', dpi=100)
plt.savefig('plot-p-vs-stats-scale-n90-large.png', dpi=300)
