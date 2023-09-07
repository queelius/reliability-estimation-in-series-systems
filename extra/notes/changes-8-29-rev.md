# Change Log for Paper Revision

## General
- Addressed each comment provided by Dr. Agustin on the draft paper.
- Updated figures and analysis based on new simulation data.

## Introduction
- Rewrote the introduction to better motivate the research and provide an up-to-date overview of the paper.

## Theoretical Developments
- Consolidated the reliability, hazard, and PDF for the Weibull series into Theorem 6.1.
- Incorporated the theorem for Pr{K_i = j | T_i = t_i} as it is referenced in the simplified Weibull series model. Derived Pr{K_i = j | T_i = t_i, C_i = c} and showed it reduces to Pr{K_i = j | T_i = t_i} when c = {1, ..., m}. This version is included for review and possible inclusion. The direct proof for
Pr{K_i = j | T_i = t_i} is much easier to derive and does not depend on any of the assumptions for candidate sets, so it may be advisable to use that approach instead.

## Simulation Studies
- Revised the "Simulation Scenarios" section to accurately reflect the updated scenarios.
- Extended simulation runtimes to yield more reliable results and updated plots and analyses accordingly.
- Enhanced the analysis of simulation results to better understand the effects of right-censoring on MLE and its impact on reliability and hazard rate functions.
- Introduced Section "8.4 Assessing the Impact of Right-Censoring" detailing the simulation study and results.
- Included a new simulation study comparing the Full Weibull Model with the Reduced (Homogenous Shape) Model, using likelihood ratio tests. The study explores the relationship between varying component shape parameters and sample sizes.
- Conducted an additional test with fixed shape parameters and varying sample sizes to understand the conditions under which the likelihood ratio test rejects the reduced model hypothesis. Discussed the implications in the corresponding section.

## Conclusion
- Added a "Conclusion" section to summarize the key findings and implications from the paper and simulation studies.

## Future Work
- Added a "Future Work" section to outline potential directions for subsequent research.

