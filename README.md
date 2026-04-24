# UoA City Campus Biodiversity Analysis

Analysis of iNaturalist biodiversity observations recorded on the University of Auckland City Campus, submitted as part of a *Significance*-style article for BIOSCI 738.

---

## Project Overview

This project explores biodiversity patterns on the UoA City Campus using citizen science observation data from iNaturalist. The analysis examines how the proportion of charismatic animal species recorded by casual and power users of the iNaturalist UoA Campus Project differ. 

The findings are written up as a *Significance*-style article aimed at a general, non-specialist audience.

---

## Data Sources

| File | Description |
|------|-------------|
| `01_data/raw/UoA_campus_observations701361.ods` | iNaturalist observations from the UoA City Campus (n = 5,654 records, 2002–present). Columns include observation date, GPS coordinates, taxon classification, common name, quality grade, and observer ID. |
| `01_data/raw/HumanAnimal_relations_Appendix_A1.xlsx` | Supplementary dataset on human–animal relationships, including ratings for valence, arousal, familiarity, cuteness, dangerousness, and other attributes across animal categories. Used for defining whether an animal is considered charismatic or not.

> Raw data files are read-only and are not modified by any script. All outputs are written to `03_figures/` and `04_outputs/`.

---

## How to Run the Analysis

### Requirements

- R (version 4.5.3 or later)
- The following R packages:

```r
install.packages(c(
  "tidyverse",   # data wrangling and plotting
  "readr",       # reading .csv files
  "lubridate",   # date handling
  "sf"           # spatial data (if mapping)
))
```

### Running the scripts

Run the scripts in order from the `02_R/` folder:

1. `01_data_cleaning.R` — imports raw data, standardises column names, filters to research-quality observations
2. `02_explore.R` — exploratory summaries and initial plots
3. `03_analysis.R` — main analysis (species richness, temporal trends, etc.)
4. `04_figures.R` — generates final figures saved to `03_figures/`

Each script can be run independently as long as the previous outputs exist, or run all in sequence from `00_run_all.R`.

---

## Repository Structure

```
uoa-campus-biodiversity/
│
├── README.md                   ← you are here
│
├── 01_data/
│   └── raw/                    ← original unmodified data files
│
├── 02_R/
│   ├── 00_run_all.R            ← runs all scripts in sequence
│   ├── 01_data_cleaning.R
│   ├── 02_explore.R
│   ├── 03_analysis.R
│   └── 04_figures.R
│
├── 03_figures/                 ← all plots exported here (PNG/PDF)
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
