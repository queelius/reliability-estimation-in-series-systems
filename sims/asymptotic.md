Hello, I'm working on my statistics thesis and I need to do an analysis of my maximum likelihood estimator.
I want to analyze the performance, robustness, and sensitivity of my MLE.
I already have the likelihood model for the data and some code to solve the MLE,
and now I'm doing a simulation study. I uploaded a CSV file that my simulation code generated.

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
We use the inverse of the FIM to generate confidence intervals and other interesting statistics. 

Here are explanations of the columns:

- `n` is sample size

- `p` is what I call the masking probability. If the system is not right-censored, then we observe an exact system failure time but the component cause of the system failure is masked. The higher the masking probability, the more masking of the component cause. In particular, the masking is defined by a candidate set, in which the failed component is definitely in the candidate set, but each non-failed components will be in the candidate set with probability `p`. We don't know which of the components in the candidate set caused the failure, we only know that, according to our data model, one of the components in the candidate set is the cause. If `p=0` then no probability masking: we know the precise component that failed and thus caused the series system to fail.

- `q` is the right-censoring quantile. If `q=1` then no right censoring is taking place (`tau = infinity`). The lower the `q` (0 < q <= 1), the higher the probability of right-censoring, i.e., the higher the probability that a system failure will not be observed.

- `tau` is the lifespan that corresponds to `q`

- `shapej.mle` is the MLE estimate of shape parameter j for component j.

- `scalej.mle` is the MLE estimate of scale parameter j for component j.

- `shapej.var` is the estimated variance of `shapej.mle` from the asymptotic theory (using information in the diagonal of the inverse of the FIM).

- `scalej.var` is the estimated variance of `scalej.mle` from the asymptotic theory (using information in the diagonal of the inverse of the FIM).

- `convergences` indicates whether the MLE converged (e.g., the stopping condition was met before reaching the maximum number of iterations).

- `shapej.coverage` is the coverage for shape parameter j, i.e., indicates whether the CI for shape parameter j contains shape parameter j.

- `scalej.coverage` is the coverage for scale parameter j, i.e., indicates whether the CI for scale parameter j contains scale parameter j.

- `shapej.lower` is the lower bound of the CI for shape parameter j.

- `shapej.upper` is the upper-bound of the CI for shape parameter j.

- `scalej.lower` is the lower bound of the CI for scale parameter j.

- `scalej.upper` is the upper bound of the CI for scale parameter j.

The `shapej.mle` and `scalej.mle` columns (MLEs) are an *empirical* sampling distribution of the MLE and we treat this as the ground truth. For instance, we can compute the bias of the MLE by taking
the expectation with respect to empirical sampling distribution,

$$
    E_{\hat\theta \sim \text{data}}(\hat\theta) - \theta
$$

Note that we specifically controlled, in our simulation setup, `n`, `p`, `q`. We will analyze the other statistics with respect to these simulation parameters, e.g., we can plot the variance:

- with respect to sample size `n`, with `p` and `q` fixed

- with respect to masking probability `p`, with `n` and `q` fixed. 

- with respect to quantile `q`, with `n` and `p` fixed.

Later, I will upload a different data file, one that includes Boostrapped confidence interval estimator, bootstrapped bias, bootstrapped variance, and bootstrapped MSE estimates. We will have these for smaller sample sizes, with the assumption being that for the larger samples, the asymptotic theory will suffice, so we seek to use the Bootstrapped estimates for cases when the asympototic theory doesn't kick in. We will be doing a similar analysis for it, and we compare the results with the asymptotic theory. We will identity where the there are issues with the estimator, such as potentially right censoring being problematic for the Bootstrap, since it may estimate the variance to be smaller than the actual (empirically computed) variance, resulting in confidence intervals that are poorly calibrated.

As data scientists, we will be doing a rigorous and comprehensive analysis of the MLE. Let's begin.