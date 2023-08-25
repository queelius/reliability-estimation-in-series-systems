library(tidyverse)
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
m <- length(shapes)

csv.file <- "data-lrt-masked-reduced-2.csv"
N <- rep(c(1500, 2500, 3500), 100)
#N <- rep(c(50, 60, 70, 80, 90, 100, 250, 500, 1000, 5000), 100)
p <- .215
q <- .825
max_iter <- 1000L
tau <- qwei_series(p = q, scales = scales, shapes = shapes)

for (n in N) {
    df <- generate_guo_weibull_table_2_data(
        shapes = shapes, scales = scales, n = n, p = p, tau = tau)

#    start <- mle_sann_wei_series_md_c1_c2_c3(
 #       theta0 = theta, df = df, hessian = FALSE,
  #      control = list(maxit = 200L, parscale = theta))

    sol <- mle_lbfgsb_wei_series_md_c1_c2_c3(
        theta0 = theta, df = df, hessian = FALSE,
        control = list(maxit = max_iter, parscale = theta))

    if (sol$convergence != 0) {
        cat("Failed to converge, retrying.\n")
        continue
    }
    shapes.mle <- sol$par[seq(1, length(theta), 2)]
    scales.mle <- sol$par[seq(2, length(theta), 2)]
    k.hat <- mean(shapes.mle)
    scale.hat <- mean(scales.mle)    

    loglik.reduced.2 <- function(df, k, scale, candset = "x",
        lifetime = "t", right_censoring_indicator = "delta") {

        theta <- rep(c(k, scale), m) 
        wei.series.md.c1.c2.c3::loglik_wei_series_md_c1_c2_c3(
            df = df, theta = theta, candset = candset,
            lifetime = lifetime, right_censoring_indicator = right_censoring_indicator)
    }

    sol.R <- stats::optim(
        par = c(k.hat, scale.hat),
        fn = function(theta) {
            loglik.reduced.2(df = df, k = theta[1], scale = theta[2])
        },
        control = list(fnscale = -1, maxit = max_iter))

    Lambda <- -2 * (sol.R$value - sol$value)
    p.value <- pchisq(Lambda, 2*m-2, lower.tail = FALSE)

    # write this data to a CSV file
    cat("n =", n, "p-value =", p.value, ", Lambda =", Lambda, ", loglik.F =", sol$value, ", loglik.R =", sol.R$value, "\n")

    # write this data to a CSV file    
    write.table(
        x = data.frame(n = n, pmask = p, q = q, p.value = p.value, Lambda = Lambda,
                       loglik.F = sol$value, loglik.R = sol.R$value),
        file = csv.file, sep = ",", append = TRUE,
        row.names = FALSE, col.names = FALSE)
}
