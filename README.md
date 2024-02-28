---
title: "Reliability Estimation in Series Systems"
subtitle: "Maximum Likelihood Techniques for Right-Censored and Masked Failure Data"
author: Alex Towell (lex@metafunctor.com)
abstract: "This paper investigates maximum likelihood techniques to estimate component reliability from masked failure data in series systems. A likelihood model accounts for right-censoring and candidate sets indicative of masked failure causes. Extensive simulation studies assess the accuracy and precision of maximum likelihood estimates under varying sample size, masking probability, and right-censoring time for components with Weibull lifetimes. The studies specifically examine the accuracy and precision of estimates, along with the coverage probability and width of BCa confidence intervals. Despite significant masking and censoring, the maximum likelihood estimator demonstrates good overall performance. The bootstrap yields correctly specified confidence intervals even for small sample sizes. Together, the modeling framework and simulation studies provide rigorous validation of statistical learning from masked reliability data."
keywords: "reliability, series systems, maximum likelihood estimation, right-censoring, masked failure data, Weibull distribution, bootstrap confidence intervals"
date: "2023-09-30"
marp: true
theme: default
math: mathjax
---

## Reliability Estimation in Series Systems: Maximum Likelihood Techniques for Right-Censored and Masked Failure Data

Alex Towell
Email: [lex@metafunctor.com](mailto:lex@metafunctor.com)
GitHub: [github.com/queelius](https://github.com/queelius)

---
## Context & Motivation

**Reliability** in **Series Systems** is like a chain's strength -- determined
by its weakest link.

- Essential for system design and maintenance.
 
**Main Goal**: Estimate individual component reliability from *failure data*.

**Challenges**:

- *Masked* component-level failure data.
- *Right-censoring* system-level failure data.

**Our Response**:

- Derive techniques to interpret such ambiguous data.
- Aim for precise and accurate reliability estimates for individual components
  using maximum likelihood estimation (MLE)
- Quantify uncertainty in estimates with bootstrap confidence intervals (CIs).

---
## Core Contributions

**Likelihood Model** for **Series Systems**.

- Accounts for *right-censoring* and *masked component failure*.

**Specifications of Conditions**:

- Assumptions about the masking of component failures.
- Simplifies and makes the model more tractable.

**Simulation Studies**:

- Components with *Weibull* lifetimes.
- Evaluate MLE and confidence intervals under different scenarios.

**R Library**: Methods available on GitHub.

- See: [www.github.com/queelius/wei.series.md.c1.c2.c3](https://github.com/queelius/wei.series.md.c1.c2.c3)
