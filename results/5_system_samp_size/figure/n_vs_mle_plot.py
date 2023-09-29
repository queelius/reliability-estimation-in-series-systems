import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import random

k = 1000

def remove_outliers_iqr(df, param_mle):
    q1 = df[param_mle].quantile(0.25)
    q3 = df[param_mle].quantile(0.75)
    iqr = q3 - q1
    return df[(df[param_mle] > q1 - k * iqr) & (df[param_mle] < q3 + k * iqr)]

def plot_mles_and_cis(raw_data, x_col, true_params, param, param_label):

    # 'shape.lower.1' and upper CI is 'shape.upper.1'
    param_lower = f'{param.split(".")[0]}.lower.{param.split(".")[1]}'
    param_upper = f'{param.split(".")[0]}.upper.{param.split(".")[1]}'

    print(param_lower, param_upper)

    # prepare MLEs. if param == 'shape.1', then MLE is 'shape.mle.1'
    param_mle = f'{param.split(".")[0]}.mle.{param.split(".")[1]}'

    print(param_mle)

    iqr_data = raw_data.groupby(x_col).apply(remove_outliers_iqr, param_mle).reset_index(drop=True)
    x_values = sorted(iqr_data[x_col].unique())
    print(x_values)

    median_mles = []
    mean_mles = []
    lower_quantile = []
    upper_quantile = []

    plt.figure(figsize=(4, 4))

    for i, x in enumerate(x_values):
        data = iqr_data[iqr_data[x_col] == x]
        lower_q3, upper_q1 = np.percentile(data[param_lower], 50), np.percentile(data[param_upper], 50)
        print(lower_q3, upper_q1)
        mean_mle = data[param_mle].mean()
        mean_mles.append(mean_mle)
        median_mle = data[param_mle].median()
        median_mles.append(median_mle)
        lower_quantile.append(np.percentile(data[param_mle], 2.5))
        upper_quantile.append(np.percentile(data[param_mle], 97.5))

        plt.vlines(i, lower_q3, upper_q1, color='blue', alpha=0.5, label='Median 95% CI' if i == 0 else "")
        plt.plot(i, mean_mle, 'ro', label='Mean MLE' if i == 0 else "")
        plt.plot(i, median_mle, 'bo', label='Median MLE' if i == 0 else "")

    plt.plot(np.arange(len(x_values)), [true_params[param]] * len(x_values), 'g-', label=f'True Value')
    plt.plot(np.arange(len(x_values)), mean_mles, 'r--')
    plt.plot(np.arange(len(x_values)), median_mles, 'b--')
    
    plt.fill_between(
        np.arange(len(x_values)),
        lower_quantile, upper_quantile,
        color='blue', alpha=0.15, label='95% Quantile Range')

    # angle the x-axis labels
    plt.xticks(np.arange(len(x_values)), x_values)
    plt.xlabel('Sample Size ($n$)')
    plt.ylabel(f'Statistics for ${param_label}$')
    plt.title(f'MLE for ${param_label}$')

    
    plt.legend(loc='upper right')

    # decrease text side of legend
    leg = plt.gca().get_legend()
    for text in leg.get_texts():
        plt.setp(text, fontsize='small')

    plt.tight_layout(h_pad=4.0, w_pad=2.5)
    #plt.savefig(f'plot-{x_col}-vs-{param}.png', dpi=150)

    # make it so that the gaps between x-axis ticks scale with the distance between the ticks
    

    plt.savefig(f'plot-{x_col}-vs-{param}.pdf')
    plt.close()

true_params = {
    'shape.1': 1.2576,
    'scale.1': 994.3661,
    'shape.2': 1.1635,
    'scale.2': 908.9458,
    'shape.3': 1.1308,
    'scale.3': 840.1141,
    'shape.4': 1.1802,
    'scale.4': 940.1342,
    'shape.5': 1.2034,
    'scale.5': 923.1631
}

x_col = 'n'
params = ['scale.1', 'shape.1', 'scale.2', 'shape.2', 'scale.3', 'shape.3', 'scale.4', 'shape.4', 'scale.5', 'shape.5']
param_labels = ['\lambda_1', 'k_1', '\lambda_2', 'k_2', '\lambda_3', 'k_3', '\lambda_4', 'k_4', '\lambda_5', 'k_5']

#data = pd.read_csv('5_system_samp_size.csv', na_values=['NA', 'nan', 'NaN', 'NAN'])
data = pd.read_csv('cleaned-theta-small-2.csv')
#data = pd.read_csv('5_system_samp_size.csv')
# remove nan values
#data = data.dropna()

print("Number of rows in data =", data.shape[0])

for param, param_label in zip(params, param_labels):
    plot_mles_and_cis(data, x_col, true_params, param, param_label)
