# =============================================================================
# Mapping the evidence with R — FRB-CESAB training course, Tuesday 14:00
# Fill in the blanks (___). Solutions are in the practical web page.
# Data: Jones et al. (2021) Scientific Data 8:212 — one row = one comparison
# =============================================================================

library(dplyr)
library(tidyr)
library(ggplot2)
library(forcats)

comp <- readr::read_csv("comparisons_all.csv", show_col_types = FALSE)
dim(comp)

# --- 2. Count studies, not rows ----------------------------------------------
comp |>
  group_by(year) |>
  summarise(rows = n(), studies = n_distinct(study_id)) |>
  arrange(desc(rows)) |>
  head(5)
# What happened in 1992?

# --- 3. Exercise 1: your first evidence map ----------------------------------
# Step 1: number of STUDIES per practice x comparator, keeping empty cells
map_data_1 <- comp |>
  distinct(___, practice, comparator_system) |>
  count(practice, comparator_system, name = "n_studies") |>
  complete(___, ___, fill = list(n_studies = 0))

# Step 2: the heat map
ggplot(map_data_1, aes(x = ___, y = ___, fill = n_studies)) +
  geom_tile(colour = "white") +
  geom_text(aes(label = ___)) +
  scale_fill_gradient(low = "#F4F7F8", high = "#045C82") +
  labs(x = "Comparator", y = "Diversification practice", fill = "Studies")

# Interpret: one cluster? one gap? Is a big number a big effect?

# --- 4. Exercise 2 (pairs): add a third dimension — choose A or B -------------

# Option A: practice x functional group, one panel per comparator
map_data_2 <- comp |>
  filter(comparator_system %in% c("Monoculture", "Natural")) |>
  distinct(study_id, practice, functional_group, comparator_system) |>
  count(practice, functional_group, comparator_system, name = "n_studies") |>
  complete(practice, functional_group, comparator_system, fill = list(n_studies = 0))

ggplot(map_data_2, aes(x = ___, y = ___, fill = n_studies)) +
  geom_tile(colour = "white") +
  geom_text(aes(label = n_studies), size = 3) +
  scale_fill_gradient(low = "#F4F7F8", high = "#045C82") +
  facet_wrap(~ ___) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Option B: bubble map — size = number of studies, colour = share of valid comparisons
# (validity computed per study first, otherwise big studies dominate)
map_data_3 <- comp |>
  group_by(practice, comparator_system, study_id) |>
  summarise(valid = mean(validity_biodiv == 1, na.rm = TRUE), .groups = "drop") |>
  group_by(practice, comparator_system) |>
  summarise(n_studies   = n_distinct(___),
            share_valid = mean(valid, na.rm = TRUE),
            share_na    = mean(is.nan(valid)),     # studies that could not be appraised
            .groups = "drop")

ggplot(map_data_3, aes(comparator_system, practice)) +
  geom_point(aes(size = ___, colour = ___)) +
  scale_size_area(max_size = 18) +
  scale_colour_viridis_c(direction = -1, labels = scales::percent)   # colour-blind safe

# Before sharing: write 3 sentences for a decision-maker
# (one cluster, one gap, how reliable the evidence is)

# --- 7. Bonus: where and when? -------------------------------------------------
world <- map_data("world")
setdiff(unique(comp$country), unique(world$region))   # which countries would vanish?
# -> recode their names, count studies per country, join, and draw with geom_polygon()

comp |>
  distinct(study_id, year, practice) |>
  count(practice, year) |>
  group_by(practice) |>
  arrange(year) |>
  mutate(cumulative = ___(n)) |>
  ggplot(aes(year, cumulative, colour = practice)) +
  geom_step(linewidth = 1)
