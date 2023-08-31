# Change log

- Addressed each of the comments Dr. Agustin gave me on the draft paper.

- Consolidated the reliability, hazard, and pdf for the Weibull series into a single theorem (Theorem 6.1).

- Added the Theorem for Pr{K_i = j | T_i = t_i} to the paper because I reference it in the simplified Weibull series model
  with homogenous shape parameters when deriving the result that Pr{K_i = j} = Pr{K_i = j | T_i = t_i}.
  Note that I actually derived the result for Pr{K_i = j | T_i = t_i, C_i = c} and then showed that it reduces to
  Pr{K_i = j | T_i = t_i} when c = {1, ..., m}. However, the result for Pr{K_i = j | T_i = t_i} is much easier to
  derive, and does not depend on any of the assumptions for candidate sets, so this may not be the best approach.
  I did it this way so that you can view it to determine if you think it is appropriate to include in the paper,
  otherwise I'll just add the direct proof for Pr{K_i = j | T_i = t_i}.

- Updated the "Simulation Scenarios" section to better describe what I plan on doing in the simulation study, since I included
  a few more scenarios that weren't reflected in the description of the scenarios.

- Ran the simulations longer to produce more reliable results for each scenario. I then updated the plots and analysis to reflect
  the new results, using generally better visualizations.

- Refined the analysis of the simulation results. I now have a better understanding of the impacts of right-censoring on the MLE
  and the impacts of the MLE on the reliability function and hazard rate function. I've also added a new section, "8.4 Assessing
  the Impact of Right-Censoring", to describe the simulation study and the results.

- I include a new simulation study: "# Simulation Study: Full Weibull Model vs Reduced (Homogenous Shape) Model", which investigates
  when it is apporopriate to use the reduced model vs the full model. We use the likelihood ratio test to assess where the
  data is compatible with the reduced model, by doing a simulation study that simultaenously varies the shape parameter of
  component 3 and the sample size. I find that it takes extremely large samples to reject the null hypothesis of the reduced
  for reasonably well-designed systems (the shape can vary somewhat from the baseline in the well-designed system).
  
  I do an additional test where I use the "well-designed series system" I base most of my simulation studies on, and I only
  vary the sample size to show when the likelihood ratio test tends to reject the null hypothesis of the reduced homogenous
  shape model. I find that it takes extremely large samples to reject the null hypothesis. I discuss the implications of this
  result in that section.

- I rewrote the "Introduction" to better motivate the paper and the simulation study. It is now up-to-date with the rest of the
  paper.

- I added a "Conclusion" section to summarize the paper and the simulation studies and discuss the implications of the
  simulation study results.

- I added a "Future Work" section.

- TODO: I added more citations. 

