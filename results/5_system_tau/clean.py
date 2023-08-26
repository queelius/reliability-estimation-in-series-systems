
# Importing necessary libraries
import pandas as pd

# Loading the data
file_path = 'merged_data.csv'
data = pd.read_csv(file_path)

# Extracting the columns related to MLEs for shape and scale parameters
shape_mle_columns = [col for col in data.columns if col.startswith("shape.mle")]
scale_mle_columns = [col for col in data.columns if col.startswith("scale.mle")]

# Function to remove outliers using IQR within each group of 'q'
def remove_outliers_by_group_iqr(dataframe, columns, group_column):
    cleaned_data = pd.DataFrame()
    unique_groups = dataframe[group_column].unique()
    for group in unique_groups:
        group_data = dataframe[dataframe[group_column] == group].copy()
        for col in columns:
            Q1 = group_data[col].quantile(0.25)
            Q3 = group_data[col].quantile(0.75)
            IQR = Q3 - Q1
            lower_bound = Q1 - 1.5 * IQR
            upper_bound = Q3 + 1.5 * IQR
            group_data = group_data[(group_data[col] >= lower_bound) & (group_data[col] <= upper_bound)]
        cleaned_data = pd.concat([cleaned_data, group_data])
    return cleaned_data

# Combining shape and scale MLE columns
shape_and_scale_mle_columns = shape_mle_columns + scale_mle_columns

# Removing outliers for shape and scale MLEs grouped by 'q' using IQR method
cleaned_data = remove_outliers_by_group_iqr(data, shape_and_scale_mle_columns, 'q')

# write the cleaned data to a CSV file
cleaned_data.to_csv("cleaned_data.csv", index=False)