import csv
import math

unique_cols = ["n","p","q","tau","mle.1","mle.2","mle.3","mle.4","mle.5","mle.6","mle.7","mle.8","mle.9","mle.10","coverages.1","coverages.2","coverages.3","coverages.4","coverages.5","coverages.6","coverages.7","coverages.8","coverages.9","coverages.10","var.fim.1","var.fim.2","var.fim.3","var.fim.4","var.fim.5","var.fim.6","var.fim.7","var.fim.8","var.fim.9","var.fim.10","lowers.1","lowers.2","lowers.3","lowers.4","lowers.5","lowers.6","lowers.7","lowers.8","lowers.9","lowers.10","uppers.1","uppers.2","uppers.3","uppers.4","uppers.5","uppers.6","uppers.7","uppers.8","uppers.9","uppers.10"]

def validate_row(row):
    # check that no value is 'NA' or 'NaN'
    if 'NA' in row or 'NaN' in row:
        return False

    # check that n is an integer
    if not row[0].isdigit():
        return False
    
    # check that 0 < p <= 1 and 0 < q <= 1
    for i in [1, 2]:
        try:
            value = float(row[i])
            if not 0 < value <= 1:
                return False
        except ValueError:
            return False
    
    # check that tau > 0
    try:
        if float(row[3]) <= 0:
            return False
    except ValueError:
        return False

    # check that coverages.j are Boolean TRUE/FALSE values
    for i in range(14, 24):  # coverages columns indices
        if row[i] not in ["TRUE", "FALSE"]:
            return False

    # check that var.fim.j are positive
    for i in range(24, 34):  # var.fim columns indices
        try:
            if float(row[i]) <= 0:
                return False
        except ValueError:
            return False

    # If all checks passed, the row is valid
    return True

with open('filename.csv', 'r') as csv_in, open('clean_filename.csv', 'w', newline='') as csv_out:
    reader = csv.reader(csv_in)
    writer = csv.writer(csv_out)
    
    for row in reader:
        if len(row) == len(unique_cols) and validate_row(row):
            writer.writerow(row)
