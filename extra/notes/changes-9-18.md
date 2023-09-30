

Dr. Agustin wrote:

> Regarding the removal/replacing of those cases when you have the “extreme MLE”, I am curious how putting a max on the number of iterations compares with the case when you did not remove those “outliers”. How many were “removed” due to achieving 125 iterations? One can see that the “MLE outliers” are being discarded when the 125 max is reached so this may already be considered.

I removed the non-converging items first, then I did outlier removal, so they were separate. I have re-did the plots without any outlier removal. I think it's fine. The updated plots are in the attached pdf file. I also re-did simulations (without Bootstrap code so it was fast) to generate
convergence rates for each scenario. I unfortunately didn't store this information in the original CSV files, but I think it's fine to
estimate it separately using the same code. I added a new section that discusses plots of the convergence rates for the scenarios.

I'm in the process of also re-doing the R code for the simulation scenarios in the appendix, since this seems like an important statistic to track and I want other people, if they are so inclined, to be able to gather the same statistics in their own experiments.

Dr. Agustin wrote:
> Could you remind me or at least direct to the section/page of the last file you sent on how you obtained the IQR? Are you not using the usual 75th percentile minus the 25th percentile?

Originally, I was taking the 75% percentile of the lower-bounds of the confidence intervals, and the 25% percentile of the upper-bounds of the confidence intervals. See Section 7.1, page 19. In the updated plots, I just take the median of the upper and lower bounds of the confidence intervals.

Here is my change log:

Change log for 9-18-2019

- Removed mention of outlier removal in the simulation study since we no longer
do that.

- Added updated plots for the simulation study. These plots do not include
any outlier removal.

- For the purpose of reproducibility, I added new Appendices for
the precise MLE procedure and the codes for producing the plots in the
simulation study.

- I re-ran simulations (didn't take long, since I didn't do the bootstrap
estimates, which take the vast majority of the time) to get data for the
convergence rates of the MLEs. See Section 7.1.

- Added a new section for the convergence rates of the MLEs.

- Started to refine the look of the codes in the appendix. The actual codes may
be broken right now, since I'm still trying to make it look nice and I changed
the R code a bit to simplify for presentation. Untested, but to get it working
should be easy enough.
