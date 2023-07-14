
#' optimization using BFGS
#' @param df data frame, right-censored lifetimes with masked component cause of failure
#' @param theta0 initial parameter vector
#' @param reltol relative tolerance
#' @param parscale parameter scaling vector
#' @param maxit maximum number of iterations
#' @param ... additional arguments passed to `optim`
#' @param control list of control parameters passed to `loglik_wei_series_md_c1_c2_c3`
#' @return list with components:
#' - `par` final parameter vector
#' - `value` final negative log-likelihood
#' - `counts` number of function evaluations, gradient evaluations, and Hessian evaluations
#' - `convergence` convergence code
#' - `message` convergence message
#' - `hessian` estimated Hessian
#' @importFrom stats optim
#' @export
mle_bfgs_wei_series_md_c1_c2_c3 <- function(df, theta0, reltol = 1e-10,
    parscale = NULL,
    maxit = 10000, ..., control = list()) {

    optim(
        par = theta0,
        fn = function(theta) {
            loglik_wei_series_md_c1_c2_c3(
                df = df,
                theta = theta,
                control = control)
        },
        gr = function(theta) {
            score_wei_series_md_c1_c2_c3(
                df = df,
                theta = theta,
                control = control)
        },
        hessian = TRUE,
        method = "BFGS",
        control = list(
            parscale = parscale,
            fnscale = -1,
            maxit = maxit,
            reltol = reltol,
            ...))
}

#' optimization using conjugate gradient
#' @param df data frame, right-censored lifetimes with masked component cause of failure
#' @param theta0 initial parameter vector
#' @param reltol relative tolerance
#' @param parscale parameter scaling vector
#' @param maxit maximum number of iterations
#' @param ... additional arguments passed to `optim`
#' @param control list of control parameters passed to `loglik_wei_series_md_c1_c2_c3`
#' @return list with components:
#' - `par` final parameter vector
#' - `value` final negative log-likelihood
#' - `counts` number of function evaluations, gradient evaluations, and Hessian evaluations
#' - `convergence` convergence code
#' - `message` convergence message
#' - `hessian` estimated Hessian
#' @importFrom stats optim
#' @export
mle_cg_wei_series_md_c1_c2_c3 <- function(df, theta0, reltol = 1e-10,
    parscale = NULL,
    maxit = 10000, ..., control = list()) {

    stats::optim(
        par = theta0,
        fn = function(theta) {
            loglik_wei_series_md_c1_c2_c3(
                df = df,
                theta = theta,
                control = control)
        },
        gr = function(theta) {
            score_wei_series_md_c1_c2_c3(
                df = df,
                theta = theta,
                control = control)
        },
        hessian = TRUE,
        method = "CG",
        control = list(
            parscale = parscale,
            fnscale = -1,
            maxit = maxit,
            reltol = reltol,
            ...))
}

#' optimization using L-BFGS-B
#' @param df data frame, right-censored lifetimes with masked component cause of failure
#' @param theta0 initial parameter vector
#' @param factr convergence tolerance
#' @param pgtol convergence tolerance
#' @param lmm number of limited memory corrections
#' @param parscale parameter scaling vector
#' @param maxit maximum number of iterations
#' @param ... additional arguments passed to `optim`
#' @param control list of control parameters passed to `loglik_wei_series_md_c1_c2_c3`
#' @return list with components:
#' - `par` final parameter vector
#' - `value` final negative log-likelihood
#' - `counts` number of function evaluations, gradient evaluations, and Hessian evaluations
#' - `convergence` convergence code
#' - `message` convergence message
#' - `hessian` estimated Hessian
#' @importFrom stats optim
#' @export
mle_lbfgsb_wei_series_md_c1_c2_c3 <- function(df, theta0, factr = 1e-7, pgtol = 1e-7, lmm = 20,
    parscale = NULL,
    maxit = 10000, ..., control = list()) {

    stats::optim(
        par = theta0,
        fn = function(theta) {
            loglik_wei_series_md_c1_c2_c3(
                df = df,
                theta = theta,
                control = control)
        },
        gr = function(theta) {
            score_wei_series_md_c1_c2_c3(
                df = df,
                theta = theta,
                control = control)
        },
        hessian = TRUE,
        lower = rep(0, length(theta0)),
        method = "L-BFGS-B",
        control = list(
            parscale = parscale,
            fnscale = -1,
            maxit = maxit,
            factr = factr,
            lmm = lmm,
            pgtol = pgtol,
            ...))
}

#' optimization using Nelder-Mead
#' @param df data frame, right-censored lifetimes with masked component cause of failure
#' @param theta0 initial parameter vector
#' @param reltol relative tolerance
#' @param parscale parameter scaling vector
#' @param maxit maximum number of iterations
#' @param ... additional arguments passed to `optim`
#' @param control list of control parameters passed to `loglik_wei_series_md_c1_c2_c3`
#' @return list with components:
#' - `par` final parameter vector
#' - `value` final negative log-likelihood
#' - `counts` number of function evaluations, gradient evaluations, and Hessian evaluations
#' - `convergence` convergence code
#' - `message` convergence message
#' - `hessian` estimated Hessian
#' @importFrom stats optim
#' @export
mle_nelder_wei_series_md_c1_c2_c3 <- function(df, theta0, reltol = 1e-10,
    parscale = NULL,
    maxit = 10000, ..., control = list()) {

    optim(
        par = theta0,
        fn = function(theta) {
            loglik_wei_series_md_c1_c2_c3(
                df = df,
                theta = theta,
                control = control)
        },
        hessian = TRUE,
        method = "Nelder-Mead",
        control = list(
            parscale = parscale,
            fnscale = -1,
            maxit = maxit,
            reltol = reltol,
            ...))
}




#' optimization using Newton-Raphson
#' @param df data frame, right-censored lifetimes with masked component cause of failure
#' @param theta0 initial parameter vector
#' @param lr learning rate
#' @param tol tolerance
#' @param maxit maximum number of iterations
#' @param ... additional arguments passed to `newton_raphson`
#' @param control list of control parameters passed to `loglik_wei_series_md_c1_c2_c3`
#' @return list with components:
#' - `par` final parameter vector
#' - `value` final negative log-likelihood
#' - `convergence` convergence code
#' - `iter` number of iterations
#' - `hessian` estimated Hessian
#' @importFrom stats optim
#' @export
mle_newton_wei_series_md_c1_c2_c3 <- function(df, theta0, lr = 1, tol = 1e-10,
    maxit = 10000, ..., control = list()) {

    newton_raphson(
        fn = function(theta) { 
            loglik_wei_series_md_c1_c2_c3(
                df = df, 
                theta = theta, 
                control = control)
        },
        x0 = theta0,
        gr = function(theta) {
            score_wei_series_md_c1_c2_c3(
                df = df,
                theta = theta,
                control = control)
        },
        hess = function(theta) {
            hessian_wei_series_md_c1_c2_c3(
                df = df,
                theta = theta,
                control = control)
        },
        sup = function(theta) {
            all(theta > 0)
        },
        tol = tol,
        lr = lr,
        maxit = maxit,
        ...)
}

#' optimization using simulated annealing
#' @param df data frame, right-censored lifetimes with masked component cause of failure
#' @param theta0 initial parameter vector
#' @param reltol relative tolerance
#' @param parscale parameter scaling vector
#' @param maxit maximum number of iterations
#' @param ... additional arguments passed to `optim`
#' @param control list of control parameters passed to `loglik_wei_series_md_c1_c2_c3`
#' @return list with components:
#' - `par` final parameter vector
#' - `value` final negative log-likelihood
#' - `counts` number of function evaluations, gradient evaluations, and Hessian evaluations
#' - `convergence` convergence code
#' - `message` convergence message
#' - `hessian` estimated Hessian
#' @importFrom stats optim
#' @export
mle_sann_wei_series_md_c1_c2_c3 <- function(df, theta0, reltol = 1e-10,
    parscale = NULL, maxit = 10000, ..., control = list()) {

    optim(
        par = theta0,
        fn = function(theta) {
            loglik_wei_series_md_c1_c2_c3(
                df = df,
                theta = theta,
                control = control)
        },
        method = "SANN",
        control = list(
            parscale = parscale,
            fnscale = -1,
            maxit = maxit,
            reltol = reltol,
            ...))
}
