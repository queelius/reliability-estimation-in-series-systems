library(tidyverse)
library(stats)
library(algebraic.mle)
library(algebraic.dist)
library(md.tools)
library(wei.series.md.c1.c2.c3)
library(microbenchmark)

theta <- c(shape1 = 1.2576, scale1 = 994.3661,
           shape2 = 1.1635, scale2 = 908.9458,
           shape3 = 1.1308, scale3 = 840.1141,
           shape4 = 1.1802, scale4 = 940.1141,
           shape5 = 1.3311, scale5 = 836.1123)

shapes <- theta[seq(1, length(theta), 2)]
scales <- theta[seq(2, length(theta), 2)]
parscale <- c(1, 1000, 1, 1000, 1, 1000, 1, 1000, 1, 1000)

n <- 75
p <- .1
q <- .95
R <- 10

tau <- wei.series.md.c1.c2.c3::qwei_series(
    p = q, scales = scales, shapes = shapes)

microbenchmark(
bench = optim(
    par = theta,
    fn = loglik_wei_series_md_c1_c2_c3,
    gr = score_wei_series_md_c1_c2_c3,
    df = wei.series.md.c1.c2.c3::generate_guo_weibull_table_2_data(
        shapes = shapes, scales = scales, n = n, p = p, tau = tau),
    method = "L-BFGS-B",
    lower = rep(0, length(theta)),
    control = list(
        maxit = 1000L,
        lmm = 100,
        fnscale = -1,
        parscale = parscale),
    hessian = TRUE))


