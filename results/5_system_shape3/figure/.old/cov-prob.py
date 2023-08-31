import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Read the data
data_path = 'prob-shape3-vary-mod.csv' # Adjust the path to your CSV file
data = pd.read_csv(data_path)

# True parameter values for shapes and scales
true_values = {
    'shape1': 1.2576,
    'shape2': 1.1635,
    'shape3': None, # Varies
    'shape4': 1.1802,
    'shape5': 1.2034,
    'scale1': 994.3661,
    'scale2': 908.9458,
    'scale3': 840.1141,
    'scale4': 940.1342,
    'scale5': 923.1631
}

# Function to calculate coverage probability for each unique value of prob3
def calculate_coverage_prob_by_prob3(true_value, lower_ci, upper_ci):
    return data.groupby('prob3').apply(lambda group: ((true_value >= group[lower_ci]) & (true_value <= group[upper_ci])).mean()).reset_index()

# Function to calculate coverage probability for each shape and scale by prob3
def calculate_all_coverage_prob_by_prob3():
    result_shapes = []
    result_scales = []
    for i in range(1, 6):
        shape_key = f'shape{i}'
        scale_key = f'scale{i}'
        lower_shape_key = f'shapes.lower.{i}'
        upper_shape_key = f'shapes.upper.{i}'
        lower_scale_key = f'scales.lower.{i}'
        upper_scale_key = f'scales.upper.{i}'
        
        if i == 3: # Special case for shape3 as it varies
            shape_coverage_prob_by_prob3 = data.groupby('prob3').apply(lambda group: ((group['shape3'] >= group[lower_shape_key]) & (group['shape3'] <= group[upper_shape_key])).mean()).reset_index()
        else:
            shape_coverage_prob_by_prob3 = calculate_coverage_prob_by_prob3(true_values[shape_key], lower_shape_key, upper_shape_key)
        
        scale_coverage_prob_by_prob3 = calculate_coverage_prob_by_prob3(true_values[scale_key], lower_scale_key, upper_scale_key)
        
        shape_coverage_prob_by_prob3.columns = ['prob3', f'coverage_probability_{shape_key}']
        scale_coverage_prob_by_prob3.columns = ['prob3', f'coverage_probability_{scale_key}']
        
        result_shapes.append(shape_coverage_prob_by_prob3)
        result_scales.append(scale_coverage_prob_by_prob3)

    # Merging results for shapes and scales
    result_shapes_df = result_shapes[0]
    result_scales_df = result_scales[0]
    for i in range(1, 5):
        result_shapes_df = result_shapes_df.merge(result_shapes[i], on='prob3')
        result_scales_df = result_scales_df.merge(result_scales[i], on='prob3')
    
    return result_shapes_df, result_scales_df

# Calculating coverage probabilities for all shapes and scales by prob3
shapes_coverage_prob_by_prob3, scales_coverage_prob_by_prob3 = calculate_all_coverage_prob_by_prob3()
shapes_coverage_prob_by_prob3['average_coverage_probability'] = shapes_coverage_prob_by_prob3[[f'coverage_probability_shape{i}' for i in range(1, 6)]].mean(axis=1)
scales_coverage_prob_by_prob3['average_coverage_probability'] = scales_coverage_prob_by_prob3[[f'coverage_probability_scale{i}' for i in range(1, 6)]].mean(axis=1)

print(shapes_coverage_prob_by_prob3)

# Plotting the coverage probabilities for all shapes vs. prob3
plt.figure(figsize=(12, 8))
for shape_key in true_values.keys():
    if 'shape' in shape_key:
        color = 'red' if shape_key == 'shape3' else None
        index = shape_key[-1]
        label = f'Coverage Probability for $k_{{{index}}}$' if shape_key != 'shape3' else f'Coverage Probability for $k_{{{index}}}$ (Varies)'
        sns.lineplot(x='prob3', y=f'coverage_probability_{shape_key}', data=shapes_coverage_prob_by_prob3, label=label, color=color)
sns.lineplot(x='prob3', y='average_coverage_probability', data=shapes_coverage_prob_by_prob3, label='Average Coverage Probability', color='purple', linestyle='--')
plt.axhline(y=0.95, color='red', linestyle='--', label='Nominal Level = 95%')
plt.xlabel('$\\Pr\\{K_i = 3\\}$')
plt.ylabel('Coverage Probability')
plt.title('Coverage Probabilities for All $k_j$ as a Function of $\\Pr\\{K_i = 3\\}$')
plt.legend()

plt.savefig('coverage_probabilities_shape.pdf', dpi=100)

# Plotting the coverage probabilities for all scales vs. prob3
plt.figure(figsize=(12, 8))
for scale_key in true_values.keys():
    if 'scale' in scale_key:
        color = 'red' if scale_key == 'scale3' else None
        index = scale_key[-1]
        label = f'Coverage Probability for $\\lambda_{{{index}}}$'
        sns.lineplot(x='prob3', y=f'coverage_probability_{scale_key}', data=scales_coverage_prob_by_prob3, label=label, color=color)
sns.lineplot(x='prob3', y='average_coverage_probability', data=scales_coverage_prob_by_prob3, label='Average Coverage Probability', color='purple', linestyle='--')
plt.axhline(y=0.95, color='red', linestyle='--', label='Nominal Level = 95%')
plt.xlabel('$\\Pr\\{K_i = 3\\}$')
plt.ylabel('Coverage Probability')
plt.title('Coverage Probabilities for All $\\lambda_j$ as a Function of $\\Pr\\{K_i = 3\\}$')
plt.legend()


# save the plot
plt.savefig('coverage_probabilities_scale.pdf', dpi=100)
