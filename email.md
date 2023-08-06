Hi Dr. Agustin,

I have two prelimary results:

**1. Shape Parameter 3's Impact on MLE**
When I vary the shape parameter of component 3, the MTTF isn't as predictive of component 3 failing before or after the others. For instance, you can have a large MTTF relative to the other components but still have a higher probability of failing first. This is interesting, and it makes sense, as it relates to the failure rate being a function of the shape parameter. If k < 1, then the failure rate decreases over time, e.g., "infanty mortality phase", and if k > 1, then the failure rate increases over time, e.g., "aging phase".

In the simulation I ran, I didn't account for this and the results were perplexing. I mapped the shape and scale of component 3 to the probability of component failure (numerically solved the probability that component 3 is the cause of a system failure), but I haven't had time to analyze it.

I want to do another simulation to account for the shape parameter having such an important impact on the failure rate.
To make my next sim run faster and more easily understood, I'm going to just do a 2-component system, no bootstrapping, and email you an analysis tomorrow (Sunday).

**2. Sample Modifiation**
I believe I've discerned why modifying the data both made the profile of the likelihood function identifiable for shape paramteter 1 and improved its estimate.

First, before the modification, the profile of the likelihood function had a flat "peak" region, and any value in that region is an MLE. The true value for shape parameter 1 is 1.26, and we see that the smallest MLE was around 1.5, there just wasn't enough information to identify a unique point and so if we're forced to choose one, any value in that flat region will do.

I did a preliminary analysis to demonstrate when our data yields a unique MLE, and I think I may have identified some necessary conditions, but not all conditions. 

Second, why did modifying the data improve the estimate of shape parameter 1 in that case? By introducing that change, we made the likelihood function identifiable, but it may have been the case that its peak was further away from the true parameter value. Here is why it was (probably) improved: we made that observation in the sample indicate that component 1 was the cause of failure, and the system lifetime was quite short. This nudged the likelihood to peak at a smaller value to make it shape parameter 1 more likely to produce earlier failures for component 1.

We implicitly gave our MLE a prior by adding "fake" data to the sample. If we pursued this idea much further, we risk dragging in a Bayesian analysis into the paper, which I doubt we want to do. However, there is a middle-ground, where we just augment the samples a bit, particularly small samples, to:

(1) Make the likelihood function identifiable

(2) Bias the estimates towards a well-engineered system, where there is no "weakest link" in the series system, i.e., the shape parameters being roughly the same and the scale parameters being roughly the same,  With a sufficiently large enough sample, this has no discernable effect, but for small samples, it can have a huge effect. If the assumption (of being well-engineered in the way I discribed) is wrong, it will be more a more biased estimator. 

Here is an ad-hoc way we can add fake data: For each component, resample a few system lifetimes from the observed sample, compute the mean system lifetime, and then add that component as the exact cause of the system failure at that mean lifetime. This is a pretty ad-hoc way of doing it, but the intuition is that we want to get a reasonable estimate of the MTTF (by resampling from the data), and then saying that each component is equally likely to produce that failure time, which is compatible with the definition of the "well-engineered" system I described above. The more data of this kind you add, the stronger your assumption and the lager the sample we need to "undo" the assumption. To prevent biasing the results too much, we could do this only a single time for each component.

I'm not sure we want to go down this path for the project. If nothing else, it is something we could pursue later on if you're interested in writing a paper on this topic. 

I'll send you an email tomorrow with a analysis of the results of the 2-component system.

Regards,
Alex
