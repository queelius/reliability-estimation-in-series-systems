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
options(digits = 3)
n <- 60 # n is the sample size of the scenario            
p <- 0 # p is the masking probability of the scenario
q <- 1 # q is the right-censoring probability of the scenario
R <- 10
B <- 10
total_retries <- 20L

# tau, the right-censoring time of the scenario, is the
# q-th quantile of the weibull series ssytem distribution
tau <- wei.series.md.c1.c2.c3::qwei_series(
    p = q, scales = scales, shapes = shapes)

cat("Simulation parameters:\n")
cat("R: ", R, "\n")
cat("B: ", B, "\n")
cat("n_cores: ", n_cores, "\n")
cat("retry_abort: ", retry_abort, "\n")
cat("\n")
cat("Scenario:\n")
cat("shape: ", shapes, "\n")
cat("scale: ", scales, "\n")
cat("n: ", n, "\n")
cat("p: ", p, "\n")
cat("q: ", q, "\n")
cat("tau: ", tau, "\n")

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

# for each MLE, we bootstrap the variance of the MLE
var.boot <- matrix(NA, nrow = R, ncol = length(theta))

# for each MLE, we bootstrap the confidence interval of the MLE
# and the coverage probability of the confidence intervals
cov_prob <- rep(0, length(theta))

# for each MLE, we compute the log-likelihood
logliks <- rep(0, R)

# for each MLE, compute its coverage (TRUE/FALSE)
coverages <- matrix(NA, nrow = R, ncol = length(theta))

iter <- 0L
retries <- 0L

cat("Starting...\n")
repeat {
    retry <- FALSE
    t0 <- Sys.time()
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
    t1 <- Sys.time()
    cat("Time: ", t1 - t0, "\n")

    if (retries > retry_abort) {
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

    if (iter %% 30 == 0) {
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
    n = rep(n, iter),
    p = rep(p, iter),
    q = rep(q, iter),
    tau = rep(tau, iter),
    mle = theta.hats[1:iter, ],
    coverages = coverages[1:iter, ],
    lowers = lowers.boot[1:iter, ],
    uppers = uppers.boot[1:iter, ],
    bias = bias.boot[1:iter, ],
    var = var.boot[1:iter, ],
    mse = mse.boot[1:iter, ],
    loglik = logliks[1:iter])

# write this scenario to a file
# append it to the file if it already exists
# otherwise create a new file
# i want the first row to be the column names, after that no more column names
# i want to be able to read this CSV file in R with read.csv or read.table

write.table(df, file = "data.csv", sep = ",", row.names = FALSE,
    col.names = !file.exists("data.csv"), append = TRUE)

