
## Change Log

- Updated the proof for the componant cause of failure probability Pr(K_i = j), Equation 8 in Section 2.1, to make the expectation
  step more explict. Btw, should I include the proof for Pr(K_i = j | T_i = t) in the paper? I don't actually use it in the paper.
  If we wanted to add a prediction section, where we show how we may apply these results.
  I have a more general proof for Pr(K_i = j | T_i = t, C_i = c), which reduces to Pr(K_i = j | T_i = t) when c = {1, ..., m}.
  I think I'll leave it out for now, but I can add it later if we want to add a prediction section. (Note that the predictions can also
  use Bootstrapping to construct prediction intervals which account for the uncertainty in the parameter estimates and the
  irreducible uncertainty in the model.)

- TODO: Likelihood ratio test. Fit to series system that is Weibull (same shape for all components)
    * Consider same scale too, if we find that for some small $n$ the same shape system fits data well.
    * If we find that the same shape system fits data well, then we can use the likelihood ratio test to compare the fit of the same shape system to the fit of the general system.
    * Easiest system is lambda1 = ... = lambdam, k1 = ... = km, and then we can compare to the general system.

- TODO: Weibull: combine some results into a single Theorem (see draft paper Agustin gave back to me for notes)

- TODO: Change R_{T_i} to \prod R_j (product of reliabilities) and h_{T_i} to \sum h_j (sum of hazard rates) to focus discussion around the components.

- TODO: make simplified system its own section, and in the subsection, we'll do the likelihood ratio test. here is what i hope happens. for small samples, the data is compatible with the homogenous shape (weibull) due to insufficient data. for large samples, say n=90, the data becomes increasingly incompatible with the homogenous system, as  determined by the likelihood ratio test.

- TODO: since we're already using the bootstrap, we will also bootstrap the likelihood ratio test to estimate its p-value, instead of relying upon the normal approximation. since the sample is relatively small and the models are relatively complex but nested, the normal approximation may not be very good anyways.