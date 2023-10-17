<map version="1.1.0">
<!-- To view this file, download free mind mapping software FreeMind from http://freemind.sourceforge.net -->
<node CREATED="1653252217441" ID="ID_904898474" MODIFIED="1653252340140" TEXT="">
<node CREATED="1653252822906" ID="ID_1760206518" MODIFIED="1653252853829" POSITION="left" TEXT="Notes #2 (older)">
<richcontent TYPE="NOTE"><html>
  <head>
    
  </head>
  <body>
    <p>
      Hi Alex,
    </p>
    <p>
      
    </p>
    <p>
      Some comments:
    </p>
    <p>
      
    </p>
    <p>
      (a) For now, concentrate on a constant p_{j} for each component j for your simulation. The question is &quot;Are you considering p_{j} as a parameter that you need to estimate?&quot;. I do not think that is your current interest.
    </p>
    <p>
      
    </p>
    <p>
      (b) If you consider p as a function of time t, using the cdf of some random variable forces the case that p is an increasing function of time. In the event that this may not be the case, one can consider the survivor function which is 1 - cdf.
    </p>
    <p>
      
    </p>
    <p>
      (c) Can you remind me what the non-Bernoulli model you considered?
    </p>
    <p>
      
    </p>
    <p>
      (d) When dealing with lifetime data, it is typical to consider 'operational time'. In other words, the time between repairs is assumed to be negligible. This will result in interarrival times t1-t0 (t0 is set to be 0; t1 is the time first failure is observed), t2-t1 (t2 is the time second failure is observed), t3-t2, ..., t_{i} - t_{i-1}, where t_{i} is the observed time of the ith failure and t_{i-1} is the observed time of the (i-1)th failure. You will have an exponential (or whatever distribution) assumption on the interarrival times. If the system is a series system, then failure is caused by a single component. On the other hand, any other system will result in failure that will be due to a subset of components.
    </p>
    <p>
      
    </p>
    <p>
      (d) For a series system with three components, I suggest obtaining the simulated data following see section 3 of the Guo, Szidarovsky, and Niu (2013) paper, with assumption that failures cannot be clearly identified (see Table 1 of the paper). You start with exponential component lifetimes (find estimator of the scale parameter) then assume Weibull component lifetimes (need to estimate the scale and shape parameters). Then proceed with a 2-out-of-3 system. Assume that your data is an exact failure time. Then, you can consider right-censored data (paper calls this suspension; use right-censored since that is more appropriate). The change will be on the contribution of the ith observation will be on the likelihood function.
    </p>
    <p>
      
    </p>
    <p>
      To have a clearer focus, stay with what I mentioned in this email. One quantity that can be obtained, after finding the appropriate parameter estimators, is the probability that a failure is caused by a particular component. You can find the discussion on subsection 3.5 of the paper.
    </p>
    <p>
      
    </p>
    <p>
      I am not sure if I forwarded to you the copy of a paper cited by Guo, etal. Attached is a pdf copy of Usher and Hodgson (1988) on MLE analysis of masked system life data.
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1653252856042" ID="ID_981307818" MODIFIED="1653252897337" POSITION="right" TEXT="Notes #3 (older)">
<richcontent TYPE="NOTE"><html>
  <head>
    
  </head>
  <body>
    <p>
      
    </p>
    <p>
      - constant probability model, p1,...,pm, does not seem to be a named distribution, but
    </p>
    <p>
      &#160;&#160;that's okay.
    </p>
    <p>
      
    </p>
    <p>
      - the failed component K|S=s is a categorical distribution. Then, given a sample
    </p>
    <p>
      &#160;&#160;n, it is a multinomial distribution where pj = f(j;theta|s). In the exponential case,
    </p>
    <p>
      &#160;&#160;since f(j;theta|s) = f(j;theta), the failed component K is categorical (without
    </p>
    <p>
      &#160;&#160;needing to condition on S=s).
    </p>
    <p>
      
    </p>
    <p>
      - under constant probability model, for the candidate sets to contain info about theta, they must
    </p>
    <p>
      &#160;&#160;have some relationship to theta that can be exploited in the inference procedure for
    </p>
    <p>
      &#160;&#160;estimating theta from data.
    </p>
    <p>
      
    </p>
    <p>
      - estimating p1,...,pn in constant probability model is trivial, E(Xj) = n pj. Thus,
    </p>
    <p>
      &#160;&#160;pj.hat = mean(Xj)/n.
    </p>
    <p>
      - If pj is proportional to f(j|theta), where f is the pdf of K, then we have a way to
    </p>
    <p>
      &#160;&#160;estimate theta also.
    </p>
    <p>
      
    </p>
    <p>
      &#160;&#160;for instance, in exponential series case, f(k|theta) = lambdak/(lambda1 + ... + lambdam).
    </p>
    <p>
      &#160;&#160;thus, pj.hat = mean(Xj)/n =&gt; lambdaj/(lambda1+...+lambdam) = pj.hat for j=1,...,m.
    </p>
    <p>
      &#160;&#160;We have m unknowns and m equations, and thus we may solve for the unknowns to
    </p>
    <p>
      &#160;&#160;estimate lambda1,...,lambdam. Of course, if we're also given system times-to-failure,
    </p>
    <p>
      &#160;&#160;we use information from that also to provide a more accurate estimator of theta.
    </p>
    <p>
      &#160;&#160;In general, we would just set up the likelihood function and find the MLE from that.
    </p>
    <p>
      
    </p>
    <p>
      - In our contruction, we are given the constants p1,...,pm. Thus, in the case where
    </p>
    <p>
      &#160;&#160;pj is proportional to f(j;theta), we do not need to estimate theta, we have theta
    </p>
    <p>
      &#160;&#160;as a function of p1,...,pm.
    </p>
    <p>
      
    </p>
    <p>
      - To make things interesting in the constant probability model, then, we may want
    </p>
    <p>
      &#160;&#160;to assume that p1,...,pm are fixed but known parameters that are a function of
    </p>
    <p>
      &#160;&#160;theta, e.g., pj proportional to f(j;theta). Now, we can estimate p1,...,pm
    </p>
    <p>
      &#160;&#160;and use those estimates to estimate theta. I think it'll usually just be
    </p>
    <p>
      &#160;&#160;an MLE on the multinomial, but we also want to include info in the
    </p>
    <p>
      &#160;&#160;system's times-to-failure if we have it. (If we don't have times to failure
    </p>
    <p>
      &#160;&#160;data, that's okay also.)
    </p>
    <p>
      
    </p>
    <p>
      - We can extend this to a candidate model that is also a function of S and
    </p>
    <p>
      &#160;&#160;let pj be proportional to f(j;theta|s). This would lead to a more accurate
    </p>
    <p>
      &#160;&#160;estimator.
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1653252378265" ID="ID_1556022931" MODIFIED="1653252416921" POSITION="right" TEXT="Identification">
<richcontent TYPE="NOTE"><html>
  <head>
    
  </head>
  <body>
    <p>
      Identification of the model:
    </p>
    <p>
      &#952; != &#952;0 means that f(.|&#952;) != f(.|&#952;0).
    </p>
    <p>
      In other words, different parameter values &#952; correspond to different distributions within the model.
    </p>
    <p>
      If this condition did not hold, there would be some value &#952;1 such that &#952;0 and &#952;1 generate an
    </p>
    <p>
      identical distribution of the observable data. Then we would not be able to distinguish between
    </p>
    <p>
      these two parameters even with an infinite amount of data--these parameters would have been
    </p>
    <p>
      observationally equivalent.
    </p>
    <p>
      
    </p>
    <p>
      Example: whenever component 1 or 2 fails, the candidate set is {1,2} and if any other component
    </p>
    <p>
      fails, component indexes 1 and 2 are not in the candidate set.
    </p>
    <p>
      
    </p>
    <p>
      Lack of identification means that the MLE is not consistent. Consistency is difficult if not
    </p>
    <p>
      impossible to obtain in practice (on real-world data sets, since X[i] ~ f(.|&#952;) does not
    </p>
    <p>
      describe precisely the generative procedure for X[1],...,X[n], but as a theoretical device
    </p>
    <p>
      consistency is considered to be desirable. In our case, even if X[i] ~ f(.|&#952;), the MLE
    </p>
    <p>
      would still be inconsistent.
    </p>
    <p>
      
    </p>
    <p>
      
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1653252383688" ID="ID_495878709" MODIFIED="1653252633606" POSITION="left" TEXT="Conditions">
<richcontent TYPE="NOTE"><html>
  <head>
    
  </head>
  <body>
    <p>
      All models are approximations and any assumptions, implied or implicit, are never exactly true
    </p>
    <p>
      in the real world (but can be true in simulated data).
    </p>
    <p>
      The question we must ask is therefore &quot;Is the model good enough for this particular application?&quot;
    </p>
    <p>
      We worry that the conditions we impose, particularly condition 2, may not be good enough, at
    </p>
    <p>
      least in some cases.
    </p>
    <p>
      
    </p>
    <p>
      We propose an *alternative* set of conditions, Condition 1, 3, and two new conditions,
    </p>
    <p>
      4 and 5.
    </p>
    <p>
      
    </p>
    <p>
      
    </p>
    <p>
      If Conditions 1, 3, 4, and 5 are met (or at least approximately, since all models are wrong),
    </p>
    <p>
      then the full model for Pr{C[i] = c[i] | K[i] = j} can be derived and thus we may estimate
    </p>
    <p>
      it using the MLE method.
    </p>
  </body>
</html></richcontent>
<node CREATED="1653252449768" ID="ID_1219095384" MODIFIED="1653252452455" TEXT="Condition 1"/>
<node CREATED="1653252449768" ID="ID_367612141" MODIFIED="1653252461655" TEXT="Condition 2"/>
<node CREATED="1653252449768" ID="ID_1121765754" MODIFIED="1653252464927" TEXT="Condition 3"/>
<node CREATED="1653252449768" ID="ID_1474498248" MODIFIED="1653252529499" TEXT="Condition 4">
<richcontent TYPE="NOTE"><html>
  <head>
    
  </head>
  <body>
    <p>
      Condition 4: C[1],...C[n] are i.i.d.
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1653252535260" ID="ID_1151717811" MODIFIED="1653252777839" TEXT="Condition 5">
<richcontent TYPE="NOTE"><html>
  <head>
    
  </head>
  <body>
    <p>
      Condition 5: Pr{C[i] = c[i] | K[i] = j} = Pr{C[i] = c[i] | K[i] = j, T[i] = t[i]}
    </p>
    <p>
      
    </p>
    <p>
      If Conditions 1, 3, 4, and 5 are met (or at least approximately, since all models are wrong),
    </p>
    <p>
      then the full model for Pr{C[i] = c[i] | K[i] = j} can be derived and thus we may estimate
    </p>
    <p>
      it using the MLE method.
    </p>
    <p>
      
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1653252554653" ID="ID_1657694579" MODIFIED="1653252799857" TEXT="Condition 6">
<richcontent TYPE="NOTE"><html>
  <head>
    
  </head>
  <body>
    <p>
      Condition 6: The conditional distribution of Pr{j' in C[i] | K[i] = j} is
    </p>
    <p>
      independent of the conditional distribution of Pr{j'' in C[i] | K[i] = j}
    </p>
    <p>
      when j' != j''.
    </p>
    <p>
      
    </p>
    <p>
      
    </p>
    <p>
      It may be the case that Conditions 1, 3, 4, and 5 are met, but we wish to
    </p>
    <p>
      see how good of an approximation the simpler model (for the case when
    </p>
    <p>
      Condition 5 is replaced by Condition 6) is.
    </p>
    <p>
      
    </p>
  </body>
</html></richcontent>
<node CREATED="1653252658926" ID="ID_1346804020" MODIFIED="1653252752742" TEXT="nparams">
<richcontent TYPE="NOTE"><html>
  <head>
    
  </head>
  <body>
    <p>
      If Conditions 1, 3, 4, and 6 are met, then the full model for candidate sets
    </p>
    <p>
      only has m(m-1) = O(m^2) parameters to estimate.
    </p>
  </body>
</html></richcontent>
</node>
</node>
<node CREATED="1653252676381" ID="ID_1034940538" MODIFIED="1653252686729" TEXT="Condition 7">
<richcontent TYPE="NOTE"><html>
  <head>
    
  </head>
  <body>
    <p>
      An even simpler model is given by:
    </p>
    <p>
      
    </p>
    <p>
      Condition 7: Pr{j' in C[i] | K[i] = j} = Pr{j'' in C[i] | K[i] = j}.
    </p>
    <p>
      
    </p>
    <p>
      Now, the full model for when Conditions 1, 3, 4, and 7 are met has only
    </p>
    <p>
      m parameters to estimate. We call this model the Bernoulli candidate model,
    </p>
    <p>
      and it is the data model we will explore in this section.
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1653252924017" ID="ID_1439267877" MODIFIED="1653252962787" TEXT="Guo Conditions">
<richcontent TYPE="NOTE"><html>
  <head>
    
  </head>
  <body>
    <p>
      I should point out that in the Gou paper, they assume that the
    </p>
    <p>
      component that caused the system failure is definitely in the
    </p>
    <p>
      candidate set. When we generate candidate sets from the Bernoulli
    </p>
    <p>
      model you described, there is no such guarantee.
    </p>
    <p>
      
    </p>
    <p>
      When Guo describes &quot;Table 1. Scenarios for Masked Failure Data&quot;,
    </p>
    <p>
      he claims that &quot;The notation {1, 2} means that the system failure
    </p>
    <p>
      is caused by either component 1 or component 2.&quot; That means that
    </p>
    <p>
      the either 1 or 2 had the minimum time-to-failure. When we generate
    </p>
    <p>
      candidate sets according to the Bernoulli model you describe,
    </p>
    <p>
      no such guarantee is provided.
    </p>
    <p>
      
    </p>
    <p>
      In section 3.2, &quot;Failures with Masked Causes&quot;, they say the following:
    </p>
    <p>
      &quot;If only one component is in C_i , then it becomes the case where the cause
    </p>
    <p>
      can be clearly identified, as described in section 3.1.&quot;
    </p>
    <p>
      
    </p>
    <p>
      Let the times-to-failure of the m=3 components be (t1=5,t2=3,t3=4).
    </p>
    <p>
      We see that component 2 is the cause of the system failure.
    </p>
    <p>
      If we generate a candidate set with only one component label, according to
    </p>
    <p>
      the Bernoulli model you described, then the component label can be any
    </p>
    <p>
      of the components; it is not constrained to contain the failed component
    </p>
    <p>
      label 2. And more generally, for a candidate set with two component labels,
    </p>
    <p>
      the only options are {1,2} and {2,3}, since in the Guo paper, they are
    </p>
    <p>
      explicit that the failed component label must be in the candidate set.
    </p>
    <p>
      
    </p>
    <p>
      It is not clear to me, even on an intuitive level, why generating
    </p>
    <p>
      candidate sets that are not correlated with the components' times to failure
    </p>
    <p>
      in any way (i.e., C_i and (T_{i 1}, T_{i 2}, T_{i 3}) are independent)
    </p>
    <p>
      can possibly be of any use in having any information about the parameters
    </p>
    <p>
      of the component lifetime distributions. Please, explain this to me.
    </p>
    <p>
      I took what you said and I adapted it slightly so that the X_j=1
    </p>
    <p>
      probability p_j given that K is not equal to j, and otherwise
    </p>
    <p>
      X_j=1 with probability 1 for j=1,...,m. We can certainly have X_j
    </p>
    <p>
      be conditioned are a function of other properties of the unobserved
    </p>
    <p>
      variables, e.g., X_j = f(j|t). In this case, the candidate sets *alone*
    </p>
    <p>
      can be used to estimate theta.
    </p>
    <p>
      
    </p>
    <p>
      In the papers we've read, they normally make a few assumptions about how
    </p>
    <p>
      the candidate sets are generated. I think a big one is that it always contains
    </p>
    <p>
      the failed component label, and it contains other labels with equal probability.
    </p>
  </body>
</html></richcontent>
</node>
</node>
<node CREATED="1653275801647" ID="ID_1696602164" MODIFIED="1653275845206" POSITION="right" TEXT="MLE accuracy/precision">
<richcontent TYPE="NOTE"><html>
  <head>
    
  </head>
  <body>
    <p>
      \newcommand{\harmonic}[2]{H_{#1,#2}}
    </p>
    <p>
      
    </p>
    <p>
      \begin{document}
    </p>
    <p>
      \begin{enumerate}
    </p>
    <p>
      &#160;&#160;&#160;&#160;\item Only consider the matrix error functions. Forget the sampling distribution hypothesis testing nonsense.
    </p>
    <p>
      &#160;&#160;&#160;&#160;\item Compute the entropy of the sample of masked system failure times, parameterized by failure rate $\tparam\lambda$ and number of components $m$.
    </p>
    <p>
      &#160;&#160;&#160;&#160;\item Calculate the maximum entropy distribution with these parameter constraints. It should be lifetimes that are exponentially distributed and components that each have the same distribution. As such, each component is exponentially distributed, since $S = \min(T_1, \ldots, T_m)$ is exponentially distributed if $T_j$ is exponentially distributed with a failure rate is $\tparam\lambda$ if each component has a failure given by
    </p>
    <p>
      &#160;&#160;&#160;&#160;\begin{equation}
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;\frac{\tparam\lambda}{k}\,.
    </p>
    <p>
      &#160;&#160;&#160;&#160;\end{equation}
    </p>
    <p>
      &#160;&#160;&#160;&#160;That is,
    </p>
    <p>
      &#160;&#160;&#160;&#160;\begin{equation}
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;S \sim \rm{EXP}(\lambda)
    </p>
    <p>
      &#160;&#160;&#160;&#160;\end{equation}
    </p>
    <p>
      &#160;&#160;&#160;&#160;and
    </p>
    <p>
      &#160;&#160;&#160;&#160;\begin{equation}
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;T_j \sim \rm{EXP}\left(\frac{\lambda}{k}\right)\,.
    </p>
    <p>
      &#160;&#160;&#160;&#160;\end{equation}
    </p>
    <p>
      &#160;&#160;&#160;
    </p>
    <p>
      &#160;&#160;&#160;&#160;Should I put this in the entropy section? Maybe introduce these concepts, but derive it in the exponential section.
    </p>
    <p>
      &#160;&#160;&#160;
    </p>
    <p>
      &#160;&#160;&#160;&#160;\item We can use this entropy stuff to compute entropy vs MSE.
    </p>
    <p>
      &#160;&#160;&#160;&#160;Suppose we assign lambdas like so
    </p>
    <p>
      &#160;&#160;&#160;&#160;\begin{equation}
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;\lambda_k = \frac{\lambda}{k^s \harmonic{m}{s}}
    </p>
    <p>
      &#160;&#160;&#160;&#160;\end{equation}
    </p>
    <p>
      &#160;&#160;&#160;&#160;where
    </p>
    <p>
      &#160;&#160;&#160;&#160;\begin{equation}
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;\lambda_1 + \cdots + \lambda_m = \lambda\,.
    </p>
    <p>
      &#160;&#160;&#160;&#160;\end{equation}
    </p>
    <p>
      &#160;&#160;&#160;&#160;For small $s$, entropy is large. $s=0$ entropy is maximum $\log_2 m$. For large $s$ entropy is small, and $0$ at $s=\infnty.$
    </p>
    <p>
      &#160;&#160;&#160;
    </p>
    <p>
      &#160;&#160;&#160;&#160;So,
    </p>
    <p>
      &#160;&#160;&#160;&#160;\begin{equation}
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;T_k \sim \rm{EXP}\left(\frac{\lambda}{k^n \harmonic{m}{s}}\right)\,,
    </p>
    <p>
      &#160;&#160;&#160;&#160;\end{equation}
    </p>
    <p>
      &#160;&#160;&#160;&#160;is our system of interest and we can change $s$ from $0$ to $\infty$ and plot
    </p>
    <p>
      &#160;&#160;&#160;&#160;the MSE of the maximum likelihood estimator with respect to entropy by changing
    </p>
    <p>
      &#160;&#160;&#160;&#160;$s$.
    </p>
    <p>
      &#160;&#160;&#160;
    </p>
    <p>
      &#160;&#160;&#160;&#160;\[
    </p>
    <p>
      &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;\rm{MSE}(\lambda, s) = \frac{3 \lambda^2}{n}(1+\frac{1}{2^s}+\frac{1}{3^s})\,.
    </p>
    <p>
      &#160;&#160;&#160;&#160;\]
    </p>
    <p>
      &#160;&#160;&#160;
    </p>
    <p>
      &#160;&#160;&#160;&#160;Ironically, entropy is large when $s=0$ since you can't tell which component failed in the sample in this case. However, the fisher information about the paramters is largest! the smallest MSE, when $s=0$.
    </p>
    <p>
      \end{enumerate}
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1433768541170" ID="ID_1468916546" MODIFIED="1433771065318" POSITION="right" TEXT="Research">
<node CREATED="1433768613954" ID="ID_1286271816" MODIFIED="1433768641043" TEXT="Data">
<node CREATED="1433768625495" ID="ID_1392278440" MODIFIED="1433770488468" TEXT="Masked failure data">
<richcontent TYPE="NOTE"><html>
  <head>
    
  </head>
  <body>
    <p>
      <font color="rgb(0, 0, 0)" face="Arial, Lucida Grande, Geneva, Verdana, Helvetica, Lucida Sans Unicode, sans-serif">Masked failure data: the cause of failure for the system is not known exactly; rather, some subset S, |S| &gt; 1, of the components in the system are known to be the cause. </font>
    </p>
    <p>
      
    </p>
    <p>
      <font color="rgb(0, 0, 0)" face="Arial, Lucida Grande, Geneva, Verdana, Helvetica, Lucida Sans Unicode, sans-serif">Note: Another name for components, in a competing-risks model, a component is just a potential risk.</font>
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1433768629238" ID="ID_1861277905" MODIFIED="1433770056581" TEXT="Left censored data"/>
<node CREATED="1433768643104" ID="ID_250335244" MODIFIED="1433770058586" TEXT="Right censored data">
<node CREATED="1433769870878" ID="ID_689869742" MODIFIED="1433769875785" TEXT="Suspension time"/>
</node>
<node CREATED="1433768653261" ID="ID_480894251" MODIFIED="1433773098737" TEXT="Interval time"/>
<node CREATED="1433768661103" ID="ID_975912818" MODIFIED="1433773103862" TEXT="Exact time (point)"/>
</node>
<node CREATED="1433769889109" ID="ID_1618920322" MODIFIED="1433769893084" TEXT="MLE"/>
<node CREATED="1433770201509" ID="ID_1424037648" MODIFIED="1433770210774" TEXT="Systems">
<node CREATED="1433770211468" ID="ID_300271844" MODIFIED="1433770644147" TEXT="Parallel systems"/>
<node CREATED="1433770215066" ID="ID_145523884" MODIFIED="1433770640900" TEXT="Series systems">
<node CREATED="1433770195919" ID="ID_58752443" MODIFIED="1433770199521" TEXT="Competing-risks model"/>
</node>
<node CREATED="1433770218436" ID="ID_1800998564" MODIFIED="1433770226979" TEXT="Complex systems"/>
</node>
<node CREATED="1433770615016" ID="ID_341293868" MODIFIED="1433770616516" TEXT="Estimating Component Reliabilities from Incomplete System Failure Data">
<node CREATED="1433770666551" ID="ID_261130296" MODIFIED="1433772976020" TEXT="Estimating component reliabilities from masked system failure data"/>
<node CREATED="1433770657415" ID="ID_110582797" MODIFIED="1433770660725" TEXT="System failure data"/>
<node CREATED="1433772410614" ID="ID_1736296038" MODIFIED="1433772419631" TEXT="s-independent masking"/>
</node>
<node CREATED="1433771066256" ID="ID_820774502" MODIFIED="1433771070608" TEXT="Reliability functions">
<node CREATED="1433770921089" ID="ID_1082515672" MODIFIED="1433771568961" TEXT="Survival function">
<richcontent TYPE="NOTE"><html>
  <head>
    
  </head>
  <body>
    <p>
      S(t) = 1 - F(t) = Pr[T &gt; t]
    </p>
    <p>
      
    </p>
    <p>
      S(t) = exp{ -chf(t) }
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1433770908985" ID="ID_61178513" MODIFIED="1433771448889" TEXT="Hazard function">
<richcontent TYPE="NOTE"><html>
  <head>
    
  </head>
  <body>
    <p>
      h(t) = lim dt -&gt; 0 { Pr[t &lt;= T &lt; t + dt|T &gt;= t] } / dt
    </p>
    <p>
      
    </p>
    <p>
      h(t) = 1 / [1 - F(t)] * lim dt -&gt; 0 { F(t + dt) - F(t) } / dt = 1 / S(t) * lim dt -&gt; 0 { S(t) - S(t + dt) } / dt = - d log S(t) / dt
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1433770932432" ID="ID_1960405258" MODIFIED="1433770935274" TEXT="pdf"/>
<node CREATED="1433770929235" ID="ID_1232997951" MODIFIED="1433770930630" TEXT="CDF"/>
<node CREATED="1433770950368" ID="ID_98125843" MODIFIED="1433771171045" TEXT="Cumulative hazard function">
<richcontent TYPE="NOTE"><html>
  <head>
    
  </head>
  <body>
    <p>
      chf(t) = integrate h(s) ds from s = 0 to s = t
    </p>
  </body>
</html></richcontent>
</node>
</node>
<node CREATED="1433772856406" ID="ID_1668460198" MODIFIED="1653276133134" TEXT="(old) possible direction 1">
<richcontent TYPE="NOTE"><html>
  <head>
    
  </head>
  <body>
    <p>
      Chapter 7 of the reliability book by Leemis for discussion on Likelihood Theory.
    </p>
  </body>
</html>
</richcontent>
<node CREATED="1433772769842" ID="ID_227542097" MODIFIED="1433772869698" TEXT="information matrix">
<node CREATED="1433772784116" ID="ID_756540934" MODIFIED="1433772915016" TEXT="observed information matrix">
<richcontent TYPE="NOTE"><html>
  <head>
    
  </head>
  <body>
    <p>
      This is needed when you establish the asymptotic distribution of the MLE (not sure if this may be a direction that you will go in your masters project).
    </p>
  </body>
</html></richcontent>
</node>
<node CREATED="1433772808803" ID="ID_1490856436" MODIFIED="1433772812657" TEXT="derivative of score vector"/>
</node>
<node CREATED="1433772776214" ID="ID_633150308" MODIFIED="1433772778898" TEXT="score vector"/>
</node>
</node>
</node>
</map>
