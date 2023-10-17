# Estimating series systems from samples with masked system failure times

Suppose we have a population of similar systems and we are interested in their
lifetime properties. 

Assumption: Two randomly chosen subsets of the same size generally have similiar
empirical distributions and converge to the same distribution as the sample size
increases, i.e., the lifetimes of the systems are *independently and identically
distributed* (iid).

If the only information we have about population is given by a sample of `n`
system lifetimes, then we may model each point in the sample as having an
random lifetime `T(j)` for `j=1,...,n` where each `T(j)` is iid and greater than
zero. We may estimate properties that are only a function of the system
lifetime, such as the mean time to failure.

Most systems are more complex than just 'having a lifetime' and thus have
multiple observable properties. One of the simplest structures is a series
system, where the system is modelled as `m` independent components each with an
uncertain lifetime. The random lifetime of the `j-th` component of the `k-th`
system in a sample is denoted by `T(j,k)`

The maximum information about the `j-th`system in a sample is then given by
observing each of the `m` component lifetimes, `T(j,1), ..., T(j,m)`, and the
system lifetime is a function of the `m` component lifetimes,
    `T(j) = min{T(j,1), ..., T(j,m)}`.

*We may ask other questions about the system since we have more information.*

The maximum information in a sample of `n` system lifetimes is then given by
a sample of `n` vectors of size `m`. The sample may now be represented as a
matrix of `n` rows and `m` columns.

Often, we cannot observe all the propoerties of the system. For instance, in a
series system we may only be able to observe the system for a fixed unit of
time `t`, which may result in situations where, if the system has no failed, we
only know that `T(j,1) > t, ..., T(j, m) > t`, or if the system has failed at
time `t`, we may only know the component lifetimes of some subset of the `m`
components and we only know that the remaining have uncertain lifetimes greater
than `t`.

There is another type of uncertainty we are interested in. Often, we are able
to observe some properties of a system that we know are functions of some other
unobserved parts of the system. For instance, in a series system, if we are only
able to observe the system lifetime T(j) but none of the component lifetimes,
we say that `T(j,1),...,T(j,m)` are **latent** random variables.

In the previous example, we did not have enough information to estimate the
properties of the components. In this case, we may as well forget the serial
structure and model it as a point system as before. However, there are other
things that may be observed about the series system.

We are particularly interested in **masked system failure times**, where we
observe the system lifetime and also observe some subset of the components
that caused, or likely caused, the failure. That is to say, we observe something
like the following two properties:

1. For the `j-th` system, we observed that it failed at time `t`. So, we know that
one of the components has a lifetime `t` and the remaining components have a
lifetime greater than `t`.

2. For system `j`, we also observed that one of the components in some subset `C`
of `{1,..,m}` failed at time `t`. If `C = {1,...,m}` then this tells us nothing.
If `|C| = 1` this tells us exactly which component failed. This is the maximum
information possible given samples of this kind, but note that it is still not
as much information as knowing the lifetimes of all `m` components.

Thus, samples take the form:
```
{
    T(1),{1,3},
    T(2),{1,2},
    T(3),{2,3,4}
}
```
