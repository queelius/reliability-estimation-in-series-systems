args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
    stop("You must provide a csv_file name as an argument.")
} else {
    csv_file <- args[1]
}

source("../sim-scenario.R")
library(wei.series.md.c1.c2.c3)
N <- rep(c(50L, 100L, 250L),10)
P <- c(.215)
Q <- c(.825)

# max_iter <- 100L
# max_boot_iter <- 125L

sim_scenario(
    theta = alex_weibull_series$theta,
    N = N, P = P, Q = Q, R = 10L, B = 500L,
    max_iter = 100L, max_boot_iter = 125L,
    n_cores = 2L, csv_file = csv_file,
    ci_method = "bca", ci_level = .95)
