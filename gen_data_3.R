library(tidyverse)
library(wei.series.md.c1.c2.c3)
library(usethis)
library(readr)
library(stats)
library(algebraic.mle)
library(algebraic.dist)
library(md.tools)
devtools::load_all("./wei.series.md.c1.c2.c3/")

options(digits = 3)
options(scipen = 999)

theta <- c(shape1 = 1.2576, scale1 = 994.3661,
           shape2 = 1.1635, scale2 = 908.9458,
           shape3 = 1.1308, scale3 = 840.1141,
           shape4 = 1.1802, scale4 = 940.1141,
           shape5 = 1.3311, scale5 = 836.1123)

shapes <- theta[seq(1, length(theta), 2)]
scales <- theta[seq(2, length(theta), 2)]

generate_data <- function(theta, n, p) {

    shape <- theta[seq(1, length(theta), 2)]
    scale <- theta[seq(2, length(theta), 2)]
    m <- length(shape)
    comp_times <- matrix(nrow = n, ncol = m)

    for (j in 1:m) {
        comp_times[, j] <- rweibull(
            n = n,
            shape = shape[j],
            scale = scale[j])
    }
    comp_times <- md_encode_matrix(comp_times, "t")

    comp_times %>%
        md_series_lifetime_right_censoring() %>%
        md_bernoulli_cand_c1_c2_c3(p) %>%
        md_cand_sampler()
}

fit.wei.series.md.c1.c2.c2 <- function(df, theta0, maxit = 10000) {

    stats::optim(
        par = theta0,
        fn = function(theta) {
            wei.series.md.c1.c2.c3::loglik_wei_series_md_c1_c2_c3(
                df = df,
                theta = theta,
                control = list(
                    candset = "x",
                    lifetime = "t",
                    right_censoring_indicator = NULL))
        },
        hessian = TRUE,
        method = "Nelder-Mead",
        control = list(
            parscale = c(1, 1000,
                         1, 1000,
                         1, 1000,
                         1, 1000,
                         1, 1000),
            fnscale = -1,
            maxit = maxit,
            trace = 0,
            REPORT = 100,
            reltol = 1e-6,
            abstol = 1e-6))
}

ns <- c(30, 40, 50, 60, 70, 80, 90, 100, 125, 150, 175, 200)
ps <- c(0, .1, .2, .3)
qs <- c(.99, .95, .75, .5)
R <- 1000

for (n in ns) {
    for (p in ps) {
        if (n == 30 && p == 0) {
            next
        }
        if (n == 30 && p == .1) {
            next
        }
        for (q in qs) {
            mles <- list()
            problems <- list()
            tau <- qwei_series(p = q, scales = scales, shapes = shapes)
            cat("n =", n, ", p =", p, ", q = ", q, ", tau = ", tau, "\n")
            for (r in 1:R) {
                result <- tryCatch({
                    df <- generate_data(
                        theta = theta,
                        n = n,
                        p = p)

                    sol <- fit.wei.series.md.c1.c2.c2(
                        df = df,
                        theta0 = theta)
                    theta.mle <- mle_numerical(sol)

                    cat("r = ", r, ": ", params(theta.mle), "\n")
                    mles <- append(mles, list(theta.mle))
                }, error = function(e) {
                    cat("Error at iteration", r, ":", e, "\n")
                    problems <- append(problems, list(list(
                        error = e, n = n, p = p, q = q, tau = tau, df = df)))
                })
            }

            # save results to disk for each scenario
            if (length(mles) != 0) {
                saveRDS(
                    list(n = n, p = p, q = q, tau = tau, mles = mles),
                    file = paste0(
                        "./results/results_",
                        n,
                        "_",
                        p,
                        "_",
                        q,
                        ".rds"))
            }

            # save problems to disk for each scenario
            if (length(problems) != 0) {
                saveRDS(
                    problems,
                    file = paste0(
                        "./problems/problems_",
                        n,
                        "_",
                        p,
                        "_",
                        q,
                        ".rds"))
            }
        }
    }
}
