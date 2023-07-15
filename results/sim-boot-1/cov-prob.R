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
sim_n <- c(30, 50, 100, 200, 400)

###############################################################
# COVERAGE PROBABILITIES FOR CONFIDENCE INTERVALS p=0 and q=1 #
###############################################################
sim_30_0_1 <- readRDS("results/sim-boot-1/results_30_0_1.rds")
sim_50_0_1 <- readRDS("results/sim-boot-1/results_50_0_1.rds")
sim_100_0_1 <- readRDS("results/sim-boot-1/results_100_0_1.rds")
sim_200_0_1 <- readRDS("results/sim-boot-1/results_200_0_1.rds")
sim_400_0_1 <- readRDS("results/sim-boot-1/results_400_0_1.rds")

###############################################################
# COVERAGE PROBABILITIES FOR CONFIDENCE INTERVALS p=.1 and q=1 #
###############################################################
sim_30_0.1_1 <- readRDS("results/sim-boot-1/results_30_0.1_1.rds")
sim_50_0.1_1 <- readRDS("results/sim-boot-1/results_50_0.1_1.rds")
sim_100_0.1_1 <- readRDS("results/sim-boot-1/results_100_0.1_1.rds")
sim_200_0.1_1 <- readRDS("results/sim-boot-1/results_200_0.1_1.rds")
sim_400_0.1_1 <- readRDS("results/sim-boot-1/results_400_0.1_1.rds")

###############################################################
# COVERAGE PROBABILITIES FOR CONFIDENCE INTERVALS p=.215 and q=1 #
###############################################################
sim_30_0.215_1 <- readRDS("results/sim-boot-1/results_30_0.215_1.rds")
sim_50_0.215_1 <- readRDS("results/sim-boot-1/results_50_0.215_1.rds")
sim_100_0.215_1 <- readRDS("results/sim-boot-1/results_100_0.215_1.rds")
sim_200_0.215_1 <- readRDS("results/sim-boot-1/results_200_0.215_1.rds")
sim_400_0.215_1 <- readRDS("results/sim-boot-1/results_400_0.215_1.rds")

sim_0_1_mles <- list(sim_30_0_1, sim_50_0_1, sim_100_0_1, sim_200_0_1, sim_400_0_1)
sim_0.1_1_mles <- list(sim_30_0.1_1, sim_50_0.1_1, sim_100_0.1_1, sim_200_0.1_1, sim_400_0.1_1)
sim_0.215_1_mles <- list(sim_30_0.215_1, sim_50_0.215_1, sim_100_0.215_1, sim_200_0.215_1, sim_400_0.215_1)

ci_comp <- function(sim_p_q_mles, sim_n) {
    data <- list()

    for (mle in sim_p_q_mles) {
        theta.hat <- mle_numerical(mle$mle)
        theta.hat$nobs <- sim_n[i]
        theta.boot <- mle_boot(mle$mle.boot)

        # this is a m x 2 matrix, where m is the number of parameters
        ci.fim <- confint(theta.hat, use_t_dist = FALSE)
        ci.boot <- confint(theta.boot)
        var.fim <- diag(vcov(theta.hat))
        var.boot <- diag(vcov(theta.boot))

        if (any(is.na(ci.fim))) {
            print("NA")
        } else {
            # append to data list
            data <- c(data, list(list(n = mle$n, p = mle$p, q = mle$q,
                ci.fim = ci.fim,
                ci.boot = ci.boot,
                var.fim = var.fim,
                var.boot = var.boot,
                ci.fim.contains = theta > ci.fim[,1] & theta < ci.fim[,2],
                ci.boot.contains = theta > ci.boot[,1] & theta < ci.boot[,2],
                ci.fim.width = ci.fim[,2] - ci.fim[,1],
                ci.boot.width = ci.boot[,2] - ci.boot[,1])))
        }
    }
    return(data)
}

results1 <- ci_comp(sim_0_1_mles, sim_n)
results2 <- ci_comp(sim_0.1_1_mles, sim_n)
results3 <- ci_comp(sim_0.215_1_mles, sim_n)




# Load necessary packages
library(dplyr)
library(tidyr)
library(ggplot2)

results <- results3
# Extract necessary data
data <- lapply(results, function(x) {
  tibble(
    n = x$n,
    var.fim = x$var.fim,
    var.boot = x$var.boot,
    parameter = rep(c("shape", "scale"), each = 5) # adjust here according to your parameters
  )
})

# Combine all data
data <- bind_rows(data)
data_shapes <- data[data$parameter == "shape",]
data_scales <- data[data$parameter == "scale",]

# Create the plot
plot(x = data_shapes$n, y = data_shapes$var.boot, col = "blue", xlab = "Sample Size", ylab = "Variance")
points(x = data_shapes$n, y = data_shapes$var.fim, col = "green")

# Add a legend
legend("topright", legend = c("Boot", "FIM"), col = c("blue", "green"), pch = c(1, 1))

# Save the plot as an image file
png("plot_shapes_0.215.png")
plot(x = data_shapes$n, y = data_shapes$var.boot,
    col = "blue", xlab = "Sample Size", ylab = "Variance",
    main = "Masking Probability = 0.215")
points(x = data_shapes$n, y = data_shapes$var.fim, col = "green")
legend("topright", legend = c("Boot", "FIM"), col = c("blue", "green"), pch = c(1, 1))
dev.off()





#########



# Create the plot
plot(x = data_scales$n, y = data_scales$var.boot, col = "blue", xlab = "Sample Size", ylab = "Variance")
points(x = data_scales$n, y = data_scales$var.fim, col = "green")

# Add a legend
legend("topright", legend = c("Boot", "FIM"), col = c("blue", "green"), pch = c(1, 1))

# Save the plot as an image file
png("plot_scales_0.215.png")
plot(x = data_scales$n, y = data_scales$var.boot, col ="blue",xlab = "Sample Size", ylab = "Variance",
    main = "Masking Probability = 0.215")
points(x = data_scales$n, y = data_scales$var.fim, col = "green")
legend("topright", legend = c("Boot", "FIM"), col = c("blue", "green"), pch = c(1, 1))
dev.off()