Meeting notes:

- Fixed numerous typos, unresolved references (no more "See Equation ??"), deleted or finished
  incomplete sentences, and other issues.

- I was using the BCa (Bias-corrected and Accelerated) bootstrapped confidence intervals
	It's properly cited, and briefly discussed. I can go into more details if needed.
	
  I said I was using the percentile method. I thought I was, to be honest, but I was wrong
  about the default method
  
- Bias-Corrected and Accelerated Bootstrap Confidence Intervals, I provide more information
  and justification for why BCa is an interesting method to use for our case. It has to do
  with the effect of right censoring and masking of component cause of failure as
  potential sources of bias.
	
- In "Effect of Right-Censoring on the MLE", I discovered a few errors (mixing up the role
  of the shape and scale parameters) that I have corrected. I also changed how I presented
  it and clarified why the bias for the shape and scale parameters are introduced in the presence
  of right censoring. I also cite a source for this effect.
  
- In "Effect of Masking the Component Cause of Failure", I discover a few errors and fixed them.
  I also rewrote it to provide a clearer explanataion of the effect. Finally, I explained that
  this effect is opposite to the effect of right censoring, and so while right censoring wants
  to nudge the MLE to estimate a larger MTTF, masking nudges the components in the candidate
  sets to have a smaller MTTF.
  
- Do I have enough results from the simulation study to begin discussing my conclusions? I think
  there's a lot of interesting data there, but it has a pretty complex relationship between
  masking and right censoring that I only recently became aware of.
  

