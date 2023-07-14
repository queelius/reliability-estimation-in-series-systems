library(tidyverse)
library(parallel)
library(wei.series.md.c1.c2.c3)
library(usethis)
library(readr)
library(stats)
library(algebraic.mle)
library(algebraic.dist)
library(md.tools)

options(digits = 3)
options(scipen = 999)

theta <- c(shape1 = 1.2576, scale1 = 994.3661,
           shape2 = 1.1635, scale2 = 908.9458,
           shape3 = 1.1308, scale3 = 840.1141,
           shape4 = 1.1802, scale4 = 940.1141,
           shape5 = 1.3311, scale5 = 836.1123)

shapes <- theta[seq(1, length(theta), 2)]
scales <- theta[seq(2, length(theta), 2)]

q.95 <- qwei_series(p = .9, scales = scales, shapes = shapes)
df <- generate_guo_weibull_table_2_data(
    n = 100,
    scales = scales,
    shapes = shapes,
    p = 0,
    tau = q.95)

parscale <- c(1, 1000, 1, 1000, 1, 1000, 1, 1000, 1, 1000)

res.optim <- optim(par = theta,
             fn = loglik_wei_series_md_c1_c2_c3,
             df = df,
             hessian = TRUE,
             control = list(
                REPORT = 100L,
                trace = 1L,
                fnscale = -1,
                reltol = 1e-40,
                maxit = 10000L,
                parscale = parscale))


res.newt <- wei.series.md.c1.c2.c3::mle_newton_wei_series_md_c1_c2_c3(
    df = df,
    theta0 = res.optim$par,
    lr = .1,
    tol = 1e-20,
    debug = TRUE,
    REPORT = 1L,
    maxit = 1000)


res.cg <- wei.series.md.c1.c2.c3::mle_cg_wei_series_md_c1_c2_c3(
    df = df,
    theta0 = res.optim$par,
    reltol = 1e-20,
    parscale = parscale,
    REPORT = 1L,
    maxit = 1000)


set.seed(9484913)
ns <- c(40, 60, 80, 100, 150, 200, 300, 400, 500, 600, 700, 800, 900, 1000)
ps <- c(0, .15, .3)
qs <- c(1, .9, .7)
R <- 200

for (n in ns) {
    for (p in ps) {
        for (q in qs) {
            mles <- list()
            problems <- list()
            tau <- qwei_series(p = q, scales = scales, shapes = shapes)
            cat("n =", n, ", p =", p, ", q = ", q, " (tau = ", tau, ")\n")
            for (r in 1:R) {
                result <- tryCatch({
                    df <- generate_data(
                        theta = theta,
                        n = n,
                        p = p)

                    sol <- fit.wei.series.md.c1.c2.c2(
                        df = df,
                        theta0 = theta,
                        tol = 1e-7,
                        maxit = 10000)

                    cat("r = ", r, ": ", sol$par, "\n")
                    mles <- append(mles, list(sol))
                }, error = function(e) {
                    cat("Error at iteration", r, ":")
                    print(e)
                    problems <- append(problems, list(list(
                        error = e, n = n, p = p, q = q, tau = tau, df = df)))
                })
            }

            # save results to disk for each scenario
            if (length(mles) != 0) {
                saveRDS(
                    list(n = n, p = p, q = q, tau = tau, mles = mles),
                    file = paste0(
                        "./results/results_",
                        n,
                        "_",
                        p,
                        "_",
                        q,
                        ".rds"))
            }

            # save problems to disk for each scenario
            if (length(problems) != 0) {
                saveRDS(
                    problems,
                    file = paste0(
                        "./problems/problems_",
                        n,
                        "_",
                        p,
                        "_",
                        q,
                        ".rds"))
            }
        }
    }
}



# simulation run #1
# -----------------
# set.seed(UNKNOWN)
# stats::optim: tol = 1e-6, maxit = 100000
# ns <- c(30)
# ps <- c(0, .1, .2)
# qs <- c(.99, .95, .75, .5)
# R <- 1000
# also: for n = 30 and p = .3, i only ran p = .3


# simulation run #2
# -----------------
# set.seed(9484913)
# ns <- c(40, 60)
# ps <- c(0, .15, .3)
# qs <- c(1, .9, .7)
# R <- 200
# stats::optim: tol = 1e-7, maxit = 10000












set.seed(34849131)
ns <- c(20, 40, 60, 80, 100)
ps <- c(0, .1, .2, .3, .4)
qs <- c(1, .9, .8, .7, .6)
R <- 1000


# Define the function you want to parallelize
myfun <- function(n, p, q) {
  mles <- list()
  problems <- list()
  tau <- qwei_series(p = q, scales = scales, shapes = shapes)
  cat("n =", n, ", p =", p, ", q = ", q, ", tau = ", tau, "\n")
  
  for (r in 1:R) {
    result <- tryCatch({
      df <- generate_data(theta = theta, n = n, p = p)
      sol <- fit.wei.series.md.c1.c2.c2(df = df, theta0 = theta, tol = 1e-4, maxit = 2000)
      #if (r %% 25 == 0) {
      cat("r = ", r, ": ", sol$par, "\n")
      #}
      mles <- append(mles, list(sol))
    }, error = function(e) {
      cat("Error at iteration", r, ":")
      print(e)
      problems <- append(problems, list(list(error = e, n = n, p = p, q = q, tau = tau, df = df)))
    })
  }

  if (length(mles) != 0) {
    saveRDS(list(n = n, p = p, q = q, tau = tau, mles = mles), file = paste0("./results/results_", n, "_", p, "_", q, ".rds"))
  }

  if (length(problems) != 0) {
    saveRDS(problems, file = paste0("./problems/problems_", n, "_", p, "_", q, ".rds"))
  }
}

# Run the function in parallel
params <- expand.grid(n = ns, p = ps, q = qs)
result <- mclapply(1:nrow(params), function(i) myfun(params$n[i], params$p[i], params$q[i]), mc.cores = 4)
