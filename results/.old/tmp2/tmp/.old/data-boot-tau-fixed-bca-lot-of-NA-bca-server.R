

#' we do the semi-parametric bootstrap in two steps:
#' 1. generate component lifetimes from the fitted MLE weibull distributions
#' 2. populate the df with the component lifetimes, censored system failure times,
#'    and the censoring indicator.
#' 3. populate the df with the component cause of failure
#' 4. sample a C[i] from the df with replacement using the
#'    empirical distribution of C[i] | K[i] = k.

library(tidyverse)
library(parallel)
library(boot)
library(stats)
library(algebraic.mle)
library(algebraic.dist)
library(md.tools)
library(wei.series.md.c1.c2.c3)

theta <- c(shape1 = 1.2576, scale1 = 994.3661,
           shape2 = 1.1635, scale2 = 908.9458,
           shape3 = 1.1308, scale3 = 840.1141,
           shape4 = 1.1802, scale4 = 940.1342,
           shape5 = 1.2034, scale5 = 923.1631)

shapes <- theta[seq(1, length(theta), 2)]
scales <- theta[seq(2, length(theta), 2)]
parscale <- c(1, 1000, 1, 1000, 1, 1000, 1, 1000, 1, 1000)
stopifnot(length(parscale) == length(theta))
options(digits = 5, scipen = 999)

n = 100, 200, 500
B = 500
p = .333

N <- c(100, 200, 500)
P <- c(.333)
Q <- c(.825)
R <- 10
B <- 500
max_iter <- 50L
max_boot_iter <- 50L
total_retries <- 10000L
n_cores <- detectCores() - 1

cat("Simulation parameters:\n")
cat("R: ", R, "\n")
cat("B: ", B, "\n")
cat("n_cores: ", n_cores, "\n")
cat("total_retries: ", total_retries, "\n")
cat("shape: ", shapes, "\n")
cat("scale: ", scales, "\n")

for (n in N) {
    for (p in P) {
        for (q in Q) {
            cat("Starting scenario:\n")
            cat("n: ", n, "\n")
            cat("p: ", p, "\n")
            cat("q: ", q, "\n")

            # tau, the right-censoring time of the scenario, is the
            # q-th quantile of the weibull series ssytem distribution
            tau <- wei.series.md.c1.c2.c3::qwei_series(
                p = q, scales = scales, shapes = shapes)

            # we compute R MLEs for each scenario
            shapes.mle <- matrix(NA, nrow = R, ncol = length(theta) / 2)
            scales.mle <- matrix(NA, nrow = R, ncol = length(theta) / 2)

            shapes.lower <- matrix(NA, nrow = R, ncol = length(theta) / 2)
            shapes.upper <- matrix(NA, nrow = R, ncol = length(theta) / 2)
            scales.lower <- matrix(NA, nrow = R, ncol = length(theta) / 2)
            scales.upper <- matrix(NA, nrow = R, ncol = length(theta) / 2)

            # for each MLE, we compute the log-likelihood
            logliks <- rep(0, R)

            iter <- 0L
            retries <- 0L
            repeat {
                retry <- FALSE
                tryCatch({
                    repeat {
                        df <- wei.series.md.c1.c2.c3::generate_guo_weibull_table_2_data(
                            shapes = shapes, scales = scales, n = n, p = p, tau = tau)

                        sol <- mle_lbfgsb_wei_series_md_c1_c2_c3(
                            theta0 = theta, df = df, hessian = FALSE,
                            control = list(maxit = max_iter, parscale = theta))
                        if (sol$convergence == 0) {
                            cat("Found MLE: ", sol$par, "\n")
                            break
                        }
                        cat("[", iter, "] MLE did not converge, retrying...\n")
                    }

                    mle_solver <- function(df, i) {
                        solb <- mle_lbfgsb_wei_series_md_c1_c2_c3(
                            theta0 = sol$par, df = df[i, ], hessian = FALSE,
                            control = list(maxit = max_boot_iter, parscale = sol$par))
                        solb$par
                    }

                    # do the non-parametric bootstrap
                    sol.boot <- boot::boot(df, mle_solver,
                        R = B, parallel = "multicore", ncpus = n_cores)
                },
                error = function(e) {
                    cat("Error: ", conditionMessage(e), "\n")
                    retries <<- retries + 1L
                    if (retries < total_retries) {
                        cat("Scenario (n = ", n, ", p = ", p, ", q = ", q, "): ",
                            retries, "/", total_retries, " retries\n")
                        retry <<- TRUE
                    }
                })
                if (retries > total_retries) {
                    break
                }

                if (retry) {
                    next
                }
                iter <- iter + 1L
                shapes.mle[iter,] <- sol$par[seq(1, length(theta), 2)]
                scales.mle[iter,] <- sol$par[seq(2, length(theta), 2)]
                logliks[iter] <- sol$value

                tryCatch({
                    sb <- mle_boot(sol.boot)
                    ci <- confint(sb, type = "bca", level = 0.95)
                    #ci <- confint(sb, type = "perc", level = 0.95)
                    shapes.ci <- ci[seq(1, length(theta), 2), ]
                    scales.ci <- ci[seq(2, length(theta), 2), ]
                    shapes.lower[iter, ] <- shapes.ci[, 1]
                    shapes.upper[iter, ] <- shapes.ci[, 2]
                    scales.lower[iter, ] <- scales.ci[, 1]
                    scales.upper[iter, ] <- scales.ci[, 2]
                }, error = function(e) {
                    cat("Error: ", conditionMessage(e), "\n")
                })
                if (iter %% 1 == 0) {
                    cat("Iter = ", iter, ", Shapes = ", shapes.mle[iter,], "Scales = ", scales.mle[iter, ], "\n")
                    print(shapes.lower[iter,])
                }

                if (iter == R) {
                    break
                }
            }

            df <- data.frame(
                n = rep(n, R),
                p = rep(p, R),
                q = rep(q, R),
                tau = rep(tau, R),
                B = rep(B, R),
                shapes = shapes.mle,
                scales = scales.mle,
                shapes.lower = shapes.lower,
                shapes.upper = shapes.upper,
                scales.lower = scales.lower,
                scales.upper = scales.upper,
                logliks = logliks)

            write.table(df, file = "data-boot-tau-fixed-bca-lot-of-NA-server.csv", sep = ",", row.names = FALSE,
                col.names = !file.exists("data-boot-tau-fixed-bca-lot-of-NA-server.csv"), append = TRUE)
        }
    }
}
