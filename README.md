# Rounded Vowel Transfer

This repository contains materials for a pilot phonetic study on how speakers of a language without front rounded vowels produce unfamiliar vowel categories in a second language. The focus is on the acoustic realization of the French rounded front vowels [y], [œ], and [ø].

## Purpose

The study explores how first language (L1) phonetic patterns influence the production of unfamiliar second language (L2) vowels, with attention to:
- Substitution strategies
- Formant dynamics (F1, F2, F3)
- Effects of consonantal context
- Degree of labialization

## Contents

- `stimuli_table.csv` – a spreadsheet of lexical items used as stimuli in the experiment.
- `scripts/plot_F1_F2_rounded_front_vowels_with_targets.R` – R script for visualizing F1–F2 distributions of rounded vowels, with reference targets from native French data.
- `scripts/plot_formant_trajectories_by_consonant_type.R` – R script to visualize F1 and F2 trajectories for each vowel across time, grouped by preceding consonant type and language.
- `scripts/all_vowel_plots.R` – R script to clean, average, and plot formant trajectories for multiple vowel sets and participants.
- (future) `data/` – formant measurements and annotations.

## Formant Extraction (Praat)

Praat script for extracting F1, F2, and F3 values from annotated vowels in a TextGrid file.

- [`extract_formants_from_textgrid.praat`](scripts/extract_formants.praat)

This script:
- Iterates over labeled vowel intervals in a specified tier
- Retrieves overlapping word and trial annotations
- Samples formant values at fixed intervals across each vowel
- Outputs a structured table with vowel, word, trial, time, and F1–F3 values

Settings:
- Number of timepoints per vowel: `10`
- Tiers: `vowel = 2`, `word = 1`, `trial = 3`

## Tools

- Praat for acoustic analysis
- R (ggplot2, dplyr, ggforce, here, readr) for visualization and data aggregation
- Python (planned) for data processing

## License

This project is for academic research purposes. No license yet specified.
