# Changing parameter `scale3` so that component 3 has a lower MTTF

In this experiment, I want to see how changing the MTTB of one component, making
it by far the weakest link in the chain, changes the sampling distribution of
the MLE in our likelihood model.

I expect that it will bias everything. It will estimate component 3's parameters
quite well, but all the other parameters will be biased to have much larger
lifetimes (MTTF) because we don't see them in the data as much, we only know
they survived long than some given time in general.
