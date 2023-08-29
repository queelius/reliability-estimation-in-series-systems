import pandas as pd
import argparse
import sys

def main(args):
    csv_file = args.input
    csv_file_out = args.output

    if csv_file == "-":
        df = pd.read_csv(sys.stdin)
    else:
        df = pd.read_csv(csv_file)

    rename_dict = {}
    for col in df.columns:
        if col.startswith("shapes.lower."):
            rename_dict[col] = col.replace("shapes.lower.", "shape.lower.")
        elif col.startswith("shapes.upper."):
            rename_dict[col] = col.replace("shapes.upper.", "shape.upper.")
        elif col.startswith("scales.lower."):
            rename_dict[col] = col.replace("scales.lower.", "scale.lower.")
        elif col.startswith("scales.upper."):
            rename_dict[col] = col.replace("scales.upper.", "scale.upper.")

    df.rename(columns=rename_dict, inplace=True)

    rename_dict = {}
    for col in df.columns:
        if col.startswith("shapes."):
            rename_dict[col] = col.replace("shapes.", "shape.mle.")
        elif col.startswith("scales."):
            rename_dict[col] = col.replace("scales.", "scale.mle.")

    df.rename(columns=rename_dict, inplace=True)

    # Define the true parameter values
    true_values = {
        'shape.1': 1.2576,
        'scale.1': 994.3661,
        'shape.2': 1.1635,
        'scale.2': 908.9458,
        'shape.3': 1.1308,
        'scale.3': 840.1141,
        'shape.4': 1.1802,
        'scale.4': 940.1342,
        'shape.5': 1.2034,
        'scale.5': 923.1631
    }

    # Add the true parameter values to each row in the DataFrame
    for col, value in true_values.items():
        df[col] = value        

    if csv_file_out == "-":
        df.to_csv(sys.stdout, index=False)
    else:
        df.to_csv(csv_file_out, index=False)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Standardize CSV columns.")
    parser.add_argument("input", nargs="?", default="-", help="Input CSV file or '-' for stdin")
    parser.add_argument("-o", "--output", default="-", help="Output CSV file or '-' for stdout")
    args = parser.parse_args()
    main(args)
