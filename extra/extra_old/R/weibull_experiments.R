library(dplyr)
library(series.system.estimation.masked.data)
library(algebraic.mle)

# sample size
n <- 500

# m components in series system
m <- 3

# true parameter value of series system
theta <- c(2,40,      # lambda_1, k_1
           3,10,      # lambda_2, k_2
           2,30)      # lambda_3, k_3

# bernoulli candidate model parameter

# right censoring times
tau <- rep(2,n)


md_block_candidate_m3 <- function(md)
{
    block <- function(k)
    {
        if (k == 1)
            return(c(T,T,F))
        if (k == 2)
            return(c(T,T,F))
        if (k == 3)
        {
            if (runif(1) < 0.1)
                return(c(T,T,T))
            else
                return(c(F,F,T))
        }
    }

    n <- nrow(md)
    x <- matrix(nrow=n,ncol=3)
    for (i in 1:n)
        x[i,] <- block(md$k[i])

    x <- tibble::as_tibble(x)
    colnames(x) <- paste0("x",1:3)
    md %>% dplyr::bind_cols(x)
}


md.nu <- tibble(t1=stats::rweibull(n,shape=theta[2],scale=theta[1]),
                t2=stats::rweibull(n,shape=theta[4],scale=theta[3]),
                t3=stats::rweibull(n,shape=theta[6],scale=theta[5])) %>%
    md_series_lifetime() %>%
    md_series_lifetime_right_censoring(tau) %>%
    md_block_candidate_m3()


md.nu.tmp <- md.nu
md.nu.tmp$x1 <- as.integer(md.nu.tmp$x1)
md.nu.tmp$x2 <- as.integer(md.nu.tmp$x2)
md.nu.tmp$x3 <- as.integer(md.nu.tmp$x3)
md.nu.tmp$delta <- as.integer(md.nu.tmp$delta)
head(round(md.nu.tmp,digits=3),n=15)




loglike.nu.weibull <- md_loglike_weibull_series_C1_C2_C3(md.nu)
theta.nu.hat <- mle_newton_raphson(
    l=loglike.nu.weibull,
    theta0=theta)

points.nu <- cbind(point(theta.nu.hat),as.matrix(theta))
colnames(points.nu) <- c("MLE","Parameter")
cbind(points.nu,confint(theta.nu.hat))
