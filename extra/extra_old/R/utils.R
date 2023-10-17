# mean absolute deviation
mad <- function(x)
{
    u <- mean(x)
    n <- length(x)
    sum(abs(x-u)) / n
}

# linearly rescale numbers in x each in the range [x_low,x_high] to an output
# in the range [out_low, out_high].
rescale <- function(x,x_low=0,x_high=1,_low=0,y_high=1)
{
    y_low + ((y_high - y_low) / (x_high - x_low)) * (x - x_low)
}

survival_general_series_helper <- function(R)
{
    function(t)
    {
        p <- 0
        for (Rj in R)
            p <- p + R(t)
        p
    }
}

hazard_general_series_helper <- function(h)
{
    function(t)
    {
        v <- 0
        for (hj in h)
            v <- v + hj(t)
        v
    }
}
