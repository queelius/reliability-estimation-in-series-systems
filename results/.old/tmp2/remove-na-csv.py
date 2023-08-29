#!/usr/bin/env python3
from typing import List, Optional
import pandas as pd
import argparse
import sys
import logging

def read_csv(csv_file, na_values: Optional[List[str]] = None) -> pd.DataFrame:
    default_na_values = ["NA", "NaN"]
    if na_values is None:
        na_values = default_na_values
    return pd.read_csv(csv_file, na_values=na_values)

def main() -> None:
    parser = argparse.ArgumentParser(description="Remove rows with missing values from CSV files.")
    parser.add_argument("input_csv", nargs="?", type=argparse.FileType('r'), default=sys.stdin, help="Input CSV filename or standard input.")
    parser.add_argument("-o", "--output", help="Output CSV filename.", default=sys.stdout, type=argparse.FileType("w"))
    parser.add_argument("-n", "--na-values", type=str, help="Custom list of strings to recognize as NaN, separated by commas.")
    parser.add_argument("-N", "--output-na-rep", type=str, help="String to represent NA values in the output file.", default="")

    args = parser.parse_args()

    custom_na_values = args.na_values.split(',') if args.na_values else None

    logging.basicConfig(level=logging.INFO)

    try:
        df = read_csv(args.input_csv, custom_na_values)
    except FileNotFoundError:
        logging.error("File not found.")
        sys.exit(1)
    except pd.errors.EmptyDataError:
        logging.error("File is empty.")
        sys.exit(1)

    logging.info("Processing input")

    cleaned_df = df.dropna()
    cleaned_df.to_csv(args.output, index=False, na_rep=args.output_na_rep)

    # report number of rows removed
    num_rows_removed = len(df) - len(cleaned_df)
    logging.info(f"Removed {num_rows_removed} rows with missing values.")

if __name__ == "__main__":
    main()
