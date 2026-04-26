## Installing packages if needed
# install.packages("ggplot2")

## Libraries
library(ggplot2)

# How many unique users are in the dataset?

n_distinct(uoa_data$user_login)

# How many observations per user?

obs_per_user <- uoa_data |>
  count(user_login, sort = TRUE)

uoa_data |>
  count(user_login, sort = TRUE) |>
  ggplot(aes(x = reorder(user_login, -n), y = n)) +
  geom_col(fill = "steelblue") +
  labs(
    title = "Number of Observations per User",
    x = "User",
    y = "Number of Observations"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank())

# How many users have more than one observation?

uoa_data |>
  count(user_login) |>
  filter(n > 1) |>
  nrow()

uoa_data |>
  count(user_login, sort = TRUE) |>
  filter(n > 1) |>
  ggplot(aes(x = reorder(user_login, -n), y = n)) +
  geom_col(fill = "steelblue") +
  labs(
    title = "Number of Observations per User",
    x = "User",
    y = "Number of Observations"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank())

# How many users per observation count?

uoa_data |>
  filter(user_login != "stephen_thorpe") |>
  count(user_login) |>
  count(n, name = "num_users") |>
  ggplot(aes(x = n, y = num_users)) +
  geom_col(fill = "steelblue") +
  labs(
    title = "How many users per observation count",
    x = "Number of Observations",
    y = "Number of Users"
  ) +
  theme_minimal()

# How many total observations not by stephen_thorpe, and then how many by stephen_thorpe?

uoa_data |>
  mutate(is_stephen = if_else(user_login == "stephen_thorpe", "stephen_thorpe", "everyone_else")) |>
  count(is_stephen)

uoa_data |>
  mutate(is_stephen = if_else(user_login == "stephen_thorpe", "stephen_thorpe", "everyone_else")) |>
  count(is_stephen) |>
  ggplot(aes(x = is_stephen, y = n, fill = is_stephen)) +
  geom_col() +
  labs(
    title = "Observations: stephen_thorpe vs everyone else",
    x = NULL,
    y = "Number of Observations"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

# Grady et al. (2026) defined highly active users as the top 5% of observers by 
# number of observations. If I did the same, how many users are in the top 5%?

top_5_n <- ceiling(n_distinct(uoa_data$user_login) * 0.05)

uoa_data |>
  count(user_login, sort = TRUE) |>
  slice_head(n = top_5_n)

uoa_data |>
  count(user_login, sort = TRUE) |>
  slice_head(n = top_5_n) |>
  mutate(is_stephen = user_login == "stephen_thorpe") |>
  group_by(is_stephen) |>
  summarise(total_obs = sum(n))

# If I split the users into three groups, on-offs, active, and highly active
# (where the number of observations needed for each category are made up by me),
# what is the % split?

user_counts <- uoa_data |>
  count(user_login)

user_counts |>
  mutate(group = case_when(
    n == 1  ~ "one_off",
    n <= 19 ~ "active",
    n >= 20 ~ "highly_active"
  )) |>
  group_by(group) |>
  summarise(
    n_users = n(),
    n_observations = sum(n)
  ) |>
  mutate(
    user_pct = round(n_users / sum(n_users) * 100, 1),
    obs_pct  = round(n_observations / sum(n_observations) * 100, 1),
    group    = factor(group, levels = c("one_off", "active", "highly_active"))
  ) |>
  arrange(group)

# Jenks natural breaks - finds splits that minimise within-group variance
install.packages("classInt")
library(classInt)

breaks <- classIntervals(user_counts$n, n = 3, style = "jenks")
print(breaks)

# What if I used number of unique days observed to quantify regularity of 
# observations?

uoa_data |>
  group_by(user_login) |>
  summarise(
    n_obs = n(),
    n_days = n_distinct(observed_on)
  )

uoa_data |>
  filter(user_login != "stephen_thorpe") |>
  group_by(user_login) |>
  summarise(n_days = n_distinct(observed_on)) |>
  ggplot(aes(x = n_days)) +
  geom_histogram(binwidth = 1, fill = "steelblue") +
  labs(
    title = "Number of unique days observed per user (excl. stephen_thorpe)",
    x = "Unique days",
    y = "Number of users"
  ) +
  theme_minimal()

# Finding natural break using Jenks analysis (excl. stephen)

user_days <- uoa_data |>
  filter(user_login != "stephen_thorpe") |>
  group_by(user_login) |>
  summarise(n_days = n_distinct(observed_on))

breaks <- classIntervals(user_days$n_days, n = 2, style = "jenks")
print(breaks)

# relationship between unique days observed and total observations

uoa_data %>%
  filter(user_login != "stephen_thorpe") |>
  group_by(user_login) %>%
  summarise(
    n_obs  = n(),
    n_days = n_distinct(observed_on)
  ) %>%
  ggplot(aes(x = n_days, y = n_obs)) +
  geom_point(alpha = 0.6) +
  labs(
    title = "Unique days vs total observations per user",
    x = "Unique days observed",
    y = "Total observations"
  ) +
  theme_minimal()

# number of users who observed on 2 or more unique days

uoa_data |>
  filter(user_login != "stephen_thorpe") |>
  group_by(user_login) |>
  summarise(n_days = n_distinct(observed_on)) |>
  mutate(group = if_else(n_days == 1, "one_day", "multi_day")) |>
  count(group)

# Number of users who had more than 1 total observation

uoa_data |>
  filter(user_login != "stephen_thorpe") |>
  count(user_login) |>
  mutate(group = if_else(n <= 2, "one-two_off", "returning")) |>
  count(group)

# who made the most observations on only 1 unique day of observing?

uoa_data |>
  filter(user_login != "stephen_thorpe") |>
  group_by(user_login) |>
  summarise(
    n_obs  = n(),
    n_days = n_distinct(observed_on)
  ) |>
  filter(n_days == 1) |>
  arrange(desc(n_obs)) |>
  head(10)

# what did they observe?

uoa_data |>
  filter(user_login == "invertebratist") |>
  select(user_login, observed_on, common_name, ha_animal, charisma_score)

# comparison of charisma scores between one-off and active users (and stephen)

user_groups <- uoa_data %>%
  count(user_login) %>%
  mutate(user_group = case_when(
    user_login == "stephen_thorpe" ~ "highly_active",
    n == 1                         ~ "one_off",
    TRUE                           ~ "active"
  ))

uoa_data_grouped <- uoa_data %>%
  left_join(user_groups %>% select(user_login, user_group), by = "user_login")

# Summary statistics
uoa_data_grouped %>%
  filter(!is.na(charisma_score)) %>%
  group_by(user_group) %>%
  summarise(
    n_obs           = n(),
    mean_charisma   = round(mean(charisma_score), 2),
    sd_charisma     = round(sd(charisma_score), 2),
    median_charisma = round(median(charisma_score), 2)
  )

# Plot
uoa_data_grouped %>%
  filter(!is.na(charisma_score)) %>%
  mutate(user_group = factor(user_group, levels = c("one_off", "active", "highly_active"))) %>%
  ggplot(aes(x = user_group, y = charisma_score, fill = user_group)) +
  geom_boxplot() +
  labs(
    title = "Charisma scores by user group",
    x = "User group",
    y = "Charisma score"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

# charisma score by observation count

uoa_data_grouped %>%
  filter(user_login != "stephen_thorpe") |>
  filter(!is.na(charisma_score)) %>%
  group_by(user_login, user_group) %>%
  summarise(
    n_obs         = n(),
    mean_charisma = mean(charisma_score),
    .groups = "drop"
  ) %>%
  mutate(user_group = factor(user_group, levels = c("one_off", "active", "highly_active"))) %>%
  ggplot(aes(x = n_obs, y = mean_charisma, colour = user_group)) +
  geom_point(alpha = 0.6) +
  labs(
    title = "Mean charisma score vs total observations per user",
    x     = "Total observations",
    y     = "Mean charisma score",
    colour = "User group"
  ) +
  theme_minimal()

# mean charisma score by observation count

uoa_data_grouped %>%
  filter(user_login != "stephen_thorpe") |>
  filter(!is.na(charisma_score)) %>%
  group_by(user_login, user_group) %>%
  summarise(
    n_obs         = n(),
    mean_charisma = mean(charisma_score),
    .groups = "drop"
  ) %>%
  group_by(n_obs) %>%
  summarise(
    mean_charisma = mean(mean_charisma),
    n_users       = n(),
    .groups = "drop"
  ) %>%
  ggplot(aes(x = n_obs, y = mean_charisma)) +
  geom_point(aes(size = n_users), alpha = 0.6) +
  geom_smooth(method = "lm", se = TRUE, colour = "steelblue", linetype = "dashed") +
  labs(
    title = "Mean charisma score by observation count",
    x     = "Total observations",
    y     = "Mean charisma score",
    size  = "Number of users"
  ) +
  theme_minimal()



