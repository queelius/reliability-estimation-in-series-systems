import sys
sys.path.append('../../')
from plot_utils import plot_cp
import pandas as pd

x_col = 'p'
x_col_label = 'Masking Probability'
data = pd.read_csv("data-small.csv")

plot_cp(data, x_col, x_col_label)