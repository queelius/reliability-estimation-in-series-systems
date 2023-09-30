args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
    stop("You must provide a csv_file name as an argument.")
} else {
    csv_file <- args[1]
}

source("../sim-scenario.R")
library(wei.series.md.c1.c2.c3)
N <- c(90L)
P <- rep(c(.1, .25, .4, .55, .7), 100)
Q <- c(.825)

sim_scenario(
    theta = alex_weibull_series$theta,
    N = N, P = P, Q = Q, R = 200L, B = 1000L,
    max_iter = 125L, max_boot_iter = 125L,
    n_cores = 2L, csv_file = csv_file,
    ci_method = "bca", ci_level = .95)
