#' Newton-Raphson method
#' 
#' @param fn function to be optimized
#' @param x0 initial guess
#' @param gr gradient function
#' @param hess hessian function
#' @param tol tolerance
#' @param sup support function
#' @param lr learning rate
#' @param debug debug flag
#' @param REPORT report frequency
#' @param r line search decay
#' @param maxit maximum number of iterations
#' @return list of converged, parameter, number of iterations, hessian, and value
#' @importFrom MASS ginv
#' @export
newton_raphson <- function(
    fn,
    x0,
    gr,
    hess,
    tol = 1e-10,
    sup = function(x) TRUE,
    lr = 1,
    debug = FALSE,
    REPORT = 100L,
    r = 0.8,
    maxit = 1000L) {

    iter <- 1L
    converged <- FALSE
    repeat {
        y <- fn(x0)
        d <- ginv(hess(x0)) %*% gr(x0)
        if (debug && iter %% REPORT == 0) {
            cat("iter = ", iter, ", x0 = ", x0, ", f(x0) = ", y, "\n")
        }
        eta <- lr
        repeat {
            x1 <- x0 - eta * d
            if (sup(x1) && fn(x1) >= y) {
                break
            }
            eta <- r * eta
        }

        if (iter == maxit) {
            break
        }

        if (max(abs(x1 - x0) < tol)) {
            converged <- TRUE
            break
        }

        x0 <- x1
        iter <- iter + 1L
    }
    list(converged = converged, par = x1, iter = iter, hessian = hess(x1),
        value = fn(x1))
}

#' Gradient ascent method
#' 
#' @param fn function to be optimized
#' @param x0 initial guess
#' @param gr gradient function
#' @param sup support function
#' @param lr learning rate
#' @param debug debug flag
#' @param REPORT report frequency
#' @param r line search decay
#' @param maxit maximum number of iterations
#' @return list of converged, parameter, and number of iterations
#' @export
grad_ascent <- function(
    fn,
    x0,
    gr,
    sup = function(x) TRUE,
    lr = 1,
    debug = FALSE,
    REPORT = 100L,
    r = 0.8,
    maxit = 100L) {

    iter <- 1L
    repeat {
        y <- fn(x0)
        gx <- gr(x0)
        if (debug && iter %% REPORT == 0) {
            cat("iter = ", iter, ", x0 = ", x0, ", f(x0) = ", y, "\n")
        }
        eta <- lr
        repeat {
            iter <- iter + 1L
            x1 <- x0 + eta * gx
            if (sup(x1) && fn(x1) > y) {
                break
            }
            eta <- r * eta
        }

        if (iter > maxit) {
            break
        }

        x0 <- x1
    }
    return(list(param = x1, iter = iter))
}

