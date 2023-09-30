import sys
sys.path.append('../../')
from plot_utils import plot_mle
import pandas as pd

x_col = 'q'
params = ['scale.1', 'shape.1', 'scale.3', 'shape.3']
param_labels = ['$\lambda_1$', '$k_1$', '$\lambda_3$', '$k_3$']
k = 100 # 3 or greater specifies only extreme outlier, so 100 is insane
label = 'Right-Censoring Quantile'
loc = 'upper right'

data = pd.read_csv("data-tau.csv")
for param, param_label in zip(params, param_labels):
  plot_mle(data, x_col, param, param_label, label, k, loc)
