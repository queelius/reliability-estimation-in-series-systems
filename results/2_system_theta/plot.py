import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.interpolate import make_interp_spline
from sklearn.neighbors import LocalOutlierFactor
from statsmodels.nonparametric.smoothers_lowess import lowess

# Read the data from the CSV file
file_path = "./prob-shape1-vary-unmasked.csv"  # Change this to the path of your CSV file
data = pd.read_csv(file_path)

# Compute biases
data['bias_scale1'] = data['scale.mles.1'] - data['scale1']
data['bias_shape1'] = data['shape.mles.1'] - data['shape1']
data['bias_scale2'] = data['scale.mles.2'] - data['scale2']
data['bias_shape2'] = data['shape.mles.2'] - data['shape2']

# Function to remove outliers using Local Outlier Factor (LOF)
def remove_outliers(df):
    lof = LocalOutlierFactor()
    outlier_predictions = lof.fit_predict(df[['bias_scale1', 'bias_shape1', 'bias_scale2', 'bias_shape2']])
    return df[outlier_predictions == 1]

def plot_loess(ax, x, y, title, xlabel, ylabel, custom_scale = None):
    smooth_data = lowess(y, x, frac=0.3)
    ax.plot(smooth_data[:, 0], smooth_data[:, 1], 'r-', label='Bias (LOESS Smoothed)')
    ax.axhline(y=0, color='g', linestyle='--', label='Unbiased Line')
    ax.set_title(title)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.legend()
    if custom_scale is not None:
        ax.set_ylim(custom_scale)


def plot_mean(ax, x, y, title, xlabel, ylabel, custom_scale=None):
    # Create a DataFrame from x and y
    mean_data = pd.DataFrame({'x': x, 'y': y})
    
    # Group by unique x values and calculate the mean of y for each group
    mean_data_grouped = mean_data.groupby('x').mean().reset_index()

    ax.plot(mean_data_grouped['x'], mean_data_grouped['y'], 'r-', label='Bias (Mean)')
    ax.axhline(y=0, color='g', linestyle='--', label='Unbiased Line')
    ax.set_title(title)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.legend()
    if custom_scale is not None:
        ax.set_ylim(custom_scale)

def create_plots_for(plot, n, p, q, data, prob_lo = 0.0, prob_hi = 0.55, remove_outliers = True):
    # Filtering the data based on the specified criteria
    filtered_data = data[(data['n'] == n) & (data['p'] == p) & (data['q'] == q) &
                         (data['probs'] >= prob_lo) & (data['probs'] <= prob_hi)]
    
    #filtered_data = remove_outliers(filtered_data)

    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    fig.suptitle(f'Bias vs Component 1 Failure Probability (Scenario: n = {n}, p = {p}, q = {q})')

    plot(axes[0, 0], filtered_data['probs'], filtered_data['bias_shape1'],
               'Bias of Shape Parameter 1',
               'Probability that Component 1 Fails',
               'Bias of Shape Parameter 1', None)

    plot(axes[0, 1], filtered_data['probs'], filtered_data['bias_scale1'],
               'Bias of Scale Parameter 1',
               'Probability that Component 1 Fails',
               'Bias of Scale Parameter 1', None)

    plot(axes[1, 0], filtered_data['probs'], filtered_data['bias_shape2'],
               'Bias of Shape Parameter 2',
               'Probability that Component 1 Fails',
               'Bias of Shape Parameter 2', None)

    plot(axes[1, 1], filtered_data['probs'], filtered_data['bias_scale2'],
               'Bias of Scale Parameter 2',
               'Probability that Component 1 Fails',
               'Bias of Scale Parameter 2', None)

    plt.tight_layout(rect=[0, 0.03, 1, 0.95])
    plt.savefig(f'./loess_smoothed_n_{n}_p_{p}_q_{q}_probs_{prob_lo}_-_{prob_hi}.png')
    plt.savefig(f'./loess_smoothed_n_{n}_p_{p}_q_{q}_probs_{prob_lo}_-_{prob_hi}.pdf')

#unique_p_values = data[data['n'] == 100]['p'].unique()
ps = data['p'].unique()
qs = data['q'].unique()
ns = data['n'].unique()


shape_ylim_custom = (-0.01, 0.04)

create_plots_for(plot_loess, n=100, p=0, q=1, data=data, prob_lo=0.0, prob_hi=0.55, remove_outliers=False)
create_plots_for(plot_loess, n=100, p=.215, q=.825, data=data, prob_lo=0.0, prob_hi=0.55, remove_outliers=False)


# Creating the 2x2 LOESS-smoothed plots for all combinations of p and q for n=100
#for n in ns:
#    for p in ps:
#        for q in qs:
#            create_loess_plots_for(n=n, p=p, q=q, data=data)

