import pandas as pd
import os

# recursively walk the subdirectories of the current working dir and retrieve all *.csv filenames in the sub-directories and put them in `file_paths`
file_paths = []
for root, dirs, files in os.walk("."):
    for file in files:
        if file.endswith(".csv"):
            file_paths.append(os.path.join(root, file))

print(file_paths)
    

# Merging all the CSV files into a single data frame. The `ignore_index=True` argument is used to reset the index of the resulting DataFrame.
# The `na_values='NA'` argument is used to convert the string 'NA' to a NaN value, to handle missing values from R outputs.
merged_data = pd.concat([pd.read_csv(file_path, na_values='NA') for file_path in file_paths], ignore_index=True)


# report the number of rows and columns in the merged data frame
print(merged_data.shape)
# report the number of rows in which any column has a missing value.
print("rows with missing values: ", merged_data.isnull().any(axis=1).sum())

# report rows with missing values and place the result in a new data frame
missing_data = merged_data[merged_data.isnull().any(axis=1)]
# print how many rows are in the missing data per unique `q` column value
print("missing values per `q` column")
print(missing_data.groupby('q').size())

# filter the missing values
merged_data = merged_data.dropna()
# print rows in non-missing data
print("rows without missing values: ", merged_data.shape[0])

# Fixed true shape and scale parameters
true_shape_scale_values = {
    "shape.1": 1.2576, "scale.1": 994.3661,
    "shape.2": 1.1635, "scale.2": 908.9458,
    "shape.3": 1.1308, "scale.3": 840.1141,
    "shape.4": 1.1802, "scale.4": 940.1342,
    "shape.5": 1.2034, "scale.5": 923.1631,
}

# Adding the fixed true shape and scale parameters to each row
for column, value in true_shape_scale_values.items():
    merged_data[column] = value

# Renaming the columns as per the instructions
rename_dict = {
    **{f"shapes.{i}": f"shape.mle.{i}" for i in range(1, 6)},
    **{f"scales.{i}": f"scale.mle.{i}" for i in range(1, 6)},
    **{f"shapes.lower.{i}": f"shape.lower.{i}" for i in range(1, 6)},
    **{f"shapes.upper.{i}": f"shape.upper.{i}" for i in range(1, 6)},
    **{f"scales.lower.{i}": f"scale.lower.{i}" for i in range(1, 6)},
    **{f"scales.upper.{i}": f"scale.upper.{i}" for i in range(1, 6)},
}

# Applying the renaming
merged_data.rename(columns=rename_dict, inplace=True)

# print the first 5 rows of the merged data frame
print(merged_data.head())

# save the merged data frame to a CSV file
merged_data.to_csv("merged_data.csv", index=False)
