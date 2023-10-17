mle_grad <- function(l,score,theta0,eps=1e-5,r=.75)
{
    repeat {
        # we use backtracking for an approximate line search
        alpha <- 1
        theta1 <- theta0
        g <- score(theta0)
        l_theta0 <- l(theta0)
        repeat {
            theta1 <- theta0 + alpha * g
            if (all(theta1 > 0) && l(theta1) > l_theta0)
                break
            alpha <- r*alpha
        }

        # infinity norm
        if (abs(max(theta1-theta0)) < eps)
            return(theta1)
        theta0 <- theta1
    }
}



mle_newton <- function(l,score,info,theta0,eps=1e-5,r=.75)
{
    repeat {
        # we use backtracking for an approximate line search
        alpha <- 1
        theta1 <- theta0
        d <- MASS::ginv(info(theta0)) %*% score(theta0)
        l_theta0 <- l(theta0)
        repeat {
            theta1 <- theta0 + alpha * d
            if (all(theta1 > 0) && l(theta1) > l_theta0)
                break
            alpha <- r*alpha
        }

        # infinity norm
        if (abs(max(theta1-theta0)) < eps)
            return(theta1)
        theta0 <- theta1
    }
}




make_cand_set_pmf <- function(comp_ttfs,p)
{
    m <- length(comp_ttfs)
    k <- which.min(comp_ttfs)
    function(x)
    {
        if (length(x) != m)
            return(0)

        f <- 1
        for (j in 1:m)
        {
            if (j == k)
                f <- f * ifelse(x[j],1,0)
            else
                f <- f * ifelse(x[j],p[j],1-p[j])
        }
        f
    }
}


make_joint_pdf <- function(p,theta)
{
    fcomp <- make_comp_ttfs_pdf(theta)
    m <- length(p)

    function(v)
    {
        t <- v[1]
        x <- as.logical(v[2:(m+1)])
        comp_ttfs <- v[(m+2):(2*m+1)]
        fc <- make_cand_set_pmf(comp_ttfs,p)
        ft <- make_ttf_pdf(comp_ttfs)
        fc(x) * ft(t) * fcomp(comp_ttfs)
    }
}

theta <- c(3,4,5)
p <- c(.5,.5,.5)
f <- make_joint_pdf(p,theta)

marg.f <- function(t,x,f)
{
    m <- length(x)
    g <- function(ts)
    {
        f(c(min(ts),x,ts))
    }
    ul <- c(100,100,100)
    adaptIntegrate(g,lowerLimit=c(0,t,t),upperLimit=ul,maxEval=10000)$integral+
        adaptIntegrate(g,lowerLimit=c(t,0,t),upperLimit=ul,maxEval=10000)$integral+
        adaptIntegrate(g,lowerLimit=c(t,t,0),upperLimit=ul,maxEval=10000)$integral
}


# f(t,t1,t2,t3,x1,x2,x3)
make_joint_pdf <- function(rate1,rate2,rate3)
{
    # component failure time pdfs
    f1 <- function(t1) rate1 * t1
    f2 <- function(t2) rate2 * t2
    f3 <- function(t3) rate3 * t3
    p1 = .5
    p2 = .5
    p3 = .5

    # f(t|t1,t2,t3)
    ft <- function(t,t1,t2,t3)
        t == min(t1,t2,t3)

    fx1 <- function(x1,t1,t2,t3)
        ifelse(t1 == min(t1,t2,t3), as.numeric(x1), ifelse(x1,p1,1-p1))

    fx2 <- function(x2,t1,t2,t3)
        ifelse(t2 == min(t1,t2,t3), as.numeric(x2), ifelse(x2,p2,1-p2))

    fx3 <- function(x3,t1,t2,t3)
        ifelse(t3 == min(t1,t2,t3), as.numeric(x3), ifelse(x3,p3,1-p3))

    function(t,t1,t2,t3,x1,x2,x3)
        ft(t,t1,t2,t3)*fx1(x1,t1,t2,t3)*fx2(x2,t1,t2,t3)*fx3(x3,t1,t2,t3)*
        f1(t1)*f2(t2)*f3(t3)
}

f <- make_joint_pdf(3,4,5)



# f(t=1,x1=T,x2=T,x3=T)
rate1=3
rate2=4
rate3=5
t <- 1
g1 <- function(args)
{
    t2 <- args[1]
    t3 <- args[2]
    rate1*rate2*rate3*exp(-(rate1*t+rate2*t2+rate3*t3))
}

g2 <- function(args)
{
    t1 <- args[1]
    t3 <- args[2]
    rate1*rate2*rate3*exp(-(rate1*t1+rate2*t+rate3*t3))
}


g3 <- function(args)
{
    t1 <- args[1]
    t2 <- args[2]
    rate1*rate2*rate3*exp(-(rate1*t1+rate2*t2+rate3*t))
}


part1 <- .25*(hcubature(g1,
                        lowerLimit=c(t,t),
                        upperLimit=c(100,100))$integral)

part2 <- .25*(hcubature(g2,
                        lowerLimit=c(t,t),
                        upperLimit=c(100,100))$integral)


part3 <- .25*(hcubature(g3,
                        lowerLimit=c(t,t),
                        upperLimit=c(100,100))$integral)

