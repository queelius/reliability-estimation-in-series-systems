library(tidyverse)
library(wei.series.md.c1.c2.c3)
library(usethis)
library(readr)
library(stats)
library(algebraic.mle)
library(algebraic.dist)

options(digits = 3)
options(scipen = 999)

theta <- c(shape1 = 0.25, scale1 = 50,
           shape2 = 1, scale2 = 50,
           shape3 = 2.5, scale3 = 15,
           shape4 = 3, scale4 = 30,
           shape5 = 5, scale5 = 20)

theta <- c(shape1 = 0.25, scale1 = 5,
           shape2 = 1, scale2 = 5,
           shape3 = 2.5, scale3 = 1,
           shape4 = 3, scale4 = 3,
           shape5 = 5, scale5 = 2)


generate_data_2 <- function(theta, n, p, tau = NULL) {
    shape <- theta[seq(1, length(theta), 2)]
    scale <- theta[seq(2, length(theta), 2)]
    m <- length(shape)
    comp_times <- matrix(nrow = n, ncol = m)

    for (j in 1:m)
        comp_times[, j] <- rweibull(
            n = n,
            shape = shape[j],
            scale = scale[j])
    comp_times <- md_encode_matrix(comp_times, "t")

    comp_times %>% md_series_lifetime_right_censoring(tau) %>%
        md_bernoulli_cand_c1_c2_c3(p) %>% md_cand_sampler()
}


fit.wei.series.md.c1.c2.c2.sann <- function(df, theta0, maxit = 10000) {

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
        method = "SANN",
        control = list(
            parscale = c(1, 1000, 1, 1000, 1, 1000),
            fnscale = -1,
            maxit = maxit,
            trace = 0,
            REPORT = 100,
            reltol = 1e-8,
            abstol = 1e-8))
}

fit.wei.series.md.c1.c2.c2 <- function(df, theta0, maxit = 1000) {

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
            parscale = c(1, 1,
                         1, 1,
                         1, 1,
                         1, 1,
                         1, 1),
            fnscale = -1,
            maxit = maxit,
            trace = 0,
            REPORT = 100,
            reltol = 1e-6,
            abstol = 1e-6))
}


p <- .15
ns <- c(30, 40, 50, 60, 70, 80, 90, 100, 200, 300, 400, 500, 1000, 2000, 5000)
for (n in ns) {
    df <- generate_data_2(theta = theta, n = n, p = p, tau = NULL)
    theta.mle <- mle_numerical(fit.wei.series.md.c1.c2.c2(
        df = df,
        theta0 = theta))

    print(params(theta.mle))
}


