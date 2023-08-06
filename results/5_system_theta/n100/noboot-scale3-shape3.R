#########################################
# Configuration file for the simulation #
#########################################

theta.star <- c(shape1 = 1.2576, scale1 = 994.3661,
                shape2 = 1.1635, scale2 = 908.9458,
                shape3 = NA, scale3 = NA,
                shape4 = 1.1802, scale4 = 940.1342,
                shape5 = 1.2034, scale5 = 923.1631)

shapes3 <- c(.4, .456, .5, .55, .635, .75, 1.2034, 2.5, 5, 10, 15, 20)
scales3 <- c(840.1141)

# MTTF[3] = scale[3] * gamma(1 + 1/shape[3])

name <- "noboot-scale3-{}-shape3-{}"
N <- c(100)
P <- c(.215)
Q <- c(1)
R <- 1000
max_iter <- 500L
total_retries <- 10000L

##########################################
library(tidyverse)
library(parallel)
library(boot)
library(stats)
library(algebraic.mle)
library(algebraic.dist)
library(md.tools)
library(wei.series.md.c1.c2.c3)
options(digits = 5, scipen = 999)

for (scale3 in scales3) {
    for (shape3 in shapes3) {
        for (n in N) {
            for (p in P) {
                for (q in Q) {

                    theta <- theta.star
                    theta["shape3"] <- shape3
                    theta["scale3"] <- scale3

                    shapes <- theta[seq(1, length(theta), 2)]
                    scales <- theta[seq(2, length(theta), 2)]
                    convergences <- rep(NA, R)
                    shapes.mle <- matrix(NA, nrow = R, ncol = length(theta) / 2)
                    scales.mle <- matrix(NA, nrow = R, ncol = length(theta) / 2)
                    probs <- rep(NA, R)
                    mttfs <- rep(NA, R)

                    tau <- wei.series.md.c1.c2.c3::qwei_series(
                        p = q, scales = scales, shapes = shapes)

                    cat("[starting] scenario(shape3: ", shape3, ", scale3: ", scale3, ", n: ", n, ", p: ", p, ", q: ", q, ")\n")

                    iter <- 0L
                    retries <- 0L
                    repeat {
                        retry <- FALSE
                        tryCatch({
                            df <- wei.series.md.c1.c2.c3::generate_guo_weibull_table_2_data(
                                shapes = shapes, scales = scales, n = n, p = p, tau = tau)

                            sol <- wei.series.md.c1.c2.c3::mle_lbfgsb_wei_series_md_c1_c2_c3(
                                theta0 = theta, df = df, hessian = FALSE,
                                control = list(maxit = max_iter, parscale = theta))
                        },
                        error = function(e) {
                            cat("[warning] scenario(shape3: ", shape3, ", scale3: ", scale3, ", n: ", n, ", p: ", p, ", q: ", q, ")\n")
                            cat("[error message] ", conditionMessage(e), "\n")
                            retries <<- retries + 1L
                            if (retries < total_retries) {
                                cat("[retrying] scenario(shape3: ", shape3, ", scale3: ", scale3, ", n: ", n, ", p: ", p, ", q: ", q, ")\n")
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
                        mttfs[iter] <- scale3 * gamma(1 + 1/shape3)
                        probs[iter] <- wei_series_cause(3L, shapes = shapes, scales = scales)

                        if (iter %% 10 == 0) {
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
                        probs = probs,
                        mttfs = mttfs,
                        tau = rep(tau, R),
                        convergences = convergences,
                        shape3 = rep(shape3, R),
                        scale3 = rep(scale3, R),
                        shapes = shapes.mle,
                        scales = scales.mle)

                    csv_out <- paste0(name, ".csv")
                    write.table(df, file = csv_out, sep = ",", row.names = FALSE,
                        col.names = !file.exists(csv_out), append = TRUE)
                }
            }
        }
    }
}
