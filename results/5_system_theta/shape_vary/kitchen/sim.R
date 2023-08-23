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

shapes3 <- rep(c(0.1, 0.3, 0.5, 0.7, 0.9, 1.1, 1.3, 1.5, 1.7, 1.9), 1000)
N <- c(100)
P <- c(0.215)
Q <- c(0.825)
R <- 5
B <- 1000
max_iter <- 125L
max_boot_iter <- 125L
total_retries <- 10000L
n_cores <- 2L

experiment.name <- "boot-prob-shape1-vary-unmasked"
csv.out <- paste0(experiment.name, ".csv")

mttfs3_fn <- list()
probs3_fn <- list()
probs1_fn <- list()

for (shape3 in shapes3) {
    theta["shape3"] <- shape3
    shapes <- theta[seq(1, length(theta), 2)]
    scales <- theta[seq(2, length(theta), 2)]

    mttfs3_fn[[as.character(shape3)]] <- wei.series.md.c1.c2.c3::wei_mttf(shape = shapes[3], scale = scales[3])
    tryCatch({
        probs1_fn[[as.character(shape3)]] <- wei.series.md.c1.c2.c3::wei_mttf(shape = shapes[1], scale = scales[1])
        probs3_fn[[as.character(shape3)]] <- wei.series.md.c1.c2.c3::wei_series_cause(k = 3L, shapes = shapes, scales = scales)
    },
    error = function(e) {
        probs1_fn[[as.character(shape3)]] <<- wei.series.md.c1.c2.c3::wei_mttf(shape = shapes[1], scale = scales[1])
        probs3_fn[[as.character(shape3)]] <<- wei.series.md.c1.c2.c3::wei_series_cause(k = 3L, shapes = shapes, scales = scales,
            mc = TRUE, n = 200000L)
    })
}

options(digits = 5, scipen = 999)
for (shape3 in shapes3) {
    for (n in N) {
        for (p in P) {
            for (q in Q) {

                theta["shape3"] <- shape3
                shapes <- theta[seq(1, length(theta), 2)]
                scales <- theta[seq(2, length(theta), 2)]

                tau <- wei.series.md.c1.c2.c3::qwei_series(p = q, scales = scales, shapes = shapes)
                shapes.mle <- matrix(NA, nrow = R, ncol = length(theta) / 2)
                scales.mle <- matrix(NA, nrow = R, ncol = length(theta) / 2)

                shapes.lower <- matrix(NA, nrow = R, ncol = length(theta) / 2)
                shapes.upper <- matrix(NA, nrow = R, ncol = length(theta) / 2)
                scales.lower <- matrix(NA, nrow = R, ncol = length(theta) / 2)
                scales.upper <- matrix(NA, nrow = R, ncol = length(theta) / 2)

                cat("[starting] scenario(shapes: ", shapes, ", scales: ", scales, ", n: ", n, ", p: ", p, ", q: ", q, ")\n")
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
                            solb <- mle_lbfgsb_wei_series_md_c1_c2_c3(
                                theta0 = sol$par, df = df[i, ], hessian = FALSE,
                                control = list(maxit = max_boot_iter, parscale = sol$par))
                            solb$par
                        }

                        sol.boot <- boot::boot(df, mle_solver,
                            R = B, parallel = "multicore", ncpus = n_cores)
                    },
                    error = function(e) {
                        cat("[error] ", conditionMessage(e), "\n")
                        retries <<- retries + 1L
                        if (retries < total_retries) {
                            cat("[scenario n = ", n, ", p = ", p, ", q = ", q, "]: ",
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

                    tryCatch({
                        sb <- mle_boot(sol.boot)
                        ci <- confint(sb, type = "bca", level = 0.95)
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
                    prob3 = rep(probs3_fn[[as.character(shape3)]], R),
                    mttf3 = rep(mttfs3_fn[[as.character(shape3)]], R),
                    prob1 = rep(probs1_fn[[as.character(shape3)]], R),
                    mttf1 = rep(wei.series.md.c1.c2.c3::wei_mttf(shape = shapes[1], scale = scales[1]), R),
                    mttf = rep(wei.series.md.c1.c2.c3::wei_series_mttf(shapes = shapes, scales = scales), R),
                    tau = rep(tau, R),
                    shapes1 = rep(shape3, R),
                    shape.mles = shapes.mle,
                    scale.mles = scales.mle,
                    shapes.lower = shapes.lower,
                    shapes.upper = shapes.upper,
                    scales.lower = scales.lower,
                    scales.upper = scales.upper)

                write.table(df, file = csv.out, sep = ",", row.names = FALSE,
                    col.names = !file.exists(csv.out), append = TRUE)
            }
        }
    }
}
