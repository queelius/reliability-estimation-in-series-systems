import sys
sys.path.append('../../')
from plot_utils import plot_cp
import pandas as pd

x_col = 'n'
x_col_label = 'Sample Size'
data = pd.read_csv("merged_cleaned_data.csv")

plot_cp(data, x_col, x_col_label)
