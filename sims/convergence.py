import pandas as pd

# Load your data
df = pd.read_csv('data-boot.csv')

# Count the number of rows where 'convergence' is 0 (converged)
num_converged = (df['convergence'] == 0).sum()

# Count the number of rows where 'convergence' is not 0 (not converged)
num_not_converged = (df['convergence'] != 0).sum()

# Calculate the proportion of rows that have converged
proportion_converged = num_converged / df.shape[0]

# Print statistics
print(f"Number of converged: {num_converged}")
print(f"Number of not converged: {num_not_converged}")
print(f"Proportion converged: {proportion_converged}")
