In the simulation study, we have generated many different synthetic samples of different sizes from a DGP that is compatible with the assumptions our likelihood model makes about the data.
In particular, right-censored series system lifetimes with a fixed right-censoring time for the system and five components with Weibull lifetimes, each with a different shape and scale parameter.
For each observation, we then mask the component cause of failure with candidate sets that satisfy the three primary conditions of the likelihood model, e.g., the failed component is always in the
candidate set.

For each synthetic data set, we then compute the MLEs of the shape and scale parameters of the Weibull distribution. We then use the MLEs to compute the bootstrapped CIs. The following figure shows the distribution of the MLEs and the bootstrapped CIs for different sample sizes.

*Confidence Band* of the MLEs: The blue shaded region represents the range where 95% of the MLEs fall. This is not exactly a confidence interval but is more like a 95% quantile range representing the dispersion of MLEs.

*IQR of Bootstrapped CIs*: The vertical blue bars represent the Interquartile Range (IQR) of the actual bootstrapped Confidence Intervals (CIs). Since in practice we only have one sample and consequently one MLE, we use bootstrapping to resample and compute multiple CIs. The IQR then represents the middle 50% range of these bootstrapped CIs.

For each sample size $n$, we also show:

    - The *coverage probability* (CP) of the bootstrapped CIs. The CP is the proportion of the bootstrapped CIs that contain the true value of the scale parameter.
      The CP is a good indicator of the reliability of the estimates as previously discussed.

    - Mean of the MLEs. The mean of the MLEs is a good indicator of the bias in the estimates. If the mean of the MLEs is close to the true value, then the MLEs are, on average, unbiased.

The distinction between the shaded region (95% range of MLEs) and the blue vertical bars (IQR of bootstrapped CIs) is important. The shaded region provides insight into the distribution of the MLEs, whereas the blue vertical bars provide information about the variation in the bootstrapped CIs. Both are relevant for understanding the behavior of the estimations.

Here are a few key observations:

- *Coverage Probability (CP)*: The CP is well-calibrated, obtaining a value near the 95% probability level high across different sample sizes. This suggests that the bootstrapped CIs will contain the true value of the shape parameter with the specified confidence level. The CIs are neither too wide nor too narrow.

- *Dispersion of MLEs*: The shaded regions representing the 95% probability range of the MLEs get narrower as the sample size increases. This is an indicator of the increased precision in the estimates as more data is available. 

- *IQR of Bootstrapped CIs*: The IQR (vertical blue bars) reduces with an increase in sample size. This suggests that the bootstrapped CIs are getting more consistent and focused around a narrower range with larger samples while maintaining a good coverage probability. As we get more data, the bootstrapped CIs are more likely to be closer to each other and the true value of the scale parameter.

- *Mean of MLEs*: The red dashed line indicating the mean of MLEs remains stable across different sample sizes and close to the true value, suggesting that the MLEs are, on average, reasonably unbiased.

Effect of p Value: As mentioned earlier, it would be interesting to observe how changes in the value of p would affect these distributions.

