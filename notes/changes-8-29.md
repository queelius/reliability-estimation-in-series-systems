# Change log

- Consolidated the reliability, hazard, and pdf for the Weibull series into a single theorem (Theorem 6.1).

- Updated the "Simulation Scenarios" section to better describe what I plan on doing in the simulation study, since I included
  a few more scenarios that weren't reflected in the description of the scenarios.

- Ran the simulations longer to produce more reliable results for each scenario. I then updated the plots and analysis to reflect
  the new results, using generally better visualizations.

- Refined the analysis of the simulation results. I now have a better understanding of the impacts of right-censoring on the MLE
  and the impacts of the MLE on the reliability function and hazard rate function. I've also added a new section, "8.4 Assessing
  the Impact of Right-Censoring", to describe the simulation study and the results.

- I include a likelihood ratio test to incorporate the Weibull Series Model (Weibull components with homogenous shape parameters).
  I did this as a simulation scenario, since I assess its performance in two ways: in the simlation scenario, I vary the
  shape parameter of component 3 and I vary the sample size, and then for each combination of shape parameter and sample size,
  I run over a 1000 simulations and record the median and 95% quantile of the p-value. I then plot the median and 95% quantile
  of the p-value as a function of the shape parameter and sample size and analyze the results.

  I do an additional test where I use the "well-designed series system" I base most of my simulation study on, and I vary the
  sample size to show when the likelihood ratio test rejects the null hypothesis of the homogenous shape parameter system
  (reduced model). I find that it takes extremely large samples to reject the null hypothesis. 