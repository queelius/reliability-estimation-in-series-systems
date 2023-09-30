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
m <- length(scales)

simulate_it <- function(N, P, Q, file) {
    for (n in N) {
        for (p in P) {
            for (q in Q) {
                tau <- qwei_series(p = q, scales = scales, shapes = shapes)
                convergences <- rep(NA, R)
                for (iter in 1:R) {
                    df <- wei.series.md.c1.c2.c3::generate_guo_weibull_table_2_data(
                        shapes = shapes, scales = scales, n = n, p = p, tau = tau)

                    sol <- mle_lbfgsb_wei_series_md_c1_c2_c3(
                        theta0 = theta, df = df, hessian = FALSE,
                        control = list(maxit = max_iter, parscale = theta))

                    convergences[iter] <- sol$convergence
                    if (iter %% 10 == 0) {
                        cat("[iteration ", iter, "] p = ", p, ", q = ", q, ", n = ", n, ", convergence rate = ", sum(convergences[1:iter] == 0) / iter, "\n")
                    }
                }

                
                cat("p = ", p, ", q = ", q, ", n = ", n, ", convergence rate = ", sum(convergences == 0) / R, "\n")
                # append to file
                sink(file, append = TRUE)
                cat("p = ", p, ", q = ", q, ", n = ", n, ", convergence rate = ", sum(convergences == 0) / R, "\n")
                sink()
            }
        }
    }
}

R <- 1000L

N <- c(100)
P <- c(.215)
Q <- c(.825)
max_iter <- 125L
simulate_it(N, P, Q, "conv-rate-n.txt")