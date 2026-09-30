# Shared ggplot2 look for all course figures (FRB-CESAB 2026 palette)
cesab <- c(blue = "#045C82", teal = "#56B8B9", green = "#86BC25",
           lime = "#BCCF00", ink = "#1F2A33", grey = "#5B6770",
           light = "#EEF5F7", warn = "#C0392B")

theme_cesab <- function(base_size = 20) {
  ggplot2::theme_minimal(base_size = base_size, base_family = "Poppins") +
    ggplot2::theme(
      text             = ggplot2::element_text(colour = cesab[["ink"]]),
      axis.text        = ggplot2::element_text(colour = cesab[["grey"]]),
      axis.title       = ggplot2::element_text(colour = cesab[["ink"]]),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(colour = "#E3ECEF", linewidth = 0.4),
      plot.title       = ggplot2::element_text(colour = cesab[["blue"]], face = "bold"),
      plot.title.position = "plot",
      legend.position  = "top",
      legend.justification = "left",
      plot.background  = ggplot2::element_rect(fill = "transparent", colour = NA),
      panel.background = ggplot2::element_rect(fill = "transparent", colour = NA)
    )
}

# percent change from a log response ratio
pct <- function(lnrr, digits = 0) {
  v <- 100 * (exp(lnrr) - 1)
  paste0(ifelse(v > 0, "+", ""), formatC(v, format = "f", digits = digits), "%")
}
