# in this simulation, we have no right censoring and no masking of component cause
# of failure. it's the ideal case. we want to see how well the estimator
# performs in this case as a function of sample size, from n = 20 to n = 1000.
# we have R = 200 replicates for each sample size.


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
m <- 5
shapes <- theta[seq(1, length(theta), 2)]
scales <- theta[seq(2, length(theta), 2)]

# let's read in the results from the simulations
sim1_20 <- readRDS("results/sim-1/results_20_0_1.rds") 
sim1_40 <- readRDS("results/sim-1/results_40_0_1.rds")
sim1_60 <- readRDS("results/sim-1/results_60_0_1.rds")
sim1_80 <- readRDS("results/sim-1/results_80_0_1.rds")
sim1_100 <- readRDS("results/sim-1/results_100_0_1.rds")
sim1_150 <- readRDS("results/sim-1/results_150_0_1.rds")
sim1_200 <- readRDS("results/sim-1/results_200_0_1.rds")
sim1_300 <- readRDS("results/sim-1/results_300_0_1.rds")
sim1_400 <- readRDS("results/sim-1/results_400_0_1.rds")
sim1_500 <- readRDS("results/sim-1/results_500_0_1.rds")
sim1_600 <- readRDS("results/sim-1/results_600_0_1.rds")
sim1_700 <- readRDS("results/sim-1/results_700_0_1.rds")
sim1_800 <- readRDS("results/sim-1/results_800_0_1.rds")
sim1_900 <- readRDS("results/sim-1/results_900_0_1.rds")
sim1_1000 <- readRDS("results/sim-1/results_1000_0_1.rds")
sim1_n <- c(20, 40, 60, 80, 100, 150, 200, 300, 400, 500, 600, 700, 800, 900, 1000)
sim1_mles <- list(sim1_20$mles, sim1_40$mles, sim1_60$mles, sim1_80$mles,
                  sim1_100$mles, sim1_150$mles, sim1_200$mles, sim1_300$mles,
                  sim1_400$mles, sim1_500$mles, sim1_600$mles, sim1_700$mles,
                  sim1_800$mles, sim1_900$mles, sim1_1000$mles)


##########################
# COVERAGE PROBABILITIES #
##########################

# let's compute the confint of each mle for each sample size and compute the
# coverage probability

for (i in 1:length(sim1_n)) {
    counts <- rep(0, length(theta))
    for (j in 1:length(sim1_mles[[i]])) {
        theta.hat <- algebraic.mle::mle_numerical(sim1_mles[[i]][[j]])
        theta.hat$nobs <- sim1_n[i]
        ci <- confint(theta.hat, use_t_dist = TRUE)
        #cat("r = ", j, ": ", params(theta.hat), "\n")
        #print(ci)

        if (any(is.na(ci))) {
            next
        }

        for (k in 1:length(theta)) {
            if (theta[k] > ci[k, 1] && theta[k] < ci[k, 2]) {
                counts[k] <- counts[k] + 1
            }
        }
    }
    cat("n =", sim1_n[i], ":", counts / length(sim1_mles[[i]]), "\n")
}



########
# BIAS #
########

bias_list <- list()
for (i in 1:length(sim1_n)) {
    pars <- t(sapply(sim1_mles[[i]], function(x) x$par))
    bias <- abs(colMeans(pars) - theta)
    cat("n = ", sim1_n[1], " => ", bias, "\n")
    
}

