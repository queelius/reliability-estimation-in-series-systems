#!/usr/bin/env python3
from typing import List, Set, Optional, TextIO
import os
import pandas as pd
import argparse
import fnmatch
import sys
import logging

def read_config(config_path: str) -> dict:
    config = {}
    with open(config_path, 'r') as f:
        for line in f:
            key, value = line.strip().split('=', 1)
            config[key] = value
    return config

def update_args_from_config(args, config: dict):
    args.root_dir = config.get("root_dir", args.root_dir)
    args.output = config.get("output", args.output)
    args.ignore_dirs = config.get("ignore_dirs", args.ignore_dirs).split(',')
    args.recurse = config.get("recurse", args.recurse).lower() == 'true'
    args.pattern = config.get("pattern", args.pattern)
    args.skip_hidden = config.get("skip_hidden", args.skip_hidden).lower() == 'true'
    args.na_values = config.get("na_values", args.na_values)
    args.output_na_rep = config.get("na_rep", args.output_na_rep)

def find_csv_files(root_dir: str, pattern: str, ignore_dirs: Set[str], recurse: bool, skip_hidden: bool) -> List[str]:
    csv_files = []
    for dirpath, dirnames, filenames in os.walk(root_dir):
        if skip_hidden:
            dirnames[:] = [d for d in dirnames if not d.startswith('.')]
        
        if dirpath in ignore_dirs:
            continue

        for filename in fnmatch.filter(filenames, pattern):
            csv_files.append(os.path.join(dirpath, filename))

        if not recurse:
            break
    return csv_files

def read_csv(csv_file: str, na_values: Optional[List[str]] = None) -> pd.DataFrame:
    default_na_values = ["NA", "NaN"]
    if na_values is None:
        na_values = default_na_values
    return pd.read_csv(csv_file, na_values=na_values)

def are_columns_compatible(df1: pd.DataFrame, df2: pd.DataFrame) -> bool:
    return list(df1.columns) == list(df2.columns)

def are_dtypes_compatible(df1: pd.DataFrame, df2: pd.DataFrame) -> bool:
    return all(df1.dtypes == df2.dtypes)

def main() -> None:
    parser = argparse.ArgumentParser(description="Merge CSV files.")
    parser.add_argument("root_dir", type=str, help="Root directory.")
    parser.add_argument("-o", "--output", help="Output CSV filename.", default=sys.stdout, type=argparse.FileType("w"))
    parser.add_argument("-I", "--ignore-dirs", nargs="*", help="Directories to ignore.", default=['.*'])
    parser.add_argument("-r", "--recurse", help="Recurse into subdirectories.", action="store_true")
    parser.add_argument("-p", "--pattern", type=str, help="Filename pattern to match.", default="*.csv")
    parser.add_argument("-s", "--skip-hidden", help="Skip hidden directories.", action="store_true")
    parser.add_argument("-n", "--na-values", type=str, help="Custom NA values to use.")
    parser.add_argument("-N", "--output-na-rep", type=str, help="String to represent NA values in the output file.", default="NA")
    parser.add_argument("--config", type=str, help="Path to a custom configuration file.")
    
    args = parser.parse_args()
    custom_na_values = args.na_values.split(',') if args.na_values else None

    default_config_path = os.path.expanduser("~/.config/csvmerger/config")
    if os.path.exists(default_config_path):
        config = read_config(default_config_path)
        update_args_from_config(args, config)
    
    if args.config:
        custom_config_path = os.path.abspath(args.config)
        if os.path.exists(custom_config_path):
            custom_config = read_config(custom_config_path)
            update_args_from_config(args, custom_config)

    logging.basicConfig(level=logging.INFO)
    
    ignore_dirs = set(os.path.abspath(d) for d in args.ignore_dirs)
    root_dir = os.path.abspath(args.root_dir)
    
    logging.info(f"Starting CSV merge from root directory: {root_dir}")

    csv_files = find_csv_files(root_dir, args.pattern, ignore_dirs, args.recurse, args.skip_hidden)
    if not csv_files:
        logging.error("No compatible files found.")
        sys.exit(1)

    total_files = len(csv_files)
    
    try:
        merged_df = read_csv(csv_files[0], custom_na_values)
    except Exception as e:
        logging.error(f"Failed to read file {csv_files[0]}: {e}")
        sys.exit(1)

    logging.info(f"Processing 1/{total_files} files: {csv_files[0]}")    
    for i, csv_file in enumerate(csv_files[1:], 2):
        logging.info(f"Processing {i}/{total_files} files: {csv_file}")
        try:
            df = read_csv(csv_file, custom_na_values)
        except Exception as e:
            logging.warning(f"Failed to read file {csv_file}: {e}")
            continue

        if not are_columns_compatible(merged_df, df) or not are_dtypes_compatible(merged_df, df):
            logging.warning(f"Incompatible file: {csv_file}")
            continue
        
        merged_df = pd.concat([merged_df, df])
    
    merged_df.to_csv(args.output, index=False, na_rep=args.output_na_rep)
    logging.info(f"Merge completed. Total rows: {len(merged_df)}.")

if __name__ == "__main__":
    main()
