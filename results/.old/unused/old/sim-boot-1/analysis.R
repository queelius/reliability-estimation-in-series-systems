#confint(theta.hat)
#confint(theta.boot)

#bias(theta.hat, theta)
#mse(theta.hat, theta)

#vcov(theta.hat)
#vcov(theta.boot)

#sqrt(diag(vcov(theta.hat)))
#sqrt(diag(vcov(theta.boot)))



boots <- readRDS("./results/sim-boot-1/results_100_0_1.rds")
boots$tau
boots$df
boots$n
boots$p
boots$q
boots$mle$par
boots$mle.boot$t0
diag(cov(boots$mle.boot$t))
diag(-MASS::ginv(wei.series.md.c1.c2.c3::hessian_wei_series_md_c1_c2_c3(boots$df, boots$mle$par)))


boots$mle.boot
confint(mle_boot(boots$mle.boot))
confint(mle_numerical(boots$mle))
