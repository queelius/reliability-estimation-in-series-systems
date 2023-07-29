# Load data
library(wei.series.md.c1.c2.c3)
df <- guo_weibull_series_md
# resample from df

theta <- c(shape1 = 1.2576, scale1 = 994.3661,
           shape2 = 1.1635, scale2 = 908.9458,
           shape3 = 1.1308, scale3 = 840.1141,
           shape4 = 1.1802, scale4 = 940.1141,
           shape5 = 1.3311, scale5 = 836.1123)

shapes <- theta[seq(1, length(theta), 2)]
scales <- theta[seq(2, length(theta), 2)]


k <- 0L
R <- 10000
n <- 30
q <- 0.75
p <- 0.3
for (i in 1:R) {
    wei.series.md.c1.c2.c3::generate_guo_weibull_table_2_data(
        n = n,
        tau = qwei_series(
            p = q,
            shapes = guo_weibull_series_mle$shape_mles,
            scales = guo_weibull_series_mle$scale_mles),
        p = p)
    is <- sample.int(n = nrow(df), size = n, replace = TRUE)
    dfi <- df[is, ]
    good <- md_bernoulli_cand_c1_c2_c3_identifiable(dfi)
    if (good) {
        k <- k + 1L
    }
    if (i %% 1000 == 0) {
        cat(k / i, "\n")
    }
}














remove_outliers_sd <- function(df, col) {
    mean_col <- mean(df[[col]], na.rm = TRUE)
    sd_col <- sd(df[[col]], na.rm = TRUE)
    df <- df[abs(df[[col]] - mean_col) <= 3*sd_col, ]
    return(df)
}






library(tidyverse)
library(stats)
library(algebraic.mle)
library(algebraic.dist)
library(md.tools)
library(wei.series.md.c1.c2.c3)

theta <- c(shape1 = 1.2576, scale1 = 994.3661,
           shape2 = 1.1635, scale2 = 908.9458,
           shape3 = 1.1308, scale3 = 840.1141,
           shape4 = 1.1802, scale4 = 940.1342,
           shape5 = 1.2034, scale5 = 923.1631)

shapes <- theta[seq(1, length(theta), 2)]
scales <- theta[seq(2, length(theta), 2)]

df <- read.csv("./sims/data-boot-q-fixed-bca.csv")
df.new <- data.frame()
for (n in unique(df$n)) {
    for (p in unique(df$p)) {
        df.np <- df[df$n == n & df$p == p, ]

        df.shapes <- df.np %>% select(starts_with("shapes"))
        #df.shapes <- remove_outliers_sd(df.shapes, "shapes.1")
        #df.shapes <- remove_outliers_sd(df.shapes, "shapes.2")
        #df.shapes <- remove_outliers_sd(df.shapes, "shapes.3")
        #df.shapes <- remove_outliers_sd(df.shapes, "shapes.4")
        #df.shapes <- remove_outliers_sd(df.shapes, "shapes.5")
        df.shapes <- df.shapes %>% mutate(shapes.covers.1 = shapes.lower.1 <= shapes[1] & shapes[1] <= shapes.upper.1)
        df.shapes <- df.shapes %>% mutate(shapes.covers.2 = shapes.lower.2 <= shapes[2] & shapes[2] <= shapes.upper.2)
        df.shapes <- df.shapes %>% mutate(shapes.covers.3 = shapes.lower.3 <= shapes[3] & shapes[3] <= shapes.upper.3)
        df.shapes <- df.shapes %>% mutate(shapes.covers.4 = shapes.lower.4 <= shapes[4] & shapes[4] <= shapes.upper.4)
        df.shapes <- df.shapes %>% mutate(shapes.covers.5 = shapes.lower.5 <= shapes[5] & shapes[5] <= shapes.upper.5)
        # compute coverage probability
        shapes.cp.1 <- mean(df.shapes$shapes.covers.1)
        shapes.cp.2 <- mean(df.shapes$shapes.covers.2)
        shapes.cp.3 <- mean(df.shapes$shapes.covers.3)
        shapes.cp.4 <- mean(df.shapes$shapes.covers.4)
        shapes.cp.5 <- mean(df.shapes$shapes.covers.5)
        shapes.cp <- c(shapes.cp.1, shapes.cp.2, shapes.cp.3, shapes.cp.4, shapes.cp.5)
        shapes.mu <- c(mean(df.shapes$shapes.1), mean(df.shapes$shapes.2), mean(df.shapes$shapes.3), mean(df.shapes$shapes.4), mean(df.shapes$shapes.5))

        df.scales <- df.np %>% select(starts_with("scales"))
        #df.scales <- remove_outliers_sd(df.scales, "scales.1")
        #df.scales <- remove_outliers_sd(df.scales, "scales.2")
        #df.scales <- remove_outliers_sd(df.scales, "scales.3")
        #df.scales <- remove_outliers_sd(df.scales, "scales.4")
        #df.scales <- remove_outliers_sd(df.scales, "scales.5")
        df.scales <- df.scales %>% mutate(scales.covers.1 = scales.lower.1 <= scales[1] & scales[1] <= scales.upper.1)
        df.scales <- df.scales %>% mutate(scales.covers.2 = scales.lower.2 <= scales[2] & scales[2] <= scales.upper.2)
        df.scales <- df.scales %>% mutate(scales.covers.3 = scales.lower.3 <= scales[3] & scales[3] <= scales.upper.3)
        df.scales <- df.scales %>% mutate(scales.covers.4 = scales.lower.4 <= scales[4] & scales[4] <= scales.upper.4)
        df.scales <- df.scales %>% mutate(scales.covers.5 = scales.lower.5 <= scales[5] & scales[5] <= scales.upper.5)

        # compute coverage probability
        scales.cp.1 <- mean(df.scales$scales.covers.1)
        scales.cp.2 <- mean(df.scales$scales.covers.2)
        scales.cp.3 <- mean(df.scales$scales.covers.3)
        scales.cp.4 <- mean(df.scales$scales.covers.4)
        scales.cp.5 <- mean(df.scales$scales.covers.5)
        scales.cp <- c(scales.cp.1, scales.cp.2, scales.cp.3, scales.cp.4, scales.cp.5)
        scales.mu <- c(mean(df.scales$scales.1), mean(df.scales$scales.2), mean(df.scales$scales.3), mean(df.scales$scales.4), mean(df.scales$scales.5))

        # add row to new data frame
        row <- data.frame(n = n, p = p, shapes.cp = shapes.cp, scales.cp = scales.cp, shapes.mu = shapes.mu, scales.mu = scales.mu)
        df.new <- rbind(df.new, row)
    }
}



unique(df$n)
