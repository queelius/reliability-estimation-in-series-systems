library(tidyverse)
library(parallel)
library(stats)
library(algebraic.mle)
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
n_cores <- detectCores() - 1

N <- c(30, 40, 60, 80, 100, 150, 200, 300, 400, 500, 750, 1000)
P <- c(0, .1, .2, .3, .4, .5)
Q <- c(1, .9, .8, .7, .6, .5)
R <- 1000
total_retries <- 20L
options(digits = 3)
n_cores <- detectCores() - 1
scenario_fn <- function(n, p, q) {
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

    # for each MLE, we FIM the confidence interval of the MLE
    # these are the lower ranges of the confidence intervals
    lowers.fim <- matrix(NA, nrow = R, ncol = length(theta))

    # for each MLE, we FIM confidence interval of the MLE
    # these are the upper ranges of the confidence intervals
    uppers.fim <- matrix(NA, nrow = R, ncol = length(theta))

    # for each MLE, we FIM confidence interval of the MLE
    # and the coverage probability of the confidence intervals
    cov_prob <- rep(0, length(theta))

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
                theta0 = theta, df = df, hessian = TRUE,
                control = list(maxit = 100L, parscale = parscale))
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
        var.fim[iter, ] <- diag(vcov(mle_numerical(sol)))
        ci <- confint(mle_numerical(sol))
        covers <- (ci[, 1] <= theta & theta <= ci[, 2])
        coverages[iter, ] <- covers
        # update coverage probs
        cov_prob <- cov_prob + covers
        lowers.fim[iter, ] <- ci[, 1]
        uppers.fim[iter, ] <- ci[, 2]
        theta.hats[iter, ] <- sol$par

        if (iter %% 50 == 0) {
            cat("[", iter , "] ", theta.hats[iter,], "\n")
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
        coverages = coverages,
        var.fim = var.fim,
        lowers = lowers.fim,
        uppers = uppers.fim)

    write.table(df, file = "data-fim.csv", sep = ",", row.names = FALSE,
        col.names = !file.exists("data-fim.csv"), append = TRUE)
}


scenario_fn(30, 0, 1)