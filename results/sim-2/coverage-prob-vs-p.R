# in this simulation, we have no right censoring and we vary the masking probability
# we want to see how well the estimator performs in this case as a function of
#sample size, from n = 30 to n = 800 for each masking probability 0, 01, 0.2, 0.3, 0.4.
# we have R = 100 replicates for each sample size.

library(gtable)
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
m <- 5
sim2_n <- c(30, 40, 50, 75, 100, 200, 400, 800)


#########################################################
# COVERAGE PROBABILITIES FOR CONFIDENCE INTERVALS p=0.0 #
#########################################################
sim2_30_0 <- readRDS("results/sim-1-accurate/results_30_0_1.rds")
sim2_40_0 <- readRDS("results/sim-1-accurate/results_40_0_1.rds")
sim2_50_0 <- readRDS("results/sim-1-accurate/results_50_0_1.rds")
sim2_75_0 <- readRDS("results/sim-1-accurate/results_75_0_1.rds")
sim2_100_0 <- readRDS("results/sim-1-accurate/results_100_0_1.rds")
sim2_200_0 <- readRDS("results/sim-1-accurate/results_200_0_1.rds")
sim2_400_0 <- readRDS("results/sim-1-accurate/results_400_0_1.rds")
sim2_800_0 <- readRDS("results/sim-1-accurate/results_800_0_1.rds")

sim2_p_0_mles <- list(sim2_30_0$mles, sim2_40_0$mles, sim2_50_0$mles,
    sim2_75_0$mles, sim2_100_0$mles, sim2_200_0$mles, sim2_400_0$mles,
    sim2_800_0$mles)

coverage_probs_p_0 <- list()
for (i in 1:length(sim2_n)) {
    counts <- rep(0, length(theta))
    ci_matrix <- matrix(nrow = length(sim2_p_0_mles[[i]]), ncol = length(theta) * 2)
    for (j in 1:length(sim2_p_0_mles[[i]])) {
        theta.hat <- algebraic.mle::mle_numerical(sim2_p_0_mles[[i]][[j]])
        theta.hat$nobs <- sim2_n[i]

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
    coverage_probs_p_0[[i]] <- counts / length(sim2_p_0_mles[[i]])
}

coverage_p_0_vs_n_df <- data.frame(SampleSize = rep(sim2_n,
    each = length(coverage_probs_p_0[[1]])),
                          Coverage = unlist(coverage_probs_p_0),
                          Parameter = rep(seq(length(coverage_probs_p_0[[1]])),
                          times = length(coverage_probs_p_0)))

#########################################################
# COVERAGE PROBABILITIES FOR CONFIDENCE INTERVALS p=0.1 #
#########################################################
sim2_30_0.1 <- readRDS("results/sim-2/results_30_0.1_1.rds")
sim2_40_0.1 <- readRDS("results/sim-2/results_40_0.1_1.rds")
sim2_50_0.1 <- readRDS("results/sim-2/results_50_0.1_1.rds")
sim2_75_0.1 <- readRDS("results/sim-2/results_75_0.1_1.rds")
sim2_100_0.1 <- readRDS("results/sim-2/results_100_0.1_1.rds")
sim2_200_0.1 <- readRDS("results/sim-2/results_200_0.1_1.rds")
sim2_400_0.1 <- readRDS("results/sim-2/results_400_0.1_1.rds")
sim2_800_0.1 <- readRDS("results/sim-2/results_800_0.1_1.rds")

sim2_p_0.1_mles <- list(sim2_30_0.1$mles, sim2_40_0.1$mles, sim2_50_0.1$mles,
    sim2_75_0.1$mles, sim2_100_0.1$mles, sim2_200_0.1$mles, sim2_400_0.1$mles,
    sim2_800_0.1$mles)

coverage_probs_p_0.1 <- list()
for (i in 1:length(sim2_n)) {
    counts <- rep(0, length(theta))
    ci_matrix <- matrix(nrow = length(sim2_p_0.1_mles[[i]]), ncol = length(theta) * 2)
    for (j in 1:length(sim2_p_0.1_mles[[i]])) {
        theta.hat <- algebraic.mle::mle_numerical(sim2_p_0.1_mles[[i]][[j]])
        theta.hat$nobs <- sim2_n[i]

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
    coverage_probs_p_0.1[[i]] <- counts / length(sim2_p_0.1_mles[[i]])
}

coverage_p_0.1_vs_n_df <- data.frame(SampleSize = rep(sim2_n,
    each = length(coverage_probs_p_0.1[[1]])),
                          Coverage = unlist(coverage_probs_p_0.1),
                          Parameter = rep(seq(length(coverage_probs_p_0.1[[1]])),
                          times = length(coverage_probs_p_0.1)))

#########################################################
# COVERAGE PROBABILITIES FOR CONFIDENCE INTERVALS p=0.2 #
#########################################################


# let's read in the results from the simulations
sim2_30_0.2 <- readRDS("results/sim-2/results_30_0.2_1.rds")
sim2_40_0.2 <- readRDS("results/sim-2/results_40_0.2_1.rds")
sim2_50_0.2 <- readRDS("results/sim-2/results_50_0.2_1.rds")
sim2_75_0.2 <- readRDS("results/sim-2/results_75_0.2_1.rds")
sim2_100_0.2 <- readRDS("results/sim-2/results_100_0.2_1.rds")
sim2_200_0.2 <- readRDS("results/sim-2/results_200_0.2_1.rds")
sim2_400_0.2 <- readRDS("results/sim-2/results_400_0.2_1.rds")
sim2_800_0.2 <- readRDS("results/sim-2/results_800_0.2_1.rds")

sim2_p_0.2_mles <- list(sim2_30_0.2$mles, sim2_40_0.2$mles, sim2_50_0.2$mles,
    sim2_75_0.2$mles, sim2_100_0.2$mles, sim2_200_0.2$mles, sim2_400_0.2$mles,
    sim2_800_0.2$mles)

coverage_probs_p_0.2 <- list()
for (i in 1:length(sim2_n)) {
    counts <- rep(0, length(theta))
    ci_matrix <- matrix(nrow = length(sim2_p_0.2_mles[[i]]), ncol = length(theta) * 2)
    for (j in 1:length(sim2_p_0.2_mles[[i]])) {
        theta.hat <- algebraic.mle::mle_numerical(sim2_p_0.2_mles[[i]][[j]])
        theta.hat$nobs <- sim2_n[i]

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
    coverage_probs_p_0.2[[i]] <- counts / length(sim2_p_0.2_mles[[i]])
}

# Create a data frame
coverage_p_0.2_vs_n_df <- data.frame(SampleSize = rep(sim2_n,
    each = length(coverage_probs_p_0.2[[1]])),
                          Coverage = unlist(coverage_probs_p_0.2),
                          Parameter = rep(seq(length(coverage_probs_p_0.2[[1]])),
                          times = length(coverage_probs_p_0.2)))

#########################################################
# COVERAGE PROBABILITIES FOR CONFIDENCE INTERVALS p=0.3 #
#########################################################

sim2_30_0.3 <- readRDS("results/sim-2/results_30_0.3_1.rds")
sim2_40_0.3 <- readRDS("results/sim-2/results_40_0.3_1.rds")
sim2_50_0.3 <- readRDS("results/sim-2/results_50_0.3_1.rds")
sim2_75_0.3 <- readRDS("results/sim-2/results_75_0.3_1.rds")
sim2_100_0.3 <- readRDS("results/sim-2/results_100_0.3_1.rds")
sim2_200_0.3 <- readRDS("results/sim-2/results_200_0.3_1.rds")
sim2_400_0.3 <- readRDS("results/sim-2/results_400_0.3_1.rds")
sim2_800_0.3 <- readRDS("results/sim-2/results_800_0.3_1.rds")

sim2_p_0.3_mles <- list(sim2_30_0.3$mles, sim2_40_0.3$mles, sim2_50_0.3$mles,
    sim2_75_0.3$mles, sim2_100_0.3$mles, sim2_200_0.3$mles, sim2_400_0.3$mles,
    sim2_800_0.3$mles)
coverage_probs_p_0.3 <- list()
for (i in 1:length(sim2_n)) {
    counts <- rep(0, length(theta))
    ci_matrix <- matrix(nrow = length(sim2_p_0.3_mles[[i]]), ncol = length(theta) * 2)
    for (j in 1:length(sim2_p_0.3_mles[[i]])) {
        theta.hat <- algebraic.mle::mle_numerical(sim2_p_0.3_mles[[i]][[j]])
        theta.hat$nobs <- sim2_n[i]

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
    coverage_probs_p_0.3[[i]] <- counts / length(sim2_p_0.3_mles[[i]])
}

coverage_p_0.3_vs_n_df <- data.frame(SampleSize = rep(sim2_n,
    each = length(coverage_probs_p_0.3[[1]])),
                          Coverage = unlist(coverage_probs_p_0.3),
                          Parameter = rep(seq(length(coverage_probs_p_0.3[[1]])),
                          times = length(coverage_probs_p_0.3)))

#########################################################
# COVERAGE PROBABILITIES FOR CONFIDENCE INTERVALS p=0.4 #
#########################################################

sim2_30_0.4 <- readRDS("results/sim-2/results_30_0.4_1.rds")
sim2_40_0.4 <- readRDS("results/sim-2/results_40_0.4_1.rds")
sim2_50_0.4 <- readRDS("results/sim-2/results_50_0.4_1.rds")
sim2_75_0.4 <- readRDS("results/sim-2/results_75_0.4_1.rds")
sim2_100_0.4 <- readRDS("results/sim-2/results_100_0.4_1.rds")
sim2_200_0.4 <- readRDS("results/sim-2/results_200_0.4_1.rds")
sim2_400_0.4 <- readRDS("results/sim-2/results_400_0.4_1.rds")
sim2_800_0.4 <- readRDS("results/sim-2/results_800_0.4_1.rds")

sim2_p_0.4_mles <- list(sim2_30_0.4$mles, sim2_40_0.4$mles, sim2_50_0.4$mles,
    sim2_75_0.4$mles, sim2_100_0.4$mles, sim2_200_0.4$mles, sim2_400_0.4$mles,
    sim2_800_0.4$mles)

coverage_probs_p_0.4 <- list()
for (i in 1:length(sim2_n)) {
    counts <- rep(0, length(theta))
    ci_matrix <- matrix(nrow = length(sim2_p_0.4_mles[[i]]), ncol = length(theta) * 2)
    for (j in 1:length(sim2_p_0.4_mles[[i]])) {
        theta.hat <- algebraic.mle::mle_numerical(sim2_p_0.4_mles[[i]][[j]])
        theta.hat$nobs <- sim2_n[i]

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
    coverage_probs_p_0.4[[i]] <- counts / length(sim2_p_0.4_mles[[i]])
}

# Create a data frame
coverage_p_0.4_vs_n_df <- data.frame(SampleSize = rep(sim2_n,
    each = length(coverage_probs_p_0.4[[1]])),
                          Coverage = unlist(coverage_probs_p_0.4),
                          Parameter = rep(seq(length(coverage_probs_p_0.4[[1]])),
                          times = length(coverage_probs_p_0.4)))

############################################################
# PLOT ALL COVERAGE PROBABILITIES FOR CONFIDENCE INTERVALS #
############################################################

coverage_p_0.4_vs_n_df <- coverage_p_0.4_vs_n_df %>%
    mutate(ParameterType = ifelse(Parameter %% 2 != 0, "Shape", "Scale"))
coverage_p_0.3_vs_n_df <- coverage_p_0.3_vs_n_df %>%
    mutate(ParameterType = ifelse(Parameter %% 2 != 0, "Shape", "Scale"))
coverage_p_0.2_vs_n_df <- coverage_p_0.2_vs_n_df %>%
    mutate(ParameterType = ifelse(Parameter %% 2 != 0, "Shape", "Scale"))
coverage_p_0.1_vs_n_df <- coverage_p_0.1_vs_n_df %>%
    mutate(ParameterType = ifelse(Parameter %% 2 != 0, "Shape", "Scale"))
coverage_p_0_vs_n_df <- coverage_p_0_vs_n_df %>%
    mutate(ParameterType = ifelse(Parameter %% 2 != 0, "Shape", "Scale"))
myColors <- c("Shape" = "blue", "Scale" = "red")
myLines <- c("Shape" = "solid", "Scale" = "dashed")
plot_coverage_p_0_vs_n <- ggplot(coverage_p_0_vs_n_df,
    aes(x = SampleSize, y = Coverage, linetype = ParameterType)) +
  geom_line(aes(color = ParameterType)) +
  geom_hline(yintercept = 0.95, linetype = "dashed",  color = "darkred", linewidth = 2) +
  scale_color_manual(values = myColors) +
  scale_linetype_manual(values = myLines) +
  labs(x = "Sample Size", y = "Coverage Probability") +
  theme_minimal() + ggtitle("No Masking")

plot_coverage_p_0.1_vs_n <- ggplot(coverage_p_0.1_vs_n_df,
    aes(x = SampleSize, y = Coverage, linetype = ParameterType)) +
  geom_line(aes(color = ParameterType)) +
  geom_hline(yintercept = 0.95, linetype = "dashed",  color = "darkred", linewidth = 2) +
  scale_color_manual(values = myColors) +
  scale_linetype_manual(values = myLines) +
  labs(x = "Sample Size", y = "Coverage Probability") +
  theme_minimal() + ggtitle("Masking Probability 0.1")

plot_coverage_p_0.2_vs_n <- ggplot(coverage_p_0.2_vs_n_df,
    aes(x = SampleSize, y = Coverage, linetype = ParameterType)) +
  geom_line(aes(color = ParameterType)) +
  geom_hline(yintercept = 0.95, linetype = "dashed",  color = "darkred", linewidth = 2) +
  scale_color_manual(values = myColors) +
  scale_linetype_manual(values = myLines) +
  labs(x = "Sample Size", y = "Coverage Probability") +
  theme_minimal() + ggtitle("Masking Probability 0.2")

plot_coverage_p_0.3_vs_n <- ggplot(coverage_p_0.3_vs_n_df,
    aes(x = SampleSize, y = Coverage, linetype = ParameterType)) +
  geom_line(aes(color = ParameterType)) +
  geom_hline(yintercept = 0.95, linetype = 
    color = "green") +
  scale_color_manual(values = myColors) +
  scale_linetype_manual(values = myLines) +
  labs(x = "Sample Size", y = "Coverage Probability") +
  theme_minimal() + ggtitle("Masking Probability 0.3")

plot_coverage_p_0.4_vs_n <- ggplot(coverage_p_0.4_vs_n_df,
    aes(x = SampleSize, y = Coverage, linetype = ParameterType)) +
  geom_line(aes(color = ParameterType)) +
  geom_hline(yintercept = 0.95, linetype = "dashed",  color = "darkred", linewidth = 2) +
  scale_color_manual(values = myColors) +
  scale_linetype_manual(values = myLines) +
  labs(x = "Sample Size", y = "Coverage Probability") +
  theme_minimal() + ggtitle("Masking Probability 0.4")

legend <- gtable_filter(ggplotGrob(plot_coverage_p_0.4_vs_n), "guide-box")
plot_coverage_p_0_vs_n_scaled <- plot_coverage_p_0_vs_n + theme(legend.position = "none") + ylim(0.4,1)
plot_coverage_p_0.1_vs_n_scaled <- plot_coverage_p_0.1_vs_n + theme(legend.position = "none") + ylim(0.4,1)
plot_coverage_p_0.2_vs_n_scaled <- plot_coverage_p_0.2_vs_n + theme(legend.position = "none") + ylim(0.4,1)
plot_coverage_p_0.3_vs_n_scaled <- plot_coverage_p_0.3_vs_n + theme(legend.position = "none") + ylim(0.4,1)
plot_coverage_p_0.4_vs_n_scaled <- plot_coverage_p_0.4_vs_n + theme(legend.position = "none") + ylim(0.4,1)

plot_coverage_p_vs_n <- grid.arrange(
    plot_coverage_p_0_vs_n_scaled,
    plot_coverage_p_0.1_vs_n_scaled,
    plot_coverage_p_0.2_vs_n_scaled,
    plot_coverage_p_0.3_vs_n_scaled,
    plot_coverage_p_0.4_vs_n_scaled,
    legend, ncol=2)

ggsave("results/sim-2/plot-coverage-p-vs-sample-size.pdf",
  plot = plot_coverage_p_vs_n)


plot_coverage_p_0.3_vs_n_alt <- ggplot(coverage_p_0.3_vs_n_df,
  aes(x = SampleSize, y = Coverage, linetype = ParameterType, color = factor(Parameter))) +
  geom_line() + geom_hline(yintercept = 0.95, linetype = "dashed", color = "darkred", linewidth = 2) +
  labs(x = "Sample Size", y = "Coverage Probability", color = "Parameter") +
  theme_minimal() + ggtitle("Masking Probability 0.3") +
  scale_color_discrete(name = "Parameters",
                       labels = c("Shape 1", "Scale 1", "Shape 2", "Scale 2", "Shape 3", "Scale 3", "Shape 4", "Scale 4", "Shape 5", "Scale 5")) +
  scale_linetype_discrete(name = "Parameter Type", labels = c("Shape", "Scale")) +
  scale_linetype_manual(values=c("Shape" = "solid", "Scale" = "dashed"))

ggsave("results/sim-2/plot-coverage-p_0.3-vs-sample-size.pdf",
  plot = plot_coverage_p_0.3_vs_n_alt)
