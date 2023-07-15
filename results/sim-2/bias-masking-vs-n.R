###############################
# BIAS OF ESTIMATORS          #
# bias vs masking probability #
###############################

# in this simulation, we have no right censoring and a sample size of 100, 400, 800.
# we want to see how well the estimator performs in this case as a function of
# masking component cause of failure p from p = 0 to p = 0.4.
# we have R = 100 replicates for each p.
library(patchwork)
library(cowplot)
library(reshape2)
library(gridExtra)  # for arranging plots
library(ggplot2)
library(tidyverse)
library(dplyr)
library(algebraic.mle)
library(algebraic.dist)
library(md.tools)
library(wei.series.md.c1.c2.c3)


theta <- c(shape1 = 1.2576, scale1 = 994.3661,
           shape2 = 1.1635, scale2 = 908.9458,
           shape3 = 1.1308, scale3 = 840.1141,
           shape4 = 1.1802, scale4 = 940.1141,
           shape5 = 1.3311, scale5 = 836.1123)

shapes <- theta[seq(1, length(theta), 2)]
scales <- theta[seq(2, length(theta), 2)]
m <- 5

sim_p <- c(0, .1, .2, .3, .4)

###################
# 400 sample size #
###################

sim_p_400_0.0 <- readRDS("results/sim-1-accurate/results_400_0_1.rds")
sim_p_400_0.1 <- readRDS("results/sim-2/results_400_0.1_1.rds")
sim_p_400_0.2 <- readRDS("results/sim-2/results_400_0.2_1.rds")
sim_p_400_0.3 <- readRDS("results/sim-2/results_400_0.3_1.rds")
sim_p_400_0.4 <- readRDS("results/sim-2/results_400_0.4_1.rds")

sim_p_400_mles <- list(sim_p_400_0.0$mles, sim_p_400_0.1$mles, sim_p_400_0.2$mles,
    sim_p_400_0.3$mles, sim_p_400_0.4$mles)


bias_p_400_df <- matrix(NA, nrow = length(sim_p), ncol = length(theta))
for (i in 1:length(sim_p)) {
    pars <- t(sapply(sim_p_400_mles[[i]], function(x) x$par))
    bias_p_400_df[i,] <- colMeans(pars) - theta
}
bias_p_400_df <- as.data.frame(bias_p_400_df)
colnames(bias_p_400_df) <- c("shape1", "scale1", "shape2", "scale2", "shape3", "scale3",
                       "shape4", "scale4", "shape5", "scale5")
bias_p_400_df$MaskingProb <- sim_p

# Melt data frame for ggplot
bias_p_400_df_melted <- melt(bias_p_400_df, id.vars = "MaskingProb")

# grab only shapes
bias_p_400_df_melted_shapes <- bias_p_400_df_melted %>%
  filter(grepl("shape", variable))

masking_prob_vs_shapes_bias_sample_size_400 <- ggplot(
  bias_p_400_df_melted_shapes, aes(x = MaskingProb, y = value, color = variable)) +
  geom_line() +
  labs(x = "Masking Probability (Sample Size 400)", y = "Bias", color = "Parameter") +
  theme_minimal()

# grab only shapes
bias_p_400_df_melted_scales <- bias_p_400_df_melted %>%
  filter(grepl("scale", variable))

masking_prob_vs_scales_bias_sample_size_400 <- ggplot(
  bias_p_400_df_melted_scales, aes(x = MaskingProb, y = value, color = variable)) +
  geom_line() +
  labs(x = "Masking Probability (Sample Size 400)", y = "Bias", color = "Parameter") +
  theme_minimal()

###################
# 100 sample size #
###################

sim_p_100_0.0 <- readRDS("results/sim-1-accurate/results_100_0_1.rds")
sim_p_100_0.1 <- readRDS("results/sim-2/results_100_0.1_1.rds")
sim_p_100_0.2 <- readRDS("results/sim-2/results_100_0.2_1.rds")
sim_p_100_0.3 <- readRDS("results/sim-2/results_100_0.3_1.rds")
sim_p_100_0.4 <- readRDS("results/sim-2/results_100_0.4_1.rds")

sim_p_100_mles <- list(sim_p_100_0.0$mles, sim_p_100_0.1$mles, sim_p_100_0.2$mles,
    sim_p_100_0.3$mles, sim_p_100_0.4$mles)
bias_p_100_df <- matrix(NA, nrow = length(sim_p), ncol = length(theta))
for (i in 1:length(sim_p)) {
    pars <- t(sapply(sim_p_100_mles[[i]], function(x) x$par))
    bias_p_100_df[i,] <- colMeans(pars) - theta
}
bias_p_100_df <- as.data.frame(bias_p_100_df)
colnames(bias_p_100_df) <- c("shape1", "scale1", "shape2", "scale2", "shape3", "scale3",
                       "shape4", "scale4", "shape5", "scale5")
bias_p_100_df$MaskingProb <- sim_p

# Melt data frame for ggplot
bias_p_100_df_melted <- melt(bias_p_100_df, id.vars = "MaskingProb")

bias_p_100_df_melted_shapes <- bias_p_100_df_melted %>%
  filter(grepl("shape", variable))

masking_prob_vs_shapes_bias_sample_size_100 <- ggplot(
  bias_p_100_df_melted_shapes, aes(x = MaskingProb, y = value, color = variable)) +
  geom_line() +
  labs(x = "Masking Probability (Sample Size 100)", y = "Bias", color = "Parameter") +
  theme_minimal()

# grab only shapes
bias_p_100_df_melted_scales <- bias_p_100_df_melted %>%
  filter(grepl("scale", variable))

# Plot
masking_prob_vs_scales_bias_sample_size_100 <- ggplot(
  bias_p_100_df_melted_scales, aes(x = MaskingProb, y = value, color = variable)) +
  geom_line() +
  labs(x = "Masking Probability (Sample Size 100)", y = "Bias", color = "Parameter") +
  theme_minimal()

###################
# 100 sample size #
###################

sim_p_800_0.0 <- readRDS("results/sim-1-accurate/results_800_0_1.rds")
sim_p_800_0.1 <- readRDS("results/sim-2/results_800_0.1_1.rds")
sim_p_800_0.2 <- readRDS("results/sim-2/results_800_0.2_1.rds")
sim_p_800_0.3 <- readRDS("results/sim-2/results_800_0.3_1.rds")
sim_p_800_0.4 <- readRDS("results/sim-2/results_800_0.4_1.rds")

sim_p_800_mles <- list(sim_p_800_0.0$mles, sim_p_800_0.1$mles, sim_p_800_0.2$mles,
    sim_p_800_0.3$mles, sim_p_800_0.4$mles)


bias_p_800_df <- matrix(NA, nrow = length(sim_p), ncol = length(theta))
for (i in 1:length(sim_p)) {
    pars <- t(sapply(sim_p_800_mles[[i]], function(x) x$par))
    bias_p_800_df[i,] <- colMeans(pars) - theta
}
bias_p_800_df <- as.data.frame(bias_p_800_df)

colnames(bias_p_800_df) <- c("shape1", "scale1", "shape2", "scale2", "shape3", "scale3",
                       "shape4", "scale4", "shape5", "scale5")
bias_p_800_df$MaskingProb <- sim_p

# Melt data frame for ggplot
bias_p_800_df_melted <- melt(bias_p_800_df, id.vars = "MaskingProb")

bias_p_800_df_melted_shapes <- bias_p_800_df_melted %>%
  filter(grepl("shape", variable))

masking_prob_vs_shapes_bias_sample_size_800 <- ggplot(
  bias_p_800_df_melted_shapes, aes(x = MaskingProb, y = value, color = variable)) +
  geom_line() +
  labs(x = "Masking Probability (Sample Size 800)", y = "Bias", color = "Parameter") +
  theme_minimal()

# grab only scales
bias_p_800_df_melted_scales <- bias_p_800_df_melted %>%
  filter(grepl("scale", variable))

# Plot
masking_prob_vs_scales_bias_sample_size_800 <- ggplot(
  bias_p_800_df_melted_scales, aes(x = MaskingProb, y = value, color = variable)) +
  geom_line() +
  labs(x = "Masking Probability (Sample Size 800)", y = "Bias", color = "Parameter") +
  theme_minimal()


###########################
# DO THE PLOTS BELOW HERE #
###########################
y_range_scales <- c(-20, 200)  # Adjust the range as per your data

# Set the y-axis limits for both plots
masking_prob_vs_scales_bias_sample_size_100_yscaled <- masking_prob_vs_scales_bias_sample_size_100 +
  theme(legend.position = "none") + ylim(y_range_scales)

masking_prob_vs_scales_bias_sample_size_400_yscaled <- masking_prob_vs_scales_bias_sample_size_400 +
  theme(legend.position = "none") + ylim(y_range_scales)

masking_prob_vs_scales_bias_sample_size_800_yscaled <- masking_prob_vs_scales_bias_sample_size_800 +
  theme(legend.position = "none") + ylim(y_range_scales)

plot_for_legend <- masking_prob_vs_scales_bias_sample_size_100 +
  guides(color = guide_legend(direction = "vertical")) +
  ylim(y_range_scales)

# Extract the legend
common_legend <- get_legend(plot_for_legend)

combined_plot_scales <- masking_prob_vs_scales_bias_sample_size_100_yscaled |
  masking_prob_vs_scales_bias_sample_size_400_yscaled |
  masking_prob_vs_scales_bias_sample_size_800_yscaled | common_legend

ggsave("results/sim-2/plot-bias-scales-p-vs-sample-size-100-400-800.pdf",
  plot = combined_plot_scales)


##########
# SHAPES #
##########

y_range_shapes <- c(0, 0.3)  # Adjust the range as per your data

# Set the y-axis limits for both plots
masking_prob_vs_shapes_bias_sample_size_100_yscaled <- masking_prob_vs_shapes_bias_sample_size_100 +
  theme(legend.position = "none") + ylim(y_range_shapes)

masking_prob_vs_shapes_bias_sample_size_400_yscaled <- masking_prob_vs_shapes_bias_sample_size_400 +
  theme(legend.position = "none") + ylim(y_range_shapes)

masking_prob_vs_shapes_bias_sample_size_800_yscaled <- masking_prob_vs_shapes_bias_sample_size_800 +
  theme(legend.position = "none") + ylim(y_range_shapes)

plot_for_legend <- masking_prob_vs_shapes_bias_sample_size_100 +
  guides(color = guide_legend(direction = "vertical")) +
  ylim(y_range_shapes)

# Extract the legend
common_legend <- get_legend(plot_for_legend)

combined_plot_shapes <- masking_prob_vs_shapes_bias_sample_size_100_yscaled |
  masking_prob_vs_shapes_bias_sample_size_400_yscaled |
  masking_prob_vs_shapes_bias_sample_size_800_yscaled | common_legend

ggsave("results/sim-2/plot-bias-shapes-p-vs-sample-size-100-400-800.pdf",
  plot = combined_plot_shapes)




