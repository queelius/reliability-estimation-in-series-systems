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
n_cores <- detectCores() - 1

n <- 1000
p <- .215
q <- .825
B <- 100
max_iter <- 1000L
max_boot_iter <- 250L

# tau, the right-censoring time of the scenario, is the
# q-th quantile of the weibull series ssytem distribution
tau <- wei.series.md.c1.c2.c3::qwei_series(
    p = q, scales = scales, shapes = shapes)

cat("Simulation parameters:\n")
cat("B: ", B, "\n")
cat("n_cores: ", n_cores, "\n")
cat("max_iter: ", max_iter, "\n")
cat("max_boot_iter: ", max_boot_iter, "\n")
cat("n: ", n, "\n")
cat("p: ", p, "\n")
cat("q: ", q, "\n")
cat("shape: ", shapes, "\n")
cat("scale: ", scales, "\n")
cat("tau: ", tau, "\n")

repeat {
    df <- wei.series.md.c1.c2.c3::generate_guo_weibull_table_2_data(
        shapes = shapes, scales = scales, n = n, p = p, tau = tau)

    sol <- mle_lbfgsb_wei_series_md_c1_c2_c3(
        theta0 = theta, df = df, hessian = FALSE,
        control = list(maxit = max_iter, parscale = theta))
    if (sol$convergence == 0) {
        break
    }
    cat("MLE did not converge, retrying...\n")
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

# compute the confidence interval
ci <- boot.ci(sol.boot, type = "bca", index = 1)
ci <- boot.ci(sol.boot, type = "perc", index=1)
lwr <- ci$bca[4]
upr <- ci$bca[5]


plot(sol.boot$t[,1])

hist(sol.boot$t[,1], main = "Histogram of Bootstrap Replicates", xlab = "Values")

library(ggplot2)

ggplot() + geom_histogram(
    aes(x = sol.boot$t[,1], bins = 30, fill = 'blue', color = 'black')) +
  ggtitle("Histogram of Bootstrap Replicates") +
  xlab("Values")

# compute two std devs, one for each parameter
q.975 <- qnorm(0.975)
serr1 <- sqrt(diag(cov(sol.boot$t)))
lwr <- sol.boot$t0 - q.975 * serr1
upr <- sol.boot$t0 + q.975 * serr1
# what's an alternative way to compute the confidence interval?
# use the boot.ci function

plot(sol.boot$t[,1])

print(ci)
cat("Bootstrapped MLE #1: ", sol.boot$t0, "\n")
print(matrix(c(lwr, upr), ncol = 2))
cat("Bootstrapped MLE #2: ", sol.boot$t0, "\n")
print(matrix(c(lwr2, upr2), ncol = 2))

print(confint(mle_boot(sol.boot), type = "perc", level = 0.95))
print(confint(mle_boot(sol.boot), type = "bca", level = 0.95))
print(confint(mle_boot(sol.boot), type = "norm", level = 0.95))
?confint(mle_boot(sol.boot), type = "student", level = 0.95)

plot(sol.boot, index = 1, type = "bca")

