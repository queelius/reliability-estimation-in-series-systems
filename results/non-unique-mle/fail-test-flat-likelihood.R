library(tidyverse)
library(stats)
library(md.tools)
library(wei.series.md.c1.c2.c3)

theta <- c(shape1 = 1.2576, scale1 = 994.3661,
           shape2 = 1.1635, scale2 = 908.9458,
           shape3 = 1.1308, scale3 = 840.1141,
           shape4 = 1.1802, scale4 = 940.1141,      
           shape5 = 1.3311, scale5 = 1.1123)

shapes <- theta[seq(1, length(theta), 2)]
scales <- theta[seq(2, length(theta), 2)]
parscale <- c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
stopifnot(length(parscale) == length(theta))

n <- 100
p <- 0
q <- 1

tau <- wei.series.md.c1.c2.c3::qwei_series(p = q, scales = scales, shapes = shapes)
df <- wei.series.md.c1.c2.c3::generate_guo_weibull_table_2_data(
    shapes = shapes, scales = scales, n = n, p = p, tau = tau)
sol <- mle_lbfgsb_wei_series_md_c1_c2_c3(
    theta0 = runif(10,1,100), df = df, hessian = FALSE,
    control = list(maxit = 1000, parscale = parscale))
l <- Vectorize(function(shape1) {
    theta <- sol$par
    theta[1] <- shape1
    wei.series.md.c1.c2.c3::loglik_wei_series_md_c1_c2_c3(df, theta)
}, vectorize.args = "shape1")
shape1 <- seq(9.28, 26, by=.01)

plt <- ggplot(data.frame(x=shape1, y=l(shape1)), aes(x=x, y=y)) +
    geom_line() +
    labs(x="Shape 1", y="Log-likelihood",
    title="Log-likelihood Profile vs Shape 1") + theme_bw() +
    theme(plot.title = element_text(hjust = 0.5))

ggsave("fail-test-flat-likelihood.pdf", plot=plt, device="pdf", width=4, height=3, units="in", dpi=75)
