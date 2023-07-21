# in this simulation, we have no right censoring and slight masking of component cause
# of failure, p = .1. we want to see how well the estimator performs in this case as
# a function of sample size, from n = 20 to n = 800.
# we have R = 100 replicates for each sample size.

library(tidyverse)
library(parallel)
library(wei.series.md.c1.c2.c3)
library(stats)
library(algebraic.mle)
library(algebraic.dist)
library(md.tools)

theta <- c(shape1 = 1.2576, scale1 = 994.3661,
           shape2 = 1.1635, scale2 = 908.9458,
           shape3 = 1.1308, scale3 = 840.1141,
           shape4 = 1.1802, scale4 = 940.1141,
           shape5 = 1.3311, scale5 = 836.1123)

shapes <- theta[seq(1, length(theta), 2)]
scales <- theta[seq(2, length(theta), 2)]

parscale <- c(1, 1000, 1, 1000, 1, 1000, 1, 1000, 1, 1000)

#set.seed(134849131)
ns <- c(75)
n = 75
#ns <- c(30, 40, 50, 75, 100, 100, 200, 400, 800)
ps <- c(0.1)
qs <- c(1)
R <- 100


n=75
p=.1
q=.95
sim.run <- function(n, p, q) {
    mles <- list()
    problems <- list()

    tau <- wei.series.md.c1.c2.c3::qwei_series(
        p = q, scales = scales, shapes = shapes)

    microbenchmark(
        sol.neld = wei.series.md.c1.c2.c3::mle_nelder_wei_series_md_c1_c2_c3(
                df = df,
                theta0 = theta,
                control = list(
                    reltol = 1e-3,
                    parscale = parscale,
                    maxit = 100L)))
    microbenchmark(
        sol.lbfgsb = wei.series.md.c1.c2.c3::mle_lbfgsb_wei_series_md_c1_c2_c3(
                df = df,
                theta0 = theta,
                control = list(
                    pgtol = 1e-1,
                    factr = 1e-1,
                    parscale = parscale,
                    maxit = 100L)))


    for (r in 1:R) {
        tryCatch({
            df <- wei.series.md.c1.c2.c3::generate_guo_weibull_table_2_data(
                shapes = shapes,
                scales = scales,
                n = n,
                p = p,
                tau = tau)

            sol.neld <- wei.series.md.c1.c2.c3::mle_nelder_wei_series_md_c1_c2_c3(
                df = df,
                theta0 = theta,
                control = list(
                    reltol = 1e-3,
                    parscale = parscale,
                    maxit = 200L))

            sol.lbfgsb <- wei.series.md.c1.c2.c3::mle_lbfgsb_wei_series_md_c1_c2_c3(
                df = df,
                theta0 = theta,
                control = list(
                    pgtol = 1e-2,
                    factr = 1e-2,
                    parscale = parscale,
                    maxit = 200L))

            sol.neld$hessian <- wei.series.md.c1.c2.c3::hessian_wei_series_md_c1_c2_c3(
                df = df, theta = sol.neld$par)

            #sol.lbfgsb <- wei.series.md.c1.c2.c3::mle_lbfgsb_wei_series_md_c1_c2_c3(
            #    df = df,
            #    theta0 = sol.neld$par,
            #    control = list(
            #        pgtol = 1e-7,
            #        factr = 1e-7,
            #        parscale = parscale,
            #        fnscale = -1,
            #        maxit = 50L))

            sol.sann <- wei.series.md.c1.c2.c3::mle_sann_wei_series_md_c1_c2_c3(
                df = df,
                theta0 = theta,
                control = list(
                    maxit = 10000L))

            sol.sann2 <- algebraic.mle::sim_anneal(
                par = theta,
                fn = function(theta) {
                    wei.series.md.c1.c2.c3::loglik_wei_series_md_c1_c2_c3(
                        df = df, theta = theta)
                },
                control = list(
                    t_init = 20,
                    t_end = .0001,
                    fnscale = -1,
                    alpha = .95,
                    neigh = function(par, temp, ...) {
                        a <- min(temp, 1) * parscale / 100
                        par + runif(length(par), -a, a)
                    },
                    proj = function(par) {
                        # project any non-positive components onto the nearest
                        # point in the parameter space, but slightly perturbed
                        # using `runif` to avoid numerical issues
                        for (i in 1:length(par)) {
                            if (par[i] <= 0) {
                                par[i] <- runif(1, .001, .2) * parscale[i] / 100
                            }
                        }
                        par
                    }))


            sol.newt <- wei.series.md.c1.c2.c3::mle_newton_wei_series_md_c1_c2_c3(
                df = df,
                theta0 = theta,
                control = list(
                    lr = .1,
                    maxit = 10L,
                    zero_tol = 1e-2))

            mles <- append(mles, list(sol.newt))

            if (r %% 1 == 0) {
                cat("R = ", r, ": n =", n, ", p =", p, ", q = ", q, ", tau = ", tau, "\n")
                cat("neld convergence = ", sol.neld$convergence, "\n")
                if (!is.null(sol.neld$message)) {
                    cat("neld message = ", sol.neld$message, "\n")
                }
                cat("neld value = ", sol.neld$value, "\n")
                cat("newton convergence = ", sol.newt$convergence, "\n")
                cat("newton value = ", sol.newt$value, "\n")
                cat("newton iterations = ", sol.newt$counts, "\n")

                cat("neld pars = ", sol.neld$par, "\n")
                cat("newton pars = ", sol.newt$par, "\n")
                ci.neld <- confint(mle_numerical(sol.neld, df))
                ci.newt <- confint(mle_numerical(sol.newt, df))
                print(cbind(ci.neld, ci.newt, theta))
            }

        }, error = function(e) {
            cat("Error at iteration", r, ":")
            print(e)
            problems <- append(problems, list(list(
                error = e, n = n, p = p, q = q, tau = tau, df = df)))
        })
    }
  
    if (length(mles) != 0) {
        saveRDS(list(n = n, p = p, q = q, tau = tau, mles = mles),
            file = paste0("./results/sim-20/results_", n, "_", p, "_", q, ".rds"))
    }

    if (length(problems) != 0) {
        saveRDS(list(n = n, p = p, q = q, tau = tau, problems = problems),
            file = paste0("./problems/sim-20/problems_", n, "_", p, "_", q, ".rds"))
    }
}

params <- expand.grid(n = ns, p = ps, q = qs)
result <- mclapply(
    1:nrow(params),
    function(i) sim.run(params$n[i], params$p[i], params$q[i]),
    mc.cores = 4)
