---
title: "Reliability Estimation in Series Systems"
subtitle: "Maximum Likelihood Techniques for Right-Censored and Masked Failure Data"
author: Alex Towell
output: 
  powerpoint_presentation:
    keep_md: true
    slide_level: 2
  beamer_presentation:
    theme: Boadilla
    slide_level: 2
header-includes:
   - \usepackage{tikz}
   - \usepackage{caption}
   - \usepackage{amsthm}
   - \renewcommand{\v}[1]{\boldsymbol{#1}}
   - \theoremstyle{definition}
   - \newtheorem{condition}{Condition}
   - \theoremstyle{plain}
   - "\\setbeameroption{show notes on second screen=right}"
bibliography: ../refs.bib
link-citations: true
natbiboptions: "numbers"
csl: ../ieee-with-url.csl
---

# Introduction

## Context & Motivation
- Quantifying reliability in series systems is essential.
- Real-world systems often only provide system-level failure data.
  - Masked and right-censored data obscure reliability metrics.
- Need robust techniques to decipher this data and make accurate estimations.

## Core Contributions
- Derivation of likelihood model that accounts for right-censoring and masking.
  - Trivial to add more failure data via a likelihood contribution model.
  - R Library: [github.com/queelius/wei.series.md.c1.c2.c3](https://github.com/queelius/wei.series.md.c1.c2.c3)
- Clarification of the assumptions required for the likelihood model.
- Simulation studies with Weibull distributed component lifetimes.
  - Assess performance of MLE and BCa confidence intervals under various
    scenarios.

# Series System

\begin{figure}
\centering
\resizebox{0.7\textwidth}{!}{\input{../image/series.tex}}
\end{figure}

- **Main Concept**: If one component fails, the entire system fails.
\note{Remember the analogy: "A chain is only as strong as its weakest link."}

## Reliability Function

**Definition**: Probability a system/component works beyond time \( t \):
$$
R_X(x) = \Pr\{X > x\}.
$$

\note{High reliability = low failure probability. Used directly in likelihood models for right-censoring events.}

For series systems:
$$
R_{T_i}(t;\v\theta) = \prod_{j=1}^m R_j(t;\v{\theta_j}).
$$

\note{Core of many reliability analyses. Influences system design and maintenance decisions.}

## Hazard Function

**Definition**: Instantaneous failure rate, given survival to a time:
$$
h_X(x) = \frac{f_X(t)}{R_X(t)}.
$$

Characterizes failure risk over time:
- Rising: wear-out.
- Declining: defects.
- Constant: random events.

\note{Useful for guiding maintenance and interventions based on failure patterns.}

For series systems:
$$
h_{T_i}(t;\v{\theta}) = \sum_{j=1}^m h_j(t;\v{\theta_j}).
$$

## Component Cause of Failure

Defining \( K_i \) as the component causing the \( i^{th} \) system's failure:

Probabilities:
- Component \( j \) is the cause:
$$
\Pr\{K_i = j\} = E_{\v\theta} \left[ \frac{h_j(T_i;\v{\theta_j})} {h_{T_i}(T_i ; \v{\theta_l})} \right].
$$
- Given the system failed at time \( t \):
$$
\Pr\{K_i = j | T_i = t\} = \frac{h_j(t;\v{\theta_j})} {h_{T_i}(t ; \v{\theta_l})}.
$$
- Joint distribution:
$$
f_{K_i,T_i}(j,t;\v\theta) = h_j(t;\v{\theta_j}) R_{T_i}(t;\v\theta).
$$

\note{Critical for understanding masked failures in our likelihood model.}

## Well-Designed Series Systems

Key Points:
- MTTF is a measure of reliability but can be misleading.
- Components should have similar failure patterns.

\note{A well-designed series system has components with matching MTTFs and failure causes. The simulation study focuses on such systems.}

# Likelihood Model
We have our system model, but we don't observe component lifetimes. We observe
data related to component lifetimes.

### Observed Data
- Right censoring: No failure observed.
  - The experiment ended before the system failed.
    - $\tau$ is the right-censoring time.
    - $\delta_i = 0$ indicates right-censoring for system $i$.
- Masked causes
  - The system failed, but we don't know the component cause.
    - $S_i$ is the observed time of system failure.
    - $\delta_i = 1$ indicates system failure for system $i$.
    - $\mathcal{C}_i$ are a subset of components that could have caused failure.

## Observed Data Example
Observed data with a right-censoring time $\tau = 5$ for a series system with
$3$ components.

System | Right-censored lifetime | Event indicator | Candidate set  |
------ | ----------------------- | --------------- | -------------- |
   1   | $1.1$                   | 1               | $\{1,2\}$      |
   2   | $1.3$                   | 1               | $\{2\}$        |
   4   | $2.6$                   | 1               | $\{2,3\}$      |
   5   | $3.7$                   | 1               | $\{1,2,3\}$    |
   6   | $5$                     | 0               | $\emptyset$    |
   7   | $5$                     | 0               | $\emptyset$    |

## Data Generating Process
DGP is underlying process that generates observed data:

- Green elements are observed.
- Red elements are unobserved (latent).
- Candidate sets ($\mathcal{C}_i$) related to component lifetimes ($T_{i j})$
  and other (unknown) covariates.
  - Distribution of candidate sets complex. Seek a simple model valid under certain assumptions.

\begin{figure}
\centering
\resizebox{0.7\textwidth}{!}{\input{../image/dep_model.tex}}
\end{figure}

## Likelihood Function
### Assumptions
- Right-censoring time $\tau$ independent of component lifetimes and parameters:
\begin{align*}
S_i       &= \min(\tau, T_i),\\
\delta_i  &= 1_{\{T_i < \tau\}}.
\end{align*}
- Observed failure time with candidate sets. Candidate sets satisfy some
conditions (discussed later).

### Likelihood Contributions
  $$
  L_i(\v\theta) \propto
  \begin{cases}
      \prod_{l=1}^m R_l(s_i;\v{\theta_l})         &\text{ if } \delta_i = 0\\
      \prod_{l=1}^m R_l(s_i;\v{\theta_l})
          \sum_{j\in c_i} h_j(s_i;\v{\theta_j})   &\text{ if } \delta_i = 1.
  \end{cases}
  $$

## Derivation: Likelihood Contribution for Masked Failures

Masking occurs when a system fails but the precise failed component is ambiguous.
To make problem more tractable, we introduce certain conditions (which are reasonable
for many real-world systems).

### Conditions

1. **Candidate Set Contains Failed Component**:
The candidate set, $\mathcal{C}_i$, always includes the failed component:
    - $\Pr{}_{\!\v\theta}\{K_i \in \mathcal{C}_i\} = 1$.

2. **Equal Probabilities Across Candidate Sets**:
For an observed system failure time $T_i=t_i$ and a candidate set $\mathcal{C}_i = c_i$, the candidate set probability is constant across different component failure causes within the set:
    - $\Pr{}_{\!\v\theta}\{\mathcal{C}_i = c_i | K_i = j, T_i = t_i\} = \Pr{}_{\!\v\theta}\{\mathcal{C}_i = c_i | K_i = j', T_i = t_i\}$
  for every $j,j' \in c_i$.

3. **Masking Probabilities Independent of $\v{\theta}$**:
Masking probabilities, when conditioned on $T_i$ and failed component, aren't functions of $\v{\theta}$.

## Likelihood Contribution: Masked Component Cause of Failure

We construct the likelihood contribution for masked data like so:

- The joint distribution of $T_i$, $K_i$, and $\mathcal{C}_i$ is written as:
$$
f_{T_i,K_i,\mathcal{C}_i}(t_i,j,c_i;\v{\theta}) = f_{T_i,K_i}(t_i,j;\v{\theta})\Pr{}_{\!\v\theta}\{\mathcal{C}_i = c_i | T_i = t_i, K_i = j\}.
$$
- Marginalizing over $K_i$ and applying Conditions 1, 2, and 3 yields:
$$
f_{T_i,\mathcal{C}_i}(t_i,c_i;\v{\theta}) = \beta_i \prod_{l=1}^m R_l(t_i;\v{\theta_l}) \sum_{j \in c_i} h_j(t_i;\v{\theta_j}).
$$
- The likelihood contribution: $L_i(\v\theta) \propto f_{T_i,\mathcal{C}_i}(t_i,c_i;\v{\theta})$.

  - We do not need to model the distribution of the candidate sets.

## Methodology: Maximum Likelihood Estimation

**Maximum Likelihood Estimation (MLE)**: Maximize the likelihood function:
$$
\hat{\v\theta} = \arg\max_{\v\theta} L(\v\theta).
$$

**Log-likelihood**: Easier to work with and numerically more stable:
$$
\ell(\v\theta) = \sum_{i=1}^n \ell_i(\v\theta),
$$
where $\ell_i$ is the log-likelihood contribution for the $i$\textsuperscript{th} observation:
$$
\ell_i(\v\theta) = \sum_{j=1}^m \log R_j(s_i;\v{\theta_j}) +
    \delta_i \log \biggl(\sum_{j\in c_i} h_j(s_i;\v{\theta_j}) \biggr).
$$

**Solution**: Numerically solve the following system of equations for $\hat{\v\theta}$:
$$
\nabla_{\v\theta} \ell(\hat{\v\theta}) = \v{0}.
$$

## Bootstrap Method: Confidence Intervals

**Sampling Distribution of MLE**: Asymptotic normality is useful for
constructing confidence intervals.

  - **Issue**: May need large samples before asymptotic normality holds.

**Bootstrapped CIs**: Resample data and find an MLE for each. Use the
distribution of the bootstrapped MLEs to construct CIs.

- **Percentile Method**: Simple and intuitive.

- **Coverage Probability**: Probability that the confidence interval contains
  the true parameter value $\v\theta$.

**Correctly Specified CIs**: A coverage probability close to the nominal level of $95\%$.

- **Adjustments**: To improve coverage probability, we use the BCa method to
  adjust for bias (bias correction) and skewness (acceleration) in the estimate.
  Coverage probabilities above $90\%$ acceptable.

## Challenges with MLE on Masked Data

We discovered some challenges with the MLE on masked data.

**Convergence Issues**: Flat likelihood regions were observed due to the
  ambiguity in the masked data and small sample sizes.
  
**Bootstrap Issues**: Bootstrap relies on the Law of Large Numbers.

- Bootstrap might not represent the true variability, leading to inaccuracies.

- Due to right censoring and masking, the effective sample size is reduced.

**Mitigation**: We discard non-convergent samples for the MLE on original data,
but keep all resamples for the bootstrap.

- This ensures that the bootstrap for "good" data is representative of the
  variability in the original data.

- We report convergence rates in our simulation study.

# Series System with Weibull Component Lifetimes

The Weibull distribution has been crucial in reliability analysis due to its
versatility. In our study, we model a system's components using Weibull
distributed lifetimes.

- Introduced by Waloddi Weibull in 1937.

- Reflecting on its utility, Weibull modestly noted: "[...] may sometimes render good service."
  
## Weibull Distribution Characteristics

The lifetime distribution for the $j$\textsuperscript{th} component of the $i$\textsuperscript{th} system is:
$$
    T_{i j} \sim \operatorname{Weibull}(k_j,\lambda_j)
$$

Where:

- $\lambda_j > 0$ is the scale parameter.
- $k_j > 0$ is the shape parameter.

#### Significance of the Shape Parameter:

- $k_j < 1$: Indicates infant mortality. E.g., defective components weeded out early.
- $k_j = 1$: Indicates random failures. E.g., result of random shocks.
- $k_j > 1$: Indicates wear-out failures. E.g., components wearing out with age.

## Theoretical Results
Reliability and hazard functions of a series system with Weibull components:
\begin{align*}
R_{T_i}(t;\v\theta) &= \exp\biggl\{-\sum_{j=1}^{m}\biggl(\frac{t}{\lambda_j}\biggr)^{k_j}\biggr\},\\
h_{T_i}(t;\v\theta) &= \sum_{j=1}^{m} \frac{k_j}{\lambda_j}\biggl(\frac{t}{\lambda_j}\biggr)^{k_j-1},
\end{align*}
where $\v\theta = (k_1, \lambda_1, \ldots, k_m, \lambda_m)$ is the parameter vector of the series system.

### Likelihood Model
We deal with right censoring and masked component cause of failure. The
likelihood contribution of system $i$:
$$
L_i(\v\theta) \propto
\begin{cases}
    R_{T_i}(t_i;\v\theta) & \text{if } \delta_i = 0,\\
    R_{T_i}(t_i;\v\theta) \sum_{j \in c_i} h_j(t_i;\v{\theta_j}) & \text{if } \delta_i = 1.
\end{cases}
$$

# Simulation Study Overview

We conduct a simulation study based on a series system.

### System Description

This study is centered around the following *well-designed series system*:

| Component   | Shape | Scale | MTTF | $\Pr\{K_i\}$ |
|-------------|------------|----------|---------|-------|
| 1      | 1.26 | 994.37 | 924.87 | 0.17 | 0.74 |
| 2      | 1.16 | 908.95 | 862.16 | 0.21 | 0.70 |
| 3      | 1.13 | 840.11 | 803.56 | 0.23 | 0.67 |
| 4      | 1.18 | 940.13 | 888.24 | 0.20 | 0.71 |
| 5      | 1.20 | 923.16 | 867.75 | 0.20 | 0.71 |
| System | NA   | NA     | 222.88 | NA   | 0.18 |

## Performance Metrics

Our main objective is to evaluate the MLE and BCa confidence intervals'
performance across various scenarios.

- **MLE Evaluation**:
  - **Accuracy**: Proximity of the MLE's expected value to the actual value. 
  - **Precision**: Consistency of the MLE across samples.

- **BCa Confidence Intervals Evaluation**:
  - **Accuracy**: Ideally, Confidence Intervals (CIs) should encompass true parameters around $95\%$ of the time.
  - **Precision**: Assessed by the width of the CIs.
  
Both accuracy and precision are crucial for confidence in the analysis.

## Data Generation

We generate data for $n$ systems with $5$ components each.
We satisfy the assumptions of our likelihood model by generating data as follows:

- **Right-Censoring Model**: Right-censoring time set at a known value,
parameterized by the quantile $q$.

  - Satisfies the assumption that the right-censoring time is independent of
    component lifetimes and parameters.

- **Masking Model**: Using a *Bernoulli masking model* for component cause of failure,
parameterized by the probability $p$.

  - Satisfies masking Conditions 1, 2, and 3.

## Scenario: Impact of Right-Censoring

Vary the right-censoring quantile ($q$): $60\%$ to $100\%$.
Fixed the parameters: $p = 21.5\%$ and $n = 90$.

### Background
- **Right-Censoring**: No failure observed.
- **Impact**: Reduces the effective sample size.
- **MLE**: Bias and precision affected by censoring.

## Scale Parameters

\begin{figure}
\begin{minipage}{.5\textwidth}
![](../image/plot-q-vs-scale.1-mle.pdf){width=0.95\linewidth}
\end{minipage}%
\begin{minipage}{.5\textwidth}
![](../image/plot-q-vs-scale.3-mle.pdf){width=0.95\linewidth}
\end{minipage}
\end{figure}


- **Dispersion**: Less censoring improves MLE precision.
- **Bias**: Both parameters are biased. Bias decreases with less censoring.
- **Median-Aggregated CIs**: Bootstrapped CIs become consistent with more data.


## Shape Parameters

\begin{figure}
\begin{minipage}{.5\textwidth}
![](../image/plot-q-vs-shape.1-mle.pdf){width=0.95\linewidth}
\end{minipage}%
\begin{minipage}{.5\textwidth}
![](../image/plot-q-vs-shape.3-mle.pdf){width=0.95\linewidth}
\end{minipage}
\end{figure}

- **Dispersion**: Less censoring improves MLE precision.
- **Bias**: Both parameters are biased. Bias decreases with less censoring.
- **Median-Aggregated CIs**: Bootstrapped CIs become consistent with more data.

## Coverage Probability and Convergence Rate

\begin{figure}
\begin{minipage}{.5\textwidth}
![](../image/plot-q-vs-cp.pdf){width=0.95\linewidth}
\end{minipage}%
\begin{minipage}{.5\textwidth}
![](../image/q_vs_convergence.pdf){width=0.95\linewidth}
\end{minipage}
\end{figure}

- **Calibration**: CIs converge to $95\%$. Scale parameters better calibrated.
- **Convergence Rate**: Increases as right-censoring reduces.

## Conclusion
- MLE precision improves, bias drops with decreased right-censoring.
- BCa CIs perform well, particularly for scale parameters.
- MLE of most reliable component more affected by right-censoring.

## Impact of Masking Probability
Vary the masking probability $p$: $0.1$ to $0.7$.
Fixed the parameters: $q = 0.825$ and $n = 90$.

### Background
- **Masking** adds ambiguity in identifying the failed component.
- Impacts of masking on MLE:
  - **Ambiguity**: Higher $p$ increases uncertainty in parameter adjustment.
  - **Bias**: Similar to right-censoring, but affected by both $p$ and $q$.
  - **Precision**: Reduces as $p$ increases.

## Scale Parameters

\begin{figure}
\begin{minipage}{.5\textwidth}
![](../image/plot-p-vs-scale.1-mle.pdf){width=0.95\linewidth}
\end{minipage}%
\begin{minipage}{.5\textwidth}
![](../image/plot-p-vs-scale.3-mle.pdf){width=0.95\linewidth}
\end{minipage}
\end{figure}


- **Dispersion**: Increases with $p$, indicating reduced precision.
- **Bias**: Positive bias rises with $p$.
- **Median-Aggregated CIs**: Widen and show asymmetry as $p$ grows.


## Shape Parameters

\begin{figure}
\begin{minipage}{.5\textwidth}
![](../image/plot-p-vs-shape.1-mle.pdf){width=0.95\linewidth}
\end{minipage}%
\begin{minipage}{.5\textwidth}
![](../image/plot-p-vs-shape.3-mle.pdf){width=0.95\linewidth}
\end{minipage}
\end{figure}


- **Dispersion**: Increases with $p$, indicating reduced precision.
- **Bias**: Positive bias rises with $p$.
- **Median-Aggregated CIs**: Widen and show asymmetry as $p$ grows.


## Coverage Probability and Convergence Rate

\begin{figure}
\begin{minipage}{.45\textwidth}
![](../image/plot-p-vs-cp.pdf){width=0.95\linewidth}
\end{minipage}%
\begin{minipage}{.45\textwidth}
![](../image/p_vs_convergence.pdf){width=0.95\linewidth}
\end{minipage}
\end{figure}


**Calibration**: Caution advised for severe masking with small samples.

- Scale parameters maintain coverage up to $p = 0.7$.

- Shape parameters drop below $90\%$ after $p = 0.4$.

**Convergence Rate**: Reduces after $p > 0.4$, consistent with CP behavior.


## Conclusion
- Masking influences MLE precision, coverage probability, and introduces bias.
- Despite significant masking, scale parameters have commendable CI coverage.

## Impact of Sample Size
Assess the impact of sample size on MLEs and BCa CIs.

- Vary sample size $n$: $50$ to $500$
- Parameters: $p = 0.215$, $q = 0.825$

### Background
- **Sample Size**: Number of systems observed.
- **Impact**: More data reduces uncertainty in parameter estimation.
- **MLE**: Mitigates biasing effects of right-censoring and masking.

## Both Scale and Shape Parameters

\begin{figure}
\begin{minipage}{.375\textwidth}
![](../image/plot-n-vs-scale.1-mle.pdf){width=0.95\linewidth}
\end{minipage}%
\begin{minipage}{.375\textwidth}
![](../image/plot-n-vs-scale.3-mle.pdf){width=0.95\linewidth}
\end{minipage}
\begin{minipage}{.375\textwidth}
![](../image/plot-n-vs-shape.1-mle.pdf){width=0.95\linewidth}
\end{minipage}%
\begin{minipage}{.375\textwidth}
![](../image/plot-n-vs-shape.3-mle.pdf){width=0.95\linewidth}
\end{minipage}
\end{figure}

## Parameters

- **Dispersion**:
  - Dispersion reduces with $n$—indicating improved precision.
  - Disparity observed between components $k_1, \lambda_1$ and $k_3, \lambda_3$.
- **Bias**:
  - High positive bias initially, but diminishes around $n=250$.
  - Enough sample data can counteract right-censoring and masking effects.

- **Median-Aggregated CIs**:
  - CIs tighten as $n$ grows—showing more consistency.
  - Upper bound more dispersed than lower, reflecting the MLE bias direction.


## Coverage Probability and Convergence Rate

\begin{figure}
\begin{minipage}{.4\textwidth}
![](../image/plot-n-vs-cp.pdf){width=0.95\linewidth}
\end{minipage}%
\begin{minipage}{.4\textwidth}
![](../image/n_vs_convergence.pdf){width=0.95\linewidth}
\end{minipage}
\end{figure}

- **Calibration**: 
  - CIs are mostly above $90\%$ across sample sizes.
  - Converge to $95\%$ as $n$ grows.
  - Scale parameters have better coverage than shape.

- **Convergence Rate**:
  - Improves with $n$, surpassing $95\%$ for $n \geq 100$.
  - Caution for estimates with $n < 100$ in specific setups.

## Conclusion
- Sample size significantly mitigates challenges from right-censoring and masking.
- MLE precision and accuracy enhance notably with growing samples.
- BCa CIs become narrower and more reliable as sample size increases.

# Conclusion

## Part 1

### Key Findings
- Employed maximum likelihood techniques for component reliability estimation in series systems with masked failure data.
- Methods performed robustly despite masking and right-censoring challenges.

### Simulation Insights
- Right-censoring and masking introduce positive bias; more reliable components are most affected.
- Shape parameters harder to estimate than scale.
- Large samples can counteract these challenges.

## Part 2

### Confidence Intervals
- Bootstrapped BCa CIs demonstrated commendable coverage probabilities, even in smaller sample sizes.
  
### Takeaways
- Framework offers a rigorous method for latent component property estimation from limited observational data.
- Techniques validated to provide practical insights in diverse scenarios.
- Enhanced capability for learning from obscured system failure data.

# Discussion
