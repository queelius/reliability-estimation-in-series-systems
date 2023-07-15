# in this simulation, we have no right censoring and a sample size of 400.
# we want to see how well the estimator performs in this case as a function of
# masking component cause of failure p from p = 0 to p = 0.4.
# we have R = 100 replicates for each p.

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

# let's read in the results from the simulations
sim_p_400_0.0 <- readRDS("results/sim-1-accurate/results_400_0_1.rds")
sim_p_400_0.1 <- readRDS("results/sim-2/results_400_0.1_1.rds")
sim_p_400_0.2 <- readRDS("results/sim-2/results_400_0.2_1.rds")
sim_p_400_0.3 <- readRDS("results/sim-2/results_400_0.3_1.rds")
sim_p_400_0.4 <- readRDS("results/sim-2/results_400_0.4_1.rds")
m <- 5

# let's compute the confint of each mle for each sample size and compute the
# coverage probability
sim_p <- c(0, .1, .2, .3, .4)
sim_p_mles <- list(sim_p_400_0.0$mles, sim_p_400_0.1$mles, sim_p_400_0.2$mles,
    sim_p_400_0.3$mles, sim_p_400_0.4$mles)


###################################################
# COVERAGE PROBABILITIES FOR CONFIDENCE INTERVALS #
###################################################
coverage_probs <- list()
for (i in 1:length(sim_p)) {
    counts <- rep(0, length(theta))
    ci_matrix <- matrix(nrow = length(sim_p_mles[[i]]), ncol = length(theta) * 2)
    for (j in 1:length(sim_p_mles[[i]])) {
        theta.hat <- algebraic.mle::mle_numerical(sim_p_mles[[i]][[j]])
        theta.hat$nobs <- 100

        # this is a m x 2 matrix, where m is the number of parameters
        ci <- confint(theta.hat, use_t_dist = TRUE)

        if (any(is.na(ci))) {
            next
        }

        for (k in 1:length(theta)) {
            if (theta[k] > ci[k, 1] && theta[k] < ci[k, 2]) {
                counts[k] <- counts[k] + 1
            }
        }
    }
    coverage_probs[[i]] <- counts / length(sim_p_mles[[i]])
}


# Create a data frame
coverage_df <- data.frame(p = rep(sim_p, each = length(coverage_probs[[1]])),
                          Coverage = unlist(coverage_probs),
                          Parameter = rep(seq(length(coverage_probs[[1]])),
                          times = length(coverage_probs)))
# Plot, give a title indicating the confidence level and an indicating that this is
# for simulation parameter p = 0.1
ggplot(coverage_df, aes(x = rep(sim_p, each = length(coverage_probs[[1]])), y = Coverage, color = factor(Parameter))) +
  geom_line() + 
  geom_hline(yintercept = 0.95, linetype = "dashed", color = "red") + 
  labs(x = "Masking Probability", y = "Coverage Probability", color = "Parameter") +
  theme_minimal() +
  ggtitle("Coverage Probability for 95% Confidence Intervals, n = 100")



#############
# CI WIDTHS #
#############

ci_widths <- list()

for (i in 1:length(sim_p)) {

    ci_widths[[i]] <- matrix(nrow = length(sim_p_mles[[i]]), ncol = length(theta))

    for (j in 1:length(sim_p_mles[[i]])) {
        theta.hat <- algebraic.mle::mle_numerical(sim_p_mles[[i]][[j]])
        # this is a m x 2 matrix, where m is the number of parameters
        ci <- confint(theta.hat, use_t_dist = FALSE)

        if (any(is.na(ci))) {
            next
        }

        ci_widths[[i]][j,] <- ci[,2] - ci[,1]
    }
}

###################################
# PLOT CONFIDENCE INTERVAL WIDTHS #
###################################

# Create a long-form data frame from your list
ci_widths_df <- do.call(rbind, lapply(seq_along(ci_widths), function(i) {
  data.frame(SampleSize = rep(sim_p[i], nrow(ci_widths[[i]])),
             CI_Width = as.vector(ci_widths[[i]]),
             Parameter = rep(seq(ncol(ci_widths[[i]])), each = nrow(ci_widths[[i]])),
             Type = rep(c("Shape", "Scale"), each = nrow(ci_widths[[i]]), times = ncol(ci_widths[[i]]) / 2))
}))

# Split the data frame based on parameter type (Scale or Shape)
ci_widths_list <- split(ci_widths_df, ci_widths_df$Type)
head(ci_widths_list$Shape)

# Generate a plot for each type
plots <- lapply(ci_widths_list, function(df) {
  ggplot(df, aes(x = sim_p, y = CI_Width, color = factor(Parameter))) +
    geom_line() + 
    labs(x = "Masking Probability", y = "Confidence Interval Width", color = "Parameter") +
    facet_wrap(~ Type, scales = "free") +
    theme_minimal()
})

# Arrange the plots in a grid
grid.arrange(grobs = plots, ncol = 2)


######################
# BIAS OF ESTIMATORS #
######################

bias_df <- matrix(NA, nrow = length(sim_p), ncol = length(theta))
for (i in 1:length(sim_p)) {
    pars <- t(sapply(sim_p_mles[[i]], function(x) x$par))
    bias_df[i,] <- colMeans(pars) - theta
}
bias_df <- as.data.frame(bias_df)
# Load necessary libraries

colnames(bias_df) <- c("shape1", "scale1", "shape2", "scale2", "shape3", "scale3",
                       "shape4", "scale4", "shape5", "scale5")
bias_df$MaskingProb <- sim_p

# Melt data frame for ggplot
bias_df_melted <- melt(bias_df, id.vars = "MaskingProb")

# grab only shapes
bias_df_melted_shapes <- bias_df_melted %>%
  filter(grepl("shape", variable))

# Plot
masking_prob_vs_shapes_bias_sample_size_400 <- ggplot(
  bias_df_melted_shapes, aes(x = MaskingProb, y = value, color = variable)) +
  geom_line() +
  labs(x = "Masking Probability (Sample Size 400)", y = "Bias", color = "Parameter") +
  theme_minimal()


# grab only shapes
bias_df_melted_scales <- bias_df_melted %>%
  filter(grepl("scale", variable))

# Plot
masking_prob_vs_scales_bias_sample_size_400 <- ggplot(
  bias_df_melted_scales, aes(x = MaskingProb, y = value, color = variable)) +
  geom_line() +
  labs(x = "Masking Probability (Sample Size 400)", y = "Bias", color = "Parameter") +
  theme_minimal()

masking_prob_vs_bias_sample_size_400 <- grid.arrange(
  grobs = list(masking_prob_vs_shapes_bias_sample_size_400,
               masking_prob_vs_scales_bias_sample_size_400), ncol = 2)


# save the plots
ggsave("results/sim-2/plot-bias-scales-vary-p-sample-size-400.pdf",
  plot = masking_prob_vs_scales_bias_sample_size_400)

ggsave("results/sim-2/plot-bias-shapes-vary-p-sample-size-400.pdf",
  plot = masking_prob_vs_shapes_bias_sample_size_400)

ggsave("results/sim-2/plot-bias-vary-p-sample-size-400.pdf",
  plot = masking_prob_vs_bias_sample_size_400)


###########
# PLOT different sample sizes side by side
###########

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
# Load necessary libraries

colnames(bias_p_100_df) <- c("shape1", "scale1", "shape2", "scale2", "shape3", "scale3",
                       "shape4", "scale4", "shape5", "scale5")
bias_p_100_df$MaskingProb <- sim_p

# Melt data frame for ggplot
bias_p_100_df_melted <- melt(bias_p_100_df, id.vars = "MaskingProb")

# grab only shapes
bias_p_100_df_melted_scales <- bias_p_100_df_melted %>%
  filter(grepl("scale", variable))

# Plot
masking_prob_vs_scales_bias_sample_size_100 <- ggplot(
  bias_p_100_df_melted_scales, aes(x = MaskingProb, y = value, color = variable)) +
  geom_line() +
  labs(x = "Masking Probability (Sample Size 100)", y = "Bias", color = "Parameter") +
  theme_minimal()




#----------------


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
# Load necessary libraries

colnames(bias_p_800_df) <- c("shape1", "scale1", "shape2", "scale2", "shape3", "scale3",
                       "shape4", "scale4", "shape5", "scale5")
bias_p_800_df$MaskingProb <- sim_p

# Melt data frame for ggplot
bias_p_800_df_melted <- melt(bias_p_800_df, id.vars = "MaskingProb")

# grab only shapes
bias_p_800_df_melted_scales <- bias_p_800_df_melted %>%
  filter(grepl("scale", variable))

# Plot
masking_prob_vs_scales_bias_sample_size_800 <- ggplot(
  bias_p_800_df_melted_scales, aes(x = MaskingProb, y = value, color = variable)) +
  geom_line() +
  labs(x = "Masking Probability (Sample Size 100)", y = "Bias", color = "Parameter") +
  theme_minimal()




#--------------
y_range <- c(0, 200)  # Adjust the range as per your data

# Set the y-axis limits for both plots
masking_prob_vs_scales_bias_sample_size_100_yscaled <- masking_prob_vs_scales_bias_sample_size_100 + ylim(y_range)
masking_prob_vs_scales_bias_sample_size_400_yscaled <- masking_prob_vs_scales_bias_sample_size_400 + ylim(y_range)
masking_prob_vs_scales_bias_sample_size_800_yscaled <- masking_prob_vs_scales_bias_sample_size_800 + ylim(y_range)

# Arrange the plots side by side
masking_prob_vs_scales_bias_sample_size_100_400_800 <- grid.arrange(
    masking_prob_vs_scales_bias_sample_size_100_yscaled,
    masking_prob_vs_scales_bias_sample_size_400_yscaled
    masking_prob_vs_scales_bias_sample_size_800_yscaled, ncol = 3)


