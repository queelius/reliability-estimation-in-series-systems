library(tidyverse)
library(parallel)
library(boot)
library(stats)
library(algebraic.mle)
library(algebraic.dist)
library(md.tools)
library(wei.series.md.c1.c2.c3)


####################################
# Setup simulation parameters here #
####################################
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

seed_value <- 151234
set.seed(151234)
N <- c(200)
P <- rep(c(0, .1, .2, .3, .4, .5), 50)
Q <- c(.825)
R <- 10
B <- 750L
max_iter <- 150L
max_boot_iter <- 150L
total_retries <- 10000L
n_cores <- detectCores() - 1
filename <- "data-boot-tau-fixed-bca-p-vs-ci"
ci_method <- "bca"          # Bootstrap CI method. See ?boot::boot.ci for details.

##############################
# Simulation code below here #
##############################
file.meta <- paste0(filename, ".txt")
file.csv <- paste0(filename, ".csv")
if (file.exists(file.meta)) {
  stop("File already exists: ", file.meta)
}
if (file.exists(file.csv)) {
  stop("File already exists: ", file.csv)
}

sink(paste0(file, "txt"))
cat("Simulation Parameters:\n")
cat("seed_value: ", seed_value, "\n")
cat("ci_method: ", ci_method, "\n")
cat("theta: ", theta, "\n")
cat("N: ", N, "\n")
cat("P: ", P, "\n")
cat("Q: ", Q, "\n")
cat("R: ", R, "\n")
cat("B: ", B, "\n")
cat("max_iter: ", max_iter, "\n")
cat("max_boot_iter: ", max_boot_iter, "\n")
cat("n_cores: ", n_cores, "\n")
cat("total_retries: ", total_retries, "\n")
cat("shape: ", shapes, "\n")
cat("scale: ", scales, "\n")
cat("parscale: ", parscale, "\n")
sink()

for (n in N) {
    for (p in P) {
        for (q in Q) {
            cat("Starting Scenario (n = ", n, ", p = ", p, ", q = ", q, ")\n")
            tau <- wei.series.md.c1.c2.c3::qwei_series(
                p = q, scales = scales, shapes = shapes)

            # we compute R MLEs for each scenario
            shapes.mle <- matrix(NA, nrow = R, ncol = length(theta) / 2)
            scales.mle <- matrix(NA, nrow = R, ncol = length(theta) / 2)
            shapes.lower <- matrix(NA, nrow = R, ncol = length(theta) / 2)
            shapes.upper <- matrix(NA, nrow = R, ncol = length(theta) / 2)
            scales.lower <- matrix(NA, nrow = R, ncol = length(theta) / 2)
            scales.upper <- matrix(NA, nrow = R, ncol = length(theta) / 2)
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
                    ci <- confint(sb, type = ci_method, level = 0.95)
                    shapes.ci <- ci[seq(1, length(theta), 2), ]
                    scales.ci <- ci[seq(2, length(theta), 2), ]
                    shapes.lower[iter, ] <- shapes.ci[, 1]
                    shapes.upper[iter, ] <- shapes.ci[, 2]
                    scales.lower[iter, ] <- scales.ci[, 1]
                    scales.upper[iter, ] <- scales.ci[, 2]
                }, error = function(e) {
                    cat("Error: ", conditionMessage(e), "\n")
                })
                if (iter %% 10 == 0) {
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

            write.table(df, file = file.csv, sep = ",", row.names = FALSE,
                col.names = !file.exists(file.csv), append = TRUE)
        }
    }
}
