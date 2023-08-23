# Import necessary libraries
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Define the function to calculate IQR
def calculate_iqr(data, column):
    Q1 = data[column].quantile(0.25)
    Q3 = data[column].quantile(0.75)
    IQR = Q3 - Q1
    return IQR, Q1, Q3

# Load the data
data = pd.read_csv('./data-boot-tau-fixed-bca-p-vs-ci.csv')

# Calculate IQR for scales.1
iqr_scales_1, Q1_scales_1, Q3_scales_1 = calculate_iqr(data, 'scales.1')

# Define bounds for scales.1
lower_bound_scales_1 = Q1_scales_1 - 1.5 * iqr_scales_1
upper_bound_scales_1 = Q3_scales_1 + 1.5 * iqr_scales_1

# Remove outliers from original data
filtered_data = data[(data['scales.1'] >= lower_bound_scales_1) & 
                     (data['scales.1'] <= upper_bound_scales_1)]

# Define the true value for scale.1
true_scale_1 = 994.3661

# Create a new DataFrame for the lower and upper bounds of each confidence interval
ci_df = pd.melt(filtered_data, id_vars=['p'], value_vars=['scales.lower.1', 'scales.upper.1'])

# Create a box plot of the confidence intervals for each value of p
plt.figure(figsize=(15, 10))
box_plot = sns.boxplot(x='p', y='value', data=ci_df)

# Overlay the true value of scale.1
box_plot.axhline(true_scale_1, color='r', linestyle='--', label='True value')

# Set the labels and title
plt.xlabel('Candidate Masking Probability (p)')
plt.ylabel('CI Bounds for scale.1')
plt.title('Distribution of Confidence Intervals for scale.1 as a function of p')
plt.legend()

# Show the plot
plt.show()
