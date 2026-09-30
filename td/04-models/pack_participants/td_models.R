# =============================================================================
# Pooling effect sizes in R — FRB-CESAB training course, Wednesday 14:25
# Fill in the blanks (___). Solutions are in the practical web page.
# Data: Jones et al. (2021) Scientific Data 8:212 — intercropping vs monoculture
# =============================================================================

library(dplyr)
library(metafor)
library(ggplot2)

ic <- read.csv("intercropping_biodiversity.csv")

grp <- "Pests"   # <- section 6: change this word only, then rerun everything

sub <- ic |> filter(functional_group == grp, !sd_missing, !zero_mean)

dat <- escalc(measure = "ROM",
              m1i = b_mean_t, sd1i = b_sd_t, n1i = b_n_t,
              m2i = b_mean_c, sd2i = b_sd_c, n2i = b_n_c,
              data = sub)
c(comparisons = nrow(dat), studies = n_distinct(dat$study_id))

pct <- function(x) round(100 * (exp(x) - 1), 1)   # lnRR -> % change

# --- 2. Common vs random effects ---------------------------------------------
# Exercise 1
m_ee <- rma(yi, vi, data = dat, method = "___")
m_re <- rma(yi, vi, data = dat, test = "knha")   # knha: safer CI (Knapp-Hartung)
pct(c(m_ee$b, m_ee$ci.lb, m_ee$ci.ub))
pct(c(m_re$b, ___, ___))
# Q: why is the common-effect CI so narrow?

# Exercise 2: who dominates?
w_ee <- 1 / dat$vi
w_re <- 1 / (dat$vi + m_re$___)
share <- function(w) sort(round(100 * tapply(w, dat$study_id, sum) / sum(w), 1), decreasing = TRUE)
head(share(w_ee), 3)
head(share(w_re), 3)
# Q: which study dominates in each model, and why?

# --- 3. Heterogeneity and prediction interval --------------------------------
m_re                       # find tau^2, I^2, Q
# Exercise 3
pr <- predict(m_re)
pct(c(mean = pr$pred, ci.lb = pr$ci.lb, ci.ub = pr$ci.ub, pi.lb = pr$___, pi.ub = pr$___))
# Q: a farmer asks whether intercropping will reduce pests on HER farm. What do you answer?

# --- 4. Multilevel model and robust inference --------------------------------
# Exercise 4
m_ml <- rma.mv(yi, vi, random = ~ 1 | ___ / ___, data = dat, test = "t", dfs = "contain")
m_ml
pct(c(m_ml$b, m_ml$ci.lb, m_ml$ci.ub))
# Q: the mean barely moved, the CI widened. Why?

# (optional) multilevel I2 (given): % of total variance between / within studies
w  <- 1 / dat$vi; k <- length(w)
vt <- (k - 1) * sum(w) / (sum(w)^2 - sum(w^2))
round(100 * m_ml$sigma2 / (sum(m_ml$sigma2) + vt), 1)   # % between studies, % within

# Exercise 5
m_rob <- robust(m_ml, cluster = ___, clubSandwich = TRUE)
m_rob

# --- 5. Orchard plot -----------------------------------------------------------
# Exercise 6: code given - run it, then match each element to predict() output
pr_ml <- predict(m_ml)
pr_ml                      # pred, ci.lb, ci.ub, pi.lb, pi.ub
ggplot(dat, aes(x = yi, y = 1)) +
  geom_jitter(aes(size = 1 / sqrt(vi)), height = 0.3, alpha = 0.3, colour = "#56B8B9") +
  annotate("segment", x = pr_ml$pi.lb, xend = pr_ml$pi.ub, y = 1, yend = 1, linewidth = 1) +  # prediction interval
  annotate("segment", x = pr_ml$ci.lb, xend = pr_ml$ci.ub, y = 1, yend = 1, linewidth = 4) +  # CI of the mean
  annotate("point", x = pr_ml$pred, y = 1, size = 6, shape = 21, fill = "#BCCF00") +          # mean
  geom_vline(xintercept = 0, linetype = 2) +
  labs(x = "lnRR", y = NULL)
# Q: what share of comparisons falls outside the prediction interval?
mean(dat$yi < pr_ml$pi.lb | dat$yi > pr_ml$pi.ub)

# --- 6. Your turn: natural enemies ---------------------------------------------
# Predict first: will intercropping increase or decrease them?
# Then go back to the top, set grp <- "Natural enemies", and rerun the whole script.
# Compare the multilevel estimate and prediction interval with pests.

# --- 14:55 Debrief with the whole group ----------------------------------------
