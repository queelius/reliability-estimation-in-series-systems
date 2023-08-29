#!/usr/bin/env python3
from typing import Optional
import pandas as pd
import argparse
import sys
import logging

def read_csv(csv_file, na_values: Optional[str] = None) -> pd.DataFrame:
    default_na_values = ["NA", "NaN"]
    if na_values is None:
        na_values = default_na_values
    return pd.read_csv(csv_file, na_values=na_values)

def print_metadata(df: pd.DataFrame) -> None:
    num_rows = df.shape[0]
    num_cols = df.shape[1]
    column_names = list(df.columns)
    column_dtypes = df.dtypes.to_dict()
    total_na = df.isna().sum().sum()
    rows_with_na = df.isna().any(axis=1).sum()

    print(f"Number of Rows: {num_rows}")
    print(f"Number of Columns: {num_cols}")
    print("Column Names:")
    for name in column_names:
        # print column name along with column dtype
        print(f"    {name} ({column_dtypes[name]})")
    print(f"Number of Rows with NA: {rows_with_na}")

def main() -> None:
    parser = argparse.ArgumentParser(description="Print metadata of a CSV file.")
    parser.add_argument("input_csv", nargs="?", type=argparse.FileType('r'), default=sys.stdin, help="Input CSV filename or standard input.")

    args = parser.parse_args()

    logging.basicConfig(level=logging.INFO)

    try:
        df = read_csv(args.input_csv)
    except FileNotFoundError:
        logging.error("File not found.")
        sys.exit(1)
    except pd.errors.EmptyDataError:
        logging.error("File is empty.")
        sys.exit(1)

    logging.info("Processing input")

    print_metadata(df)

    logging.info("Metadata printed.")

if __name__ == "__main__":
    main()
