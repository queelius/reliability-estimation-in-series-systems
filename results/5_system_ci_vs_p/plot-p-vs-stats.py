import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import random

def remove_outliers_iqr(df, param):
    q1 = df[param].quantile(0.25)
    q3 = df[param].quantile(0.75)
    iqr = q3 - q1
    return df[(df[param] > q1 - 1.5 * iqr) & (df[param] < q3 + 1.5 * iqr)]

def plot_mles_and_cis(data_p, true_params, param, param_label):
    data_p_no_outliers = data_p.groupby('p').apply(remove_outliers_iqr, param).reset_index(drop=True)
    p_values = sorted(data_p_no_outliers['p'].unique())
    param_lower = param.replace('.', '.lower.')
    param_upper = param.replace('.', '.upper.')

    mean_mles = []
    lower_quantile = []
    upper_quantile = []

    plt.figure(figsize=(7, 9))

    for i, p in enumerate(p_values):
        data = data_p_no_outliers[data_p_no_outliers['p'] == p]
        lower_q3, upper_q1 = np.percentile(data[param_lower], 75), np.percentile(data[param_upper], 25)
        mean_mle = data[param].mean()
        mean_mles.append(mean_mle)
        lower_quantile.append(np.percentile(data[param], 5))
        upper_quantile.append(np.percentile(data[param], 95))

        plt.vlines(i, lower_q3, upper_q1, color='blue', alpha=0.5, label='Interquartile Range of CIs' if i == 0 else "")
        plt.plot(i, mean_mle, 'ro', label='Mean of MLEs' if i == 0 else "")

    plt.plot(np.arange(len(p_values)), [true_params[param]] * len(p_values), 'g-', label=f'True Value')
    plt.plot(np.arange(len(p_values)), mean_mles, 'r--')

    plt.fill_between(
        np.arange(len(p_values)),
        lower_quantile, upper_quantile,
        color='blue', alpha=0.15, label='95% Quantile Range')

    plt.xticks(np.arange(len(p_values)), p_values)
    plt.xlabel('Masking Probability ($p$)')
    plt.ylabel(f'Statistics for ${param_label}$')
    plt.title(f'CI, Mean MLEs, and Coverage Probabilities for ${param_label}$ (n = 90)')

    plt.legend(loc='lower right', fontsize='large')
    plt.tight_layout(h_pad=8.0, w_pad=5.0)
    plt.savefig(f'plot-p-vs-{param}-n90-large.pdf', dpi=100)
    plt.close()

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

params = ['scales.1', 'shapes.1', 'scales.2', 'shapes.2', 'scales.3', 'shapes.3', 'scales.4', 'shapes.4', 'scales.5', 'shapes.5']
param_labels = ['\lambda_1', 'k_1', '\lambda_2', 'k_2', '\lambda_3', 'k_3', '\lambda_4', 'k_4', '\lambda_5', 'k_5']

data = pd.read_csv('data-boot-tau-fixed-bca-p-vs-ci-large-b-base.csv')
# remove nan values
data = data.dropna()

print("Number of rows in data =", data.shape[0])

for param, param_label in zip(params, param_labels):
    plot_mles_and_cis(data, true_params, param, param_label)
