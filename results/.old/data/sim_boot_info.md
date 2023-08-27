# Weibull Series MLE Bootstrap 

This is a bootstrap experiment to estimate the sampling distrubion of the MLE using the bootstrap method. In
particualr, we bootstrap confidence intervals, and then we do this a number of times to estimate the
coverage probability and other statistics of the sampling distribution.

The lifetimes are generated from a Weibull series model.
The bootstrap is non-parametric, since we are assuming we do not know how to generate the masked component cause of failure
data (but in fact a semi-parametric bootstrap would also be interesting, where we use the empirical sample in 
some way to estimate candidate sets, which we assume can be modeled as a conditional relation `C_i | T_i, K_i` where
C_i is the candidate set, T_i is the system failure, and K_i is the component cause of failure of the series system).

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

    - `shape.j` is the MLE estimate of shape parameter j for component j.

    - `scale.j` is the MLE estimate of scale parameter j for component j.

    - `shape.lower.j` is the lower bound of the CI for shape parameter j.

    - `shape.upper.j` is the upper-bound of the CI for shape parameter j.

    - `scale.lower.j` is the lower bound of the CI for scale parameter j.

    - `scale.upper.j` is the upper bound of the CI for scale parameter j.

The true parameter value is `θ = (shape1, scale1, shape2, scale2, shape3, scale3, shape4, scale4, shape5, scale5)`, where:
```
           shape1 = 1.2576, scale1 = 994.3661,
           shape2 = 1.1635, scale2 = 908.9458,
           shape3 = 1.1308, scale3 = 840.1141,
           shape4 = 1.1802, scale4 = 940.1141,
           shape5 = 1.3311, scale5 = 836.1123.
```
Note that the scale parameters are 1000 times larger than the shape parameters, approximately.

The CSV data was generated from a simulation study of a series system with `m = 5` components, where we estimate the parameters of the system using MLE.
We Bootstrap the FIM to generate confidence intervals and other interesting statistics and properties, like bias and MSE.

Here are explanations of the columns:

The `shapej.mle` and `scalej.mle` columns (MLEs) are an *empirical* sampling distribution of the MLE and we treat this as the ground truth.
We can compute the bias of the MLE by taking the expectation with respect to empirical sampling distribution:
$$
    E_{\hat\theta \sim \text{data}}(\hat\theta) - \theta
$$
We can compute the variance of the MLE by taking the expectation with respect to empirical sampling distribution:
$$
    E_{\hat\theta \sim \text{data}}(\hat\theta) - \hat\theta
$$
We can compute the MSE of the MLE by taking the expectation with respect to empirical sampling distribution:
$$
    E_{\hat\theta \sim \text{data}}((\hat\theta) - \theta)^2
$$

Note that we specifically controlled, in our simulation setup, `n`, `p`, `q`. We will analyze the other statistics with respect to these simulation parameters, e.g., we can plot the variance:

- with respect to sample size `n`, with `p` and `q` fixed

- with respect to masking probability `p`, with `n` and `q` fixed. 

- with respect to quantile `q`, with `n` and `p` fixed.

Later, I will upload a different data file, one that includes Boostrapped confidence interval estimator, bootstrapped bias, bootstrapped variance, and bootstrapped MSE estimates. We will have these for smaller sample sizes, with the assumption being that for the larger samples, the asymptotic theory will suffice, so we seek to use the Bootstrapped estimates for cases when the asympototic theory doesn't kick in. We will be doing a similar analysis for it, and we compare the results with the asymptotic theory. We will identity where the there are issues with the estimator, such as potentially right censoring being problematic for the Bootstrap, since it may estimate the variance to be smaller than the actual (empirically computed) variance, resulting in confidence intervals that are poorly calibrated.

As data scientists, we will be doing a rigorous and comprehensive analysis of the MLE. Let's begin.

