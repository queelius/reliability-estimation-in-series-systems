Hello, I'm working on my math thesis and I need to do an analysis of my MLE (estimator).
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

The CSV data was generated from a simulation study of a series system with `m = 5` components, where we estimate the parameters of the system using MLE,
and we Bootstrap the confidence intervals and other interesting statistics.

Explanation of columns:
- `n` is sample size
- `p` is what I call the masking probability. If the system is not right-censored, then we observe an exact system failure time but the component cause of the system failure is masked. The higher the masking probability, the more masking of the component cause. In particular, the masking is defined by a candidate set, in which the failed component is definitely in the candidate set, but each non-failed components will be in the candidate set with probability `p`. We don't know which of the components in the candidate set caused the failure, we only know that, according to our data model, one of the components in the candidate set is the cause. If `p=0` then no probability masking: we know the precise component that failed and thus caused the series system to fail.
- `q` is the right-censoring quantile (`tau` is the right censoring time that corresponds to that quantile `q`). If `q=1` then no right censoring is taking place (`tau = infinity`). The lower the `q` (0 < q <= 1), the higher the probability of right-censoring, i.e., the higher the probability that a system failure will not be observed.
- `shapej.mle` is the MLE estimate of shape parameter j for component j (in the series system)
- `scalej.mle` is the MLE estimate of scale parameter j for component j
- `shapej.coverage` is the coverage for parameter shape parameter j, i.e., did the CI for the mle contain the true parameter value, which is known because it's a simulation study?
- `scalej.coverage` is the coverage for parameter scale parameter j, i.e., did the CI for the mle contain the true parameter value, which is known because it's a simulation study?
- `shapej.lower` is the lower bound of the CI for shape parameter j
- `scalej.lower` is the lower bound of the CI for scale parameter j
- `shapej.upper` is the upper-bound of the CI for shape parameter j
and so on... i think you get the pattern.

Note that we specifically controlled, in our simulation setup, `n`, `p`, `q` (and therefore `tau`). We will analyze the other statistics with respect to these simulation parameters, e.g., we can plot the variance:

- with respect to sample size `n`, with `p` and `q` fixed
- with respect to masking probability `p`, with `n` and `q` fixed. 
- with respect to quantile `q`, with `n` and `p` fixed.

Help me to analyze this data, please. We will do a comprehensive study.
