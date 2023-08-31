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

def filter_rows(df: pd.DataFrame, condition: str) -> pd.DataFrame:
    return df.query(condition)

def main() -> None:
    parser = argparse.ArgumentParser(description="Filter rows from CSV files based on conditions.")
    parser.add_argument("input_csv", nargs="?", type=argparse.FileType('r'), default=sys.stdin, help="Input CSV filename or standard input.")
    parser.add_argument("-o", "--output", help="Output CSV filename.", default=sys.stdout, type=argparse.FileType("w"))
    parser.add_argument("-c", "--condition", required=True, type=str, help="Condition for row filtering.")

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

    filtered_df = filter_rows(df, args.condition)
    filtered_df.to_csv(args.output, index=False)

    # report number of rows removed
    num_rows_removed = len(df) - len(filtered_df)
    logging.info(f"Removed {num_rows_removed} rows from input. Output has {len(filtered_df)} rows that satisfy the condition.")

if __name__ == "__main__":
    main()
