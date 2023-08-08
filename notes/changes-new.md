## Change log

- added an equation Section 2.1: Component Cause of Failure which derives the
  probability that a component is the cause of a system failure (not depenend
  on time) since we may need this for the simulation section when showing how
  the MLE's bias changes when we change the probability that a particular
  component is the cause of system failure.

- added Data Augmentation section w/R code appendix. Explains the result in
  the flat likelihood section, and motivates why we might want to apply
  data augmentation to (1) make the likelihood identifiable and (2) bias
  the MLE towards some prior belief, like the prior belief that the
  components have approximate equal reliabilities (well-designed system).

- removed variosu sections, like "Model Verification", since it didn't seem
  to add much value.

- reorgnized the simulation section. I now have it in two primary sections:

    - assessing the MLE given a well-designed system. in this section, we
      vary the masking probability, the sample size, and the right-censoring
      time to see how the MLE's sampling distribution (confidence interval)
      changes.

    - assessing the MLE given a poorly-designed system. in this section, we
      consider the pathological case where the system is poorly designed where
      one component is much less reliable or much more reliable than other
      components. we then assess only the effect changing the degree of the

- i'm still in the middle of doing a reorgnization of the simulation section.
  i'm trying to make it more clear what the simulation is doing and what the
  simulation is trying to show. we may still want to remove entire simulations
  if we feel it detracts from the main point of the paper. do we still want to 
  assess the BCa confidence intervals given a well-designed system?

- section "Ideal Case: No Right-Censoring and No Masking of Component Cause of Failure"
  has a simulation result i can't quite make sense of. i'll take another look
  at it in a couple days with fresh eyes. maybe i'm missing something.