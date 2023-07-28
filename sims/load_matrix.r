# print current working dir
print(getwd())

# Read the file into a data frame
df <- read.table("/home/spinoza/github/private/proj/sims/boots.txt", header = TRUE)

# Convert the data frame to a matrix
mat <- as.matrix(df)
print(mat)
colnames(mat) <- NULL
row.names(mat) <- NULL
mat
cov(mat)

# from the covarniance, estimate the sd
sd1 <- sqrt(diag(cov(mat)))
sd1

means <- colMeans(mat)
# from the sd, estimate the 95% CIs
lower1 <- means - 1.96 * sd1
upper1 <- means + 1.96 * sd1

c(lower1, upper1)


sd2 <- sd(mat)