#' Likelihood model for Weibull series systems from masked data.
#'
#' Functions include the log-likelihood, score, and hessian of the log-likelihood
#' functions.
#' 
#' Masked component data approximately satisfies the following conditions:
#' C1: Pr(K in C) = 1
#' C2: Pr(C=c | K=j, T=t) = Pr(C=c | K=j', T=t)
#'     for any j, j' in c.
#' C3: masking probabilities are independent of theta
#' 
#' We also include right-censoring of system lifetime data.
#'
#' @author Alex Towell
#' @name Weibull series MLE
#' @keywords weibull, distribution, series, statistics, masked data
NULL

#' Generates a log-likelihood function for a Weibull series system with respect
#' to parameter `theta` (shape, scale) for masked data with candidate sets
#' that satisfy conditions C1, C2, and C3 and right-censored data.
#'
#' @param df (masked) data frame
#' @param theta parameter vector (shape1, scale1, ..., shapem, scalem)
#' @param control list of control parameters:
#'  - `candset` prefix of Boolean matrix encoding of candidate sets,
#'     defaults to `x`, e.g., `x1,...,xm`.
#'  - `lifetime` system lifetime (optionally right-censored) column name
#'  - `right_censoring_indicator` right-censoring indicator column name, if
#'     TRUE, then the system lifetime is observed, otherwise it is right-censored.
#'     If there is no right-censoring indicator column by the given name, then the
#'     system lifetimes are assumed to be observed.
#' @returns Log-likelihood with respect to `theta` given `df`
#' @importFrom md.tools md_decode_matrix
#' @export
loglik_wei_series_md_c1_c2_c3 <- function(
    df,
    theta,
    control = list()) {

    defaults <- list(
        candset = "x",
        lifetime = "t",
        right_censoring_indicator = "delta")

    control <- modifyList(defaults, control)
    if (!control$lifetime %in% colnames(df)) {
        stop("lifetime variable not in colnames(df)")
    }

    n <- nrow(df)
    if (n < 1) {
        stop("sample size must be greater than 0")
    }

    C <- md_decode_matrix(df, control$candset)
    if (is.null(C)) {
        stop("no candidate set found for candset")
    }
    m <- ncol(C)

    if (control$right_censoring_indicator %in% colnames(df)) {
        delta <- df[[control$right_censoring_indicator]]
    } else {
        delta <- rep(TRUE, n)
    }

    t <- df[[control$lifetime]]

    k <- length(theta)
    stopifnot(k == 2 * m)
    shapes <- theta[seq(1, k, 2)]
    scales <- theta[seq(2, k, 2)]

    s <- 0
    for (i in 1:n) {
        s <- s - sum((t[i] / scales)^shapes)
        if (delta[i]) {
            s <- s + log(sum(shapes[C[i, ]] / scales[C[i, ]] *
                (t[i] / scales[C[i, ]])^(shapes[C[i, ]] - 1)))
        }
    }
    s
}

#' Generates a score function (gradient of the log-likelihood function) for a Weibull
#' series system with respect to parameter `theta` (shape, scale) for masked data
#' with candidate sets that satisfy conditions C1, C2, and C3 and right-censored
#' data.
#'
#' @param df (masked) data frame
#' @param theta parameter vector (shape1, scale1, ..., shapem, scalem)
#' @param ... additional arguments passed to `method.args` in `grad`
#' @param control list of control parameters. See `loglik_wei_series_md_c1_c2_c3`
#' @returns Score with respect to `theta` given `df`
#' @importFrom numDeriv grad
#' @export
score_wei_series_md_c1_c2_c3 <- function(
    df,
    theta,
    ...,
    control = list()) {

    grad(
        func = loglik_wei_series_md_c1_c2_c3,
        x = theta,
        df = df,
        control = control,
        method.args = list(r = 6, ...))
}



#' Generates a hessian of the log-likelihood function (negative of the observed
#' FIM) for a Weibull series system with respect to parameter `theta` (shape, scale)
#' for masked data with candidate sets that satisfy conditions C1, C2, and C3 and
#' right-censored data.
#'
#' @param df (masked) data frame
#' @param theta parameter vector (shape1, scale1, ..., shapem, scalem)
#' @param ... additional arguments passed to `method.args` in `hessian`
#' @param control list of control parameters. See `loglik_wei_series_md_c1_c2_c3`
#' @returns Score with respect to `theta` given `df`
#' @importFrom numDeriv hessian
#' @export
hessian_wei_series_md_c1_c2_c3 <- function(
    df,
    theta,
    ...,
    control = list()) {

    hessian(
        func = loglik_wei_series_md_c1_c2_c3,
        x = theta,
        df = df,
        control = control,
        method.args = list(r = 6, ...))
}
