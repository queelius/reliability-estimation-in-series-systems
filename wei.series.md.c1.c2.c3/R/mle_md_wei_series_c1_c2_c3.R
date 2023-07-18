
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
mle_lbfgsb_wei_series_md_c1_c2_c3 <- function(
    df,
    theta0,
    factr = 1e-7,
    pgtol = 1e-7,
    lmm = 20,
    parscale = NULL,
    maxit = 10000L, ..., control = list()) {

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
#' @param maxit maximum number of iterations
#' @param ... additional arguments passed to `newton_raphson`
#' @param control list of control parameters passed to `loglik_wei_series_md_c1_c2_c3`
#' @return list with components:
#' - `par` final parameter vector
#' - `value` final negative log-likelihood
#' - `iter` number of iterations
#' - `hessian` estimated Hessian
#' @importFrom stats optim
#' @importFrom MASS ginv
#' @export
mle_newton_wei_series_md_c1_c2_c3 <- function(
    df, theta0, lr = .1, maxit = 100, control = list()) {

    tryCatch({
        for (iter in 1:maxit) {
            s <- score_wei_series_md_c1_c2_c3_3(df = df, theta = theta0, control = control)
            h <- hessian_wei_series_md_c1_c2_c3_2(df = df, theta = theta0, control = control)
            l <- loglik_wei_series_md_c1_c2_c3(df = df, theta = theta0, control = control)
            a <- lr
            repeat {
                theta1 <- theta0 - a * ginv(h) %*% s
                if (all(theta1 >= 0)) {
                    l1 <- loglik_wei_series_md_c1_c2_c3(df = df, theta = theta1, control = control)
                    
                    if (l1 >= l) {
                        cat("loglok(", theta1, ") = ", l1, " (alpha = ", a,"\n")
                        theta0 <- theta1
                        break
                    }
                }
                a <- a / 2
            }
        }
    }, error = function(e) {
        warning(e)
    })
    
    list(par = theta0,
         iter = iter,
         hessian = h,
         value = loglik_wei_series_md_c1_c2_c3(df = df, theta = theta0, control = control))
}


mle_newton_wei_series_md_c1_c2_c3_2 <- function(
    df, theta0, lr = .1, maxit = 100, control = list()) {

    tryCatch({
        for (iter in 1:maxit) {
            s <- score_wei_series_md_c1_c2_c3(df = df, theta = theta0, control = control)
            h <- hessian_wei_series_md_c1_c2_c3(df = df, theta = theta0, control = control)
            l <- loglik_wei_series_md_c1_c2_c3(df = df, theta = theta0, control = control)
            a <- lr
            repeat {
                theta1 <- theta0 - a * ginv(h) %*% s
                if (all(theta1 >= 0)) {
                    l1 <- loglik_wei_series_md_c1_c2_c3(df = df, theta = theta1, control = control)
                    
                    if (l1 >= l) {
                        cat("loglok(", theta1, ") = ", l1, " (alpha = ", a,"\n")
                        theta0 <- theta1
                        break
                    }
                }
                a <- a / 2
            }
        }
    }, error = function(e) {
        warning(e)
    })
    
    list(par = theta0,
         iter = iter,
         hessian = h,
         value = loglik_wei_series_md_c1_c2_c3(df = df, theta = theta0, control = control))
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

#' optimization using Newton-Raphson
#' @param df data frame, right-censored lifetimes with masked component cause of failure
#' @param theta0 initial parameter vector
#' @param lr learning rate
#' @param maxit maximum number of iterations
#' @param ... additional arguments passed to `newton_raphson`
#' @param control list of control parameters passed to `loglik_wei_series_md_c1_c2_c3`
#' @return list with components:
#' - `par` final parameter vector
#' - `value` final negative log-likelihood
#' - `iter` number of iterations
#' - `hessian` estimated Hessian
#' @importFrom stats optim
#' @importFrom MASS ginv
#' @export
mle_grad_wei_series_md_c1_c2_c3 <- function(
    df, theta0, lr = .1, maxit = 100, control = list()) {

    tryCatch({
        for (iter in 1:maxit) {
            s <- score_wei_series_md_c1_c2_c3(df = df, theta = theta0, control = control)
            theta0 <- theta0 + lr * s
            cat("iter = ", iter, ", theta = ", theta0, "\n")
        }
    }, error = function(e) {
        warning(e)
    })
    
    list(par = theta0,
         iter = iter,
         hessian = hessian_wei_series_md_c1_c2_c3(df = df, theta = theta0, control = control),
         value = loglik_wei_series_md_c1_c2_c3(df = df, theta = theta0, control = control))
}



#' optimization using Newton-Raphson
#' @param df data frame, right-censored lifetimes with masked component cause of failure
#' @param theta0 initial parameter vector
#' @param lr learning rate
#' @param maxit maximum number of iterations
#' @param ... additional arguments passed to `newton_raphson`
#' @param control list of control parameters passed to `loglik_wei_series_md_c1_c2_c3`
#' @return list with components:
#' - `par` final parameter vector
#' - `value` final negative log-likelihood
#' - `iter` number of iterations
#' - `hessian` estimated Hessian
#' @importFrom stats optim
#' @importFrom MASS ginv
#' @export
mle_grad_wei_series_md_c1_c2_c3_2 <- function(
    df, theta0, lr = .1, maxit = 100, control = list()) {

    tryCatch({
        for (iter in 1:maxit) {
            s <- score_wei_series_md_c1_c2_c3_2(df = df, theta = theta0, control = control)
            theta0 <- theta0 + lr * s
            #cat("iter = ", iter, ", theta = ", theta0, "\n")
        }
    }, error = function(e) {
        warning(e)
    })
    
    list(par = theta0,
         iter = iter,
         hessian = hessian_wei_series_md_c1_c2_c3_2(df = df, theta = theta0, control = control),
         value = loglik_wei_series_md_c1_c2_c3(df = df, theta = theta0, control = control))
}











mle_grad_wei_series_md_c1_c2_c3 <- function(
    df, theta0, control = list()) {

    defaults <- list(
        lr = .1,
        maxit = 100,
        score = c("analytical", "numerical"))

    control <- modifyList(defaults, control)
    type <- match.arg(control$score)
    if (type == "analytical") {
        score <- score_wei_series_md_c1_c2_c3
    } else if (scr_type == "numerical") {
        score <- function(df, theta, ...) {
            numDeriv::grad(loglik_wei_series_md_c1_c2_c3, ...)
        }
    }

    tryCatch({
        for (iter in 1:maxit) {
            s <- score(df = df, theta = theta03, control = control)
            theta0 <- theta0 + lr * s
        }
    }, error = function(e) {
        warning(e)
    })

    #cat("theta01 = ", theta01, ", l1 = ", l1, ", s1 = ", s1, "\n")
    cat("theta02 = ", theta02, ", l2 = ", l2, ", s2 = ", s2, "\n")
    cat("theta03 = ", theta03, ", l3 = ", l3, ", s3 = ", s3, "\n")
    
    #list(par = theta01,
    #     iter = iter,
    #     hessian = hessian_wei_series_md_c1_c2_c3(df = df, theta = theta01, control = control),
    #     value = loglik_wei_series_md_c1_c2_c3(df = df, theta = theta01, control = control))
}






test_score_wei_series_md_c1_c2_c3_3 <- function(
    df, parscale, it = 10, eps = 1e-3, control = list()) {

    for (i in 1:it) {
        theta <- runif(length(parscale)) * parscale
        s1 <- score_wei_series_md_c1_c2_c3(df = df, theta = theta, control = control)
        s2 <- score_wei_series_md_c1_c2_c3_2(df = df, theta = theta, control = control)
        s3 <- score_wei_series_md_c1_c2_c3_3(df = df, theta = theta, control = control)
        
        #print(abs(s1 - s3) < eps)
        print(abs(s1 - s3) < eps)
        
        

        #cat("---\n")
    }
}









mle_lbfgsb_wei_series_md_c1_c2_c3_2 <- function(
    df,
    theta0,
    factr = 1e-50,
    pgtol = 1e-50,
    lmm = 1000,
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
            score_wei_series_md_c1_c2_c3_3(
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
