# in this simulation, we have no right censoring and a sample size of 100.
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
sim_30_p_0.2 <- readRDS("results/sim-2/results_30_0.2_1.rds")
sim_40_p_0.2 <- readRDS("results/sim-2/results_40_0.2_1.rds")
sim_50_p_0.2 <- readRDS("results/sim-2/results_50_0.2_1.rds")
sim_75_p_0.2 <- readRDS("results/sim-2/results_75_0.2_1.rds")
sim_100_p_0.2 <- readRDS("results/sim-2/results_100_0.2_1.rds")
sim_200_p_0.2 <- readRDS("results/sim-2/results_200_0.2_1.rds")
sim_400_p_0.2 <- readRDS("results/sim-2/results_400_0.2_1.rds")
sim_800_p_0.2 <- readRDS("results/sim-2/results_800_0.2_1.rds")
m <- 5

# let's compute the confint of each mle for each sample size and compute the
# coverage probability
sim_n <- c(30, 40, 50, 75, 100, 200, 400, 800)
sim_n_mles <- list(sim_30_p_0.2$mles, sim_40_p_0.2$mles, sim_50_p_0.2$mles,
    sim_75_p_0.2$mles, sim_100_p_0.2$mles, sim_200_p_0.2$mles, sim_400_p_0.2$mles,
    sim_800_p_0.2$mles)


######################
# BIAS OF ESTIMATORS #
######################

bias_p_0.2_df <- matrix(NA, nrow = length(sim_n), ncol = length(theta))
for (i in 1:length(sim_n)) {
    pars <- t(sapply(sim_n_mles[[i]], function(x) x$par))
    bias_p_0.2_df[i,] <- colMeans(pars) - theta
}
bias_p_0.2_df <- as.data.frame(bias_p_0.2_df)

colnames(bias_p_0.2_df) <- c("shape1", "scale1", "shape2", "scale2", "shape3", "scale3",
                       "shape4", "scale4", "shape5", "scale5")
bias_p_0.2_df$SampleSize <- sim_n

# Melt data frame for ggplot
bias_p_0.2_df_melted <- melt(bias_p_0.2_df, id.vars = "SampleSize")

# grab only shapes
bias_p_0.2_df_melted_shapes <- bias_p_0.2_df_melted %>%
  filter(grepl("shape", variable))

plot_bias_p_0.2_shapes <- ggplot(
  bias_p_0.2_df_melted_shapes, aes(x = SampleSize, y = abs(value), color = variable)) +
  geom_line() +
  scale_y_log10() +  
  labs(x = "Sample Size", y = "Bias", color = "Parameter") +
  theme_minimal()

# grab only shapes
bias_p_0.2_df_melted_scales <- bias_p_0.2_df_melted %>%
  filter(grepl("scale", variable))

# let's plot on a log scale
plot_bias_p_0.2_scales <- ggplot(
  bias_p_0.2_df_melted_scales, aes(x = SampleSize, y = abs(value), color = variable)) +
  geom_line() +
  scale_y_log10() +  
  labs(x = "Sample Size", y = "Bias", color = "Parameter") +
  theme_minimal()

plot_bias_p_0.2 <- grid.arrange(
  grobs = list(plot_bias_p_0.2_shapes, plot_bias_p_0.2_scales), nrow = 2)


# save the plots
ggsave("results/sim-2/plot-p-0.2-bias-scales-vs-sample-size.pdf",
  plot = plot_bias_p_0.2_scales)

ggsave("results/sim-2/plot-p-0.2-bias-shapes-vs-sample-size.pdf",
  plot = plot_bias_p_0.2_shapes)

ggsave("results/sim-2/plot-p-0.2-bias-vs-sample-size.pdf",
  plot = plot_bias_p_0.2)
