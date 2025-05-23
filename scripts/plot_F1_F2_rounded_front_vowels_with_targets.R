# Load required libraries
library(dplyr)
library(ggplot2)
library(here)
library(ggforce)

# === Load and combine participant data ===
load_participant_data <- function(participant_id) {
  fr <- read.csv(here("data", paste0("participant_", participant_id, "_fr.csv")), stringsAsFactors = FALSE) %>%
    mutate(trial = as.character(trial),
           participant = paste0("P", participant_id),
           language = "fr")
  
  ru <- read.csv(here("data", paste0("participant_", participant_id, "_ru.csv")), stringsAsFactors = FALSE) %>%
    mutate(trial = as.character(trial),
           participant = paste0("P", participant_id),
           language = "ru")
  
  bind_rows(fr, ru)
}

df_all <- bind_rows(
  load_participant_data(1),
  load_participant_data(2)
)

# === Override vowel labels for Russian words ===
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

# === Filter and assign panels ===
df_all <- df_all %>%
  filter(!vowel %in% c("noise", "error", "sil", "pause", "sp"),
         vowel %in% c("y", "ʉ", "ø", "œ", "ɵ"),
         !is.na(F1), !is.na(F2)) %>%
  mutate(panel = case_when(
    vowel %in% c("y", "ʉ") ~ "[y] vs [ʉ]",
    vowel %in% c("ø", "œ", "ɵ") ~ "[ø], [œ] vs [ɵ]",
    TRUE ~ NA_character_
  )) %>%
  filter(!is.na(panel))

# === Centroids (only actual vowels in plot) ===
centroids <- df_all %>%
  group_by(vowel, panel) %>%
  summarise(F1 = mean(F1), F2 = mean(F2), .groups = "drop")

# === Reference targets from Delattre ===
reference_targets <- data.frame(
  vowel = c("y", "ø", "œ"),
  F1 = c(250, 375, 550),
  F2 = c(1800, 1600, 1400),
  label = c("[y] target", "[ø] target", "[œ] target"),
  panel = c("[y] vs [ʉ]", "[ø], [œ] vs [ɵ]", "[ø], [œ] vs [ɵ]")
)

# === Plot ===
plot <- ggplot(df_all, aes(x = F2, y = F1, color = vowel, shape = participant)) +
  geom_point(size = 3, alpha = 0.7) +
  geom_mark_ellipse(aes(group = vowel), alpha = 0.1, show.legend = FALSE) +
  geom_text(data = centroids, aes(x = F2, y = F1, label = vowel),
            inherit.aes = FALSE, color = "black", fontface = "bold", size = 5) +
  geom_point(data = reference_targets, aes(x = F2, y = F1), 
             shape = 4, size = 4, color = "black", stroke = 1.5, inherit.aes = FALSE) +
  geom_text(data = reference_targets, aes(x = F2, y = F1, label = label),
            color = "black", fontface = "italic", size = 4, hjust = -0.1, vjust = -0.5, inherit.aes = FALSE) +
  scale_color_manual(values = c(
    "y" = "#E41A1C",
    "ʉ" = "#377EB8",
    "ø" = "#FF7F00",
    "œ" = "#FDB462",
    "ɵ" = "#4DAF4A"
  )) +
  scale_x_reverse() +
  scale_y_reverse() +
  facet_wrap(~panel, nrow = 1) +
  theme_minimal(base_size = 14) +
  labs(
    title = "F1–F2: French Rounded Vowels and Russian Substitutes",
    x = "F2 (Hz)",
    y = "F1 (Hz)",
    color = "Vowel",
    shape = "Participant"
  )

print(plot)

# === Save plot ===
ggsave(
  filename = here("output", "F1_F2_vowels_with_targets.png"),
  plot = plot,
  width = 10,
  height = 6,
  dpi = 300
)
