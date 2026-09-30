# =============================================================================
# 00_prepare_data.R — Build the "running example" datasets used all week
# -----------------------------------------------------------------------------
# Source: Jones SK, Sánchez AC, Juventia SD, Estrada-Carmona N (2021).
#   A global database of diversified farming effects on biodiversity and yield.
#   Scientific Data 8: 212. https://doi.org/10.1038/s41597-021-01000-y
#
# Question followed throughout the course:
#   "Does diversifying farming systems benefit biodiversity without costing yield?"
#
# This script is the ONLY place where the raw files are modified. Every derived
# file used in lectures and practicals is produced here, so any number shown in
# the slides can be traced back to the raw data.
#
# Inputs  : donnees/brutes/jones2021_dataset1_sources.xlsx   (screening records)
#           donnees/brutes/jones2021_dataset2_outcomes.xlsx  (extracted comparisons)
# Outputs : donnees/derivees/*.csv  (see the list at the end of the script)
# =============================================================================

suppressPackageStartupMessages({
  library(readxl)
  library(dplyr)
  library(tidyr)
  library(readr)
})

raw_dir <- "donnees/brutes"
out_dir <- "donnees/derivees"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

to_num <- function(x) suppressWarnings(as.numeric(x))
na_nd  <- function(x) {
  x <- trimws(as.character(x))
  x[x %in% c("nd", "NA", "")] <- NA
  x
}

# -----------------------------------------------------------------------------
# 1. Screening records -> PRISMA counts (Monday: searching / screening)
# -----------------------------------------------------------------------------
sources <- read_excel(file.path(raw_dir, "jones2021_dataset1_sources.xlsx"),
                      sheet = "Literature_screened")

screening <- sources |>
  transmute(record_id        = ID,
            source           = Article_source,
            included         = Inclusion_yes_no == "Yes",
            exclusion_reason = Exclusion_reasion_pico,  # (sic) raw column name
            year             = Year,
            authors          = Authors,
            title            = Title,
            doi              = DOI)

write_csv(screening, file.path(out_dir, "screening_records.csv"))

# -----------------------------------------------------------------------------
# 2. All extracted comparisons, cleaned (Tuesday: evidence map)
#    One row = one comparison (intervention vs comparator) for one outcome.
#    NB: rows are NOT studies. `study_id` identifies the article.
# -----------------------------------------------------------------------------
outcomes <- read_excel(file.path(raw_dir, "jones2021_dataset2_outcomes.xlsx"),
                       sheet = "Data")

comparisons <- outcomes |>
  mutate(es_id = row_number()) |>
  transmute(
    es_id,
    study_id          = ID,
    authors           = Authors,
    year              = to_num(Year),
    country           = Country,
    lat               = to_num(Lat_T),
    long              = to_num(Long_T),
    # design
    comparator_class  = Comparison_class_C,   # Simplified / Natural
    comparator_system = System_C,             # e.g. Monoculture
    practice          = System_T,             # diversification practice
    crop              = Crop_T,
    comparator_id     = paste(ID, Comparison_ID_C, sep = "_"),  # shared controls
    treatment_id      = paste(ID, Comparison_ID_T, sep = "_"),
    # biodiversity outcome
    taxa_class        = Taxa_class,
    functional_group  = Functional_group,
    b_measure         = trimws(B_measure),
    b_error_reported  = tolower(trimws(B_error_measure_C)),
    b_mean_t = to_num(B_value_T), b_sd_t = to_num(B_SD_T), b_n_t = to_num(B_N_T),
    b_mean_c = to_num(B_value_C), b_sd_c = to_num(B_SD_C), b_n_c = to_num(B_N_C),
    # yield outcome (only reported for a subset)
    yield_unit        = Yield_measure,
    y_mean_t = to_num(Yield_value_T), y_sd_t = to_num(Yield_SD_T), y_n_t = to_num(Yield_N_T),
    y_mean_c = to_num(Yield_value_C), y_sd_c = to_num(Yield_SD_C), y_n_c = to_num(Yield_N_C),
    # validity (critical appraisal, coded by the authors: 1 = all criteria met)
    validity_biodiv   = na_nd(Validity_biodiversity_overall),
    validity_yield    = na_nd(Validity_yield_overall)
  ) |>
  mutate(b_measure = case_when(
    tolower(b_measure) == "species richness" ~ "Species richness",
    tolower(b_measure) == "shannon index"    ~ "Shannon index",
    TRUE ~ b_measure))

write_csv(comparisons, file.path(out_dir, "comparisons_all.csv"))

# -----------------------------------------------------------------------------
# 3. Focal meta-analysis dataset (Wednesday: effect sizes, models, bias,
#    meta-regression, missing data)
#    Intercropping vs monoculture, biodiversity = abundance or species richness.
#    Raw means / SDs / n are kept so that students compute effect sizes.
# -----------------------------------------------------------------------------
intercrop <- comparisons |>
  filter(practice == "Intercropping",
         comparator_system == "Monoculture",
         b_measure %in% c("Abundance", "Species richness")) |>
  mutate(
    sd_missing   = !(b_sd_t > 0 & b_sd_c > 0),   # 0 or NA SD = not usable
    zero_mean    = b_mean_t <= 0 | b_mean_c <= 0 # lnRR undefined
  )

write_csv(intercrop, file.path(out_dir, "intercropping_biodiversity.csv"))

# Biodiversity + yield on the same comparison (Wednesday late: "beyond yield")
tradeoff <- comparisons |>
  filter(comparator_system == "Monoculture",
         b_mean_t > 0, b_mean_c > 0, b_sd_t > 0, b_sd_c > 0,
         y_mean_t > 0, y_mean_c > 0)

write_csv(tradeoff, file.path(out_dir, "biodiversity_yield_pairs.csv"))

# -----------------------------------------------------------------------------
# 4. Log of what was produced (printed when the script is run)
# -----------------------------------------------------------------------------
summ <- function(d) sprintf("%5d rows | %3d studies", nrow(d), n_distinct(d$study_id))
message("screening_records.csv        : ", nrow(screening), " records, ",
        sum(screening$included), " included")
message("comparisons_all.csv          : ", summ(comparisons))
message("intercropping_biodiversity.csv: ", summ(intercrop),
        " | SD missing: ", round(100 * mean(intercrop$sd_missing), 1), "%",
        " | zero means: ", sum(intercrop$zero_mean, na.rm = TRUE))
message("biodiversity_yield_pairs.csv : ", summ(tradeoff))

# -----------------------------------------------------------------------------
# 5. Copy the data needed by each participant pack
# -----------------------------------------------------------------------------
packs <- c("td/02-td-evidence-map/pack_participants" = "comparisons_all.csv",
           "td/04-models/pack_participants"          = "intercropping_biodiversity.csv",
           "td/05-bias/pack_participants"            = "intercropping_biodiversity.csv",
           "td/06-advanced/pack_participants"        = "intercropping_biodiversity.csv")
for (p in names(packs)) {
  if (dir.exists(p)) file.copy(file.path(out_dir, packs[[p]]), p, overwrite = TRUE)
}
