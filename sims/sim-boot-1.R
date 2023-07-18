# in this simulation, we are going to use the bootstrap method. we'll have a right
# censoring at 75% quantile of weibull series system and a component cause of failure
# p = .215 with a sample size n = 100. we want to see how we can use the bootstrap
# method to estimate the bias, variance, and MSE of the estimator. we'll have
# R = 1000 replicates.
# we'll also use it to construct a 95% confidence interval for the estimator. we'll
# compare this result to the asymptotic theory confidence interval.
# finally, we'll generate CIs by each method, asymptotic (inverse FIM) and 
# bootstrap (cov), and compare the coverage probabilities.

library(boot)
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

ns <- c(30, 40, 50, 75)
ps <- c(0.215)
qs <- c(.7)
R <- 2
B <- 2
mc.cores <- 4   # number of cores to use for simulations
sim.name <- "sim-boot-2"
sim.seed <- c(10407, -1723461988, 1517526765, -325759798,
    1430175683, 851408424, -763779575)

sim.boot.run <- function(sim.name, n, p, q, R = 1000,
    bootstrap = FALSE, B = 1000, save.df = FALSE) {

    problems <- list()
    results <- list()

    tau <- wei.series.md.c1.c2.c3::qwei_series(
        p = q, scales = scales, shapes = shapes)

    cat("n =", n, ", p =", p, ", q = ", q, ", tau = ", tau, "\n")
  
    for (r in 1:R) {
        tryCatch({
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
                maxit = 2000L)

            cat("mle: ", sol$par, "\n")

            res <- list()
            res$mle <- sol
            if (save.df) {
                res$df <- df
            }
            if (bootstrap) {
                sol.boot <- boot(df, function(df, i) {
                    sol <- wei.series.md.c1.c2.c3::mle_nelder_wei_series_md_c1_c2_c3(
                        df = df[i, ],
                        theta0 = sol$par,
                        reltol = 1e-7,
                        parscale = parscale,
                        maxit = 1000L)
                    sol$par
                }, R = B)
                res$boot <- sol.boot
            }
            results <- c(results, list(res))

            }, error = function(e) {
                print(e)
                problems <- c(problems, list(list(
                    error = e, n = n, p = p, q = q, tau = tau, df = df)))
            }
        )

        if (length(results) != 0) {
            filename <- paste0("./results/", sim.name, "/", n, "_", p, "_", q, ".rds")
            if (file.exists(filename)) {
                warning(paste0("file `", filename, "` already exists. overwriting."))
            }
            saveRDS(list(n = n, p = p, q = q, tau = tau, mles = results),
                file = filename)
        }


        if (length(problems) != 0) {
            filename <- paste0("./problems/", sim.name, "/", n, "_", p, "_", q, ".rds")
            # check to see if the file named `filename` exists

            if (file.exists(filename)) {
                warning(paste0("file ", filename, " already exists. overwriting."))
            }

            saveRDS(list(n = n, p = p, q = q, tau = tau, problems = problems),
                    file = filename)
        }
    }
}

dir.create(paste0("./results/", sim.name))
dir.create(paste0("./problems/", sim.name))

RNGkind("L'Ecuyer-CMRG") 
set.seed(sim.seed)

params <- expand.grid(n = ns, p = ps, q = qs)
result <- mclapply(
    1:nrow(params),
    function(i) sim.boot.run(
        n = params$n[i],
        p = params$p[i],
        q = params$q[i],
        R = R,
        B = B,
        sim.name = sim.name,
        bootstrap = TRUE, 
        save.df = TRUE),
    mc.cores = mc.cores)
