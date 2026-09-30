# Run this ONCE before the practical (takes 1-3 minutes).
pkgs <- c("dplyr", "tidyr", "readr", "ggplot2", "forcats", "scales", "maps")
missing <- setdiff(pkgs, rownames(installed.packages()))
if (length(missing)) install.packages(missing)

# Check: this should draw a world map in the Plots pane
library(ggplot2)
ggplot(map_data("world"), aes(long, lat, group = group)) +
  geom_polygon(fill = "grey80", colour = "white") +
  coord_quickmap() +
  ggtitle("Your installation works!")
