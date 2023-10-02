import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter
import numpy as np

def remove_outliers(data, par_mle, k=100):
    q1 = data[par_mle].quantile(0.25)
    q3 = data[par_mle].quantile(0.75)
    iqr = q3 - q1
    return data[(data[par_mle] > q1 - k * iqr) & (data[par_mle] < q3 + k * iqr)]

def plot_cp(data, x_col, x_col_label):
    rel_cols = [x_col] + [f'shape.{i}' for i in range(1, 6)] + [f'scale.{i}' for i in range(1, 6)] + \
        [f'shape.lower.{i}' for i in range(1, 6)] + [f'shape.upper.{i}' for i in range(1, 6)] + \
        [f'scale.lower.{i}' for i in range(1, 6)] + [f'scale.upper.{i}' for i in range(1, 6)]
    rel_data = data[rel_cols].copy()

    def compute_coverage(row, j):
        shape_in_ci = row[f'shape.lower.{j}'] <= row[f'shape.{j}'] <= row[f'shape.upper.{j}']
        scale_in_ci = row[f'scale.lower.{j}'] <= row[f'scale.{j}'] <= row[f'scale.upper.{j}']
        return pd.Series([shape_in_ci, scale_in_ci], index=[f'shape_coverage.{j}', f'scale_coverage.{j}'])

    for j in range(1, 6):
        rel_data[[f'shape_coverage.{j}', f'scale_coverage.{j}']] = rel_data.apply(lambda row: compute_coverage(row, j), axis=1)

    coverage_cols = [f'shape_coverage.{j}' for j in range(1, 6)] + [f'scale_coverage.{j}' for j in range(1, 6)]
    cps = rel_data.groupby(x_col)[coverage_cols].mean().reset_index()

    # Mean coverage probabilities
    mean_shape_cp = cps[[f'shape_coverage.{j}' for j in range(1, 6)]].mean(axis=1)
    mean_scale_cp = cps[[f'scale_coverage.{j}' for j in range(1, 6)]].mean(axis=1)
    cps['mean_shape_cp'] = mean_shape_cp
    cps['mean_scale_cp'] = mean_scale_cp

    print(cps[[f'scale_coverage.{j}' for j in range(1, 6)]].head())
    print(cps[[f'shape_coverage.{j}' for j in range(1, 6)]].head())

    plt.figure(figsize=[5, 4])
    shape_cmap = plt.get_cmap('Blues')
    scale_cmap = plt.get_cmap('Reds')

    shape_ls = ['-', '--', '-.', ':', '-']
    shape_mk = ['o', 's', '^', 'x', 'D']

    for j, color, ls, mk in zip(range(1, 6), shape_cmap(np.linspace(0.4, 1, 5)), shape_ls, shape_mk):
        plt.plot(cps[x_col], cps[f'shape_coverage.{j}'], label=f'$k_{j}$', color=color, linestyle=ls, marker=mk)

    scale_ls = ['-', '--', '-.', ':', '-']
    scale_mk = ['o', 's', '^', 'x', 'D']

    for j, color, ls, mk in zip(range(1, 6), scale_cmap(np.linspace(0.4, 1, 5)), scale_ls, scale_mk):
        plt.plot(cps[x_col], cps[f'scale_coverage.{j}'], label=f'$\lambda_{j}$', color=color, linestyle=ls, marker=mk)


    plt.plot(cps[x_col], cps['mean_shape_cp'],
             color='darkblue', linewidth=4, linestyle='-', label='$\\bar{k}$')
    plt.plot(cps[x_col], cps['mean_scale_cp'],
             color='darkred', linewidth=4, linestyle='-', label='$\\bar{\lambda}$')

    plt.axhline(y=0.95, color='green', linestyle='--', label='$95\\%$')
    plt.axhline(y=0.90, color='red', linestyle='--', label='$90\\%$')
    plt.xlabel(f'{x_col_label} (${x_col}$)')
    plt.ylabel('Coverage Probability (CP)')
    plt.gca().yaxis.set_major_formatter(
        FuncFormatter(lambda y, _: '{:.2f}'.format(y)))
    plt.title('Coverage Probabilities for Parameters')
    plt.legend(loc='best', bbox_to_anchor=(1, 1))
    plt.tight_layout()
    plt.savefig(f'plot-{x_col}-vs-cp.pdf')


def plot_mle(raw_data, x_col, par, par_label, label, k=100, loc='upper left'):
    ps = par.split('.')
    par_low = f'{ps[0]}.lower.{ps[1]}'
    par_up = f'{ps[0]}.upper.{ps[1]}'
    par_mle = f'{ps[0]}.mle.{ps[1]}'

    # pass the k argument to remove_outliers
    raw_data = raw_data.groupby(x_col).apply(
        remove_outliers, par_mle, k).reset_index(drop=True)
    x_vals = sorted(raw_data[x_col].unique())

    median_mles = []
    true_vals = []
    mean_mles = []
    low_q = []
    up_q = []
    plt.figure(figsize=(4, 4))

    for i, x in enumerate(x_vals):
        data = raw_data[raw_data[x_col] == x]
        low_med, up_med = np.percentile(
            data[par_low], 50), np.percentile(data[par_up], 50)
        mean_mle = data[par_mle].mean()
        true_val = data[par].mean()
        median_mle = data[par_mle].median()
        mean_mles.append(mean_mle)
        median_mles.append(median_mle)
        low_q.append(np.percentile(data[par_mle], 2.5))
        up_q.append(np.percentile(data[par_mle], 97.5))
        true_vals.append(true_val)

        plt.vlines(i, low_med, up_med, color='blue',
                   label='Median 95% CI' if i == 0 else "")
        plt.plot(i, mean_mle, 'ro', label='Mean MLE' if i == 0 else "")
        plt.plot(i, median_mle, 'bo', label='Median MLE' if i == 0 else "")

    plt.plot(np.arange(len(x_vals)), mean_mles, 'r--')
    plt.plot(np.arange(len(x_vals)), median_mles, 'b--')
    plt.plot(np.arange(len(x_vals)), true_vals,
             'g-', label='True Value', linewidth=2)

    plt.fill_between(np.arange(len(x_vals)), low_q, up_q,
                     color='blue', alpha=0.15, label='95% Quantile Range')

    plt.xticks(np.arange(len(x_vals)), x_vals)
    plt.xlabel(f'{label} (${x_col}$)')
    plt.ylabel(f'Statistics for {par_label}')
    plt.title(f'MLE for {par_label}')
    plt.legend(loc=loc)

    leg = plt.gca().get_legend()
    for text in leg.get_texts():
        plt.setp(text, fontsize='small')

    plt.tight_layout(h_pad=4.0, w_pad=2.5)
    plt.savefig(f'plot-{x_col}-vs-{par}-mle.pdf')
    plt.close()
