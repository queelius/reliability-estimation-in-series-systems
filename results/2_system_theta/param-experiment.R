library(tidyverse)
library(parallel)
library(boot)
library(stats)
library(algebraic.mle)
library(algebraic.dist)
library(md.tools)
library(wei.series.md.c1.c2.c3)

shapes1 = c(10)
scales1 = c(50)
shapes2 <- c(2, 4, 6, 8, 10, 12, 14, 16, 18, 20)
scales2 <- c(30, 40, 50, 60, 70, 80)

options(digits = 5, scipen = 999)
N <- c(100)
P <- c(0)
Q <- c(1)
R <- 1000
#B <- 750L
max_iter <- 150L
total_retries <- 10000L
n_cores <- detectCores() - 1

for (shape1 in shapes1) {
    for (scale1 in scales2) {
        for (shape2 in shapes2) {
            for (scale2 in scales2) {
                for (n in N) {
                    for (p in P) {
                        for (q in Q) {
                            probs <- rep(NA, R)
                            mttfs <- rep(NA, R)
                            convergences <- rep(NA, R)
                            shapes <- c(shape1, shape2)
                            scales <- c(scale1, scale2)
                            tau <- wei.series.md.c1.c2.c3::qwei_series(
                                p = q, scales = scales, shapes = shapes)
                            # we compute R MLEs for each scenario
                            shapes.mle <- matrix(NA, nrow = R, ncol = length(theta) / 2)
                            scales.mle <- matrix(NA, nrow = R, ncol = length(theta) / 2)

                            cat("[starting] scenario(shapes: ", shapes, ", scales: ", scales, ", n: ", n, ", p: ", p, ", q: ", q, ")\n")
                            iter <- 0L
                            retries <- 0L
                            repeat {
                                retry <- FALSE
                                tryCatch({
                                    df <- wei.series.md.c1.c2.c3::generate_guo_weibull_table_2_data(
                                        shapes = shapes, scales = scales, n = n, p = p, tau = tau)

                                    sol <- mle_lbfgsb_wei_series_md_c1_c2_c3(
                                        theta0 = theta, df = df, hessian = FALSE,
                                        control = list(maxit = max_iter, parscale = theta))
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
                                convergences[iter] <- sol$convergence                    
                                mttfs[iter] <- scales[2] * gamma(1 + 1/shapes[2])
                                probs[iter] <- wei_series_cause(2L, shapes = shapes, scales = scales)

                                if (sol$convergence != 0) {
                                    cat("[warning] scenario(shapes: ", shapes, ", scales: ", scales, ", n: ", n, ", p: ", p, ", q: ", q, ") did not converge. `df` written to file\n")

                                    # let's name the file after the scenario and the iteration
                                    # if a file already exists by that name, we'll not overwrite, but append
                                    # the file name with a system time.
                                    filename <- paste0("data-mttf-shape3-vary-unmasked-", shapes, "-", scales, "-", n, "-", p, "-", q, "-", iter, "-", Sys.time(), ".csv")
                                    write.table(df, file = filename, sep = ",", row.names = FALSE,
                                        col.names = !file.exists(filename), append = TRUE)
                                }

                                if (iter %% 10 == 0) {
                                    cat("[iteration ", iter, "] shape mles: ", shapes.mle[iter,], ", scale mles = ", scales.mle[iter, ], "\n")

                                }
                                if (iter == R) {
                                    break
                                }
                            }

                            df <- data.frame(
                                n = rep(n, R),
                                p = rep(p, R),
                                q = rep(q, R),
                                probs = probs,
                                mttfs = mttfs,
                                tau = rep(tau, R),
                                convergences = convergences,
                                shape3 = rep(shape3, R),
                                shapes = shapes.mle,
                                scales = scales.mle)

                            write.table(df, file = "data-shape3-vary-unmasked.csv", sep = ",", row.names = FALSE,
                                col.names = !file.exists("data-shape3-vary-unmasked.csv"), append = TRUE)
                        }
                    }
                }
            }
        }
    }
}