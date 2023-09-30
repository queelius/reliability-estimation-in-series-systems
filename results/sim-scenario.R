library(tidyverse)
library(parallel)
library(boot)
library(stats)
library(algebraic.mle)
library(algebraic.dist)
library(md.tools)
library(wei.series.md.c1.c2.c3)

# The function 'simulate_scenario' conducts Monte Carlo simulations across various scenarios.
# It takes in a number of parameters including the file name to which results should be saved,
# parameters of the Weibull distribution, censoring probabilities, and others.
# This function is designed to assess the effect of masking probability on the sampling distribution of the MLE.

sim_scenario <- function(
    csv_file,            # File name to save the results
    N = c(90),           # Sample sizes to iterate over
    P = c(.215),         # Masking probability
    Q = c(.825),         # Quantile of the series system (fixed for the scenarios)
    R = 1000L,            # Number of simulation replicates
    B = 1000L,           # Bootstrap sample size
    max_iter = 125L,     # Maximum iterations for MLE estimation
    max_boot_iter = 125L,# Maximum iterations for bootstrap MLE estimation
    n_cores = 2,         # Number of cores to use for parallel computation
    ci_level = 0.95,     # Confidence interval level
    ci_method = "bca",   # Method to compute the bootstrap confidence interval
    theta = alex_weibull_series$theta # Parameters of the Series System
) {  
    shapes <- theta[seq(1, length(theta), 2)]
    scales <- theta[seq(2, length(theta), 2)]
    m <- length(scales)

    # Construct column names dynamically for the output CSV
    cname <- c("n", "p", "q", "tau", "B", paste0("shape.", 1:m),
               paste0("scale.", 1:m), paste0("shape.mle.", 1:m),
               paste0("scale.mle.", 1:m), paste0("shape.lower.", 1:m),
               paste0("shape.upper.", 1:m), paste0("scale.lower.", 1:m),
               paste0("scale.upper.", 1:m), "convergence", "loglik")    

    # Iterate over all combinations of N, P, and Q
    for (n in N) {
        for (p in P) {
            for (q in Q) {
                if (B < n) {
                    cat("[ info ] ", "B < n, using B = n\n")
                }
                # Calculate the right-censoring time of the scenario
                tau <- qwei_series(p = q, scales = scales, shapes = shapes)

                for (iter in 1:R) {
                    tryCatch({
                        # Generate the synthetic data
                        df <- generate_guo_weibull_table_2_data(
                            shapes = shapes, scales = scales, n = n, p = p, tau = tau)
                        # Estimate the MLE for the data
                        sol <- mle_lbfgsb_wei_series_md_c1_c2_c3(
                            theta0 = theta, df = df, hessian = FALSE,
                            control = list(maxit = max_iter, parscale = theta))
                        # Define a bootstrap MLE solver
                        mle_solver <- function(df, i) {
                            mle_lbfgsb_wei_series_md_c1_c2_c3(
                                theta0 = sol$par, df = df[i, ], hessian = FALSE,
                                control = list(maxit = max_boot_iter, parscale = sol$par))$par
                        }
                        # Perform bootstrap for the data
                        sol.boot <- boot::boot(df, mle_solver,
                            R = max(n, B), parallel = "multicore", ncpus = n_cores)
                        ci <- confint(mle_boot(sol.boot), type = ci_method, level = ci_level)
                        result <- c(n, p, q, tau, B, shapes, scales,
                                     sol$par[seq(1, length(theta), 2)],
                                     sol$par[seq(2, length(theta), 2)],
                                     ci[seq(1, length(theta), 2), 1],
                                     ci[seq(1, length(theta), 2), 2],
                                     ci[seq(2, length(theta), 2), 1],
                                     ci[seq(2, length(theta), 2), 2],
                                     sol$convergence, sol$value)
                        result_df <- setNames(data.frame(t(result)), cname)
                        # Write to the CSV file
                        write.table(result_df, file = csv_file, sep = ",", row.names = FALSE, 
                                    col.names = !file.exists(csv_file), append = TRUE)
                        cat("[ iteration ", iter, "]\n")
                        print(result_df)

                    }, error = function(e) {
                        cat("[ error ] ", conditionMessage(e), "\n")
                    })
                }
            }
        }
    }
}
