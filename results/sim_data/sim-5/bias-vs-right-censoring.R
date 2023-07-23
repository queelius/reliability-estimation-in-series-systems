# in this simulation, we have right censoring at quantiles 1, .95, .9, .7, .5
# of weibull series system and a cmoponent cause of failure p = .215. we want to see
# how well the  estimator performs in this case as a function of sample size,
# from n = 50, 150, 300 and as a function of quantiles.
# we have R = 120 replicates for each sample size.


###########################
# BIAS OF ESTIMATORS      #
# bias vs right censoring #
###########################

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

sim_n <- c(50, 150, 300)
qs <- c(1, .95, .9, .7, .5)


sim_n_50_q_1 <- readRDS("results/sim-5/results_50_0.215_1.rds")
sim_n_50_q_95 <- readRDS("results/sim-5/results_50_0.215_0.95.rds")
sim_n_50_q_9 <- readRDS("results/sim-5/results_50_0.215_0.9.rds")
sim_n_50_q_7 <- readRDS("results/sim-5/results_50_0.215_0.7.rds")
sim_n_50_q_5 <- readRDS("results/sim-5/results_50_0.215_0.5.rds")
sim_n_150_q_1 <- readRDS("results/sim-5/results_150_0.215_1.rds")
sim_n_150_q_95 <- readRDS("results/sim-5/results_150_0.215_0.95.rds")
sim_n_150_q_9 <- readRDS("results/sim-5/results_150_0.215_0.9.rds")
sim_n_150_q_7 <- readRDS("results/sim-5/results_150_0.215_0.7.rds")
sim_n_150_q_5 <- readRDS("results/sim-5/results_150_0.215_0.5.rds")
sim_n_300_q_1 <- readRDS("results/sim-5/results_300_0.215_1.rds")
sim_n_300_q_95 <- readRDS("results/sim-5/results_300_0.215_0.95.rds")
sim_n_300_q_9 <- readRDS("results/sim-5/results_300_0.215_0.9.rds")
sim_n_300_q_7 <- readRDS("results/sim-5/results_300_0.215_0.7.rds")
sim_n_300_q_5 <- readRDS("results/sim-5/results_300_0.215_0.5.rds")

##################
# 50 sample size #
##################

sim_n_50_mles <- list(sim_n_50_q_1$mles, sim_n_50_q_95$mles, sim_n_50_q_9$mles,
    sim_n_50_q_7$mles, sim_n_50_q_5$mles)

bias_n_50_df <- matrix(NA, nrow = length(sim_n_50_mles), ncol = length(theta))
for (i in 1:length(sim_n_50_mles)) {
    pars <- t(sapply(sim_n_50_mles[[i]], function(x) x$par))
    bias_n_50_df[i,] <- colMeans(pars) - theta
}

bias_n_50_df <- as.data.frame(bias_n_50_df)
colnames(bias_n_50_df) <- c("shape1", "scale1", "shape2", "scale2", "shape3", "scale3",
                       "shape4", "scale4", "shape5", "scale5")
bias_n_50_df$Tau <- qs

# Melt data frame for ggplot
bias_n_50_df_melted <- melt(bias_n_50_df, id.vars = "Tau")

# grab only shapes
bias_n_50_df_melted_shapes <- bias_n_50_df_melted %>%
  filter(grepl("shape", variable))

tau_vs_shapes_bias_sample_size_50 <- ggplot(
  bias_n_50_df_melted_shapes, aes(x = Tau, y = value, color = variable)) +
  geom_line() +
  labs(x = "Right-censoring time (Sample Size 50)", y = "Bias", color = "Parameter") +
  theme_minimal()

# grab only shapes
bias_n_50_df_melted_scales <- bias_n_50_df_melted %>%
  filter(grepl("scale", variable))

tau_vs_scales_bias_sample_size_50 <- ggplot(
  bias_n_50_df_melted_scales, aes(x = Tau, y = value, color = variable)) +
  geom_line() +
  labs(x = "Right-censoring time (Sample Size 50)", y = "Bias", color = "Parameter") +
  theme_minimal()

grid.arrange(tau_vs_shapes_bias_sample_size_50, tau_vs_scales_bias_sample_size_50,
    nrow = 1)
###################
# 150 sample size #
###################

sim_n_150_mles <- list(sim_n_150_q_1$mles, sim_n_150_q_95$mles, sim_n_150_q_9$mles,
    sim_n_150_q_7$mles, sim_n_150_q_5$mles)

bias_n_150_df <- matrix(NA, nrow = length(sim_n_150_mles), ncol = length(theta))
for (i in 1:length(sim_n_150_mles)) {
    pars <- t(sapply(sim_n_150_mles[[i]], function(x) x$par))
    bias_n_150_df[i,] <- colMeans(pars) - theta
}

bias_n_150_df <- as.data.frame(bias_n_150_df)
colnames(bias_n_150_df) <- c("shape1", "scale1", "shape2", "scale2", "shape3", "scale3",
                       "shape4", "scale4", "shape5", "scale5")
bias_n_150_df$Tau <- qs

# Melt data frame for ggplot
bias_n_150_df_melted <- melt(bias_n_150_df, id.vars = "Tau")

# grab only shapes
bias_n_150_df_melted_shapes <- bias_n_150_df_melted %>%
  filter(grepl("shape", variable))

tau_vs_shapes_bias_sample_size_150 <- ggplot(
  bias_n_150_df_melted_shapes, aes(x = Tau, y = value, color = variable)) +
  geom_line() +
  labs(x = "Right-censoring time (Sample Size 150)", y = "Bias", color = "Parameter") +
  theme_minimal()

# grab only shapes
bias_n_150_df_melted_scales <- bias_n_150_df_melted %>%
  filter(grepl("scale", variable))

tau_vs_scales_bias_sample_size_150 <- ggplot(
  bias_n_150_df_melted_scales, aes(x = Tau, y = value, color = variable)) +
  geom_line() +
  labs(x = "Right-censoring time (Sample Size 150)", y = "Bias", color = "Parameter") +
  theme_minimal()

grid.arrange(tau_vs_shapes_bias_sample_size_150, tau_vs_scales_bias_sample_size_150,
    nrow = 1)

###################
# 300 sample size #
###################
sim_n_300_mles <- list(sim_n_300_q_1$mles, sim_n_300_q_95$mles, sim_n_300_q_9$mles,
    sim_n_300_q_7$mles, sim_n_300_q_5$mles)

bias_n_300_df <- matrix(NA, nrow = length(sim_n_300_mles), ncol = length(theta))
for (i in 1:length(sim_n_300_mles)) {
    pars <- t(sapply(sim_n_300_mles[[i]], function(x) x$par))
    bias_n_300_df[i,] <- colMeans(pars) - theta
}

bias_n_300_df <- as.data.frame(bias_n_300_df)
colnames(bias_n_300_df) <- c("shape1", "scale1", "shape2", "scale2", "shape3", "scale3",
                       "shape4", "scale4", "shape5", "scale5")
bias_n_300_df$Tau <- qs

# Melt data frame for ggplot
bias_n_300_df_melted <- melt(bias_n_300_df, id.vars = "Tau")

# grab only shapes
bias_n_300_df_melted_shapes <- bias_n_300_df_melted %>%
  filter(grepl("shape", variable))

tau_vs_shapes_bias_sample_size_300 <- ggplot(
  bias_n_300_df_melted_shapes, aes(x = Tau, y = value, color = variable)) +
  geom_line() +
  labs(x = "Right-censoring time (Sample Size 300)", y = "Bias", color = "Parameter") +
  theme_minimal()

# grab only scales
bias_n_300_df_melted_scales <- bias_n_300_df_melted %>%
  filter(grepl("scale", variable))

tau_vs_scales_bias_sample_size_300 <- ggplot(
  bias_n_300_df_melted_scales, aes(x = Tau, y = value, color = variable)) +
  geom_line() +
  labs(x = "Right-censoring time (Sample Size 300)", y = "Bias", color = "Parameter") +
  theme_minimal()

grid.arrange(tau_vs_shapes_bias_sample_size_300, tau_vs_scales_bias_sample_size_300,
    nrow = 1)

###########################
# DO THE PLOTS BELOW HERE #
###########################

tau_vs_shapes_bias_sample_size_50_s <- tau_vs_shapes_bias_sample_size_50 + ylim(-.1, .9)
tau_vs_scales_bias_sample_size_50_s <- tau_vs_scales_bias_sample_size_50 + ylim(0, 500)

tau_vs_shapes_bias_sample_size_150_s <- tau_vs_shapes_bias_sample_size_150 + ylim(-.1, .9)
tau_vs_scales_bias_sample_size_150_s <- tau_vs_scales_bias_sample_size_150 + ylim(0, 500)

tau_vs_shapes_bias_sample_size_300_s <- tau_vs_shapes_bias_sample_size_300 + ylim(-.1, .9)
tau_vs_scales_bias_sample_size_300_s <- tau_vs_scales_bias_sample_size_300 + ylim(0, 500)


plot_tau_vs_sample <- grid.arrange(
    tau_vs_shapes_bias_sample_size_50_s, tau_vs_scales_bias_sample_size_50_s,
    tau_vs_shapes_bias_sample_size_150_s, tau_vs_scales_bias_sample_size_150_s,
    tau_vs_shapes_bias_sample_size_300_s, tau_vs_scales_bias_sample_size_300_s,
    nrow = 3)

ggsave("results/sim-5/plot-bias-tau-vs-sample-size-50-150-300.pdf",
  plot = plot_tau_vs_sample)





