# Runs automatically after `quarto render`.
# Copies every rendered file into diapos/, named after its session folder:
#   seances/01-introduction/slides.qmd  -> diapos/01-introduction.html
#   td/02-td-evidence-map/td.qmd        -> diapos/02-td-evidence-map_TD.html
# and builds the participant kit -> diapos/kit_meta_analysis_course_2026.zip
out <- Sys.getenv("QUARTO_PROJECT_OUTPUT_DIR", "_site")
dir.create("diapos", showWarnings = FALSE)
for (f in Sys.glob(file.path(out, c("seances", "td"), "*", "*.html"))) {
  session <- basename(dirname(f))
  kind    <- sub("\\.html$", "", basename(f))
  target  <- if (kind == "slides") paste0(session, ".html") else
             if (kind == "td") paste0(session, "_TD.html") else paste0(session, "_", kind, ".html")
  file.copy(f, file.path("diapos", target), overwrite = TRUE)
  message("diapos/", target)
}
# One kit for the whole week (scripts + data + install check)
source("R/build_kit.R")
