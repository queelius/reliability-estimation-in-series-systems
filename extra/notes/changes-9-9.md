## Change Log

- Re-worked 7.2: Simulation Scenarios. Changed the header to `Overview of Simulations`. Cleaned up the language and simplified the explanations a bit.
Added a brief explanation about what scenarios we'll be exploring and why.

- Removed the Reliability sub-section in the "Series System with Weibull Components"
section. This duplicated a lot of the material in the more general section on
series systems, so I removed some of the redundancy and integrated what remained
that was particular to the Weibull distribution as the last paragraph in the
opening section of the "Series System with Weibull Components".

- I re-worked 6.2: Weibull Series System: Homogeneous Shape Parameters. I
provided a bit of motivation for the section.

- I removed references to varying the shape and scale parameter simulation
scenarios, and I removed those two simulations entirely. Some of
the material was designed to support these simulations, so I had to
find a new way of presenting the material without those simulations justifying
it. I think I was able to do that, but I'll need to get some feedback on
whether it makes sense. I think now it just boils down to exploring the
series system model in more detail, and saying more about the behavior of
weibull series systems in particular. In the future work section, I mention
that this will a good direction to pursue work on. We already have a lot
of material for this.

- I reworded Condition 2. I've been meaning to do this for awhile, but I forgot
about it. Previously, it wasn't correct.

- I added some important details to the Data Generating Process section in
the simulation study. Mostly, I explained the nuances of Condition 2 and provide
an example. I point out that there are many different ways to satisfy the
masking conditions, but the Bernoulli masking model is quite simple and allows
us to vary the masking probability easily to assess the sensitivity of the MLE
to the Bernoulli masking probability.

- Section 2.2: System and Component Reliabilities: I re-worked this section
to clarify how the different reliability measures are related to each other,
and to provide a bit more motivation for the section by pointing out that
the simulation study will be exploring a well-designed series system as
defined in this section.

- I changed presentation of the likelihood and likelihood contributions
in Section 3 (Likelihood Model for Masked Data) to use the proportional-to
notation instead of equality, so that I could drop the constant of proportionality
$\beta_i$ from the likelihood function. This is a minor change, but it makes
it more consistent with previous work and allows to focus on those parts of
the likelihood that are important to the MLE.

- In section 7 (Simulation Study: Series System with Weibull Components)
introductory paragraphs, I expanded a bit more on Table 2 and how the
columns are related to each other. Some of this material is still based on the
idea of doing simulation study where I deviate from the well-designed system
model (e.g., I no longer vary the shape or scale parameters), so arguably
quite a lot of the material in this section and other sections could be removed
or re-worked. I think it's still useful to have this material, because it
provides a good overview of series systems and the nuances of the model.

- In section 7 (Simulation Study: Series System with Weibull Components),
I added a paragraph about the homogenous shape parameter model, suggesting that
our well-designed series system (our base model in our simulation study) is a
good candidate for this 

- Grouped R code appendices by whether it was simulation code, or code for the
likelihood model. I also reduced redundant explanations and simplified the
simulation scenario code for presentation purposes.

- Rewrote the abstract to mention the simulation scenarios we'll
be exploring.

- Rewrote the introduction to talk about the simulation scenarios, and to provide
a bit more motivation for the paper.

- Moved a lot of the summary material in the conclusion to the
Future Work section to motivate future work.

- Re-worked the conclusion.

- Added an acknowledgement section. I want to thank anyone who has helped
me with this paper, and I want to thank the reviewers for their feedback.
