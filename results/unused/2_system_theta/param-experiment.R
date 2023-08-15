library(tidyverse)
library(parallel)
library(boot)
library(stats)
library(algebraic.mle)
library(algebraic.dist)
library(md.tools)
library(wei.series.md.c1.c2.c3)

shapes1 <- rep(c(.01, .05, .1, .2, .3, .4, .5, .6, .7, .8, .9, .95, .99), 20)
scales1 <- 1
shape2 = 0.5
scale2 = 1
shape3 = 0.5
scale3 = 1

add_fake_data <- function(df, n = NULL) {

    df.censored <- df[df$delta == FALSE, ]
    df <- df[df$delta == TRUE, ]
    if (is.null(n)) {
        n <- nrow(df)
    }
    # count columns with prefix "x"
    C <- md.tools::md_decode_matrix(df, "x")
    m <- ncol(C)
    # for each component (column in C), check if there are *any* rows in which 
    # it is the only TRUE value, and the other columns in that row are FALSE.
    # if not, add a row with the median time and the component set to TRUE
    # and the other components set to FALSE
    cols <- 1:m
    for (k in cols) {
        # Find rows where only the current column is TRUE
        unique_rows <- rowSums(C == TRUE) == 1 & C[, k] == TRUE
        if (sum(unique_rows) == 0) {
            tmp <- df[sample(nrow(df), n, replace = TRUE), ]
            # take the median of the sampled data
            t <- median(tmp$t)
            row <- tmp[1, ]
            row$t <- t
            row$delta <- TRUE
            row[paste0("x", 1:m)] <- FALSE
            row[paste0("x", k)] <- TRUE
            df <- rbind(df, row)
        }
    }
    rbind(df, df.censored)
}

N <- c(100, 50, 200)
P <- c(0, 0.215)
Q <- c(1, 0.825)
R <- 20
max_iter <- 150L
total_retries <- 10000L

experiment.name <- "prob-shape1-vary-unmasked"
csv.out <- paste0(experiment.name, ".csv")

options(digits = 5, scipen = 999)
for (shape1 in shapes1) {
    for (scale1 in scales1) {
        for (n in N) {
            for (p in P) {
                for (q in Q) {

                    shapes <- c(shape1, shape2, shape3)
                    scales <- c(scale1, scale2, scale3)
                    theta <- c(shape1, scale1, shape2, scale2, shape3, scale3)
                    mttfs <- rep(wei.series.md.c1.c2.c3::wei_mttf(shape = shapes[1], scale = scales[1]), R)
                    probs <- NULL
                    tryCatch({
                        probs <- rep(wei.series.md.c1.c2.c3::wei_series_cause(k = 1L, shapes = shapes, scales = scales), R)
                    },
                    error = function(e) {
                        probs <<- rep(wei.series.md.c1.c2.c3::wei_series_cause(k = 1L, shapes = shapes, scales = scales, mc = TRUE), R)
                    })
                    convergences <- rep(NA, R)
                    tau <- wei.series.md.c1.c2.c3::qwei_series(p = q, scales = scales, shapes = shapes)
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

                            df <- add_fake_data(df)
                            start <- wei.series.md.c1.c2.c3::mle_sann_wei_series_md_c1_c2_c3(
                                theta0 = theta, df = df, hessian = FALSE,
                                control = list(maxit = 100L, parscale = theta))

                            sol <- wei.series.md.c1.c2.c3::mle_lbfgsb_wei_series_md_c1_c2_c3(
                                theta0 = start$par, df = df, hessian = FALSE,
                                control = list(maxit = max_iter, parscale = theta))
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
                        convergences[iter] <- sol$convergence                    

                        if (sol$convergence != 0) {
                            cat("[warning] scenario(shapes: ", shapes, ", scales: ", scales, ", n: ", n, ", p: ", p, ", q: ", q, ") did not converge. `df` written to file\n")
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
                        shape1 = rep(shapes[1], R),
                        scale1 = rep(scales[1], R),
                        shape2 = rep(shapes[2], R),
                        scale2 = rep(scales[2], R),
                        shape3 = rep(shapes[3], R),
                        scale3 = rep(scales[3], R),
                        shape.mles = shapes.mle,
                        scale.mles = scales.mle)

                    write.table(df, file = csv.out, sep = ",", row.names = FALSE,
                        col.names = !file.exists(csv.out), append = TRUE)
                }
            }
        }
    }
}
