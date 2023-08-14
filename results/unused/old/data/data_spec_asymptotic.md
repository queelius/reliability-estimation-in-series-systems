# Weibull Series MLE Asymptotic Experiment

This is an asymptotic experiment to assess the performance of the estimate for the variances and confidence
intervals of the MLE using the the observed FIM.

The lifetimes are generated from a Weibull series model.

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

    - `shapej.mle`: The MLE of `shapej` for the `j`-th component in the series system.

    - `scalej.mle`: The MLE of `scalej` for the `j`-th component in the series system.

    - `shapej.var`: The estimated variance of `shapej.mle` from the FIM.

    - `scalej.var`: The estimated variance of `scalej.mle` from the FIM.

    - `convergences`: Indicates whether the MLE converged (stopping condition was met before `max_iter`).

    - `shapej.coverage`: Indicates whether the CI contains true value of `shapej`.

    - `scalej.coverage`: Indicates whether the CI contains true value of `scalej`.

    - `shapej.lower`: The lower-bound of the 95% CI for `shapej`.

    - `shapej.upper`: The upper-bound of the 95% CI for `shapej`.

    - `scalej.lower`: The upper-bound of the 95% CI for `scalej`.

    - `scalej.upper`: The upper-bound of the 95% CI for `scalej`.

## MC Experiment

The `shapej.mle` and `scalej.mle` columns (MLEs) represent the empirical sampling distribution of the MLE
for a specific simulation scenario (`n`, `p`, `q`). If there are a sufficient number of rows for a
simulation scenario, we can treat these as a reasonable approximation of the true sampling distribution,
assuming that the MLEs converged and otherwise the MLE process went according to plan.

If we have these conditions met, then we can compute properties of the MLE by taking the expectation with
respect to the empirical sampling distribution. For instance, the bias of `shapej.mle` can be computed with:
```
    shapej.bias = E(shapej.mle) - shapej
```
where `E` is the empirical expectation.


The true parameter values are:
```
           shape1 = 1.2576, scale1 = 994.3661,
           shape2 = 1.1635, scale2 = 908.9458,
           shape3 = 1.1308, scale3 = 840.1141,
           shape4 = 1.1802, scale4 = 940.1141,
           shape5 = 1.3311, scale5 = 836.1123.
```
Note that the scale parameters are 1000 times larger than the shape parameters.

The CSV data was generated from a simulation study of a series system with `m = 5` components.

In this simulation, we specifically controlled `n`, `p`, `q`. We should assess the
performance of the MLE with respect to these parameters, e.g., we can plot the variance
with respect to any of the following:

(1) Sample size `n` with `p` and `q` fixed at specific known values.

(2) Masking probability `p` with `n` and `q` fixed at specific known values.

(3) Right-censoring quantile `q` with `n` and `p` fixed at specific known values.
