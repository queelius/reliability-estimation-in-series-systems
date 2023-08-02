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
            data_s = remove_outliers_iqr(data_s, param)
            data_s = remove_outliers_iqr(data_s, param_lower)
            data_s = remove_outliers_iqr(data_s, param_upper)
        lower_q3 = np.percentile(data_s[param_lower], 75)
        lower_qs.append(lower_q3)
        upper_q1 = np.percentile(data_s[param_upper], 25)
        upper_qs.append(upper_q1)
        mean_mle = data_s[param].mean()
        mean_mles.append(mean_mle)

        # let's compute the .025 and .975 quantiles of data_s[param]
        #mle_lower_q = np.percentile(data_s[param], 2.5)
        #mle_upper_q = np.percentile(data_s[param], 97.5)
        #mle_lower_qs.append(mle_lower_q)
        #mle_upper_qs.append(mle_upper_q)

        #std_dev = np.std(data_s[param], ddof=1)
        #std_devs.append(std_dev)

        if (true_value_is_col):
            tval = data_s[true_value].iloc[0]
        else:
            tval = true_value

        true_values.append(tval)
        coverage_prob = ((data_s[param_lower] <= tval) & 
                         (data_s[param_upper] >= tval)).mean()
        
        coverage_probs.append(round(coverage_prob, ndigits=2))

    #return pd.DataFrame({indep_col: values, 'ci_lower_q': lower_qs, 'ci_upper_q': upper_qs, 'mean': mean_mles, 'true_value': true_values,
    #                     'std_dev': std_devs, 'cp': coverage_probs, 'lower_q': mle_lower_qs, 'upper_q': mle_upper_qs})
    return pd.DataFrame({indep_col: values, 'ci_lower_q': lower_qs, 'ci_upper_q': upper_qs, 'mean': mean_mles, 'true_value': true_values,
                         'cp': coverage_probs})

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

k3 = true_params['shapes.3']

# Load the data from a CSV file
data = pd.read_csv('/home/spinoza/github/private/proj/results/MTTF/data-boot-tau-fixed-bca-scale3.csv')

params = ['scales.2', 'shapes.2', 'scales.3', 'shapes.3']
param_labels = ['$\lambda_2$', '$k_2$', '$\lambda_3$', '$k_3$']

dfs = {}
for param in params:
    if (param == 'scales.3'):
        df = compute_stats(data = data, true_value = 'scale3', param = param, indep_col = 'scale3', true_value_is_col = True, remove_outliers = False)
    else:
        true_value = true_params[param]    
        df = compute_stats(data = data, true_value = true_value, param = param, indep_col = 'scale3', remove_outliers = False)
    dfs[param] = df

fig, axs = plt.subplots(2, 2, figsize=(15, 15))
axs = axs.flatten()
for i, (param, df) in enumerate(dfs.items()):
    # line plots
    mttf = df['scale3'] * math.gamma(1 + 1/k3)
    for col in ['mean', 'true_value']:
        #axs[i].plot(df['scale3'], df[col], label=col)
        axs[i].plot(mttf, df[col], label=col)

    #lower = df['mean'] - 1.96 * df['std_dev']
    #upper = df['mean'] + 1.96 * df['std_dev']
    #axs[i].plot(df['scale3'], lower, upper, color='r', alpha=.1)

    #axs[i].fill_between(mttf, df['lower_q'], df['upper_q'], color='g', alpha=.1)
    axs[i].fill_between(mttf, df['ci_lower_q'], df['ci_upper_q'], color='b', alpha=.1)

    # add the coverage probability (cp) as text, near the x-axis
    # jitter both the x and y positions for the CP
    for x, label in zip(mttf, df['cp']):
        x = x + random.uniform(-5, 5) - 20
        y = axs[i].get_ylim()[0] + random.uniform(-5, 5)
        axs[i].text(x, axs[i].get_ylim()[0], f"CP: {label}", va='bottom')

    # add the ci_lower_q and ci_upper_q to the legend
    axs[i].plot([], [], color='b', alpha=.1, label='IQR of 95% CI')

    # add x-axis ticks for each data point
    axs[i].set_xticks(mttf)

    # plot dots at the data points
    axs[i].plot(mttf, df['mean'], 'o', color='black', alpha=.5)

    # Set the title and labels
    axs[i].set_title(f'MTTF of Component 3 vs MLE of {param_labels[i]}')
    axs[i].set_xlabel('MTTF of Component 3')
    axs[i].set_ylabel('MLE of ' + param_labels[i])
    axs[i].legend()

#plt.tight_layout()  # Ensures that the subplots do not overlap
plt.savefig('/home/spinoza/github/private/proj/results/MTTF/plot-scale3-vs-stats.pdf')
