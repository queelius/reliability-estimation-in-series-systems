import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import random

def remove_outliers_iqr(df, param_mle):
    q1 = df[param_mle].quantile(0.25)
    q3 = df[param_mle].quantile(0.75)
    iqr = q3 - q1
    return df[(df[param_mle] > q1 - 1.5 * iqr) & (df[param_mle] < q3 + 1.5 * iqr)]

def plot_mles_and_cis(raw_data, x_col, param, param_label):

    # 'shape.lower.1' and upper CI is 'shape.upper.1'
    param_lower = f'{param.split(".")[0]}.lower.{param.split(".")[1]}'
    param_upper = f'{param.split(".")[0]}.upper.{param.split(".")[1]}'

    print(param_lower, param_upper)

    # prepare MLEs. if param == 'shape.1', then MLE is 'shape.mle.1'
    param_mle = f'{param.split(".")[0]}.mle.{param.split(".")[1]}'

    print(param_mle)

    iqr_data = raw_data.groupby(x_col).apply(remove_outliers_iqr, param_mle).reset_index(drop=True)
    x_values = sorted(iqr_data[x_col].unique())
    print("here are x-values:")
    print(x_values)
    
    y_values = [raw_data[raw_data[x_col] == x][param].mean() for x in x_values]
    print("here are y-values:")
    print(y_values)


    mean_mles = []
    lower_quantile = []
    upper_quantile = []

    plt.figure(figsize=(4, 4))

    for i, x in enumerate(x_values):
        data = iqr_data[iqr_data[x_col] == x]
        lower_q3, upper_q1 = np.percentile(data[param_lower], 75), np.percentile(data[param_upper], 25)
        print(lower_q3, upper_q1)
        mean_mle = data[param_mle].mean()
        mean_mles.append(mean_mle)
        lower_quantile.append(np.percentile(data[param_mle], 5))
        upper_quantile.append(np.percentile(data[param_mle], 95))

        plt.vlines(i, lower_q3, upper_q1, color='blue', alpha=0.5, label='IQR of CIs' if i == 0 else "")
        plt.plot(i, mean_mle, 'ro', label='Mean of MLEs' if i == 0 else "")

    plt.plot(np.arange(len(x_values)), y_values, 'g*', label='True Parameter Value')

    plt.plot(np.arange(len(x_values)), mean_mles, 'r--')
    plt.fill_between(
        np.arange(len(x_values)),
        lower_quantile, upper_quantile,
        color='blue', alpha=0.15, label='95% Quantile Range')

    # angle the x-axis labels
    # and round the values to 2 decimal places
    plt.xticks(np.arange(len(x_values)), [round(x, 2) for x in x_values], rotation=45)
    plt.xlabel('Probability of 3rd Component Failure')
    plt.ylabel(f'Statistics for ${param_label}$')
    plt.title(f'MLE for ${param_label}$')
    
    plt.legend(loc='upper right')
    leg = plt.gca().get_legend()
    for text in leg.get_texts():
        plt.setp(text, fontsize='small')

    plt.tight_layout(h_pad=4.0, w_pad=2.5)
    plt.savefig(f'plot-{x_col}-vs-{param}.pdf')
    plt.close()

#x_col = 'shape.3'
x_col = 'prob3'
params = ['scale.1', 'shape.1', 'scale.2', 'shape.2', 'scale.3', 'shape.3', 'scale.4', 'shape.4', 'scale.5', 'shape.5']
param_labels = ['\lambda_1', 'k_1', '\lambda_2', 'k_2', '\lambda_3', 'k_3', '\lambda_4', 'k_4', '\lambda_5', 'k_5']
data = pd.read_csv('data.csv')

print("Number of rows in data =", data.shape[0])

for param, param_label in zip(params, param_labels):
    plot_mles_and_cis(data, x_col, param, param_label)
