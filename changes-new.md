## changes log

- reorganized section on MLE convergence issues. it is now beginning to discuss a sensitivity analysis. i should
  make a note elsewhere about convergence issues in general, or keep it here, and then also mention that
  i use 125 iteration limit as a catch-all for potential convergence and identifiability issues (flat likelihood)

- provided some new material on weibull components yielding a weibull system when shapes are approximately the same.
  in this case, some interesting results: Pr(K_i = j|T_i = t_i) = Pr(K_i = j).

- removed the flat likelhood graphs and in-depth discussion.

- removed data augmentation section.

- TODO: write R as R_{T_i} everywhere. let's not use special notation, except R_j for components. No need to let
  the reader infer (even if it seems obvious which distribution the distribution function is for) the meaning.

- TODO: in general, don't even use R_{T_i} use prod R_j so the reader can can see this important detail more often

- TODO: i think i wrote things like "mean value of the bias" or something like that, which needs to be fixed.
  i think it's written like that because i had been ESTIMATING the bias using the bootstrap for each
  MLE, and in my prev analysis i was taking the mean of all of these bootstrapped bias estimates to see
  if they lined up with the true (empirical) bias. when i stripped out that work, i didn't change the wording.
