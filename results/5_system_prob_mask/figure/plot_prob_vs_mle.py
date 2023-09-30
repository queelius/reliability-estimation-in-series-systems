import sys
sys.path.append('../../')
from plot_utils import plot_mle
import pandas as pd

x_col = 'p'
params = ['scale.1', 'shape.1', 'scale.4', 'shape.4']
param_labels = ['$\lambda_1$', '$k_1$', '$\lambda_4$', '$k_4$']
k = 100 # 3 or greater specifies only extreme outlier, so 100 is insane
label = 'Masking Probability'
loc = 'upper left'
data = pd.read_csv("data-small.csv")
for param, param_label in zip(params, param_labels):
  plot_mle(data, x_col, param, param_label, label, k, loc)
