library(dplyr)
library(wei.series.md.c1.c2.c3)


data <- read.csv("./results/data/data_boot.csv", header = TRUE)
data <- data[data$q == .8,]
data <- data[data$n == 250,]
colnames(data)
summary(data)

# Convert TRUE/FALSE to 1/0
data$coverages.1 <- as.integer(data$coverages.1)
data$coverages.2 <- as.integer(data$coverages.2)
data$coverages.3 <- as.integer(data$coverages.3)
data$coverages.4 <- as.integer(data$coverages.4)
data$coverages.5 <- as.integer(data$coverages.5)
data$coverages.6 <- as.integer(data$coverages.6)
data$coverages.7 <- as.integer(data$coverages.7)
data$coverages.8 <- as.integer(data$coverages.8)
data$coverages.9 <- as.integer(data$coverages.9)
data$coverages.10 <- as.integer(data$coverages.10)



# Convert TRUE/FALSE to 1/0
# Repeat for all coverages.j columns

# Compute coverage probability for each p and n
#data_grouped <- data %>%
#  group_by(p, n) %>%
#  summarise(across(starts_with("coverages"), mean))

data_grouped <- data %>%
  group_by(p) %>%
  summarise(across(starts_with("coverages"), mean))


# Fit regression model
model <- lm(coverages.1 ~ p, data = data_grouped)
summary(model)

ggplot(data_grouped, aes(x = p, y = coverages.1)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  labs(x = "Masking Probability", y = "Coverage Probability") +
  theme_minimal()
