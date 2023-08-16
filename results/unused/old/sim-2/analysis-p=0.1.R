

#############
# CI WIDTHS #
#############

ci_widths <- list()
for (i in 1:length(sim2_n)) {
    ci_widths[[i]] <- matrix(nrow = length(sim2_mles[[i]]), ncol = length(theta))
    for (j in 1:length(sim2_mles[[i]])) {
        theta.hat <- algebraic.mle::mle_numerical(sim2_mles[[i]][[j]])
        # this is a m x 2 matrix, where m is the number of parameters
        ci <- confint(theta.hat, use_t_dist = FALSE)

        if (any(is.na(ci))) {
            next
        }

        ci_widths[[i]][j,] <- ci[,2] - ci[,1]
    }
}

###################################
# PLOT CONFIDENCE INTERVAL WIDTHS #
###################################

# Create a long-form data frame from your list
ci_widths_df <- do.call(rbind, lapply(seq_along(ci_widths), function(i) {
  data.frame(SampleSize = rep(sample_sizes[i], nrow(ci_widths[[i]])),
             CI_Width = as.vector(ci_widths[[i]]),
             Parameter = rep(seq(ncol(ci_widths[[i]])), each = nrow(ci_widths[[i]])),
             Type = rep(c("Shape", "Scale"), each = nrow(ci_widths[[i]]), times = ncol(ci_widths[[i]]) / 2))
}))

# Split the data frame based on parameter type (Scale or Shape)
ci_widths_list <- split(ci_widths_df, ci_widths_df$Type)

# scatter plot.
ggplot(ci_widths_list$Shape, aes(x = SampleSize, y = CI_Width)) +
    geom_point() +
    labs(x = "Sample Size", y = "Confidence Interval Width") +
    facet_wrap(~ Parameter, scales = "free") +
    theme_minimal()

ggplot(ci_widths_list$Scale, aes(x = SampleSize, y = CI_Width)) +
    geom_point() +
    labs(x = "Sample Size", y = "Confidence Interval Width") +
    facet_wrap(~ Parameter, scales = "free") +
    theme_minimal()

# Generate a plot for each type
plots <- lapply(ci_widths_list, function(df) {
  ggplot(df, aes(x = SampleSize, y = CI_Width, color = factor(Parameter))) +
    geom_line() + 
    #scale_y_log10() +
    labs(x = "Sample Size", y = "Confidence Interval Width", color = "Parameter") +
    facet_wrap(~ Type, scales = "free") +
    theme_minimal()
})

# Arrange the plots in a grid
grid.arrange(grobs = plots, ncol = 2)

############################
# PLOT CI WIDTH AGGREGATES #
############################
# Create a long-form data frame from your list
ci_widths_df <- do.call(rbind, lapply(seq_along(ci_widths), function(i) {
  data.frame(SampleSize = rep(sample_sizes[i], nrow(ci_widths[[i]])),
             CI_Width = as.vector(ci_widths[[i]]),
             Parameter = rep(seq(ncol(ci_widths[[i]])), each = nrow(ci_widths[[i]])),
             Type = rep(c("Shape", "Scale"), each = nrow(ci_widths[[i]]), times = ncol(ci_widths[[i]]) / 2))
}))

# Calculate mean CI width
ci_widths_df <- ci_widths_df %>%
  group_by(SampleSize, Parameter, Type) %>%
  summarise(Mean_CI_Width = mean(CI_Width), .groups = "drop")

# remove NA values
ci_widths_df <- na.omit(ci_widths_df)

# Split the data frame based on parameter type (Scale or Shape)
ci_widths_list <- split(ci_widths_df, ci_widths_df$Type)

ci_widths_list$Shape$Mean_CI_Width

# Generate a plot for each type
plots <- lapply(ci_widths_list, function(df) {
  ggplot(df, aes(x = SampleSize, y = Mean_CI_Width, color = factor(Parameter))) +
    geom_line() + 
    #scale_y_log10() +  # use a log scale for the y-axis
    labs(x = "Sample Size", y = "Mean Confidence Interval Width (log scale)", color = "Parameter") +
    theme_minimal()
})

# Arrange the plots in a grid
grid.arrange(grobs = plots, ncol = 2)


