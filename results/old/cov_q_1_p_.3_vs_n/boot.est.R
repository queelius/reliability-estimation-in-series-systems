library(tidyverse)
library(parallel)
library(boot)
library(stats)
library(algebraic.mle)
library(algebraic.dist)
library(md.tools)
library(wei.series.md.c1.c2.c3)


cat("Seting up...\n")
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

N <- c(30, 40, 60, 80, 100, 120, 140, 160, 180, 200, 250, 300, 400)
P <- c(0, .1, .2, .3)
Q <- c(1, .9, .8)
R <- 100
B <- 300
total_retries <- 20L

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
            cat("Starting scenario:\n")
            cat("n: ", n, "\n")
            cat("p: ", p, "\n")
            cat("q: ", q, "\n")

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
            t0 <- Sys.time()
            retries <- 0L
            repeat {
                retry <- FALSE
                tryCatch({
                    df <- wei.series.md.c1.c2.c3::generate_guo_weibull_table_2_data(
                        shapes = shapes, scales = scales, n = n, p = p, tau = tau)

                    sol <- mle_lbfgsb_wei_series_md_c1_c2_c3(
                        theta0 = theta, df = df, hessian = FALSE,
                        control = list(maxit = 5L, parscale = parscale))

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

                if (iter %% 25 == 0) {
                    shape.cov <- cov_prob[seq(1, length(theta), 2)] / iter
                    shape.ci <- cbind(ci[seq(1, length(theta), 2), ], shape.cov)
                    scale.cov <- cov_prob[seq(2, length(theta), 2)] / iter
                    scale.ci <- cbind(ci[seq(2, length(theta), 2), ], scale.cov)

                    cat("--------------[", iter, "]--------------\n")

                    cat("MLE: ", theta.hats[iter,], "\n")
                    cat("Loglik: ", logliks[iter], "\n")

                    cat("Var (boot): ", var.hat, "\n")
                    cat("Bias (boot): ", bias.hat, "\n")
                    cat("MSE (boot): ", mse.hat, "\n")

                    cat("Shape CI:\n")
                    print(shape.ci)

                    cat("Scale CI:\n")
                    print(scale.ci)
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
                bias = bias.boot,
                var = var.boot,
                mse = mse.boot,
                loglik = logliks)

            write.table(df, file = "data.csv", sep = ",", row.names = FALSE,
                col.names = !file.exists("data.csv"), append = TRUE)

            t1 <- Sys.time()
            cat("Scenario time: ", t1 - t0, "\n")
        }
    }
}
