# Load required libraries
library(dplyr)
library(ggplot2)
library(here)
library(ggforce)
library(readr)

# === Load and prepare the stimuli list with consonant types ===
stimuli <- read_csv(here("data", "stimuli_list.csv")) %>%
  rename(word = Word, prev_c_type = `Consonant Manner`) %>%
  mutate(
    word = gsub("\\s*\\[.*\\]", "", word),  # remove anything in brackets
    word = tolower(word)
  ) %>%
  select(word, prev_c_type)

# === Load and merge participant data ===
load_participant_data <- function(participant_id) {
  fr <- read_csv(here("data", paste0("participant_", participant_id, "_fr.csv"))) %>%
    mutate(trial = as.character(trial),
           participant = paste0("P", participant_id),
           language = "fr")
  
  ru <- read_csv(here("data", paste0("participant_", participant_id, "_ru.csv"))) %>%
    mutate(trial = as.character(trial),
           participant = paste0("P", participant_id),
           language = "ru")
  
  bind_rows(fr, ru)
}

# Load and combine all participant data
df_all <- bind_rows(
  load_participant_data(1),
  load_participant_data(2)
) %>%
  mutate(word = tolower(word))  # match case with stimuli_list

# === Override vowel labels for specific Russian words ===
df_all$vowel <- ifelse(
  df_all$language == "ru" & df_all$word %in% c("тюк", "мюсли", "сюр", "люк"),
  "ʉ",
  df_all$vowel
)

df_all$vowel <- ifelse(
  df_all$language == "ru" & df_all$word %in% c("пёстрый", "актёр", "всё"),
  "ɵ",
  df_all$vowel
)

# === Merge with consonant type information ===
df_all <- left_join(df_all, stimuli, by = "word")

# === Filter and clean ===
target_vowels <- c("y", "ø", "œ", "ʉ", "ɵ")

df_clean <- df_all %>%
  filter(vowel %in% target_vowels,
         !vowel %in% c("noise", "error", "pause", "sil", "sp"),
         !is.na(F1), !is.na(F2),
         !is.na(time_index),
         !is.na(prev_c_type))  # keep only rows with valid consonant info

# === Compute average trajectories by time point ===
formant_trajectories <- df_clean %>%
  group_by(participant, language, vowel, time_index, prev_c_type) %>%
  summarise(
    F1 = mean(F1, na.rm = TRUE),
    F2 = mean(F2, na.rm = TRUE),
    .groups = "drop"
  )

# === Plotting function ===
plot_formant_trajectory <- function(formant_col) {
  ggplot(formant_trajectories, aes(x = time_index, y = {{ formant_col }},
                                   color = language,
                                   group = interaction(language, vowel, participant, prev_c_type))) +
    geom_line(size = 1) +
    facet_grid(participant ~ vowel + prev_c_type, scales = "free_y") +
    theme_minimal(base_size = 13) +
    theme(
      strip.text.x = element_text(margin = margin(b = 5)),  # keep top facet labels neat
      axis.text.x = element_blank(),                        # remove x-axis tick labels
      axis.ticks.x = element_blank()                        # remove x-axis ticks
    ) +
    labs(
      title = paste0(deparse(substitute(formant_col)), " trajectories over time"),
      x = "Time index (normalized vowel duration)",
      y = paste0(deparse(substitute(formant_col)), " (Hz)"),
      color = "Language"
    )
}



# === Save F1 and F2 plots ===
ggsave(here("output", "F1_trajectories_by_consonant_type.png"), plot_formant_trajectory(F1), width = 12, height = 8, dpi = 300)
ggsave(here("output", "F2_trajectories_by_consonant_type.png"), plot_formant_trajectory(F2), width = 12, height = 8, dpi = 300)
