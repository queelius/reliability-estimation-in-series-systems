
## Meeting notes

- TODO: Likelihood ratio test. Fit to series system that is Weibull (same shape for all components)
    * Consider same scale too, if we find that for some small $n$ the same shape system fits data well.
    * If we find that the same shape system fits data well, then we can use the likelihood ratio test to compare the fit of the same shape system to the fit of the general system.
    * Easiest system is lambda1 = ... = lambdam, k1 = ... = km, and then we can compare to the general system.

- TODO: Weibull: combine some results into a single Theorem (see draft paper Agustin gave back to me for notes)

- TODO: Change R_{T_i} to \prod R_j (product of reliabilities) and h_{T_i} to \sum h_j (sum of hazard rates) to focus discussion around the components.

- TODO: make simplified system its own section, and in the subsection, we'll do the likelihood ratio test. here is what i hope happens. for small samples, the data is compatible with the homogenous shape (weibull) due to insufficient data. for large samples, say n=90, the data becomes increasingly incompatible with the homogenous system, as  determined by the likelihood ratio test.

- TODO: since we're already using the bootstrap, we will also bootstrap the likelihood ratio test to estimate its p-value, instead of relying upon the normal approximation. since the sample is relatively small and the models are relatively complex but nested, the normal approximation may not be very good anyways.