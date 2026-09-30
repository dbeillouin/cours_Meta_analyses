# Builds the single participant kit from the practical scripts and the data.
#   kit/meta_analysis_course_2026/  ->  diapos/kit_meta_analysis_course_2026.zip
# Run by R/post_render.R after `quarto render`; can also be run on its own.
kit  <- file.path("kit", "meta_analysis_course_2026")
dir.create(kit, recursive = TRUE, showWarnings = FALSE)
scripts <- Sys.glob(file.path("td", "*", "pack_participants", "td_*.R"))
file.copy(scripts, kit, overwrite = TRUE)
file.copy(file.path("donnees", "derivees", c("comparisons_all.csv", "intercropping_biodiversity.csv")),
          kit, overwrite = TRUE)
if (file.exists("diapos/03-effect-sizes_formula_sheet.pdf"))
  file.copy("diapos/03-effect-sizes_formula_sheet.pdf", file.path(kit, "formula_sheet.pdf"), overwrite = TRUE)
# README.txt, 00_install_and_check.R and the .Rproj are written by hand in kit/
unlink(file.path(kit, "Rplots.pdf"))
zipfile <- file.path(normalizePath("diapos"), "kit_meta_analysis_course_2026.zip")
unlink(zipfile)
old <- setwd("kit"); utils::zip(zipfile, "meta_analysis_course_2026", flags = "-rq9X"); setwd(old)
message("diapos/kit_meta_analysis_course_2026.zip")
