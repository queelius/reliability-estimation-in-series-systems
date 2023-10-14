## Methodology: Maximum Likelihood Estimation

**Maximum Likelihood Estimation (MLE)**: Maximize the log-likelihood function:
$$
\hat{\v\theta} = \arg\max_{\v\theta} \log L(\v\theta).
$$

**Solution**: Numerically solved system of equations for $\hat{\v\theta}$:
$$
\nabla_{\v\theta} \log L(\hat{\v\theta}) = \v{0}.
$$

\note{
\begin{itemize}
\item We use the standard \textbf{maximum likelihood} approach.
\item We find a parameter value that \textbf{maximizes} the likelihood function using numerical methods.
\end{itemize}
}


## Data Generation: Latent Lifetimes & Right-Censoring

**Latent Component Lifetimes**:
- Generated for each system in the study.

**Right-Censoring**:
- Objective: Ensure a specified proportion of systems fail before a given quantile $q$.
- Approach: Set the right-censoring time based on the quantile $q$ of the series system. The actual time $\tau$ then becomes a function of this chosen $q$.

**Satisfying Independence Assumption**:
- **Quantile Choice**: The chosen quantile value $q$ is determined independently for the simulation. By doing so, we ensure the independence of the derived right-censoring time $\tau$ from:
    1. Component lifetimes and system lifetime.
    2. System parameter vector $\theta$.

\note{
\begin{itemize}
\item \textbf{Data Generation}: We generate the latent component lifetimes for the series system we just discussed.
\item \textbf{Observed Data}: Then, we generate the data we actually see, which is based on the component data.
\item \textbf{Right-Censoring}: We control the probability of right-censoring by
finding the value of $\tau$ that satisfies the quantile $q$. Then, we set the
right-censoring time to be the minimum of the system lifetime and $\tau$. The
event indicator is 1 if the system fails before $\tau$, 0 otherwise.
\item \textbf{Masking}: We use a Bernoulli masking model to mask the component
cause of failure. We parameterize the level of masking by the masking probability, $p$.

\end{itemize}
}













## Bootstrap Method: Confidence Intervals

**Sampling Distribution of MLE**: Asymptotic normality is useful for
constructing confidence intervals.

  - **Issue**: May need large samples before asymptotic normality holds.

**Bootstrapped CIs**: Resample data and find an MLE for each. Use the
distribution of the bootstrapped MLEs to construct CIs.

- **Percentile Method**: Simple and intuitive.

**Correctly Specified CIs**: A coverage probability close to the nominal level of $95\%$.

  - **Issue**: Coverage probability may be too low or too high.

- **Adjustments**: To improve coverage probability, we use the BCa method to
  adjust for bias (bias correction) and skewness (acceleration) in the estimate.
  Coverage probabilities above $90\%$ acceptable.

\note{
\begin{itemize}
\item We need a way to measure the uncertainty in our estimates.
\item CIs are a popular choice. They help us pin down the likely range of values for our parameters.
\item We can use the sampling distribution of the MLE to construct confidence intervals.
\item But this requires large samples, which we don't always have.
\item We Bootstrap the CIs since there is likely to be a lot of bias and variability in our estimates due to the masking and censoring
in our small data sets.
\item The percentile method is simple and intuitive.
\item We want our CIs to be correctly specified, meaning they cover the true parameter value around 95% of the time.
\item But they may be too low or too high. A coverage probability above $90\%$ is acceptable.
\item We use the BCa method to adjust for bias and skewness in the estimate.
\end{itemize}

\note{
- Uncertainty quantification is essential.
- CIs define the probable range for parameters.
- The MLE's sampling distribution aids in CI construction but requires sizable samples.
- Bootstrapping helps with the challenges in small or biased datasets.
- The percentile method offers an easy route.
- CIs should ideally envelop the true value ~95% of the time.
- BCa adjusts for potential biases and deviations.
}


}




