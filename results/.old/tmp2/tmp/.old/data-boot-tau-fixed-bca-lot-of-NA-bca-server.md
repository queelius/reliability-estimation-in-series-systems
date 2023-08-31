
# Simulation study

Conducted on Proxmox machine.

n = 100, 200, 500
B = 500
p = .333

This run was a little unusual in that it generated a lot of NA values for the CI values. 
Initially, it had both `perc` and `bca` methods, but the `perc` was removed because
it only seemed worse, but that was just a very rough guess. I should have kept it in
and compared the two methods.

