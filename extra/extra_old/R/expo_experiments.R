library(dplyr)
library(ggplot2)
library(series.system.estimation.masked.data)
library(algebraic.mle)
library(cowplot)

n <- 500000
m <- 3
theta <- c(2,3,2.5)

md_block_candidate_m3 <- function(md)
{
    block <- function(k)
    {
        if (k == 1)
            return(c(T,T,F))
        if (k == 2)
            return(c(T,T,F))
        if (k == 3)
            return(c(F,F,T))
    }

    n <- nrow(md)
    x <- matrix(nrow=n,ncol=3)
    for (i in 1:n)
        x[i,] <- block(md$k[i])

    x <- tibble::as_tibble(x)
    colnames(x) <- paste0("x",1:3)
    md %>% dplyr::bind_cols(x)
}

md.nu <- tibble(t1=stats::rexp(n,theta[1]),
                t2=stats::rexp(n,theta[2]),
                t3=stats::rexp(n,theta[3])) %>%
    md_series_lifetime() %>%
    md_block_candidate_m3()

md.nu.tmp <- md.nu
md.nu.tmp$x1 <- as.integer(md.nu.tmp$x1)
md.nu.tmp$x2 <- as.integer(md.nu.tmp$x2)
md.nu.tmp$x3 <- as.integer(md.nu.tmp$x3)
head(round(md.nu.tmp,digits=3),n=15)

loglike.nu.exp <- md_loglike_exp_series_C1_C2_C3(md.nu)
N <- 2000
loglikes <- numeric(N)
theta.nus <- matrix(nrow=N,ncol=3)
for (i in 1:N)
{
    if (i %% 100 == 0)
        print(i)
    theta.nu <- mle_gradient_ascent(
        l=loglike.nu.exp,
        theta0=runif(3,.1,10),
        stop_cond=function(x,y) abs(max(x-y)) < 1e-5)

    theta.nus[i,] <- point(theta.nu)
    loglikes[i] <- loglike.nu.exp(point(theta.nu))
}

dat <- data.frame(data.frame(x=theta.nus[,1], y=theta.nus[,2],z=loglikes))
plot1 <-ggplot(dat,aes(x=x,y=y)) +
    #geom_density2d() +
    geom_density_2d_filled() +
    #geom_contour()+
    labs(x="lambda1",y="lambda2") +
    xlim(0,5) +
    ylim(0,5)
dat2 <- data.frame(data.frame(x=theta.nus[,3],z=loglikes))

plot2 <-ggplot(dat2,aes(x=x)) +
    geom_density() +
    labs(x="lambda3")

plot_grid(plot1, plot2, labels = "AUTO")

ggplot(data.frame(x=theta.nus[,1], y=theta.nus[,2],z=loglikes),aes(x=x, y=y,z=z)) +
    geom_density2d() +
    geom_line() +
    labs(x="lambda1",y="lambda2") +
    xlim(0,5) +
    ylim(0,5)


library(MASS)
kd <- kde2d(theta.nus[,1], theta.nus[,2], n = 50)   # from MASS package
# Contour plot overlayed on heat map image of results
image(kd)       # from base graphics package
contour(kd, add = TRUE)     # from base graphics package




plot(ecdf(theta.nus[,1]),main='empirical CDF of lambda1')
hist(theta.nus[,1], main="frequency")
boxplot(theta.nus[,1], main='boxplot')
plot(density(theta.nus[,1]), main="density")
