library(tidyverse)
library(parallel)
library(wei.series.md.c1.c2.c3)
library(usethis)
library(readr)
library(stats)
library(algebraic.mle)
library(algebraic.dist)
library(md.tools)

options(digits = 10)

theta <- c(shape1 = 1.2576, scale1 = 994.3661,
           shape2 = 1.1635, scale2 = 908.9458,
           shape3 = 1.1308, scale3 = 840.1141,
           shape4 = 1.1802, scale4 = 940.1141,
           shape5 = 1.3311, scale5 = 836.1123)

shapes <- theta[seq(1, length(theta), 2)]
scales <- theta[seq(2, length(theta), 2)]

q.95 <- qwei_series(p = .9, scales = scales, shapes = shapes)
df <- generate_guo_weibull_table_2_data(
    n = 100,
    scales = scales,
    shapes = shapes,
    p = 0,
    tau = q.95)

parscale <- c(1, 1000, 1, 1000, 1, 1000, 1, 1000, 1, 1000)

res.optim <- optim(par = theta,
             fn = loglik_wei_series_md_c1_c2_c3,
             df = df,
             hessian = TRUE,
             control = list(
                REPORT = 100L,
                trace = 1L,
                fnscale = -1,
                reltol = 1e-40,
                maxit = 10000L,
                parscale = parscale))


res.newt <- wei.series.md.c1.c2.c3::mle_newton_wei_series_md_c1_c2_c3(
    df = df,
    theta0 = res.optim$par,
    lr = 10,
    tol = 1e-20,
    debug = TRUE,
    REPORT = 1L,
    maxit = 1000)


res.cg <- wei.series.md.c1.c2.c3::mle_cg_wei_series_md_c1_c2_c3(
    df = df,
    theta0 = res.optim$par,
    reltol = 1e-20,
    parscale = parscale,
    trace = 1L,
    REPORT = 1L,
    maxit = 1000)








