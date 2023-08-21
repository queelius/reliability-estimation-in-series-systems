## changes log

- reorganized section on MLE convergence issues. it is now beginning to discuss a sensitivity analysis. i should
  make a note elsewhere about convergence issues in general, or keep it here, and then also mention that
  i use 125 iteration limit as a catch-all for potential convergence and identifiability issues (flat likelihood)

- created a new section "Special Case: Series System That Is Weibull".
  provided some new material on weibull components in series configuration yielding a weibull system when shapes are approximately the same. in this case, some interesting results: Pr(K_i = j|T_i = t_i) = Pr(K_i = j).
  I'm not sure we want to keep this section, but is interesting and I put it there for your review, since
  you had mentioned that you wanted to see if and when the series system is Weibull.

- created a new section "System and Component Reliabilities" under the "Series System Model" (section 2) that
  takes a deeper dive into the concept of reliability, MTTF, and some issues with it. Then, i discuss the
  components and how a well-designed system should have components with similar reliabilities, and provide
  a brief discussion on how i use these insights in my simulation study to assess the sensitivity the MLE
  has to varying the reliability of a single component. I think this is a good place for this material, and brings these
  ideas to the forefront, instead of burying them in the simulation section.

- Added a description in the Simulation Study subection "Right-Censoring Model" to describe
  how I generate the 82.5% quantile of the series system, with corresponding R code in a new Appendix
  section, "Appendix E: Series Quantile Function".

- filled out the table for the base series system, with the parameters chosen based off the Guo data,
  for a 5-component system. I added new columns for P(K_i = j) and R_j(tau), in preparation for
  a more nuanced discussion on how the MLE is impacted by varying shape and scale of a single component.
  I have removed parts of my previous analysis from the paper for now, while I work on correcting it
  and simplifying the presentation.

- fixed up my language regarding the interpretation of the shape and scale parameters of the Weibull.

- removed the flat likelhood graphs and in-depth discussion.

- removed data augmentation section.

- fixed Bain references/citation (i think), also added more citations for things like how the MTTF can be misleading and
  MLE convergence issues.

- fixed notation to consistently use R_{T_i} and h_{T_i} everywhere. 

- TODO: i think i wrote things like "mean value of the bias" or something like that, which needs to be fixed.
  i think it's written like that because i had been ESTIMATING the bias using the bootstrap for each
  MLE, and in my prev analysis i was taking the mean of all of these bootstrapped bias estimates to see
  if they lined up with the true (empirical) bias. when i stripped out that work, i didn't change the wording.
