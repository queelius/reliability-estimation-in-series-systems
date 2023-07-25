library(tidyverse)
library(parallel)
library(stats)
library(algebraic.mle)
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

n_cores <- 3
N <- c(25, 50, 75, 100, 200, 400, 800)
P <- c(0, .125, .25, .375, .5)
Q <- c(1, .875, .75, .625, .5)
R <- 100
total_retries <- 10L
max_iter <- 25L

cat("Simulation parameters:\n")
cat("R: ", R, "\n")
cat("n_cores: ", n_cores, "\n")
cat("total_retries: ", total_retries, "\n")
cat("shape: ", shapes, "\n")
cat("scale: ", scales, "\n")

scenario_fn <- function(params) {
    n <- params$N
    p <- params$P
    q <- params$Q
    cat("Starting scenario: n: ", n, ", p: ", p, ", q: ", q, "\n")

    # tau, the right-censoring time of the scenario, is the
    # q-th quantile of the weibull series ssytem distribution
    tau <- wei.series.md.c1.c2.c3::qwei_series(
        p = q, scales = scales, shapes = shapes)

    # we compute R MLEs for each scenario
    theta.hats <- matrix(NA, nrow = R, ncol = length(theta))

    # for each MLE, we FIM the confidence interval of the MLE
    # these are the lower ranges of the confidence intervals
    lowers.fim <- matrix(NA, nrow = R, ncol = length(theta))

    # for each MLE, we FIM confidence interval of the MLE
    # these are the upper ranges of the confidence intervals
    uppers.fim <- matrix(NA, nrow = R, ncol = length(theta))

    # for each MLE, we FIM confidence interval of the MLE
    # and the coverage probability of the confidence intervals
    cov_prob <- rep(0, length(theta))

    convergences <- rep(NA, R)

    var.fim <- matrix(NA, nrow = R, ncol = length(theta))

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
        theta.hats[iter, ] <- sol$par
        convergences[iter] <- sol$convergence

        if (iter %% 50 == 0) {
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
        mle = theta.hats,
        convergences = convergences)

    # let's making writing to the file an atomic operation, since other threads
    # might be writing to the same file.
    lock <- file(description = "data-no-hess.csv", open = "a")
    # let's append to the file if it exists, otherwise create it
    if (file.info("data-no-hess.csv")$size == 0) {
        write.table(df, file = lock, row.names = FALSE, sep = ",")
    } else {
        write.table(df, file = lock, row.names = FALSE, sep = ",", append = TRUE,
                    col.names = FALSE)
    }
    close(lock)

    cat("Scenario: (n = ", n, ", p = ", p, ", q = ", q, "): Finished!\n")
}

param_list <- expand.grid(N = N, P = P, Q = Q)
param_list <- split(param_list, seq(nrow(param_list)))
results <- mclapply(param_list, scenario_fn, mc.cores = n_cores)
