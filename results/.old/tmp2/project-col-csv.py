#!/usr/bin/env python3
from typing import List, Optional
import pandas as pd
import argparse
import sys
import logging

def read_csv(csv_file, na_values: Optional[str] = None) -> pd.DataFrame:
    default_na_values = ["NA", "NaN"]
    if na_values is None:
        na_values = default_na_values
    return pd.read_csv(csv_file, na_values=na_values)

def project_columns(df: pd.DataFrame, columns: List[str]) -> pd.DataFrame:
    return df[columns]

def main() -> None:
    parser = argparse.ArgumentParser(description="Project specified columns from a CSV file.")
    parser.add_argument("input_csv", nargs="?", type=argparse.FileType('r'), default=sys.stdin, help="Input CSV filename or standard input.")
    parser.add_argument("-o", "--output", help="Output CSV filename.", default=sys.stdout, type=argparse.FileType("w"))
    parser.add_argument("-c", "--columns", required=True, type=str, help="Comma-separated list of columns to keep.")

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

    columns_to_keep = args.columns.split(',')
    projected_df = project_columns(df, columns_to_keep)
    projected_df.to_csv(args.output, index=False)

    # report number of removed from projected columns
    num_columns_removed = len(df.columns) - len(projected_df.columns)

    logging.info("Removed %d columns from input. Output has %d columns.", num_columns_removed, len(projected_df.columns))

if __name__ == "__main__":
    main()
