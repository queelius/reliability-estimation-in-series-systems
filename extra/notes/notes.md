

I wasn't aware of condition 2 and 3, which caused some friction early on since my likelihood function was in the form that included the probability of the candidate set conditioned on the component cause of failure and the time of failure. I came up with various models for this distribution, those most
permissive of which was the conditional distribution of candidate sets given failure times. In early experiments, I still used the bernoulli masking model for generating synthetic data, but allowed the probability of being included in the candidate set to vary over the components, and of course
if i used the same parameter bernoulli model in my likelihood function, it was quite accurate and precise, but this is an unlikely DGP of reality. eventually, i found conditions 2 and 3 in the indicated paper, and i was able to justify the partial likelihood function i used in my paper.

now, if the bernoulli probabilities are allowed to vary over the components, the MLE is no longer consistent for this likelihood model that assumes those conditions, and can be made to be extremely inconsistent.






it should be pointed out that there are more conditions needed by the actual DGP of candidate sets in order for the MLE to be uniquely identified and otherwise well-behaved, e.g., if component 1 is in the candidate set if and only if component 2 is in the candidate set, then the data (for this likelihood model) can't distinguish between the two and the MLE is not uniquely identified -- in this case, you can either:

(1) merge the two components into one
(2) augment the data (i experimented with various ways of doing this, and they worked out reasonably, although they did bias the MLE a bit particularly for small samples)
(3) use a bayesian approach and put a prior on the parameters of the model, but this was too  much of a departure from the origional direction of the project, so i didn't pursue it.

in the end, dr. agustin and i decided this may be more appropriate to pursue for future research.





