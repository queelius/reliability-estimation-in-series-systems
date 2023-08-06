from scipy.special import gamma
import matplotlib.pyplot as plt
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
    param_lower = param.replace('.', '.lower.')
    param_upper = param.replace('.', '.upper.')
    mean_mles = []
    true_values = []
    std_devs = []
    coverage_probs = []
    lower_qs = []
    upper_qs = []
    mle_lower_qs = []
    mle_upper_qs = []
    for val in values:
        data_s = data[data[indep_col] == val]
        if remove_outliers:
            data_s = remove_outliers_iqr(data_s, param, 8)
            data_s = remove_outliers_iqr(data_s, param_lower, 8)
            data_s = remove_outliers_iqr(data_s, param_upper, 8)
        lower_q3 = np.percentile(data_s[param_lower], 75)
        lower_qs.append(lower_q3)
        upper_q1 = np.percentile(data_s[param_upper], 25)
        upper_qs.append(upper_q1)
        mean_mle = data_s[param].mean()
        mean_mles.append(mean_mle)

        if (true_value_is_col):
            tval = data_s[true_value].iloc[0]
        else:
            tval = true_value

        true_values.append(tval)
        coverage_prob = ((data_s[param_lower] <= tval) & 
                         (data_s[param_upper] >= tval)).mean()
        
        coverage_probs.append(round(coverage_prob, ndigits=2))

    return pd.DataFrame({indep_col: values, 'ci_lower_q': lower_qs, 'ci_upper_q': upper_qs, 'mean': mean_mles, 'true_value': true_values,
                         'cp': coverage_probs})

true_params = {
    'shapes.1': 1.2576,
    'scales.1': 994.3661,
    'shapes.2': 1.1635,
    'scales.2': 908.9458,
    'shapes.3': 1.1308,
    'scales.3': 500,
    #'scales.3': 840.1141,
    'shapes.4': 1.1802,
    'scales.4': 940.1342,
    'shapes.5': 1.2034,
    'scales.5': 923.1631
}

scale3 = true_params['scales.3']

data = pd.read_csv('/home/spinoza/github/private/proj/results/MTTF/data-shape-vary-with-low-prob.csv')

params = ['scales.1', 'shapes.1', 'scales.2', 'shapes.2', 'scales.3', 'shapes.3', 'scales.4', 'shapes.4', 'scales.5', 'shapes.5']
param_labels = ['$\lambda_1$', '$k_1$', '$\lambda_2$', '$k_2$', '$\lambda_3$', '$k_3$', '$\lambda_4$', '$k_4$', '$\lambda_5$', '$k_5$']

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

    axs[i].fill_between(mttf, df['ci_lower_q'], df['ci_upper_q'], color='b', alpha=.1)

    for x, label in zip(mttf, df['cp']):
        x = x + random.uniform(-5, 5) - 20
        y = axs[i].get_ylim()[0] + random.uniform(-5, 5)
        axs[i].text(x, axs[i].get_ylim()[0], f"CP: {label}", va='bottom')

    axs[i].plot([], [], color='b', alpha=.1, label='IQR of 95% CI')
    axs[i].set_xticks(mttf)
    axs[i].plot(mttf, df['mean'], 'o', color='black', alpha=.5)
    axs[i].set_title(f'MTTF of Component 3 vs MLE of {param_labels[i]}')
    axs[i].set_xlabel('MTTF of Component 3')
    axs[i].set_ylabel('MLE of ' + param_labels[i])
    axs[i].legend()

plt.tight_layout()  # Ensures that the subplots do not overlap
plt.savefig('/home/spinoza/github/private/proj/results/MTTF/plot-shape-vary-with-low-prob.pdf')
