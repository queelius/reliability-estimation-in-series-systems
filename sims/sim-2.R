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
ns <- c(30, 40, 50, 75, 100, 100, 200, 400, 800)
ps <- c(0.1)
qs <- c(1)
R <- 200

sim.run <- function(n, p, q) {
    mles <- list()
    problems <- list()

    tau <- wei.series.md.c1.c2.c3::qwei_series(
        p = q, scales = scales, shapes = shapes)

      cat("n =", n, ", p =", p, ", q = ", q, ", tau = ", tau, "\n")
  
    for (r in 1:R) {
        result <- tryCatch({

            df <- wei.series.md.c1.c2.c3::generate_guo_weibull_table_2_data(
                shapes = shapes,
                scales = scales,
                n = n,
                p = p,
                tau = tau)

            sol <- wei.series.md.c1.c2.c3::mle_nelder_wei_series_md_c1_c2_c3(
                df = df,
                theta0 = theta,
                reltol = 1e-7,
                parscale = parscale,
                maxit = 1000L)
            mles <- append(mles, list(sol))

            if (r %% 10 == 0) {
                cat("r = ", r, ": ", sol$par, "\n")
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
            file = paste0("./results/sim-2/results_", n, "_", p, "_", q, ".rds"))
    }

    if (length(problems) != 0) {
        saveRDS(list(n = n, p = p, q = q, tau = tau, problems = problems),
            file = paste0("./problems/sim-2/problems_", n, "_", p, "_", q, ".rds"))
    }
}

params <- expand.grid(n = ns, p = ps, q = qs)
result <- mclapply(
    1:nrow(params),
    function(i) sim.run(params$n[i], params$p[i], params$q[i]),
    mc.cores = 4)
