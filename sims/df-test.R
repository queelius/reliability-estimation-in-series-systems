theta <- c(shape.1 = 1.2576, scale.1 = 994.3661,
           shape.2 = 1.1635, scale.2 = 908.9458,
           shape.3 = 1.1308, scale.3 = 840.1141,
           shape.4 = 1.1802, scale.4 = 940.1141,
           shape.5 = 1.3311, scale.5 = 836.1123)

shape <- theta[seq(1, length(theta), 2)]
scale <- theta[seq(2, length(theta), 2)]

df <- read.csv("data-boot.csv")

# grab rows where column `p` = 0 and column `q` = 1
df.ideal <- df[df$p == 0 & df$q == 1,]
df.ideal

df.ideal.shape <- df.ideal[,grep("mle.shape", colnames(df.ideal))]
df.ideal.shape




