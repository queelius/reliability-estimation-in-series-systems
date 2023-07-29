library(MASS)
library(tidyverse)
library(wei.series.md.c1.c2.c3)
library(usethis)
library(readr)
library(stats)
library(algebraic.mle)
library(algebraic.dist)

options(digits = 3)
options(scipen = 999)

guo_weibull_series_dgp_1 <- generate_guo_weibull_table_2_data()
res <- optim(par = guo_weibull_series_mle$mle,
             fn = loglik_wei_series_md_c1_c2_c3,
             df = guo_weibull_series_dgp_1,
             hessian = TRUE,
             control = list(
                fnscale = -1,
                reltol = 1e-50,
                maxit = 10000L,
                parscale = c(1,1000,1,1000,1,1000)))

theta.hat <- mle_numerical(res)
confint(theta.hat, level = 0.95)
