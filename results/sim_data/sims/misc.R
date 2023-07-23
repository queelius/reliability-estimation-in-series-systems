



            d <- algebraic.dist::empirical_dist(theta.hats)
            logliks.d <- algebraic.dist::empirical_dist(logliks)
            lower.d <- algebraic.dist::empirical_dist(lowers.boot)
            upper.d <- algebraic.dist::empirical_dist(uppers.boot)
            mse.d <- algebraic.dist::empirical_dist(mse.boot)
            bias.d <- algebraic.dist::empirical_dist(bias.boot)


            cat("Mean log-likelihood: ", mean(logliks), "\n")
            cat("Coverage probability: ", cov_prob / R, "\n")
            print(cov_prob / R)

            shape_d <- marginal(d, c(1,3,5,7,9))
            cat("Shape parameters\n")
            cat("----------------\n")
            cat("Bias: ", mean(shape_d) - shapes, "\n")
            cat("Relative bias: ", (mean(shape_d) - shapes) / shapes, "\n")
            cat("Mean absolute bias: ", sum(abs(mean(shape_d) - shapes)), "\n")
            cat("Mean absolute relative bias: ", sum(abs(mean(shape_d) - shapes) / abs(shapes)), "\n")
            cat("SD: ", sqrt(diag(vcov(shape_d))), "\n")
            cat("Mean SD: ", mean(sqrt(diag(vcov(shape_d)))), "\n")
            cat("Var: ", diag(vcov(shape_d)), "\n")
            cat("Mean Var: ", mean(diag(vcov(shape_d))), "\n")
            cat("MSE: ", expectation(shape_d, function(x) { (x - shapes)^2 }), "\n")
            cat("Mean MSE: ", mean(expectation(shape_d, function(x) { (x - shapes)^2 })), "\n")

            scale_d <- marginal(d, c(2,4,6,8,10))
            cat("Scale parameters\n")
            cat("----------------\n")
            cat("\n")
            cat("Bias: ", mean(scale_d) - scales, "\n")
            cat("Relative bias: ", (mean(scale_d) - scales) / scales, "\n")
            cat("Mean absolute bias: ", mean(abs(mean(scale_d) - scales)), "\n")
            cat("Mean absolute relative bias: ", mean(abs(mean(scale_d) - scales) / abs(scales)), "\n")
            cat("SD: ", sqrt(diag(vcov(scale_d))), "\n")
            cat("Mean SD: ", mean(sqrt(diag(vcov(scale_d)))), "\n")
            cat("Var: ", diag(vcov(scale_d)), "\n")
            cat("Mean Var: ", mean(diag(vcov(scale_d))), "\n")
            cat("MSE: ", expectation(scale_d, function(x) { (x - scales)^2 }), "\n")
            cat("Mean MSE: ", mean(expectation(scale_d, function(x) { (x - scales)^2 })), "\n")
        }
    }

d <- algebraic.dist::empirical_dist(theta.hats)
lower.d <- algebraic.dist::empirical_dist(lowers.boot)
upper.d <- algebraic.dist::empirical_dist(uppers.boot)

cat("Mean log-likelihood: ", mean(logliks), "\n")
cat("Coverage probability: ", cov_prob / R, "\n")
print(cov_prob / R)

shape_d <- marginal(d, c(1,3,5,7,9))
cat("Shape parameters\n")
cat("----------------\n")
cat("Bias: ", mean(shape_d) - shapes, "\n")
cat("Relative bias: ", (mean(shape_d) - shapes) / shapes, "\n")
cat("Mean absolute bias: ", sum(abs(mean(shape_d) - shapes)), "\n")
cat("Mean absolute relative bias: ", sum(abs(mean(shape_d) - shapes) / abs(shapes)), "\n")
cat("SD: ", sqrt(diag(vcov(shape_d))), "\n")
cat("Mean SD: ", mean(sqrt(diag(vcov(shape_d)))), "\n")
cat("Var: ", diag(vcov(shape_d)), "\n")
cat("Mean Var: ", mean(diag(vcov(shape_d))), "\n")
cat("MSE: ", expectation(shape_d, function(x) { (x - shapes)^2 }), "\n")
cat("Mean MSE: ", mean(expectation(shape_d, function(x) { (x - shapes)^2 })), "\n")

scale_d <- marginal(d, c(2,4,6,8,10))
cat("Scale parameters\n")
cat("----------------\n")
cat("\n")
cat("Bias: ", mean(scale_d) - scales, "\n")
cat("Relative bias: ", (mean(scale_d) - scales) / scales, "\n")
cat("Mean absolute bias: ", mean(abs(mean(scale_d) - scales)), "\n")
cat("Mean absolute relative bias: ", mean(abs(mean(scale_d) - scales) / abs(scales)), "\n")
cat("SD: ", sqrt(diag(vcov(scale_d))), "\n")
cat("Mean SD: ", mean(sqrt(diag(vcov(scale_d)))), "\n")
cat("Var: ", diag(vcov(scale_d)), "\n")
cat("Mean Var: ", mean(diag(vcov(scale_d))), "\n")
cat("MSE: ", expectation(scale_d, function(x) { (x - scales)^2 }), "\n")
cat("Mean MSE: ", mean(expectation(scale_d, function(x) { (x - scales)^2 })), "\n")











# cat("Var #2: ",  expectation(shape_d, function(x) { (x - mean(shape_d))^2 }), "\n")
# cat("Var #2: ",  expectation(scale_d, function(x) { (x - mean(scales))^2 }), "\n")
# cat("MSE matrix #1:\n")
# mse.shape <- expectation(shape_d,
#     function(x) { (x - shapes) %*% t(x - shapes) })
# print(matrix(mse.shape, nrow = length(shapes)))
# cat("MSE matrix #2:\n")
# mse.shape.2 <- expectation(shape_d,
#     function(x) {
#         b <- mean(shape_d) - shapes
#         b2 <- b %*% t(b)
#         V <- vcov(shape_d)
#         b2 + V
#     })
# print(matrix(mse.shape.2, nrow = length(shapes)))

# cat("VCOV matrix #1:\n")
# vcov.shape <- expectation(shape_d,
#     function(x) { (x - mean(shape_d)) %*% t(x - mean(shape_d)) })
# print(matrix(vcov.shape, nrow = length(shapes)))
# cat("VCOV matrix #2:\n")
# print(vcov(shape_d))
# cat("\n")


# cat("MSE matrix #1:\n")
# mse.scale <- expectation(scale_d,
#     function(x) { (x - scales) %*% t(x - scales) })
# print(matrix(mse.scale, nrow = length(scales)))
# cat("MSE matrix #2:\n")
# mse.scale.2 <- expectation(scale_d,
#     function(x) {
#         b <- mean(scale_d) - scales
#         b2 <- b %*% t(b)
#         V <- vcov(scale_d)
#         b2 + V
#     })
# print(matrix(mse.scale.2, nrow = length(scales)))

# cat("VCOV matrix #1:\n")
# vcov.scale <- expectation(scale_d,
#     function(x) { (x - mean(scale_d)) %*% t(x - mean(scale_d)) })
# print(matrix(vcov.scale, nrow = length(scales)))
# cat("VCOV matrix #2:\n")
# print(vcov(scale_d))



        
        # test <- boot::boot(df, function(df, i) {
        #     mle_lbfgsb_wei_series_md_c1_c2_c3(
        #         theta0 = theta, df = df[i, ], hessian = FALSE,
        #         control = list(maxit = 4L, parscale = parscale))$par
        # }, R = 10, sim = "parametric", ran.gen = function(d, mle) {
        #     wei.series.md.c1.c2.c3::generate_guo_weibull_table_2_data(
        #         shapes = mle[seq(1, length(mle), 2)],
        #         scales = mle[seq(2, length(mle), 2)],
        #         n = n, p = p, tau = tau)
        # }, mle = sol$par, stype = "i") -> boot
