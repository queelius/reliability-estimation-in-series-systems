## Simulation details for `data-boot-tau-fixed-bca-100.md`

This was conducted on Proxmox machine.

Simulation details:

theta <- c(shape1 = 1.2576, scale1 = 994.3661,
           shape2 = 1.1635, scale2 = 908.9458,
           shape3 = 1.1308, scale3 = 840.1141,
           shape4 = 1.1802, scale4 = 940.1342,
           shape5 = 1.2034, scale5 = 923.1631)

n_cores <- 3

N <- rep(1000, 10)
P <- c(.215, .333)
Q <- c(.825)
R <- 10
B <- 750
max_iter <- 150L
max_boot_iter <- 150L

bootstrap method: percentile (`perc`)
bootstrap confidence level: 0.95

- only accepted converged MLEs for MC replicate (R)
- for each bootstrap replicate (B), accepted both converged and non-converged MLEs

