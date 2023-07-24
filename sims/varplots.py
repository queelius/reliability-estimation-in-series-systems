# Renaming columns for better visualization
shape_variances.columns = ['n', '$k_1$', '$k_2$', '$k_3$', '$k_4$', '$k_5$']
scale_variances.columns = ['n', '$\lambda_1$', '$\lambda_2$', '$\lambda_3$', '$\lambda_4$', '$\lambda_5$']

# Different line styles for better differentiation
line_styles = ['-', '--', '-.', ':', (0, (3, 1, 1, 1))]

# Plotting
fig, axs = plt.subplots(2, 1, figsize=(10, 12))

# Shape MLEs
for idx, column in enumerate(shape_variances.columns[1:]):
    axs[0].plot(shape_variances['n'], shape_variances[column], marker='o', linestyle=line_styles[idx], label=column)
axs[0].set_xlabel('Sample Size (n)', fontsize=14)
axs[0].set_ylabel('Variance of MLEs', fontsize=14)
axs[0].set_title('Variance of Shape Parameter MLEs with respect to Sample Size', fontsize=16)
axs[0].set_yscale('log')
axs[0].legend()
axs[0].grid(True)

# Scale MLEs
for idx, column in enumerate(scale_variances.columns[1:]):
    axs[1].plot(scale_variances['n'], scale_variances[column], marker='o', linestyle=line_styles[idx], label=column)
axs[1].set_xlabel('Sample Size (n)', fontsize=14)
axs[1].set_ylabel('Variance of MLEs', fontsize=14)
axs[1].set_title('Variance of Scale Parameter MLEs with respect to Sample Size', fontsize=16)
axs[1].set_yscale('log')
axs[1].legend()
axs[1].grid(True)

plt.tight_layout()
plt.show()
