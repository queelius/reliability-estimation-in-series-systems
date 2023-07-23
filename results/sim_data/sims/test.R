library(tidyverse)
library(wei.series.md.c1.c2.c3)
library(stats)
library(md.tools)

theta <- c(shape1 = 1.2576, scale1 = 994.3661,
           shape2 = 1.1635, scale2 = 908.9458,
           shape3 = 1.1308, scale3 = 840.1141,
           shape4 = 1.1802, scale4 = 940.1141,
           shape5 = 1.3311, scale5 = 836.1123)

shapes <- theta[seq(1, length(theta), 2)]
scales <- theta[seq(2, length(theta), 2)]

parscale <- c(1, 1000, 1, 1000, 1, 1000, 1, 1000, 1, 1000)
n <- 30
p <- 0.215
q <- .7
tau <- wei.series.md.c1.c2.c3::qwei_series(
    p = q, scales = scales, shapes = shapes)

set.seed(1003)
df <- wei.series.md.c1.c2.c3::generate_guo_weibull_table_2_data(
    shapes = shapes,
    scales = scales,
    n = n,
    p = p,
    tau = tau)

options(digits = 16)
test <- function(df, theta0) {

    res.nelder <- wei.series.md.c1.c2.c3::mle_nelder_wei_series_md_c1_c2_c3(
            df = df,
            theta0 = theta0,
            reltol = 1e-10,
            parscale = parscale,
            maxit = 1000L)

    res.bfgs <- wei.series.md.c1.c2.c3::mle_bfgs_wei_series_md_c1_c2_c3(
            df = df,
            theta0 = theta0,
            reltol = 1e-10,
            parscale = parscale,
            maxit = 1000L)

    res.lbfgsb <- wei.series.md.c1.c2.c3::mle_lbfgsb_wei_series_md_c1_c2_c3(
            df = df,
            theta0 = theta0,
            pgtol = 1e-10,
            factr = 1e-10,
            parscale = parscale,
            maxit = 1000L)

    res.lbfgsb5 <- wei.series.md.c1.c2.c3::mle_lbfgsb_wei_series_md_c1_c2_c3(
            df = df,
            theta0 = theta,
            pgtol = 1e-30,
            factr = 1e-30,
            lmm = 200,
            parscale = parscale,
            maxit = 10000L)

    res.newt <- wei.series.md.c1.c2.c3::mle_newton_wei_series_md_c1_c2_c3(
            df = df,
            theta0 = theta0,
            lr = 10,
            tol = 1e-70,
            maxit = 10000L)

    res.sann <- wei.series.md.c1.c2.c3::mle_sann_wei_series_md_c1_c2_c3(
            df = df,
            theta0 = theta0,
            reltol = 1e-7,
            parscale = parscale,
            maxit = 10000L)

    res.newt.lbfgsb <- wei.series.md.c1.c2.c3::mle_newton_wei_series_md_c1_c2_c3(
        df = df,
        theta = res.lbfgsb$par,
        lr = 1,
        tol = 1e-70,
        maxit = 10000L)

    res.cg.lbfgs <- wei.series.md.c1.c2.c3::mle_cg_wei_series_md_c1_c2_c3(
        df = df,
        theta0 = theta,
        reltol = 1e-7,
        parscale = parscale,
        maxit = 10000L)

    ll.sann <- wei.series.md.c1.c2.c3::loglik_wei_series_md_c1_c2_c3(
        theta = res.sann$par,
        df = df)

    ll.nelder <- wei.series.md.c1.c2.c3::loglik_wei_series_md_c1_c2_c3(
        theta = res.nelder$par,
        df = df)
    ll.bfgs <- wei.series.md.c1.c2.c3::loglik_wei_series_md_c1_c2_c3(
        theta = res.bfgs$par,
        df = df)
    ll.lbfgsb <- wei.series.md.c1.c2.c3::loglik_wei_series_md_c1_c2_c3(
        theta = res.lbfgsb$par,
        df = df)
    ll.newt <- wei.series.md.c1.c2.c3::loglik_wei_series_md_c1_c2_c3(
        theta = res.newt$par,
        df = df)

    ll.lbfgsb5 <- wei.series.md.c1.c2.c3::loglik_wei_series_md_c1_c2_c3(
        theta = res.lbfgsb5$par,
        df = df)

    ll.newt.lbfgsb <- wei.series.md.c1.c2.c3::loglik_wei_series_md_c1_c2_c3(
        theta = res.newt.lbfgsb$par,
        df = df)

    ll.theta <- wei.series.md.c1.c2.c3::loglik_wei_series_md_c1_c2_c3(
        theta = theta,
        df = df)
    ll.theta0 <- wei.series.md.c1.c2.c3::loglik_wei_series_md_c1_c2_c3(
        theta = theta0,
        df = df)

    ll.cg.lbfgs <- wei.series.md.c1.c2.c3::loglik_wei_series_md_c1_c2_c3(
        theta = res.cg.lbfgs$par,
        df = df)

    t(t(c(
        loglik.theta = ll.theta,
        loglik.newt.lbfgsb = ll.newt.lbfgsb,
        loglik.nelder = ll.nelder,
        loglik.bfgs = ll.bfgs,
        loglik.lbfgsb = ll.lbfgsb,
        loglik.lbfgsb5 = ll.lbfgsb5,
        loglik.newt = ll.newt,
        loglik.sann = ll.sann,
        loglik.theta0 = ll.theta0,
        loglik.cg.lbfgs = ll.cg.lbfgs
    )))
}

test(df, theta)




res.newt <- wei.series.md.c1.c2.c3::mle_newton_wei_series_md_c1_c2_c3(
        df = df,
        theta0 = theta,
        lr = .01,
        maxit = 1000L)


res.lbfgsb <- wei.series.md.c1.c2.c3::mle_lbfgsb_wei_series_md_c1_c2_c3(
            df = df,
            theta0 = theta,
            pgtol = 1e-10,
            factr = 1e-10,
            parscale = parscale,
            maxit = 1000L)







    # let's test score_wei_series_md_c1_c2_c3_2



# other_tests <- function() {
#     sol.sann <- wei.series.md.c1.c2.c3::mle_sann_wei_series_md_c1_c2_c3(
#         df = df,
#         theta0 = theta,
#         control = list(maxit = 10000L))

#     sol.sann2 <- algebraic.mle::sim_anneal(
#         par = theta,
#         fn = function(theta) {
#             wei.series.md.c1.c2.c3::loglik_wei_series_md_c1_c2_c3(
#                 df = df, theta = theta)
#         },
#         control = list(
#             t_init = 20,
#             t_end = .0001,
#             fnscale = -1,
#             alpha = .95,
#             neigh = function(par, temp, ...) {
#                 a <- min(temp, 1) * parscale / 100
#                 par + runif(length(par), -a, a)
#             },
#             proj = function(par) {
#                 # project any non-positive components onto the nearest
#                 # point in the parameter space, but slightly perturbed
#                 # using `runif` to avoid numerical issues
#                 for (i in 1:length(par)) {
#                     if (par[i] <= 0) {
#                         par[i] <- runif(1, .001, .2) * parscale[i] / 100
#                     }
#                 }
#                 par
#             }))

#     sol.newt <- wei.series.md.c1.c2.c3::mle_newton_wei_series_md_c1_c2_c3(
#         df = df,
#         theta0 = theta,
#         control = list(
#             lr = .1,
#             maxit = 10L,
#             zero_tol = 1e-2))
# }
