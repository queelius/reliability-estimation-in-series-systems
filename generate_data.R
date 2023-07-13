library(tidyverse)
library(wei.series.md.c1.c2.c3)
library(usethis)
library(readr)
library(stats)
library(algebraic.mle)
library(algebraic.dist)

options(digits = 3)
options(scipen = 999)

guo_weibull_series_md <- read_csv("./wei.series.md.c1.c2.c3/inst/guo_weibull_series_md.csv")
guo_weibull_series_md_mle <- c(1.2576, 994.3661, 1.1635, 908.9458, 1.1308, 840.1141)
guo_weibull_series_md_loglik <- -228.6851
#wei.series.md.c1.c2.c3::loglik_wei_series_md_c1_c2_c3(
#    df = guo_weibull_series_md,
#    theta = guo_weibull_series_md_mle)


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
            parscale = c(1, 900, 1, 900, 1, 900),
            fnscale = -1,
            maxit = maxit,
            trace = 0,
            REPORT = 100,
            reltol = 1e-6,
            abstol = 1e-6))
}

ns <- c(30, 40, 50, 60, 70, 80, 90, 100, 125, 150, 175, 200)
ps <- c(0, .1, .2, .3, .4, .5)
taus <- c(NULL, 1)
R <- 200
for (n in ns) {
    for (p in ps) {
        for (tau in taus) {
            for (r in 1:R) {

                df <- generate_data_3(
                    theta = theta,
                    n = n,
                    p = p,
                    tau = tau)

                theta.mle <- mle_numerical(fit.wei.series.md.c1.c2.c2(
                    df = df,
                    theta0 = theta))
            }
        }
    }
}