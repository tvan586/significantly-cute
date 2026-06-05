# ============================================================
# Libraries
# ============================================================
library(readr)
library(dplyr)
library(tidyr)
library(tibble)
library(ggplot2)
library(factoextra)
library(lme4)
library(lmerTest)
library(here)

# ============================================================
# Shared plot style
# ============================================================
theme_set(theme_minimal(base_size = 12))
fit_col   <- "#2c3e50"
ribbon_fl <- "grey50"
ref_col   <- "grey70"
ell_col   <- "grey40"
pc_breaks <- seq(-8, 8, by = 2)
pc_lab_x  <- "PC1 (60.5%)"
pc_lab_y  <- "PC2 (20.7%)"

# Expects from the data-cleaning script: ha_data_full, uoa_data
# (with ha_animal, charisma_score, quality_grade, user_login), and charisma_per_user

# ============================================================
# 1. Validate the charisma score: do the three dimensions load together?
# ============================================================
ha_pca_input <- ha_data_full |>
  select(animal, category, ends_with("_M")) |>
  drop_na()

ha_pca <- ha_pca_input |>
  select(ends_with("_M")) |>
  scale() |>
  prcomp()

pca_summary <- summary(ha_pca)
round(ha_pca$rotation[, 1:3], 2)

pca_summary_df <- as.data.frame(summary(ha_pca)$importance)
write.csv(pca_summary_df, here::here("4_outputs", "01_ha_pca_summary.csv"))

pc1_order <- names(sort(ha_pca$rotation[, "PC1"]))
ha_pca$rotation |>
  as.data.frame() |>
  rownames_to_column("dimension") |>
  pivot_longer(cols = starts_with("PC"), names_to = "PC", values_to = "loading") |>
  filter(PC %in% c("PC1", "PC2", "PC3")) |>
  mutate(dimension = factor(dimension, levels = pc1_order)) |>
  ggplot(aes(loading, dimension, fill = loading > 0)) +
  geom_col() +
  geom_vline(xintercept = 0, colour = ref_col, linewidth = 0.3) +
  facet_wrap(~ PC) +
  scale_fill_manual(values = c(`FALSE` = "grey75", `TRUE` = fit_col)) +
  labs(x = "Loading", y = NULL, title = "PCA loadings by dimension") +
  theme(legend.position = "none")

p_pca_biplot <- fviz_pca_biplot(ha_pca, geom.ind = "point",
                habillage = ha_pca_input$category,
                palette = "viridis", col.var = "black", repel = TRUE) +
  coord_fixed() +
  theme_minimal(base_size = 12) +
  labs(title = "Possidónio et al. Trait dimensions and animals in PC space",
       x = pc_lab_x, y = pc_lab_y)
p_pca_biplot

ggsave(here("3_figures", "01_pca_biplot.png"), p_pca_biplot, width = 10, height = 6, dpi = 300, bg = "white")

# ============================================================
# 2. Place UoA observations in PC space and cluster them
# ============================================================
ha_pc_animal <- ha_pca_input |>
  mutate(PC1 = ha_pca$x[, 1], PC2 = ha_pca$x[, 2]) |>
  group_by(animal) |>
  summarise(PC1 = mean(PC1), PC2 = mean(PC2), .groups = "drop")

ha_charisma <- ha_data_full |>
  mutate(raw = (cuteness_M + valence_M + feelings_care_M) / 3,
         charisma_score = 1 + ((raw - 1) / 6) * 9) |>
  group_by(animal) |>
  summarise(charisma_score = mean(charisma_score, na.rm = TRUE), .groups = "drop")

ha_pc_animal <- ha_pc_animal |> left_join(ha_charisma, by = "animal")

uoa_animal <- uoa_data |>
  filter(!is.na(ha_animal)) |>
  count(ha_animal, name = "n_obs") |>
  left_join(ha_pc_animal, by = c("ha_animal" = "animal")) |>
  filter(!is.na(PC1))

p_uoa_pc_space <- ggplot(uoa_animal, aes(PC1, PC2)) +
  geom_hline(yintercept = 0, colour = ref_col, linewidth = 0.3) +
  geom_vline(xintercept = 0, colour = ref_col, linewidth = 0.3) +
  geom_point(aes(colour = charisma_score, size = n_obs), alpha = 0.7) +
  scale_colour_viridis_c() +
  scale_size_continuous(range = c(2, 12)) +
  scale_x_continuous(breaks = pc_breaks) +
  scale_y_continuous(breaks = pc_breaks) +
  coord_fixed() +
  labs(title = "UoA observations in trait space (size = times recorded)",
       x = pc_lab_x, y = pc_lab_y,
       colour = "Charisma score", size = "Observations")
p_uoa_pc_space

ggsave(here("3_figures", "02_uoa_pc_space.png"), p_uoa_pc_space, width = 10, height = 6, dpi = 300, bg = "white")

# ============================================================
# 3. Does charisma drift as users gain experience?
# ============================================================
charisma_per_user <- charisma_per_user |>
  mutate(log_experience = log10(n_observations))

exp_model <- lm(mean_charisma ~ log_experience, data = charisma_per_user)
summary(exp_model)

obs_data <- uoa_data |>
  filter(!is.na(charisma_score)) |>
  group_by(user_login) |>
  mutate(log_experience = log10(n())) |>
  ungroup()

uoa_model <- lmer(charisma_score ~ log_experience + (1 | user_login), data = obs_data)
summary(uoa_model)

# population-level fixed-effect prediction from the mixed model, with Wald CI
pred_grid <- data.frame(log_experience = seq(min(obs_data$log_experience),
                                             max(obs_data$log_experience),
                                             length.out = 200))
X  <- model.matrix(~ log_experience, pred_grid)
pred_grid$fit   <- as.vector(X %*% fixef(uoa_model))
pred_grid$se    <- sqrt(rowSums((X %*% vcov(uoa_model)) * X))
pred_grid$lower <- pred_grid$fit - 1.96 * pred_grid$se
pred_grid$upper <- pred_grid$fit + 1.96 * pred_grid$se

vc <- as.data.frame(VarCorr(uoa_model))$vcov   # [1] between-user, [2] residual
var_fixed <- var(predict(uoa_model, re.form = NA))

var_fixed / sum(var_fixed, vc)              # marginal R²: experience alone
sum(var_fixed, vc[1]) / sum(var_fixed, vc)  # conditional R²: experience + observer

p_experience <- ggplot() +
  geom_point(data = charisma_per_user, aes(log_experience, mean_charisma), alpha = 0.3) +
  geom_ribbon(data = pred_grid, aes(log_experience, ymin = lower, ymax = upper),
              fill = ribbon_fl, alpha = 0.25) +
  geom_line(data = pred_grid, aes(log_experience, fit), colour = fit_col, linewidth = 1) +
  scale_x_continuous(breaks = log10(c(1, 10, 100, 1000)),
                     labels = c("1", "10", "100", "1,000")) +
  labs(x = "Experience / Number of observations (log scale)", y = "Charisma score",
       title = "Linear Mixed Model: Experience vs Charisma")
p_experience

ggsave(here("3_figures", "03_experience.png"), p_experience, width = 10, height = 6, dpi = 300, bg = "white")

# ============================================================
# 4. Does charisma predict reaching research grade?
# ============================================================
uoa_data |> count(quality_grade)

ha_familiarity <- ha_data_full |>
  group_by(animal) |>
  summarise(familiarity = mean(familiarity_M, na.rm = TRUE), .groups = "drop")

model_data <- uoa_data |>
  left_join(ha_familiarity, by = c("ha_animal" = "animal")) |>
  filter(quality_grade %in% c("research", "needs_id")) |>
  mutate(research_grade = as.integer(quality_grade == "research")) |>
  filter(!is.na(charisma_score), !is.na(familiarity))

m_engage <- glm(research_grade ~ charisma_score + familiarity,
                data = model_data, family = binomial)
summary(m_engage)
odds_ratio_table <- exp(cbind(odds_ratio = coef(m_engage), confint(m_engage)))

write.csv(odds_ratio_table, here::here("4_outputs", "02_odds_ratio_table.csv"))

newdata <- data.frame(
  charisma_score = seq(min(model_data$charisma_score),
                       max(model_data$charisma_score), length.out = 200),
  familiarity = mean(model_data$familiarity))
pred <- predict(m_engage, newdata, type = "link", se.fit = TRUE)
newdata$prob  <- plogis(pred$fit)
newdata$lower <- plogis(pred$fit - 1.96 * pred$se.fit)
newdata$upper <- plogis(pred$fit + 1.96 * pred$se.fit)

p_research_grade <- ggplot(newdata, aes(charisma_score, prob)) +
  geom_jitter(data = model_data, aes(x = charisma_score, y = research_grade),
              width = 0.1, height = 0.03, alpha = 0.1) +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = ribbon_fl, alpha = 0.25) +
  geom_line(colour = fit_col, linewidth = 1) +
  coord_cartesian(ylim = c(-0.05, 1.05)) +
  labs(x = "Charisma score", y = "Probability of reaching research grade",
       title = "More charismatic observations are more likely to be confirmed")
p_research_grade

ggsave(here("3_figures", "04_research_grade.png"), p_research_grade, width = 10, height = 6, dpi = 300, bg = "white")
