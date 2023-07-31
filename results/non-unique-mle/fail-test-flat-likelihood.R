# Load necessary libraries
library(ggplot2)
library(gridExtra)
library(latex2exp) # for LaTeX in captions
library(grid) # for textGrob
library(tidyverse)
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
set.seed(123521)
tau <- wei.series.md.c1.c2.c3::qwei_series(p = q, scales = scales, shapes = shapes)
df <- wei.series.md.c1.c2.c3::generate_guo_weibull_table_2_data(
    shapes = shapes, scales = scales, n = n, p = p, tau = tau)

df.tweaked <- df
sol <- mle_lbfgsb_wei_series_md_c1_c2_c3(
    theta0 = runif(6,1,100), df = df, hessian = FALSE,
    control = list(maxit = 1000))
sol.tweaked <- mle_lbfgsb_wei_series_md_c1_c2_c3(
    theta0 = runif(6,1,100), df = df.tweaked, hessian = FALSE,
    control = list(maxit = 1000))

l <- Vectorize(function(shape1) {
    theta <- sol$par
    theta[1] <- shape1
    wei.series.md.c1.c2.c3::loglik_wei_series_md_c1_c2_c3(df, theta)
}, vectorize.args = "shape1")
l.tweaked <- Vectorize(function(shape1) {
    theta <- sol$par
    theta[1] <- shape1
    wei.series.md.c1.c2.c3::loglik_wei_series_md_c1_c2_c3(df.tweaked, theta)
}, vectorize.args = "shape1")

shape1 <- seq(0.001, 10, by=.01)
yrange <- range(c(l(shape1), l.tweaked(shape1)))

# Define the true value and MLE for k1
true_k1 <- shapes[1]
mle_k1_left <- sol$par[1]
mle_k1_right <- sol.tweaked$par[1]

caption1 <- "Red dashed line: An MLE for Shape Parameter of Component 1.\nNon-unique MLE."
caption2 <- "Red dashed line: The MLE of Shape Parameter of Component 1.\nUnique MLE with a simple tweak to data."

plt <- ggplot(data.frame(x=shape1, y=l(shape1)), aes(x=x, y=y)) +
    geom_line() +
    geom_vline(xintercept = true_k1, linetype="dashed", color = "blue", size=1) + # Add true k1
    geom_vline(xintercept = mle_k1_left, linetype="dashed", color = "red", size=1) + # Add MLE for k1
    labs(x=TeX("Shape Parameter for Component 1 ($k_1$)"), y="Log-likelihood", caption = caption1) +
    theme_bw() +
    theme(plot.title = element_text(hjust = 0.5),
          plot.caption = element_text(hjust = 0.5, size = 10),
          plot.margin = margin(1, 1, 5, 1, "cm") # Larger bottom margin
    ) +    coord_cartesian(ylim = yrange) # Define y range

plt.tweaked <- ggplot(data.frame(x=shape1, y=l.tweaked(shape1)), aes(x=x, y=y)) +
    geom_line() +
    geom_vline(xintercept = true_k1, linetype="dashed", color = "blue", size=1) + # Add true k1
    geom_vline(xintercept = mle_k1_right, linetype="dashed", color = "red", size=1) + # Add MLE for k1
    labs(x=TeX("Shape Parameter for Component 1 ($k_1$)"), y="Log-likelihood", caption = caption2) +
    theme_bw() +
    theme(plot.title = element_text(hjust = 0.5),
          plot.caption = element_text(hjust = 0.5, size = 10),
          plot.margin = margin(1, 1, 5, 1, "cm") # Larger bottom margin
    ) +    
    coord_cartesian(ylim = yrange) # Define y range

shared_title <- textGrob("Log-likelihood Profile vs Shape Parameter for Component 1: Non-unique MLE vs Unique MLE.\nRed Dashed Line is the True Shape Value.", gp=gpar(fontsize=16))

plt.combined <- arrangeGrob(plt, plt.tweaked, ncol=2, top=shared_title) # use arrangeGrob to combine plots
ggsave("fail-test-flat-likelihood.pdf", plot=plt.combined, device="pdf", width=10, height=5, units = "in")
