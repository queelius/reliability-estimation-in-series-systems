library(ggplot2)
library(dplyr)
library(readr)
library(tidyverse)
library(latex2exp)

# Load the data
sim_data <- read_csv("simres.csv")

# rename columns for plotting
sim_data <- sim_data %>% rename(
  "Shape 1" = mle.1,
  "Scale 1" = mle.2,
  "Shape 2" = mle.3,
  "Scale 2" = mle.4,
  "Shape 3" = mle.5,
  "Scale 3" = mle.6,
  "Shape 4" = mle.7,
  "Scale 4" = mle.8,
  "Shape 5" = mle.9,
  "Scale 5" = mle.10
)

# Filter data
filtered_data <- sim_data %>% filter(p == 0 & q == 1)

# Compute variances
shape_data <- filtered_data %>% select(n, "Shape 1", "Shape 2", "Shape 3", "Shape 4", "Shape 5")
scale_data <- filtered_data %>% select(n, "Scale 1", "Scale 2", "Scale 3", "Scale 4", "Scale 5")

shape_variances <- shape_data %>% group_by(n) %>% summarise_all(var, na.rm = TRUE)
scale_variances <- scale_data %>% group_by(n) %>% summarise_all(var, na.rm = TRUE)

# Reshape the data for ggplot2
shape_variances_long <- shape_variances %>% gather(key = "Parameter", value = "Variance", -n)
scale_variances_long <- scale_variances %>% gather(key = "Parameter", value = "Variance", -n)

# Plotting
shape_plot <- ggplot(shape_variances_long, aes(x = n, y = Variance, colour = Parameter)) +
  geom_line() +
  geom_point() +
  scale_y_log10() +
  labs(x = "Sample Size (n)", y = "Variance", 
       title = "Variance of Shape Parameter MLEs with respect to Sample Size") +
  theme_minimal()

scale_plot <- ggplot(scale_variances_long, aes(x = n, y = Variance, colour = Parameter)) +
  geom_line() +
  geom_point() +
  scale_y_log10() +
  labs(x = "Sample Size (n)", y = "Variance", 
       title = "Variance of Scale Parameter MLEs with respect to Sample Size") +
  theme_minimal()


# place the plots side by side
library(gridExtra)
grid.arrange(shape_plot, scale_plot, ncol = 2)

# Save the plots
ggsave("shape_variances.pdf", width = 6, height = 4)