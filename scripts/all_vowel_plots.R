# Load required libraries
library(dplyr)
library(ggplot2)
library(here)

# === Load participant data from CSVs ===
df1_fr <- read.csv(here("data", "participant_1_fr.csv"), stringsAsFactors = FALSE) %>%
  mutate(participant = "P1", language = "fr")

df1_ru <- read.csv(here("data", "participant_1_ru.csv"), stringsAsFactors = FALSE) %>%
  mutate(participant = "P1", language = "ru")

df2_fr <- read.csv(here("data", "participant_2_fr.csv"), stringsAsFactors = FALSE) %>%
  mutate(participant = "P2", language = "fr")

df2_ru <- read.csv(here("data", "participant_2_ru.csv"), stringsAsFactors = FALSE) %>%
  mutate(participant = "P2", language = "ru")

# Ensure trial is consistent across files
df1_fr$trial <- as.character(df1_fr$trial)
df1_ru$trial <- as.character(df1_ru$trial)
df2_fr$trial <- as.character(df2_fr$trial)
df2_ru$trial <- as.character(df2_ru$trial)

# Combine all data
df_all <- bind_rows(df1_fr, df1_ru, df2_fr, df2_ru)

# === Preprocessing and corrections ===

# Replace vowel with [ʉ] for specific Russian words
df_all$vowel <- ifelse(df_all$language == "ru" & df_all$word %in% c("тюк", "мюсли", "сюр", "люк"), "ʉ", df_all$vowel)

# Remove invalid rows
exclude_labels <- c("noise", "error", "sil", "pause", "sp")
df_clean <- df_all %>%
  filter(!vowel %in% exclude_labels) %>%
  filter(!is.na(F1), !is.na(F2))

# Define vowel groups
all_target_vowels <- c("y", "ø", "œ", "ʉ", "ɵ", "e", "u", "i", "o", "о", "е")
french_targets <- c("y", "ø", "œ")
russian_targets <- c("ʉ", "ɵ")

# === Utility functions ===

average_formants <- function(df, by_participant = TRUE) {
  group_vars <- if (by_participant) c("participant", "language", "vowel", "time_index")
  else c("language", "vowel", "time_index")
  df %>%
    group_by(across(all_of(group_vars))) %>%
    summarise(F1 = mean(F1, na.rm = TRUE),
              F2 = mean(F2, na.rm = TRUE),
              .groups = "drop")
}

plot_and_save <- function(data, title, by_participant = TRUE) {
  data <- data %>%
    mutate(group = if (by_participant) interaction(language, vowel, participant)
           else interaction(language, vowel))
  
  p <- ggplot(data, aes(x = F2, y = F1,
                        group = group,
                        color = language)) +
    geom_path(arrow = arrow(length = unit(0.15, "cm")), linewidth = 1.2) +
    geom_point(data = data %>% filter(time_index == 1), shape = 21, size = 2, fill = "white") +
    geom_point(data = data %>% filter(time_index == 10), shape = 24, size = 2, fill = "black") +
    scale_x_reverse() +
    scale_y_reverse() +
    facet_wrap(~ vowel, ncol = 4) +
    theme_minimal(base_size = 14) +
    labs(title = title, x = "F2 (Hz)", y = "F1 (Hz)", color = "Language")
  
  filename <- here("output", paste0(gsub(" ", "_", tolower(title)),
                                    if (by_participant) "_by_participant" else "_pooled", ".png"))
  ggsave(filename, plot = p, width = 10, height = 6, dpi = 300)
}

# === Generate plots ===

# 1. All vowels
plot_and_save(average_formants(df_clean, TRUE), "All vowels", TRUE)
plot_and_save(average_formants(df_clean, FALSE), "All vowels", FALSE)

# 2. Target + control vowels
df_target <- df_clean %>% filter(vowel %in% all_target_vowels)
plot_and_save(average_formants(df_target, TRUE), "Target and control vowels", TRUE)
plot_and_save(average_formants(df_target, FALSE), "Target and control vowels", FALSE)

# 3. French only
df_fr <- df_target %>% filter(language == "fr")
plot_and_save(average_formants(df_fr, TRUE), "French vowels", TRUE)
plot_and_save(average_formants(df_fr, FALSE), "French vowels", FALSE)

# 4. Russian only
df_ru <- df_target %>% filter(language == "ru")
plot_and_save(average_formants(df_ru, TRUE), "Russian vowels", TRUE)
plot_and_save(average_formants(df_ru, FALSE), "Russian vowels", FALSE)

# 5. French target vowels only
df_fr_tgt <- df_clean %>% filter(vowel %in% french_targets)
plot_and_save(average_formants(df_fr_tgt, TRUE), "French target vowels", TRUE)
plot_and_save(average_formants(df_fr_tgt, FALSE), "French target vowels", FALSE)

# 6. Russian target vowels only
df_ru_tgt <- df_clean %>% filter(vowel %in% russian_targets)
plot_and_save(average_formants(df_ru_tgt, TRUE), "Russian target vowels", TRUE)
plot_and_save(average_formants(df_ru_tgt, FALSE), "Russian target vowels", FALSE)
