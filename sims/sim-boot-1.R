# in this simulation, we are going to use the bootstrap method. we'll have a right
# censoring at 75% quantile of weibull series system and a component cause of failure
# p = .215 with a sample size n = 100. we want to see how we can use the bootstrap
# method to estimate the bias, variance, and MSE of the estimator. we'll have
# R = 1000 replicates.
# we'll also use it to construct a 95% confidence interval for the estimator. we'll
# compare this result to the asymptotic theory confidence interval.
# finally, we'll generate CIs by each method, asymptotic (inverse FIM) and 
# bootstrap (cov), and compare the coverage probabilities.

library(boot)
library(tidyverse)
library(parallel)
library(wei.series.md.c1.c2.c3)
library(stats)
library(algebraic.mle)
library(algebraic.dist)
library(md.tools)

theta <- c(shape1 = 1.2576, scale1 = 994.3661,
           shape2 = 1.1635, scale2 = 908.9458,
           shape3 = 1.1308, scale3 = 840.1141,
           shape4 = 1.1802, scale4 = 940.1141,
           shape5 = 1.3311, scale5 = 836.1123)

shapes <- theta[seq(1, length(theta), 2)]
scales <- theta[seq(2, length(theta), 2)]

parscale <- c(1, 1000, 1, 1000, 1, 1000, 1, 1000, 1, 1000)

#set.seed(134849131)
ns <- c(100)
ps <- c(0.215)
qs <- c(0.75)
R <- 1000

# here is our observed data
df <- wei.series.md.c1.c2.c3::generate_guo_weibull_table_2_data(
    shapes = shapes,
    scales = scales,
    n = n,
    p = p,
    tau = tau)

theta.hat <- algebraic.mle::mle_numerical(
    wei.series.md.c1.c2.c3::mle_nelder_wei_series_md_c1_c2_c3(
        df = df,
        theta0 = theta,
        reltol = 1e-4,
        parscale = parscale,
        maxit = 1000L))


theta.boot <- mle_boot(boot(df, function(df, i) {
    sol <- wei.series.md.c1.c2.c3::mle_nelder_wei_series_md_c1_c2_c3(
        df = df[i, ],
        theta0 = params(theta.hat),
        reltol = 1e-4,
        parscale = parscale,
        maxit = 1000L)
    sol$par
}, R = 1000))

confint(theta.hat)
confint(theta.boot)

bias(theta.hat, theta)
mse(theta.hat, theta)

vcov(theta.hat)
vcov(theta.boot)

sqrt(diag(vcov(theta.hat)))
sqrt(diag(vcov(theta.boot)))
