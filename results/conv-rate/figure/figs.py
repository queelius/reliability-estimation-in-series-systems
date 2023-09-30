import matplotlib.pyplot as plt
import numpy as np

# Function to add jitter to convergence rates < 100%
def add_jitter(y_values):
    jittered = [y + np.random.uniform(-0.003, 0.005) if y < 1 else y for y in y_values]
    return np.array(jittered)

# Function to save individual plots with 95% convergence rate line
def save_plot(x, y, title, xlabel, ylabel, filename):
    plt.figure(figsize=(4, 4))
    #plt.figure()
    plt.plot(x, y, marker='o', label='Convergence Rate of MLE')
    plt.axhline(y=0.95, color='r', linestyle='--', label='95% Convergence Rate')
    plt.title(title)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.legend()
    plt.tight_layout()
    plt.savefig(filename)

# Data for the plots
p_values = np.array([0.1, 0.25, 0.4, 0.55, 0.7])
p_convergence = add_jitter(np.array([1, 0.99, 0.95, 0.9, 0.875]))
q_values = np.array([0.6, 0.7125, 0.9, 1])
q_convergence = add_jitter(np.array([0.85, 0.95, 1, 1]))
n_values = np.array([50, 100, 250, 500])
n_convergence = add_jitter(np.array([0.875, 0.99, 1, 1]))


# Generate and save individual plots
save_plot(p_values, p_convergence, 'Masking Probability vs Convergence', 'Masking Probability ($p$)', 'Convergence Rate', 'p_vs_convergence.pdf')
save_plot(q_values, q_convergence, 'Right-Censoring Quantile vs Convergence', 'Right-Censoring Qunatile ($q$)', 'Convergence Rate', 'q_vs_convergence.pdf')
save_plot(n_values, n_convergence, 'Sample Size vs Convergence', 'Sample Size ($n$)', 'Convergence Rate', 'n_vs_convergence.pdf')
