# =============================================================================
# Meta-analysis course (FRB-CESAB 2026) — run this ONCE, before Monday.
# In RStudio: open meta_analysis_course.Rproj, open this file, click "Source".
# It installs what is missing (2-5 minutes the first time), then checks that
# everything works. At the end you should read: "All good".
# =============================================================================

# 1. R version: the course code uses the native pipe |> (R >= 4.1)
if (getRversion() < "4.1.0")
  stop("Your R is too old (", getRversion(), "). Please install R >= 4.1 from https://cran.r-project.org")

# 2. Packages
pkgs <- c("dplyr", "tidyr", "readr", "forcats", "scales", "ggplot2", "maps",
          "metafor", "clubSandwich")
missing <- setdiff(pkgs, rownames(installed.packages()))
if (length(missing)) {
  message("Installing: ", paste(missing, collapse = ", "))
  install.packages(missing)
}
invisible(lapply(pkgs, function(p) suppressPackageStartupMessages(library(p, character.only = TRUE))))

# 3. Data: both files must sit next to this script
stopifnot("comparisons_all.csv not found: open meta_analysis_course.Rproj first" =
            file.exists("comparisons_all.csv"),
          file.exists("intercropping_biodiversity.csv"))
ic  <- read.csv("intercropping_biodiversity.csv")
dat <- ic |>
  filter(functional_group == "Pests", !sd_missing, !zero_mean) |>
  escalc(measure = "ROM", m1i = b_mean_t, sd1i = b_sd_t, n1i = b_n_t,
         m2i = b_mean_c, sd2i = b_sd_c, n2i = b_n_c, data = _)

# 4. The model of the week, and its cluster-robust check
m <- rma.mv(yi, vi, random = ~ 1 | study_id / es_id, data = dat,
            test = "t", dfs = "contain")
r <- robust(m, cluster = study_id, clubSandwich = TRUE)

# 5. A plot
print(ggplot(map_data("world"), aes(long, lat, group = group)) +
        geom_polygon(fill = "grey80", colour = "white") + coord_quickmap() +
        ggtitle("Your installation works"))

message("\nAll good. Pests under intercropping: ",
        round(100 * (exp(coef(m)) - 1)), "% (", nrow(dat), " comparisons, ",
        length(unique(dat$study_id)), " studies). See you on Monday!")
