import pandas as pd

# Reading the CSV file
file_path = "prob-shape3-vary.csv"
data = pd.read_csv(file_path)

# Getting the headers
headers = data.columns.tolist()

# Initial number of rows
initial_rows = data.shape[0]

# Removing the 'prob1' column
data.drop(columns=['prob1'], inplace=True)

# Renaming the 'shapes1' column to 'shape3'
data.rename(columns={'shapes1': 'shape3'}, inplace=True)

# Replacing "NA" string with NaN and dropping rows with NaN values
data.replace("NA", pd.NA, inplace=True)
data.dropna(inplace=True)

# Number of rows removed due to NaN values
rows_removed = initial_rows - data.shape[0]
rows_removed

# Writing the new CSV file
new_file_path = "prob-shape3-vary-mod.csv"
data.to_csv(new_file_path, index=False)

