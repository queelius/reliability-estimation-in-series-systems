# import gamma function from scipy.special
from scipy.special import gamma
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import pandas as pd
import numpy as np
import random

def remove_outliers(df, param):
    mean = df[param].mean()
    std_dev = df[param].std()
    return df[(df[param] > mean - 3*std_dev) & (df[param] < mean + 3*std_dev)]

def remove_outliers_iqr(df, param, d = 1.5):
    q1 = df[param].quantile(0.25)
    q3 = df[param].quantile(0.75)
    iqr = q3 - q1
    return df[(df[param] > q1 - d*iqr) & (df[param] < q3 + d*iqr)]

def compute_stats(data, true_value, indep_col, param, true_value_is_col = False, remove_outliers = False):
    # remove any rows with any NA or NaN columns
    data = data.dropna()
    values = sorted(data[indep_col].unique())
    mean_mles = []
    true_values = []
    std_devs = []
    mle_lower_qs = []
    mle_upper_qs = []
    for val in values:
        data_s = data[data[indep_col] == val]
        if remove_outliers:
            data_s = remove_outliers_iqr(data_s, param, 5)
            
        upper = np.percentile(data_s[param], 97.5)
        lower = np.percentile(data_s[param], 2.5)
        mle_lower_qs.append(lower)
        mle_upper_qs.append(upper)
        mean_mle = data_s[param].mean()
        mean_mles.append(mean_mle)

        if (true_value_is_col):
            tval = data_s[true_value].iloc[0]
        else:
            tval = true_value

        true_values.append(tval)

    return pd.DataFrame({indep_col: values, 'lower': mle_lower_qs, 'upper': mle_upper_qs, 'mean': mean_mles, 'true_value': true_values})

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

scale3 = true_params['scales.3']

data = pd.read_csv('/home/spinoza/github/private/proj/results/MTTF/data-mttf-shape3-vary-3.csv')

params = ['scales.1', 'shapes.1', 'scales.3', 'shapes.3']
param_labels = ['$\lambda_1$', '$k_1$', '$\lambda_3$', '$k_3$']

dfs = {}
for param in params:
    if (param == 'shapes.3'):
        df = compute_stats(data = data, true_value = 'shape3', param = param, indep_col = 'shape3', true_value_is_col = True, remove_outliers = True)
    else:
        true_value = true_params[param]
        df = compute_stats(data = data, true_value = true_value, param = param, indep_col = 'shape3', remove_outliers = True)
    dfs[param] = df

fig, axs = plt.subplots(len(params)//2, 2, figsize=(15, 15))
axs = axs.flatten()
for i, (param, df) in enumerate(dfs.items()):
    mttf = scale3 * gamma(1 + 1/df['shape3'])
    for col in ['mean', 'true_value']:
        axs[i].plot(mttf, df[col], label=col)

    axs[i].fill_between(mttf, df['lower'], df['upper'], color='b', alpha=.1)

    labels = axs[i].get_xticks().tolist()
    axs[i].set_xticklabels(labels, rotation=45)
    axs[i].xaxis.set_major_formatter(ticker.FuncFormatter(lambda x, pos: '{:,.2f}'.format(x)))
    
    axs[i].set_xticks(mttf)
    axs[i].plot(mttf, df['mean'], 'o', color='black', alpha=.5)
    axs[i].set_title(f'Probability of Component 3 Failure vs MLE of {param_labels[i]}')
    axs[i].set_xlabel('Probability of Component 3 Failure')
    axs[i].set_ylabel('MLE of ' + param_labels[i])
    axs[i].legend()

plt.tight_layout()  # Ensures that the subplots do not overlap
plt.savefig('/home/spinoza/github/private/proj/results/MTTF/plot-shape-vary-large.pdf')
