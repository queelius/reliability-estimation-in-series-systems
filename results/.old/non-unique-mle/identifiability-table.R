library(ggplot2)
library(gridExtra)
library(latex2exp)
library(stats)
library(md.tools)
library(wei.series.md.c1.c2.c3)

theta <- c(shape1 = 1.2576, scale1 = 994.3661,
           shape2 = 1.1635, scale2 = 908.9458)

shapes <- theta[seq(1, length(theta), 2)]
scales <- theta[seq(2, length(theta), 2)]

n <- 2
p <- .5
q <- 1
set.seed(1512341)
tau <- wei.series.md.c1.c2.c3::qwei_series(p = q, scales = scales, shapes = shapes)
(df <- wei.series.md.c1.c2.c3::generate_guo_weibull_table_2_data(
    shapes = shapes, scales = scales, n = n, p = p, tau = tau))

sol <- mle_lbfgsb_wei_series_md_c1_c2_c3(
    theta0 = theta, df = df, hessian = FALSE,
    control = list(maxit = 1000))

l <- Vectorize(function(shape1) {
    theta <- sol$par
    theta[1] <- shape1
    wei.series.md.c1.c2.c3::loglik_wei_series_md_c1_c2_c3(df, theta)
}, vectorize.args = "shape1")

shape1 <- seq(3.0, 5.5, by=.1)
yrange <- range(l(shape1))

plt <- ggplot(data.frame(x=shape1, y=l(shape1)), aes(x=x, y=y)) +
    geom_line() +
    geom_vline(xintercept = shapes[1], linetype="dashed", color = "blue", size=1) + # Add true k1
    geom_vline(xintercept = sol$par[1], linetype="dashed", color = "red", size=1) + # Add MLE for k1
    labs(x=TeX("Shape Parameter for Component 1 ($k_1$)"), y="LogLikelihood")
    theme_bw()

ggsave("flat-likelihood.pdf", plot=plt, device="pdf", width=6, height=4, units = "in")

