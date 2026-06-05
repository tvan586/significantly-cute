# UoA City Campus Animal Charisma Analysis

Analysis of iNaturalist animal observations recorded on the University of Auckland City Campus, submitted as part of a *Significance*-style article for BIOSCI 738.

---

## Project Overview

This project explores how charisma of animals effects the structure of data records on the University of Auckland City Campus in New Zealand using citizen science observation data from iNaturalist.

The findings are written up as a *Significance*-style article aimed at a general, non-specialist audience.

---

## Data Sources

| File | Description |
|------|-------------|
| `01_data/UoA_campus_observations701361.csv` | iNaturalist observations from the UoA City Campus (n = 1,048,575 observations, 2002–2026). Columns include observation ID, date, user ID, quality grade, coordinates, common name, and taxanomic classification. |
| `01_data/HumanAnimal_relations_Appendix_A1.csv` | Supplementary dataset on human–animal relationships, including ratings for valence, arousal, familiarity, cuteness, dangerousness, and other dimensions across animal categories. Used for defining whether an animal is considered charismatic or not.

> Raw data files are not modified by any script. All outputs are written to `03_figures/` and `04_outputs/`.

---

## How to Run the Analysis

### Requirements

- R (version 4.5.3 or later)
- The following R packages:

```r
install.packages(c(
  "tidyverse",   # collection including dplyr, tidyr, tibble, ggplot2, readr
  "readr",       # reading .csv files
  "lubridate",   # date handling
  "factoextra",  # clustering and multivariate data visualization
  "lme4",        # mixed-effects models
  "lmerTest",    # p-values and tests for lme4 models
  "here"         # project-oriented file paths
))
```

### Running the scripts

Run the scripts in order from the `02_R/` folder:

1. `01_data_cleaning.R` — imports raw data, standardises column names, filters to relevant columns and observations (e.g. animals in UoA dataset)
2. `02_analysis.R` — main analysis and generation of final figures saved to `03_figures/`

Each script can be run independently as long as the previous outputs exist, or run all in sequence from `00_run_all.R`.

---

## Repository Structure

```
uoa-campus-biodiversity/
│
├── README.md                   ← you are here
│
├── 01_data/                    ← original unmodified data files
│
├── 02_R/
│   ├── 00_run_all.R            ← runs all scripts in sequence
│   ├── 01_data_cleaning.R
│   └── 02_analysis.R
│
├── 03_figures/                 ← all plots exported here (PNG)
│
└── 04_outputs/                 ← summary tables and results (CSV)
```

---

## Ethical Considerations

The iNaturalist data used here is publicly available under a Creative Commons licence. All observations are voluntarily submitted by citizen scientists; no personally identifying information beyond usernames is present in the dataset. No animals were observed or disturbed as part of this study.

---

## AI Use Statement

Claude (Anthropic) was used to assist with setting up the GitHub repository structure and explaining Git workflows. Initial exploratory code was partially drafted with AI assistance and then reviewed, modified, and verified by the author. All analytical decisions, interpretations, and written content are the author's own.

---

## Author

Tasmin van Bergen

BIOSCI 738 — University of Auckland

2026
