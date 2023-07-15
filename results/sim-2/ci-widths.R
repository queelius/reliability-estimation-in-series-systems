# in this simulation, we have no right censoring and vary sample sizes.
# we want to see the CI width in this case as a function of
# masking component cause of failure p from p = 0 to p = 0.4.
# we have R = 100 replicates for each p.
library(patchwork)
library(cowplot)
library(reshape2)
library(gridExtra)  # for arranging plots
library(ggplot2)
library(tidyverse)
library(dplyr)
library(algebraic.mle)
library(algebraic.dist)
library(md.tools)
library(wei.series.md.c1.c2.c3)

theta <- c(shape1 = 1.2576, scale1 = 994.3661,
           shape2 = 1.1635, scale2 = 908.9458,
           shape3 = 1.1308, scale3 = 840.1141,
           shape4 = 1.1802, scale4 = 940.1141,
           shape5 = 1.3311, scale5 = 836.1123)

shapes <- theta[seq(1, length(theta), 2)]
scales <- theta[seq(2, length(theta), 2)]
sim2_n <- c(30, 40, 50, 75, 100, 200, 400, 800)

#############
# CI WIDTHS #
#############

gen_ci_width <- function(sim_p_mles, sim_p) {

    ci_widths <- list()

    for (i in 1:length(sim_p)) {

        ci_widths[[i]] <- matrix(nrow = length(sim_p_mles[[i]]), ncol = length(theta))

        for (j in 1:length(sim_p_mles[[i]])) {
            theta.hat <- algebraic.mle::mle_numerical(sim_p_mles[[i]][[j]])
            # this is a m x 2 matrix, where m is the number of parameters
            ci <- confint(theta.hat, use_t_dist = FALSE)

            if (any(is.na(ci))) {
                next
            }

            ci_widths[[i]][j,] <- ci[,2] - ci[,1]
        }
    }

    return(ci_widths)
}

###################################
# PLOT CONFIDENCE INTERVAL WIDTHS #
###################################


gen_ci_width_plot <- function(ci_widths, sim_n, p) {

    ci_widths_df <- do.call(rbind, lapply(seq_along(ci_widths), function(i) {
    data.frame(SampleSize = rep(sim_n[i], nrow(ci_widths[[i]])),
                CI_Width = as.vector(ci_widths[[i]]),
                Parameter = rep(seq(ncol(ci_widths[[i]])), each = nrow(ci_widths[[i]])),
                Type = rep(c("Shape", "Scale"), each = nrow(ci_widths[[i]]), times = ncol(ci_widths[[i]]) / 2))
    }))

    # Split the data frame based on parameter type (Scale or Shape)
    ci_widths_list <- split(ci_widths_df, ci_widths_df$Type)
    # Generate a plot for each type, using a log y scale
    plots <- lapply(ci_widths_list, function(df) {
        ggplot(df, aes(x = SampleSize, y = CI_Width, color = factor(Parameter))) +
            geom_line() + 
            scale_y_log10() +
            labs(title = paste("Masking Probability", p),
                x = "Sample Size", y = "Confidence Interval Width", color = "Parameter") +
            facet_wrap(~ Type, scales = "free") +
            theme_minimal()
    })

    # Arrange the plots in a grid
    grid.arrange(grobs = plots, ncol = 2)
}


###########
# p = 0.1 #
###########

sim2_30_0.1 <- readRDS("results/sim-2/results_30_0.1_1.rds")
sim2_40_0.1 <- readRDS("results/sim-2/results_40_0.1_1.rds")
sim2_50_0.1 <- readRDS("results/sim-2/results_50_0.1_1.rds")
sim2_75_0.1 <- readRDS("results/sim-2/results_75_0.1_1.rds")
sim2_100_0.1 <- readRDS("results/sim-2/results_100_0.1_1.rds")
sim2_200_0.1 <- readRDS("results/sim-2/results_200_0.1_1.rds")
sim2_400_0.1 <- readRDS("results/sim-2/results_400_0.1_1.rds")
sim2_800_0.1 <- readRDS("results/sim-2/results_800_0.1_1.rds")


sim2_p_0.1_mles <- list(sim2_30_0.1$mles, sim2_40_0.1$mles, sim2_50_0.1$mles,
    sim2_75_0.1$mles, sim2_100_0.1$mles, sim2_200_0.1$mles, sim2_400_0.1$mles,
    sim2_800_0.1$mles)
ci_width_0.1 <- gen_ci_width(sim2_p_0.1_mles, sim2_n)
plts_p_0.1 <- gen_ci_width_plot(ci_width_0.1, sim2_n, 0.1)


###########
# p = 0.2 #
###########
sim2_30_0.2 <- readRDS("results/sim-2/results_30_0.2_1.rds")
sim2_40_0.2 <- readRDS("results/sim-2/results_40_0.2_1.rds")
sim2_50_0.2 <- readRDS("results/sim-2/results_50_0.2_1.rds")
sim2_75_0.2 <- readRDS("results/sim-2/results_75_0.2_1.rds")
sim2_100_0.2 <- readRDS("results/sim-2/results_100_0.2_1.rds")
sim2_200_0.2 <- readRDS("results/sim-2/results_200_0.2_1.rds")
sim2_400_0.2 <- readRDS("results/sim-2/results_400_0.2_1.rds")
sim2_800_0.2 <- readRDS("results/sim-2/results_800_0.2_1.rds")

sim2_p_0.2_mles <- list(sim2_30_0.2$mles, sim2_40_0.2$mles, sim2_50_0.2$mles,
    sim2_75_0.2$mles, sim2_100_0.2$mles, sim2_200_0.2$mles, sim2_400_0.2$mles,
    sim2_800_0.2$mles)

ci_width_0.2 <- gen_ci_width(sim2_p_0.2_mles, sim2_n)
plts_p_0.2 <- gen_ci_width_plot(ci_width_0.2, sim2_n, , 0.2)


###########
# p = 0.3 #
###########
sim2_30_0.3 <- readRDS("results/sim-2/results_30_0.3_1.rds")
sim2_40_0.3 <- readRDS("results/sim-2/results_40_0.3_1.rds")
sim2_50_0.3 <- readRDS("results/sim-2/results_50_0.3_1.rds")
sim2_75_0.3 <- readRDS("results/sim-2/results_75_0.3_1.rds")
sim2_100_0.3 <- readRDS("results/sim-2/results_100_0.3_1.rds")
sim2_200_0.3 <- readRDS("results/sim-2/results_200_0.3_1.rds")
sim2_400_0.3 <- readRDS("results/sim-2/results_400_0.3_1.rds")
sim2_800_0.3 <- readRDS("results/sim-2/results_800_0.3_1.rds")

sim2_p_0.3_mles <- list(sim2_30_0.3$mles, sim2_40_0.3$mles, sim2_50_0.3$mles,
    sim2_75_0.3$mles, sim2_100_0.3$mles, sim2_200_0.3$mles, sim2_400_0.3$mles,
    sim2_800_0.3$mles)

ci_width_0.3 <- gen_ci_width(sim2_p_0.3_mles, sim2_n)
plts_p_0.3 <- gen_ci_width_plot(ci_width_0.3, sim2_n, , 0.3)

###########
# p = 0.4 #
###########
sim2_30_0.4 <- readRDS("results/sim-2/results_30_0.4_1.rds")
sim2_40_0.4 <- readRDS("results/sim-2/results_40_0.4_1.rds")
sim2_50_0.4 <- readRDS("results/sim-2/results_50_0.4_1.rds")
sim2_75_0.4 <- readRDS("results/sim-2/results_75_0.4_1.rds")
sim2_100_0.4 <- readRDS("results/sim-2/results_100_0.4_1.rds")
sim2_200_0.4 <- readRDS("results/sim-2/results_200_0.4_1.rds")
sim2_400_0.4 <- readRDS("results/sim-2/results_400_0.4_1.rds")
sim2_800_0.4 <- readRDS("results/sim-2/results_800_0.4_1.rds")

sim2_p_0.4_mles <- list(sim2_30_0.4$mles, sim2_40_0.4$mles, sim2_50_0.4$mles,
    sim2_75_0.4$mles, sim2_100_0.4$mles, sim2_200_0.4$mles, sim2_400_0.4$mles,
    sim2_800_0.4$mles)

ci_width_0.4 <- gen_ci_width(sim2_p_0.4_mles, sim2_n)
plts_p_0.4 <- gen_ci_width_plot(ci_width_0.4, sim2_n, 0.4)


###########
# plot all together, plts_p_0.1 to plts_p_0.4
###########

ci_plots <- plot_grid(plts_p_0.1, plts_p_0.2, plts_p_0.3, plts_p_0.4, ncol = 1)
ggsave("results/sim-2/ci-widths.pdf", ci_plots)
