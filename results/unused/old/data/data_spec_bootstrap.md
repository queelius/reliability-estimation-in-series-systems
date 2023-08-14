# Weibull Series MLE Bootstrap Experiment

This is a bootstrap experiment to estimate the bias, variance, and MSE of the MLE of the Weibull series model.
The lifetimes are generated from a Weibull series model.
The bootstrap is non-parametric, since we are assuming we do not know how to generate the component cause of failure
data.

## Weibull series syste configuration

The true parameter value is `theta = (shape.1, scale.1, shape.2, scale.2, shape.3, scale.3, shape.4, scale.4, shape.5, scale.5)`, where:
```
           shape.1 = 1.2576, scale.1 = 994.3661,
           shape.2 = 1.1635, scale.2 = 908.9458,
           shape.3 = 1.1308, scale.3 = 840.1141,
           shape.4 = 1.1802, scale.4 = 940.1141,
           shape.5 = 1.3311, scale.5 = 836.1123.
```
Note that the scale parameters are 1000 times larger than the shape parameters, approximately.


## MC Experiment

The `mle.shape.j` and `mle.scale.j` columns represent the empirical sampling distribution of the MLE
for a specific simulation scenario (`n`, `p`, `q`). If there are a sufficient number of rows for a
simulation scenario, we can treat these as a reasonable approximation of the true sampling distribution,
assuming that the MLEs converged and otherwise the MLE process went according to plan.

If we have these conditions met, then we can compute properties of the MLE by taking the expectation with
respect to the empirical sampling distribution. For instance, the bias of `mle.shape.j` can be computed with:
```
    bias(mle.shape.j) = E(mle.shape.j) - shape.j
```
where `E` is the empirical expectation.

The CSV data was generated from a simulation study of a series system with `m = 5` components.

In this simulation, we specifically controlled `n`, `p`, `q`. We should assess the
performance of the MLE with respect to these parameters, e.g., we can plot the variance
with respect to any of the following:

(1) Sample size `n` with `p` and `q` fixed at specific known values.

(2) Masking probability `p` with `n` and `q` fixed at specific known values.

(3) Right-censoring quantile `q` with `n` and `p` fixed at specific known values.

## Explanation of column data in the associated CSV file

    - `n`: The sample size. The larger the sample, the more information available about the parameter `theta` we are using
           MLE method to estimate.
    - `p`: The candidate masking probability in our Bernoulli candidate set model. If the system is not right-censored,
           then we observe an exact system failure time but the component cause of the system failure is masked by a candidate set,
           in which the failed component is definitely in the candidate set, but each non-failed components will be in the candidate
           set with probability `p`. We don't know which of the components in the candidate set caused the failure, we only know that,
           one of the components in the candidate set is the cause.

           Cases: (1) If `p = 0`, then there is no masking and we know the precise component cause of failure.
                  (2) If `p = 1`, then all components are in the candidate set and we don't know anything about the
                      component cause of failure.
                  (3) Otherwise, the higher the masking probability `0 < p < 1`, the more masking of the component cause.

    - `q`: The right-censoring quantile.

           Cases: (1) If `q = 1` then no right censoring is taking place (`tau` is infinity).
                  (2) If `q = 0`, then every system is right censoreing (`tau` is 0).
                  (3) Otherwise, the lower the right-censoring quantile `0 < q < 1`, the higher the probability of
                      right-censoring, i.e., the higher the probability that a system failure will not be observed.

    - `tau`: The Weibull series time (parameterized by `theta`) that corresponds to quantle `q`.
    - `mle.shape.j.mle`: The MLE estimate of `shape.j` for component j.
    - `mle.scale.j.mle`: The MLE estimate of `scale.j` for component j.
    - `var.shape.j`: The estimated variance of `mle.shape.j` from the Bootstrap
    - `var.scale.j`: The estimated variance of `mle.scale.j` from Bootstrap
    - `boot_convergence_ratio`: The proportion of Bootstrapped MLEs that converged for a particular MLE
    - `coverages.shape.j`: Indicates whether the CI for `shape.j` contains `shape.j`.
    - `coverages.scale.j`: Indicates whether the CI for `scale.j` contains `scale.j`.
    - `lowers.shape.j`: The lower bound of the CI for `shape.j`.
    - `uppers.shape.j`: The upper-bound of the CI for `shape.j`.
    - `lowers.scale.j`: The lower bound of the CI for `scale.j`.
    - `uppers.scale.j`: The upper bound of the CI for `scale.j`.
    - `mse.shape.j`: The Bootstrapped MSE of `mleshape.j`.
    - `mse.shape.j`: The Bootstrapped MSE of `mle.shape.j`.
    - `bias.shape.j`: The Bootstrapped bias of `mle.shape.j`.
    - `bias.scale.j`: The Bootstrapped bias of `mle.scale.j`
    - `loglik`: The log-likelihood of the MLE evaluated on the (not shown) observed data.
    - `convergences`: Indicates whether the MLE converged (e.g., the stopping condition was met before reaching
                      the maximum number of iterations).

