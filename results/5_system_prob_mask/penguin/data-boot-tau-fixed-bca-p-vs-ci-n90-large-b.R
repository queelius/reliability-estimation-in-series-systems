#
# This is an experiment to see how masking probability effects the sampling distribution of the MLE
# Of course, as always, we are interested in assessing the coverage probability and CI in general.
# But, since it's an MC simulation too, we can also see the bias plotted on the graph that results
# from this. Whenever censoring occurs, whether component cause of failure, or right censoring,
# the parameters of the components are going to be biased in a way that increases the MTTF of the
# component. Why? Because we only know that a component (if right censored, all components) survived
# longer than some time. this is interesting. we will not examine the effect of tau, we keep that fixed,
# at q = .825 (quantile of the series system). however, we do change masking probability p. when
# we increase this, it's interesting to see the effect.
#
# another experiment i'm running is making one of the components the weakest link in the chain,
# and so dominates the component cause of failure. this will increase the bias of the other
# components, but the weak component will be estimated quite well.

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
options(digits = 5, scipen = 999)

N <- c(90)
P <- rep(c(.1, .25, .4, .55, .7, .85), 100)
# .1, .25, .4, .55, .7, .85
Q <- c(.825)
R <- 10
B <- 1000L
max_iter <- 125L
max_boot_iter <- 125L
n_cores <- detectCores() - 1

cat("Simulation parameters:\n")
cat("R: ", R, "\n")
cat("B: ", B, "\n")
cat("n_cores: ", n_cores, "\n")
cat("shape: ", shapes, "\n")
cat("scale: ", scales, "\n")
m <- length(scales)

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
            shapes.mle <- matrix(NA, nrow = R, ncol = m)
            scales.mle <- matrix(NA, nrow = R, ncol = m)

            shapes.lower <- matrix(NA, nrow = R, ncol = m)
            shapes.upper <- matrix(NA, nrow = R, ncol = m)
            scales.lower <- matrix(NA, nrow = R, ncol = m)
            scales.upper <- matrix(NA, nrow = R, ncol = m)

            # for each MLE, we compute the log-likelihood
            logliks <- rep(0, R)

            iter <- 0L
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
                            break
                        }
                        cat("[", iter, "] MLE did not converge, retrying...\n")
                    }

                    mle_solver <- function(df, i) {
                        mle_lbfgsb_wei_series_md_c1_c2_c3(
                            theta0 = sol$par, df = df[i, ], hessian = FALSE,
                            control = list(maxit = max_boot_iter, parscale = sol$par))$par
                    }

                    # do the non-parametric bootstrap
                    sol.boot <- boot::boot(df, mle_solver,
                        R = B, parallel = "multicore", ncpus = n_cores)
                },
                error = function(e) {
                    cat("[error] ", conditionMessage(e), "\n")
                    cat("[retrying scenario: n = ", n, ", p = ", p, ", q = ", q, "]\n")
                    retry <<- TRUE
                })
                if (retry) {
                    next
                }
                iter <- iter + 1L
                shapes.mle[iter,] <- sol$par[seq(1, length(theta), 2)]
                scales.mle[iter,] <- sol$par[seq(2, length(theta), 2)]
                logliks[iter] <- sol$value

                tryCatch({
                    ci <- confint(mle_boot(sol.boot), type = "bca", level = 0.95)
                    shapes.ci <- ci[seq(1, length(theta), 2), ]
                    scales.ci <- ci[seq(2, length(theta), 2), ]
                    shapes.lower[iter, ] <- shapes.ci[, 1]
                    shapes.upper[iter, ] <- shapes.ci[, 2]
                    scales.lower[iter, ] <- scales.ci[, 1]
                    scales.upper[iter, ] <- scales.ci[, 2]
                }, error = function(e) {
                    cat("[bootstrap error] ", conditionMessage(e), "\n")
                })
                if (iter %% 5 == 0) {
                    cat("[iteration ", iter, "] shape mle = ", shapes.mle[iter,], ", scale mle = ", scales.mle[iter, ], "\n")
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

            write.table(df, file = "data-boot-tau-fixed-bca-p-vs-ci-large-b.csv", sep = ",", row.names = FALSE,
                col.names = !file.exists("data-boot-tau-fixed-bca-p-vs-ci-large-b.csv"), append = TRUE)
        }
    }
}
