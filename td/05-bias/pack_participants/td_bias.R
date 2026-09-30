# =============================================================================
# Publication bias and sensitivity in R — FRB-CESAB training course, Wed 15:22
# Fill in the blanks (___). Solutions are in the practical web page.
# Data: Jones et al. (2021) Scientific Data 8:212 — intercropping vs monoculture
# =============================================================================

library(dplyr)
library(metafor)
library(ggplot2)

ic <- read.csv("intercropping_biodiversity.csv")

grp <- "Pests"   # <- section 6: change this word only, then rerun everything

dat <- ic |>
  filter(functional_group == grp, !sd_missing, !zero_mean) |>
  escalc(measure = "ROM", m1i = b_mean_t, sd1i = b_sd_t, n1i = b_n_t,
         m2i = b_mean_c, sd2i = b_sd_c, n2i = b_n_c, data = _) |>
  mutate(sei = sqrt(vi),                        # standard error
         se_n = sqrt(1 / b_n_t + 1 / b_n_c),   # precision from sample size only
         inv_n = 1 / b_n_t + 1 / b_n_c,
         year_c = year - mean(year))

pct <- function(x) round(100 * (exp(x) - 1), 1)

m <- rma.mv(yi, vi, random = ~ 1 | study_id / es_id, data = dat,
            test = "t", dfs = "contain")
pct(c(m$b, m$ci.lb, m$ci.ub))

# --- 2. Contour-enhanced funnel plot -------------------------------------------
# Exercise 1: contours centred on zero
funnel(dat$yi, dat$vi, yaxis = "sei",
       level = c(90, 95, 99), shade = c("white", "gray75", "gray90"),
       refline = ___, legend = TRUE, xlab = "lnRR")
# Q: where are the imprecise comparisons, and in which zone?

# --- 3. Small-study effects and time-lag -------------------------------------
regtest(rma(yi, vi, data = dat))   # classic Egger: ignores dependence!

# Exercise 2: multilevel Egger. For lnRR, the SE depends on the means (artefact):
# compare with a precision measure based on sample size only (se_n).
# Predict first: which one will look "more significant"?
pet_se <- rma.mv(yi, vi, mods = ~ sei,  random = ~ 1 | study_id / es_id,
                 data = dat, test = "t", dfs = "contain")
pet    <- rma.mv(yi, vi, mods = ~ ___, random = ~ 1 | study_id / es_id,
                 data = dat, test = "t", dfs = "contain")
round(c(slope_p_SE = pet_se$pval[2], slope_p_n = pet$pval[2]), 3)
robust(pet, cluster = study_id, clubSandwich = TRUE)

# PET-PEESE: would the conclusion change if there were bias?
peese <- rma.mv(yi, vi, mods = ~ inv_n, random = ~ 1 | study_id / es_id,
                data = dat, test = "t", dfs = "contain")
rbind(main  = pct(c(m$b, m$ci.lb, m$ci.ub)),
      PET   = pct(c(coef(pet)[1],   pet$ci.lb[1],   pet$ci.ub[1])),
      PEESE = pct(c(coef(peese)[1], peese$ci.lb[1], peese$ci.ub[1])))

# Exercise 3 (optional): time-lag bias
tl <- rma.mv(yi, vi, mods = ~ ___, random = ~ 1 | study_id / es_id,
             data = dat, test = "t", dfs = "contain")
tl

# --- 4. Sensitivity analyses ---------------------------------------------------
# Exercise 4: leave-one-STUDY-out (~1 min)
ids <- unique(dat$study_id)
loo <- sapply(ids, function(i) {
  f <- rma.mv(yi, vi, random = ~ 1 | study_id / es_id,
              data = dat[dat$study_id ___ i, ], test = "t", dfs = "contain")
  c(est = f$b[1], ci.lb = f$ci.lb, ci.ub = f$ci.ub)
})
pct(range(loo["est", ]))
any(loo["ci.ub", ] > 0)

# Exercise 5 (optional): influence
cd <- cooks.distance(m, cluster = dat$___)
sort(round(cd, 2), decreasing = TRUE)[1:5]

# Exercise 6: study quality
sum(is.na(dat$validity_biodiv))     # how many comparisons could not be appraised?
m_val <- rma.mv(yi, vi, random = ~ 1 | study_id / es_id,
                data = filter(dat, validity_biodiv == ___), test = "t", dfs = "contain")
pct(c(m_val$b, m_val$ci.lb, m_val$ci.ub))
# validity as a moderator (a real test, not two CIs compared by eye)
m_vmod <- rma.mv(yi, vi, mods = ~ factor(validity_biodiv), random = ~ 1 | study_id / es_id,
                 data = dat, test = "t", dfs = "contain")
m_vmod$pval[2]

# --- 5. (optional) Fail-safe N: why not -----------------------------------------------------
fsn(yi, vi, data = dat)
# Q: what does this number assume about the missing studies?

# --- 6. Your turn: natural enemies -----------------------------------------------
# Set grp <- "Natural enemies" at the top and rerun sections 1-3 (skip leave-one-out),
# then Exercise 6: does validity matter here?

# --- 15:55 Debrief: fill in your robustness table ----------------------------------
