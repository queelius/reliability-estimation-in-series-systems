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
           shape4 = 1.1802, scale4 = 940.1141,
           shape5 = 1.3311, scale5 = 836.1123)

shapes <- theta[seq(1, length(theta), 2)]
scales <- theta[seq(2, length(theta), 2)]
parscale <- c(1, 1000, 1, 1000, 1, 1000, 1, 1000, 1, 1000)
stopifnot(length(parscale) == length(theta))
options(digits = 5, scipen = 999)

mle_solver <- function(df, i) {
    mle_lbfgsb_wei_series_md_c1_c2_c3(
        theta0 = theta, df = df[i, ], hessian = FALSE,
        control = list(maxit = 3L, parscale = parscale))$par
}

n_cores <- detectCores() - 1

N <- c(25, 50, 75, 100)
P <- c(0, .25, .5)
Q <- c(1, .75, .5)
R <- 10
B <- 500
total_retries <- 20L
max_iter <- 500L

cat("Simulation parameters:\n")
cat("R: ", R, "\n")
cat("B: ", B, "\n")
cat("n_cores: ", n_cores, "\n")
cat("total_retries: ", total_retries, "\n")
cat("shape: ", shapes, "\n")
cat("scale: ", scales, "\n")

mle_solver <- function(df, i) {
    mle_lbfgsb_wei_series_md_c1_c2_c3(
        theta0 = theta, df = df[i, ], hessian = FALSE,
        control = list(maxit = 3L, parscale = theta))$par
}

n_cores <- detectCores() - 1
options(digits = 3)

for (n in N) {
    for (p in P) {
        for (q in Q) {
            cat("Starting scenario: n: ", n, ", p: ", p, ", q: ", q, "\n")            
            # tau, the right-censoring time of the scenario, is the
            # q-th quantile of the weibull series ssytem distribution
            tau <- wei.series.md.c1.c2.c3::qwei_series(
                p = q, scales = scales, shapes = shapes)

            # we compute R MLEs for each scenario
            theta.hats <- matrix(NA, nrow = R, ncol = length(theta))

            # for each MLE, we bootstrap the confidence interval of the MLE
            # these are the lower ranges of the confidence intervals
            lowers.boot <- matrix(NA, nrow = R, ncol = length(theta))

            # for each MLE, we bootstrap the confidence interval of the MLE
            # these are the upper ranges of the confidence intervals
            uppers.boot <- matrix(NA, nrow = R, ncol = length(theta))

            # for each MLE, we bootstrap the bias of the MLE
            bias.boot <- matrix(NA, nrow = R, ncol = length(theta))

            # for each MLE, we bootstrap the MSE of the MLE
            mse.boot <- matrix(NA, nrow = R, ncol = length(theta))

            # capture convergence of the MLE
            convergence <- rep(NA, R)

            # for each MLE, we bootstrap the confidence interval of the MLE
            # and the coverage probability of the confidence intervals
            cov_prob <- rep(0, length(theta))

            # for each MLE, we compute the log-likelihood
            logliks <- rep(0, R)

            # for each MLE, we bootstrap the variance of the MLE
            var.boot <- matrix(NA, nrow = R, ncol = length(theta))

            # for each MLE, we compute the log-likelihood
            logliks <- rep(0, R)

            # for each MLE, compute its coverage (TRUE/FALSE)
            coverages <- matrix(NA, nrow = R, ncol = length(theta))

            iter <- 0L
            retries <- 0L
            repeat {
                retry <- FALSE
                tryCatch({
                    df <- wei.series.md.c1.c2.c3::generate_guo_weibull_table_2_data(
                        shapes = shapes, scales = scales, n = n, p = p, tau = tau)

                    sol <- mle_lbfgsb_wei_series_md_c1_c2_c3(
                        theta0 = theta, df = df, hessian = FALSE,
                        control = list(maxit = max_iter, parscale = parscale))

                    # do the non-parametric bootstrap
                    sol.boot <- mle_boot(boot::boot(df, mle_solver,
                        R = B, parallel = "multicore", ncpus = n_cores))
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
                d.boot <- empirical_dist(sol.boot$t)

                bias.hat <- expectation(d.boot, function(x) { x - params(sol.boot) })
                bias.boot[iter, ] <- bias.hat

                var.hat <- expectation(d.boot, function(x) { (x - mean(d.boot))^2 })
                var.boot[iter, ] <- var.hat

                mse.hat <- expectation(d.boot, function(x) { (x - params(sol.boot))^2 })
                mse.boot[iter, ] <- mse.hat

                ci <- confint(sol.boot)
                covers <- (ci[, 1] <= theta & theta <= ci[, 2])
                coverages[iter, ] <- covers
                # update coverage probs
                cov_prob <- cov_prob + covers
                lowers.boot[iter, ] <- ci[, 1]
                uppers.boot[iter, ] <- ci[, 2]
                theta.hats[iter, ] <- sol$par
                logliks[iter] <- sol$value
                convergence[iter] <- sol$convergence
                if (convergence[iter] == 0) {
                    cat("Iteration ", iter, ": convergence obtained!\n")
                } else {
                    cat("Iteration ", iter, ": convergence not obtained!\n")
                }

                if (iter %% 5 == 0) {
                    cat("Scenario (n = ", n, ", p = ", p, ", q = ", q, "): ", iter, "/", R, "\n")
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
                mle = theta.hats,
                coverages = coverages,
                lowers = lowers.boot,
                uppers = uppers.boot,
                convergence = convergence,
                bias = bias.boot,
                var = var.boot,
                mse = mse.boot,
                loglik = logliks)

            # let's making writing to the file an atomic operation, since other threads
            # might be writing to the same file.
            lock <- file(description = "data-boot.csv", open = "a")
            # let's append to the file if it exists, otherwise create it
            if (file.info("data-boot.csv")$size == 0) {
                write.table(df, file = lock, row.names = FALSE, sep = ",")
            } else {
                write.table(df, file = lock, row.names = FALSE, sep = ",", append = TRUE,
                            col.names = FALSE)
            }
            close(lock)

            cat("Scenario: (n = ", n, ", p = ", p, ", q = ", q, "): Finished!\n")
        }
    }
}
