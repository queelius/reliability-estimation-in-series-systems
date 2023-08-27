import pandas as pd

df = pd.read_csv('filename.csv', header=None)

expected_column_count = 52  # Replace with your expected column count

# Check the number of columns in each row, mark those that are incorrect
df['is_corrupted'] = df.apply(lambda x: len(x) != expected_column_count, axis=1)

# Filter out the corrupted rows
df_clean = df[~df['is_corrupted']]

# Drop the 'is_corrupted' column
df_clean.drop(columns=['is_corrupted'], inplace=True)

# Write the clean DataFrame to a new CSV file
df_clean.to_csv('clean_filename.csv', index=False, header=False)
