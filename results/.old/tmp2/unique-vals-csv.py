#!/usr/bin/env python3
import pandas as pd
import argparse
import logging

def enumerate_unique(df: pd.DataFrame, column: str):
    unique_values = df[column].unique()
    logging.info(f"Unique values in column {column}: {unique_values}")

def main():
    parser = argparse.ArgumentParser(description="Enumerate unique column values in a CSV file.")
    parser.add_argument("input_csv", type=argparse.FileType('r'), help="Input CSV file.")
    parser.add_argument("-c", "--column", type=str, help="Column to enumerate unique values.")
    
    args = parser.parse_args()
    
    logging.basicConfig(level=logging.INFO)
    
    df = pd.read_csv(args.input_csv)

    if args.enumerate_unique:
        enumerate_unique(df, args.enumerate_unique)

if __name__ == "__main__":
    main()
