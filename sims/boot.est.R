library(tidyverse)
library(parallel)
library(boot)
library(stats)
library(algebraic.mle)
library(algebraic.dist)
library(md.tools)
library(wei.series.md.c1.c2.c3)

theta <- c(shape1 = 1.2576, scale1 = 994.3661,
           shape2 = 1.1635, scale2 = 908.9458,
           shape3 = 1.1308, scale3 = 840.1141,
           shape4 = 1.1802, scale4 = 940.1141,
           shape5 = 1.3311, scale5 = 836.1123)

shapes <- theta[seq(1, length(theta), 2)]
scales <- theta[seq(2, length(theta), 2)]
parscale <- c(1, 1000, 1, 1000, 1, 1000, 1, 1000, 1, 1000)
stopifnot(length(parscale) == length(theta))
options(digits = 5, scipen = 999)

# for the main MC MLE
mc_require_convergence <- TRUE
n_cores <- detectCores() - 1

# N <- c(
#     35, 50, 75,
#     35, 50, 75,
#     35, 50, 75,
#     35, 50, 75,
#     35, 50, 75,
#     35, 50, 75,
#     35, 50, 75
# )
#P <- c(0, .25, .5, .25, .5, .25, .75, .25, .5, 0, .25, .75, .75)
#Q <- c(1, .75, .5, .25, .75, .75, .5, .75)
#R <- 1
#B <- 1000

N <- 50
P <- 0
Q <- 1
R <- 3
B <- 10

max_iter <- 500L
max_boot_iter <- 500L
file_out <- "data-boot-est-1"
csv_out <- paste0(file_out, ".csv")
meta_out <- paste0(file_out, ".md")
if (file.exists(csv_out)) {
    cat("A CSV file about a previous experiment by the same name already exists: ", csv_out, "\n")
    return()
}
if (file.exists(meta_out)) {
    cat("A meta-data file about a previous experiment already exists: ", meta_out, "\n")
    return()    
}

# write the above sim params to meta-data file as
# a markdown file explaining what the associated
# CSV file contains
# Grab the first part from `data-spec-bootstrap.md` file, which explains the parameters and the data model.
# The second part is the simulation parameters.

#data_spec <- readLines("data_spec_bootstrap.md")
sim_params <- paste0(
    "## Simulation parameters\n",
    "    - Shape parameters (shape): ", shapes, "\n",
    "    - Scale parameters (scale): ", scales, "\n",
    "    - Bootstrap replications (B): ", B, "\n",
    "    - Maximum iterations to find the MLE for a particular Monte-carlo experiment (max_iter): ", max_iter, "\n",
    "    - Maximum iterations to find the MLE for a particular bootstrap replication (max_boot_iter): ", max_boot_iter, "\n",
    "    - Number of Monte-carlo experiments per simulation scenario in {N, P, Q} (R): ", R, "\n",
    "## Simulation Scenarios\n",
    "    - Sample sizes (n): ", N, "\n",
    "    - P: ", P, "\n",
    "Q: ", Q, "\n",
    "Cores: ", n_cores, "\n")
cat(sim_params, "\n")
# write both to the meta-data file
#writeLines(c(data_spec, sim_params), meta_out)
options(digits = 3)

for (n in N) {
    for (p in P) {
        for (q in Q) {
            iter <- 1L
            repeat {
                cat("[START] Scenario(n: ", n, ", p: ", p, ", q: ", q, ")\n")
                tau <- wei.series.md.c1.c2.c3::qwei_series(
                    p = q, scales = scales, shapes = shapes)

                retry <- FALSE
                tryCatch({
                    df <- wei.series.md.c1.c2.c3::generate_guo_weibull_table_2_data(
                        shapes = shapes, scales = scales, n = n, p = p, tau = tau)

                    sol <- NULL
                    repeat {
                        sol <- mle_lbfgsb_wei_series_md_c1_c2_c3(
                            theta0 = theta, df = df, hessian = TRUE,
                            control = list(maxit = max_iter, parscale = parscale))
                        if (sol$convergence == 0 && mc_require_convergence) {
                            break
                        }
                        cat("[WARNING] ", sol$par, " : did not converge in empirical replication. (", iter, "/", R, ", retries = ", retries, ").\n")
                    }

                    boot.iter <- 1L
                    boot.convergences <- 0L
                    mle_solver <- function(df, i) {
                        solb <- mle_lbfgsb_wei_series_md_c1_c2_c3(
                            theta0 = sol$par, df = df[i, ], hessian = FALSE,
                            control = list(maxit = max_boot_iter, parscale = parscale))
                        if (solb$convergence != 0) {
                            cat("[WARNING] ", sol$par, " : did not converge in bootstrap replication. (", boot.iter, "/", B, ")\n")
                        } else {
                            boot.convergences <<- boot.convergences + 1L
                        }
                        boot.iter <<- boot.iter + 1L
                        solb$par
                    }

                    # do the non-parametric bootstrap
                    sol.bootstrap <- boot::boot(df, mle_solver,
                        R = B, parallel = "multicore", ncpus = n_cores)

                    sol.boot <- mle_boot(sol.bootstrap)
                    d.boot <- empirical_dist(sol.boot$t)
                    bias.boot <- expectation(d.boot, function(x) { x - params(sol.boot) })
                    var.boot <- expectation(d.boot, function(x) { (x - mean(d.boot))^2 })
                    mse.boot <- expectation(d.boot, function(x) { (x - params(sol.boot))^2 })
                    ci.boot <- confint(sol.boot)
                    covers.boot <- ci.boot[, 1] <= theta & theta <= ci.boot[, 2]

                    sol.fim <- mle_numerical(sol)
                    ci.fim <- confint(sol.fim, use_t_dist = FALSE)
                    covers.fim <- ci.fim[, 1] <= theta & theta <= ci.fim[, 2]
                    var.fim <- diag(vcov(sol.fim))
                }, error = function(e) {
                    cat("[ERROR] ", conditionMessage(e), "\n")
                    retry <- TRUE
                })

                if (retry) {
                    cat("[WARNING: ", iter, "/", R, "] Unable to generate data for iteration of Scenario(n: ", n, ", p: ", p, ", q: ", q, ")\n")
                    next
                }

                result <- list(
                    n = n,
                    p = p,
                    q = q,
                    tau = tau,
                    B = B,
                    mle = sol$par,
                    covers.boot = covers.boot,
                    lower.boot = ci.boot[, 1],
                    upper.boot = ci.boot[, 2],
                    bias = bias.boot,
                    var.boot = var.boot,
                    mse.boot = mse.boot,
                    var.fim = var.fim,
                    covers.fim = covers.fim,
                    lower.fim = ci.fim[, 1],
                    upper.fim = ci.fim[, 2],
                    loglik = sol$value,
                    convergence = sol$convergence,
                    boot_convergence_ratio = boot.convergences / B)

                # write `result` list as a row in a CSV file. there will be many such rows
                # in the CSV file, one for each iteration of the simulation. `iter`
                # doesn't determine it, that's just the number of iterations per
                # simulation scenario
                # the list is complex, so we must flatten it first. we can't lose the labels
                # in the list `result` though, we use them as prefixes for the column names
                # in the CSV file

                for (key in names(result)) {
                    cat(key, "\n")
                    cat(result[[key]], "\n")
                }
                
                

                # let's making writing to the file an atomic operation, since other threads
                # might be writing to the same file.
                #lock <- file(description = csv_out, open = "a")
                # let's append to the file if it exists, otherwise create it
                #if (file.info(csv_out)$size == 0) {
                #    write.table(result, file = lock, row.names = FALSE, sep = ",")
                #} else {
                #    write.table(result, file = lock, row.names = FALSE, sep = ",", append = TRUE,
                #                col.names = FALSE)
                #}
                #close(lock)
                cat("[INFO: ", iter, "/", R, "] Scenario(n: ", n, ", p: ", p, ", q: ", q, ") written.\n")            
                if (iter == R) {
                    cat("[END] Scenario(n: ", n, ", p: ", p, ", q: ", q, ")\n")
                    break
                }
                iter <- iter + 1L
            }
        }
    }
}

