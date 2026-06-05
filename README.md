# UoA City Campus Animal Charisma Analysis

## Project Overview

This project explores how charisma of animals effects the structure of data records on the University of Auckland City Campus in New Zealand using citizen science observation data from iNaturalist.

The findings are written up as a *Significance*-style article aimed at a general, non-specialist audience.

## Data Sources

| File | Description |
|------|-------------|
| `01_data/UoA_campus_observations701361.csv` | iNaturalist observations from the UoA City Campus (n = 1,048,575 observations, 2002–2026). Columns include observation ID, date, user ID, quality grade, coordinates, common name, and taxanomic classification. |
| `01_data/HumanAnimal_relations_Appendix_A.csv` | Supplementary dataset on human–animal relationships, including ratings for valence, arousal, familiarity, cuteness, dangerousness, and other dimensions across animal categories. Used for defining whether an animal is considered charismatic or not.

> Raw data files are not modified by any script. All outputs are written to `03_figures/` and `04_outputs/`.

## How to Run the Analysis

### Requirements

- R (version 4.5.3 or later)
- The following R packages:

```r
install.packages(c(
  "readr",
  "dplyr",
  "tidyr",
  "tibble",
  "ggplot2",
  "factoextra",
  "lme4",
  "lmerTest",
  "here"
))
```

### Running the scripts

Run the scripts in order from the `02_R/` folder:

1. `00_environment_setup.R` - sets up your R environment so all the necessary packages are installed
2. `01_data_cleaning.R` - imports raw data, standardises column names, filters to relevant columns and observations (e.g. animals in UoA dataset)
3. `02_analysis.R` - main analysis and generation of final figures saved to `03_figures/`

Each script can be run independently as long as the previous outputs exist.

## Repository Structure

```
uoa-campus-biodiversity/
│
├── README.md
│
├── 01_data/
│
├── 02_r_code/
│   ├── 00_environment_setup.R
│   ├── 01_data_cleaning.R
│   └── 02_analysis.R
│
├── 03_figures/
│
└── 04_outputs/
```

## Ethical Considerations

The iNaturalist data used here is publicly available under a Creative Commons licence. All observations are voluntarily submitted by citizen scientists; no personally identifying information beyond usernames is present in the dataset. No animals were observed or disturbed as part of this study.

## AI Use Statement

I used Claude (Anthropic) throughout this project to clarify concepts and tidy up code. All of the writing here is my own, and so are the analytical and interpretive decisions. Where I did use AI, I critically analysed every output and only took on board what made sense to me and what I could verify myself was correct.

Most of what I asked was specifically for understanding something before I made a call on it and helping find redundancies in my code. I asked it to look through one of my scripts and flag redundancies for me to review, so the code in my repo was tidy and readable. Other times it was a concept I wanted to be sure of: when my logistic regression gave me an odds ratio, I asked what it actually meant, and Claude walked me through reading it: each one-point rise in charisma nearly doubles the odds of a record reaching research grade, also pointing out that an odds ratio is about odds, not probability, which changed how I worded that result. The interpretation in the article is mine; I just wanted to understand the concept properly before writing it up.

So AI was a tool for understanding concepts and cleaning up code. Every analytical and writing decision in this article is mine.

## Author

Tasmin van Bergen

BIOSCI 738 — University of Auckland

2026
