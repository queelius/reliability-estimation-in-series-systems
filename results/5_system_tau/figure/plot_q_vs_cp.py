import sys
sys.path.append('../../')
from plot_utils import plot_cp
import pandas as pd

x_col = 'q'
x_col_label = 'Right-Censoring Quantile'
data = pd.read_csv("data-tau.csv")

plot_cp(data, x_col, x_col_label)
