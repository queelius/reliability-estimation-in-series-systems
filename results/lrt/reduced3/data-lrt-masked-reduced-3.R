library(tidyverse)
library(stats)
library(algebraic.mle)
library(algebraic.dist)
library(md.tools)
library(wei.series.md.c1.c2.c3)

theta <- c(shape1 = 1.2576, scale1 = 994.3661,
           shape2 = 1.1635, scale2 = 908.9458,
           shape3 = NA,     scale3 = 840.1141,
           shape4 = 1.1802, scale4 = 940.1342,
           shape5 = 1.2034, scale5 = 923.1631)

csv.file <- "data-lrt-masked-reduced-3.csv"
shapes3 <- c(0.25, 0.5, .75, 1, 1.1308, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3.0)
N <- rep(1000, 1000)
p <- .215
q <- .825
max_iter <- 1000L

for (n in N) {
for (shape3 in shapes3) {
    theta['shape3'] <- shape3
    shapes <- theta[seq(1, length(theta), 2)]
    scales <- theta[seq(2, length(theta), 2)]
    m <- length(shapes)
    tau <- qwei_series(p = q, scales = scales, shapes = shapes)

    df <- generate_guo_weibull_table_2_data(
        shapes = shapes, scales = scales, n = n, p = p, tau = tau)
    tryCatch({
        sol <- mle_lbfgsb_wei_series_md_c1_c2_c3(
            theta0 = theta, df = df, hessian = FALSE,
            control = list(maxit = max_iter, parscale = theta))

        shapes.mle <- sol$par[seq(1, length(theta), 2)]
        scales.mle <- sol$par[seq(2, length(theta), 2)]
        k.hat <- mean(shapes.mle)    

        loglik.reduced <- function(df, k, scales, candset = "x",
            lifetime = "t", right_censoring_indicator = "delta") {

            theta <- rep(NA, length(scales) * 2)
            for (i in 1:length(scales)) {
                theta[2*(i-1) + 1] <- k
                theta[2*(i-1) + 2] <- scales[i]
            }
            wei.series.md.c1.c2.c3::loglik_wei_series_md_c1_c2_c3(
                df = df, theta = theta, candset = candset,
                lifetime = lifetime, right_censoring_indicator = right_censoring_indicator)
        }

        sol.R <- stats::optim(
            par = c(k.hat, scales.mle),
            fn = function(theta) {
                loglik.reduced(df = df, k = theta[1], scales = theta[-1])
            },
            control = list(fnscale = -1, maxit = max_iter))

        Lambda <- -2 * (sol.R$value - sol$value)
        p.value <- pchisq(Lambda, m-1, lower.tail = FALSE)

        cat("n =", n, ", shape3 =", shape3,  ", p-value =", p.value, ", Lambda =", Lambda, ", loglik.F =", sol$value, ", loglik.R =", sol.R$value, "\n")

        write.table(
            x = data.frame(n = n, pmask = p, q = q, shape3 = shape3, p.value = p.value, Lambda = Lambda,
                           loglik.F = sol$value, loglik.R = sol.R$value),
            file = csv.file, sep = ",", append = TRUE,
            row.names = FALSE, col.names = FALSE)

    }, error = function(e) { print(e) })
}
}
