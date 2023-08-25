library(wei.series.md.c1.c2.c3)

theta <- c(shape1 = 1.2576, scale1 = 994.3661,
           shape2 = 1.1635, scale2 = 908.9458,
           shape3 = NA,     scale3 = 500,
           shape4 = 1.1802, scale4 = 940.1342,
           shape5 = 1.2034, scale5 = 923.1631)
shapes3 <- c(1.2034, .75, .635, .55, .5, .456)

shapes <- theta[seq(1, length(theta), 2)]
scales <- theta[seq(2, length(theta), 2)]

for (shape3 in shapes3) {
    shapes[3] <- shape3
    cat(shape3,
        ": Pr = ", wei_series_cause(3L, shapes = shapes, scales = scales),
        ", MTTF = ", wei_mttf(shape3, theta['scale3']),"\n")
}
shapes[3] <- 2.5
cat(shapes[3],
    ": Pr = ", wei_series_cause(3L, shapes = shapes, scales = scales),
    ", MTTF = ", wei_mttf(shapes[3], theta['scale3']),"\n")
shapes[3] <- 5
cat(shapes[3],
    ": Pr = ", wei_series_cause(3L, shapes = shapes, scales = scales),
    ", MTTF = ", wei_mttf(shapes[3], theta['scale3']),"\n")
shapes[3] <- 10.09
cat(shapes[3],
    ": Pr = ", wei_series_cause(3L, shapes = shapes, scales = scales),
    ", MTTF = ", wei_mttf(shapes[3], theta['scale3']),"\n")








theta <- c(shape1 = 1.2576, scale1 = 994.3661,
           shape2 = 1.1635, scale2 = 908.9458,
           shape3 = 1.1308, scale3 = 840.1141,
           shape4 = 1.1802, scale4 = 940.1342,
           shape5 = 1.2034, scale5 = 923.1631)
scales3 <- theta["scale3"] + c(-500, 0, 500)

shapes <- theta[seq(1, length(theta), 2)]
scales <- theta[seq(2, length(theta), 2)]

for (scale3 in scales3) {
    scales[3] <- scale3
    cat(scale3,
        ": Pr = ", wei_series_cause(3L, shapes = shapes, scales = scales),
        ", MTTF = ", wei_mttf(theta["shape3"], scale3),"\n")
}

q.825 <- wei.series.md.c1.c2.c3::qwei_series(p = .825, scales = scales, shapes = shapes)

df <- wei.series.md.c1.c2.c3::generate_guo_weibull_table_2_data(
    shapes = shapes, scales = scales, n = 100, p = .215, tau = q.825)
df
