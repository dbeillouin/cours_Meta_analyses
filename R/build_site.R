# Builds the course website in docs/ (published by GitHub Pages).
# Run after `quarto render`:  Rscript R/build_site.R
system("quarto render site")                       # home page -> docs/index.html
files <- list.files("diapos", full.names = TRUE)   # slides, practicals, PDFs, kit
file.copy(files, "docs", overwrite = TRUE)
file.create(file.path("docs", ".nojekyll"))
message("docs/ ready: ", length(files) + 1, " files")
