import pandas as pd
import numpy as np

# Function to generate the new name
def generate_new_name(col):
    prefix, suffix = col.rsplit('.', 1)
    return f"{prefix}.{suffix}"

#read csv file data-boot.csv

file = "data-boot-orig.csv"
df = pd.read_csv(file)


for col in df.columns:
    # if column ends with an integer string
    if col[-1].isdigit():
        # generate the new name. convert the string to int.
        # this is based off the last integer in the column name,
        # not the last digit, for instance if we have "test.10"
        # we want to get 10, not 0, and if we have "test.5" we
        # want to get 5.
        col_int = int(col.rsplit('.', 1)[1])
        # if the integer is odd, it's a shape parameter
        if col_int % 2 == 1:
            ends_with = "shape"
        else:
            ends_with = "scale"
        # 1 -> 1, 2 -> 1, 3 -> 2, 4 -> 2, 5 -> 3, 6 -> 3, ..., 9 -> 5, 10 -> 5, ...
        col_int = (col_int + 1) // 2
        # add this to the suffice of ends_with
        new_col = f"{ends_with}.{col_int}"
        # now we get the prefix of the column name, up until the "."
        prefix = col.rsplit('.', 1)[0]
        # now we get the new name
        new_col = f"{prefix}.{new_col}"
        # rename the column
        df.rename(columns={col: new_col}, inplace=True)

        


# write the csv
df.to_csv(file, index=False)
