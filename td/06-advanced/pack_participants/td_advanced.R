# =============================================================================
# Explaining heterogeneity in R — FRB-CESAB training course, Wed 16:33
# Work in pairs. Only TWO blanks (___) to fill (Exercises 1 and 3): the rest is
# given — run it line by line and discuss the questions (# Q:). Answers: web page.
# Data: Jones et al. (2021) Scientific Data 8:212 — intercropping vs monoculture
# =============================================================================

library(dplyr)
library(metafor)
library(ggplot2)

ic <- read.csv("intercropping_biodiversity.csv")

dat <- ic |>
  filter(functional_group %in% c("Pests", "Natural enemies"), !sd_missing, !zero_mean) |>
  escalc(measure = "ROM", m1i = b_mean_t, sd1i = b_sd_t, n1i = b_n_t,
         m2i = b_mean_c, sd2i = b_sd_c, n2i = b_n_c, data = _)

pct <- function(x) round(100 * (exp(x) - 1), 1)
fit <- function(d, mods = ~ 1)
  rma.mv(yi, vi, mods = mods, random = ~ 1 | study_id / es_id,
         data = d, test = "t", dfs = "contain")
table(dat$functional_group)

# --- 2. Meta-regression ----------------------------------------------------------
# Predict first: same effect on pests and natural enemies?
# Exercise 1
m0 <- fit(dat)
m1 <- fit(dat, mods = ~ ___)
m1            # Test of Moderators: F and p? What does functional_groupPests mean?
robust(m1, cluster = study_id, clubSandwich = TRUE)   # few studies: check with CR2

# Exercise 2 (code given): one estimate per group, and share of heterogeneity explained
m1b <- fit(dat, mods = ~ 0 + functional_group)
pct(coef(m1b))
R2 <- 1 - sum(m1$sigma2) / sum(m0$sigma2)
round(100 * R2, 1)
round(100 * (1 - m1$sigma2 / m0$sigma2), 1)   # by level: between studies, within studies
# Q: significant moderator... but how much heterogeneity does it explain? At which level?

# --- 3. Within-study check ----------------------------------------------------------
# Exercise 3: split the moderator into a within-study and a between-study part
dat <- dat |>
  mutate(pest = as.numeric(functional_group == "Pests")) |>
  group_by(study_id) |>
  mutate(pest_m = mean(pest),          # share of pest rows in the study (between)
         pest_w = pest - ___) |>       # deviation from the study mean (within)
  ungroup()
sum(tapply(dat$pest, dat$study_id, function(x) length(unique(x))) == 2)  # studies with both
m_wb <- fit(dat, mods = ~ pest_w + pest_m)
pct(coef(m_wb)[-1])
m_wb
# Q: do the within- and between-study differences agree? Which one is stronger evidence?

# (optional) Exercise 4: study quality as a moderator, natural enemies only
ne <- filter(dat, functional_group == "Natural enemies")
sum(is.na(ne$validity_biodiv))
pct(coef(fit(ne, mods = ~ 0 + factor(validity_biodiv))))
table(ne$validity_biodiv, useNA = "ifany"); tapply(ne$study_id, ne$validity_biodiv, function(x) length(unique(x)))
# Q: how many studies behind each level? How far would you trust this?

# --- 4. Missing SDs (pests) ---------------------------------------------------------
pz <- ic |> filter(functional_group == "Pests", !zero_mean)
c(total = nrow(pz), sd_missing = sum(pz$sd_missing))

# Exercise 5 (code given): check the coefficients of variation first
cvs <- pz |>
  filter(!sd_missing) |>
  mutate(cv_t = b_sd_t / b_mean_t, cv_c = b_sd_c / b_mean_c)
cvs |> group_by(study_id) |>
  summarise(cv = mean((cv_t + cv_c) / 2), n = mean(b_n_t)) |>
  arrange(desc(cv)) |> head(5)
# Q: which studies look implausible? What would you check in the paper?

# Exercise 6 (code given): impute and compare
suspect <- c(722, 729)                  # studies flagged in Exercise 5
# typical CV = mean CV weighted by n, per group, then squared
# (Nakagawa et al. 2023; what metafor does with vtype = "AV")
weighted.mean(cvs$cv_t, cvs$b_n_t)^2          # without the screen
ok   <- filter(cvs, !study_id %in% suspect)
cv2t <- weighted.mean(ok$cv_t, ok$b_n_t)^2
cv2c <- weighted.mean(ok$cv_c, ok$b_n_c)^2
c(cv2t, cv2c)                           # with the screen
pz <- pz |>
  mutate(yi = log(b_mean_t / b_mean_c),
         vi = ifelse(sd_missing,
                     cv2t / b_n_t + cv2c / b_n_c,
                     b_sd_t^2 / (b_n_t * b_mean_t^2) + b_sd_c^2 / (b_n_c * b_mean_c^2))) |>
  filter(!study_id %in% suspect)
table(pz$study_id[pz$sd_missing])       # where do the imputed rows come from?
m_cc  <- fit(filter(pz, !sd_missing))
m_imp <- fit(pz)
rbind(complete_cases = pct(c(m_cc$b,  m_cc$ci.lb,  m_cc$ci.ub)),
      with_imputed   = pct(c(m_imp$b, m_imp$ci.lb, m_imp$ci.ub)))
# Q: does the conclusion change? Where do the imputed rows come from? What would you report?
