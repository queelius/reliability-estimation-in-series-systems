library(ggplot2)
library(gridExtra)
library(latex2exp)
library(stats)
library(md.tools)
library(wei.series.md.c1.c2.c3)

theta <- c(shape1 = 1.2576, scale1 = 994.3661,
           shape2 = 1.1635, scale2 = 908.9458,
           shape3 = 1.1308, scale3 = 4.1141)

shapes <- theta[seq(1, length(theta), 2)]
scales <- theta[seq(2, length(theta), 2)]

n <- 30
p <- .215
q <- .825
set.seed(151234)
tau <- wei.series.md.c1.c2.c3::qwei_series(p = q, scales = scales, shapes = shapes)
df <- wei.series.md.c1.c2.c3::generate_guo_weibull_table_2_data(
    shapes = shapes, scales = scales, n = n, p = p, tau = tau)
df.tweaked <- df
df.tweaked[1,"x3"] <- FALSE # remove component 3 from first observation
df.tweaked[1,"x1"] <- TRUE  # add component 1 to first observation

sol <- mle_lbfgsb_wei_series_md_c1_c2_c3(
    theta0 = theta, df = df, hessian = FALSE,
    control = list(maxit = 1000))
sol.tweaked <- mle_lbfgsb_wei_series_md_c1_c2_c3(
    theta0 = theta, df = df.tweaked, hessian = FALSE,
    control = list(maxit = 1000))

l <- Vectorize(function(shape1) {
    theta <- sol$par
    theta[1] <- shape1
    wei.series.md.c1.c2.c3::loglik_wei_series_md_c1_c2_c3(df, theta)
}, vectorize.args = "shape1")
l.tweaked <- Vectorize(function(shape1) {
    theta <- sol.tweaked$par
    theta[1] <- shape1
    wei.series.md.c1.c2.c3::loglik_wei_series_md_c1_c2_c3(df.tweaked, theta)
}, vectorize.args = "shape1")

shape1 <- seq(0.25, 4, by=.025)
yrange <- range(c(l(shape1), l.tweaked(shape1)))

plt <- ggplot(data.frame(x=shape1, y=l(shape1)), aes(x=x, y=y)) +
    geom_line() +
    geom_vline(xintercept = shapes[1], linetype="dashed", color = "blue", size=1) + # Add true k1
    geom_vline(xintercept = sol$par[1], linetype="dashed", color = "red", size=1) + # Add MLE for k1
    labs(x=TeX("Shape Parameter for Component 1 ($k_1$)"), y="Log-likelihood",
         caption = "Red dashed line: An MLE for Shape Parameter of Component 1.\nNon-unique MLE.") +
    theme_bw()

plt.tweaked <- ggplot(data.frame(x=shape1, y=l.tweaked(shape1)), aes(x=x, y=y)) +
    geom_line() +
    geom_vline(xintercept = shapes[1], linetype="dashed", color = "blue", size=1) + # Add true k1
    geom_vline(xintercept = sol.tweaked$par[1], linetype="dashed", color = "green", size=1) + # Add MLE for k1
    labs(x=TeX("Shape Parameter for Component 1 ($k_1$)"), y="Log-likelihood",
         caption = "Green dashed line: The MLE of Shape Parameter of Component 1.\nUnique MLE with a simple tweak to data.") +
    theme_bw() +
    coord_cartesian(ylim = yrange) # Define y range

plt.combined <- arrangeGrob(plt, plt.tweaked, ncol=2)
ggsave("test-flat-likelihood.pdf", plot=plt.combined, device="pdf", width=10, height=5, units = "in")

