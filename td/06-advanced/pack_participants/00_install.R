# Run this ONCE before the practical (1-3 minutes).
pkgs <- c("dplyr", "ggplot2", "metafor", "clubSandwich")
missing <- setdiff(pkgs, rownames(installed.packages()))
if (length(missing)) install.packages(missing)

# Check: this should print a small meta-analysis
library(metafor)
rma(yi = c(-0.2, -0.4, 0.1), vi = c(0.02, 0.05, 0.03))
