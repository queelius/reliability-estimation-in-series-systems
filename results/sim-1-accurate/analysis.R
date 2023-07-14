# in this simulation, we have no right censoring and no masking of component cause
# of failure. it's the ideal case. we want to see how well the estimator
# performs in this case as a function of sample size, from n = 20 to n = 1000.
# we have R = 200 replicates for each sample size.

library(reshape2)
library(gridExtra)  # for arranging plots
library(ggplot2)
library(tidyverse)
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
sim1_acc_30 <- readRDS("results/sim-1-accurate/results_30_0_1.rds") 
sim1_acc_40 <- readRDS("results/sim-1-accurate/results_40_0_1.rds")
sim1_acc_50 <- readRDS("results/sim-1-accurate/results_50_0_1.rds")
sim1_acc_75 <- readRDS("results/sim-1-accurate/results_75_0_1.rds")
sim1_acc_100 <- readRDS("results/sim-1-accurate/results_100_0_1.rds")
sim1_acc_200 <- readRDS("results/sim-1-accurate/results_200_0_1.rds")
sim1_acc_400 <- readRDS("results/sim-1-accurate/results_400_0_1.rds")
sim1_acc_800 <- readRDS("results/sim-1-accurate/results_800_0_1.rds")
m <- 5

# let's compute the confint of each mle for each sample size and compute the
# coverage probability
sim1_acc_n <- c(30, 40, 50, 75, 100, 200, 400, 800)
sim1_acc_mles <- list(sim1_acc_30$mles, sim1_acc_40$mles, sim1_acc_50$mles,
    sim1_acc_75$mles, sim1_acc_100$mles, sim1_acc_200$mles, sim1_acc_400$mles,
    sim1_acc_800$mles)


###################################################
# COVERAGE PROBABILITIES FOR CONFIDENCE INTERVALS #
###################################################
coverage_probs <- list()
for (i in 1:length(sim1_acc_n)) {
    counts <- rep(0, length(theta))
    ci_matrix <- matrix(nrow = length(sim1_acc_mles[[i]]), ncol = length(theta) * 2)
    for (j in 1:length(sim1_acc_mles[[i]])) {
        theta.hat <- algebraic.mle::mle_numerical(sim1_acc_mles[[i]][[j]])
        theta.hat$nobs <- sim1_acc_n[i]

        # this is a m x 2 matrix, where m is the number of parameters
        ci <- confint(theta.hat, use_t_dist = FALSE)

        if (any(is.na(ci))) {
            next
        }

        for (k in 1:length(theta)) {
            if (theta[k] > ci[k, 1] && theta[k] < ci[k, 2]) {
                counts[k] <- counts[k] + 1
            }
        }
    }
    coverage_probs[[i]] <- counts / length(sim1_acc_mles[[i]])
}

sample_sizes <- c(30, 40, 50, 75, 100, 200, 400, 800)

# Create a data frame
# Create a data frame
coverage_df <- data.frame(SampleSize = rep(sample_sizes, each = length(coverage_probs[[1]])),
                          Coverage = unlist(coverage_probs),
                          Parameter = rep(seq(length(coverage_probs[[1]])),
                          times = length(coverage_probs)))
# Plot
ggplot(coverage_df, aes(x = SampleSize, y = Coverage, color = factor(Parameter))) +
  geom_line() + 
  geom_hline(yintercept = 0.95, linetype = "dashed", color = "red") + # assuming 95% confidence intervals
  labs(x = "Sample Size", y = "Coverage Probability", color = "Parameter") +
  theme_minimal()



#############
# CI WIDTHS #
#############

ci_widths <- list()
for (i in 1:length(sim1_acc_n)) {
    ci_widths[[i]] <- matrix(nrow = length(sim1_acc_mles[[i]]), ncol = length(theta))
    for (j in 1:length(sim1_acc_mles[[i]])) {
        theta.hat <- algebraic.mle::mle_numerical(sim1_acc_mles[[i]][[j]])
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
  data.frame(SampleSize = rep(sample_sizes[i], nrow(ci_widths[[i]])),
             CI_Width = as.vector(ci_widths[[i]]),
             Parameter = rep(seq(ncol(ci_widths[[i]])), each = nrow(ci_widths[[i]])),
             Type = rep(c("Shape", "Scale"), each = nrow(ci_widths[[i]]), times = ncol(ci_widths[[i]]) / 2))
}))

# Split the data frame based on parameter type (Scale or Shape)
ci_widths_list <- split(ci_widths_df, ci_widths_df$Type)

# Generate a plot for each type
plots <- lapply(ci_widths_list, function(df) {
  ggplot(df, aes(x = SampleSize, y = CI_Width, color = factor(Parameter))) +
    geom_line() + 
    labs(x = "Sample Size", y = "Confidence Interval Width", color = "Parameter") +
    facet_wrap(~ Type, scales = "free") +
    theme_minimal()
})

# Arrange the plots in a grid
grid.arrange(grobs = plots, ncol = 1)

######################
# BIAS OF ESTIMATORS #
######################

bias_df <- matrix(NA, nrow = length(sim1_acc_n), ncol = length(theta))
for (i in 1:length(sim1_acc_n)) {
    pars <- t(sapply(sim1_acc_mles[[i]], function(x) x$par))
    bias_df[i,] <- colMeans(pars) - theta
}
bias_df <- as.data.frame(bias_df)
# Load necessary libraries

colnames(bias_df) <- c("shape1", "scale1", "shape2", "scale2", "shape3", "scale3",
                       "shape4", "scale4", "shape5", "scale5")
bias_df$SampleSize <- sim1_acc_n

# Melt data frame for ggplot
bias_df_melted <- melt(bias_df, id.vars = "SampleSize")

# grab only shapes
bias_df_melted_shapes <- bias_df_melted %>%
  filter(grepl("shape", variable))

# Plot
ggplot(bias_df_melted_shapes, aes(x = SampleSize, y = value, color = variable)) +
  geom_line() +
  labs(x = "Sample Size", y = "Bias", color = "Parameter") +
  theme_minimal()


# grab only shapes
bias_df_melted_scales <- bias_df_melted %>%
  filter(grepl("scale", variable))

# Plot
ggplot(bias_df_melted_scales, aes(x = SampleSize, y = value, color = variable)) +
  geom_line() +
  labs(x = "Sample Size", y = "Bias", color = "Parameter") +
  theme_minimal()


