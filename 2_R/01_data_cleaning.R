## Installing packages if needed
# install.packages("readr")
# install.packages("dplyr")

## Loading libraries
library(readr)
library(dplyr)

## Loading Human-Animal Relations dataset
ha_data <- read_csv("https://raw.githubusercontent.com/tvan586/significantly-cute/refs/heads/main/1_data/Human-Animal_relations_Appendix%20A(1).csv",
  col_names = FALSE,
  skip = 3
)

## Assigning Human-Animal Relations column names
colnames(ha_data) <- c(
  "picture", "picture_name", "category", "animal",
  "valence_M",        "valence_SD",        "valence_CI_LB",        "valence_CI_UB",
  "arousal_M",        "arousal_SD",        "arousal_CI_LB",        "arousal_CI_UB",
  "familiarity_M",    "familiarity_SD",    "familiarity_CI_LB",    "familiarity_CI_UB",
  "cuteness_M",       "cuteness_SD",       "cuteness_CI_LB",       "cuteness_CI_UB",
  "dangerousness_M",  "dangerousness_SD",  "dangerousness_CI_LB",  "dangerousness_CI_UB",
  "edibility_M",      "edibility_SD",      "edibility_CI_LB",      "edibility_CI_UB",
  "similarity_M",     "similarity_SD",     "similarity_CI_LB",     "similarity_CI_UB",
  "capacity_think_M", "capacity_think_SD", "capacity_think_CI_LB", "capacity_think_CI_UB",
  "capacity_feel_M",  "capacity_feel_SD",  "capacity_feel_CI_LB",  "capacity_feel_CI_UB",
  "accept_kill_M",    "accept_kill_SD",    "accept_kill_CI_LB",    "accept_kill_CI_UB",
  "feelings_care_M",  "feelings_care_SD",  "feelings_care_CI_LB",  "feelings_care_CI_UB"
)

## Cleaning dataframe
ha_data <- ha_data[, c("picture", "picture_name", "category", "animal", "valence_M", "arousal_M", "cuteness_M")]

## Creating charisma score
ha_data <- ha_data |> mutate(
  raw_charisma   = (cuteness_M + valence_M + arousal_M) / 3,
  charisma_score = 1 + ((raw_charisma - 1) / 6) * 9
)

## Loading iNaturalist UoA Campus Project dataset
uoa_data <- read_csv("https://github.com/tvan586/significantly-cute/raw/refs/heads/main/1_data/UoA_campus_observations-701361.csv")

## Average charisma score per animal name (some animals have multiple pictures)
ha_scores <- ha_data |>
  group_by(animal) |>
  summarise(
    charisma_score = mean(charisma_score, na.rm = TRUE),
    .groups = "drop"
  )

## Map each campus observation to closest HA animal
uoa_data <- uoa_data |>
  mutate(
    ha_animal = case_when(
      
      # --- Hemiptera: split by family ---
      taxon_order_name == "Hemiptera" & taxon_family_name == "Cicadidae" ~ "beetle",
      taxon_order_name == "Hemiptera" ~ "mosquito",
      
      # --- Carnivora: split by species ---
      taxon_species_name == "Canis familiaris" ~ "dog",
      taxon_species_name == "Felis catus"      ~ "cat",
      
      # --- Reptilia ---
      taxon_order_name == "Squamata" ~ "iguana",
      
      # --- Aves ---
      taxon_order_name == "Coraciiformes"  ~ "owl",
      taxon_order_name == "Passeriformes"  ~ "blackbird",
      taxon_order_name == "Columbiformes"  ~ "pigeon",
      taxon_order_name == "Psittaciformes" ~ "parrot",
      taxon_order_name == "Charadriiformes"~ "seagull",
      
      # --- Insecta ---
      taxon_order_name == "Lepidoptera"  ~ "butterfly",
      taxon_order_name == "Diptera"      ~ "fly",
      taxon_order_name == "Hymenoptera"  ~ "bee",
      taxon_order_name == "Coleoptera"   ~ "beetle",
      taxon_order_name == "Blattodea"    ~ "coackroach",
      taxon_order_name == "Orthoptera"   ~ "grasshopper",
      taxon_order_name == "Mantodea"     ~ "praying mantis",
      taxon_order_name == "Odonata"      ~ "dragonfly",
      taxon_order_name == "Neuroptera"   ~ "dragonfly",
      taxon_order_name == "Dermaptera"   ~ "beetle",
      taxon_order_name == "Phasmida"     ~ "praying mantis",
      taxon_order_name == "Psocodea"     ~ "fly",
      taxon_order_name == "Thysanoptera" ~ "mosquito",
      taxon_order_name == "Zygentoma"    ~ "coackroach",
      
      # --- Arachnida ---
      taxon_order_name == "Araneae"        ~ "spider",
      taxon_order_name == "Sarcoptiformes" ~ "tick",
      taxon_order_name == "Trombidiformes" ~ "tick",
      
      # --- Amphibia ---
      taxon_order_name == "Anura" ~ "frog",
      
      # --- Mammalia ---
      taxon_order_name == "Rodentia"      ~ "mouse",
      taxon_order_name == "Diprotodontia" ~ "koala",
      taxon_order_name == "Eulipotyphla"  ~ "mouse",
      taxon_order_name == "Primates"      ~ "chimp",
      
      # --- Actinopterygii ---
      taxon_order_name == "Cypriniformes"   ~ "carp",
      taxon_order_name == "Acanthuriformes" ~ "queen angelfish",
      taxon_order_name == "Siluriformes"    ~ "eel",
      taxon_order_name == "Zeiformes"       ~ "sardine",
      
      # --- Mollusca ---
      taxon_order_name == "Stylommatophora" ~ "snail",
      taxon_order_name == "Trochida"        ~ "snail",
      taxon_order_name == "Cycloneritida"   ~ "sea snail",
      taxon_order_name == "Neogastropoda"   ~ "sea snail",
      
      # --- Animalia ---
      taxon_order_name == "Isopoda"          ~ "woodlouse",
      taxon_order_name == "Decapoda"         ~ "crab",
      taxon_order_name == "Amphipoda"        ~ "krill",
      taxon_order_name == "Crassiclitellata" ~ "earthworm",
      taxon_order_name == "Enchytraeida"     ~ "earthworm",
      
      # Everything else (Plantae, Fungi, unmappable Animalia etc.) → exclude
      TRUE ~ NA_character_
    )
  )

## Join charisma scores onto campus observations
uoa_data <- uoa_data |>
  left_join(ha_scores, by = c("ha_animal" = "animal"))

## Clean UoA Campus Observations dataset
uoa_data <- uoa_data |>
  select(id, observed_on, user_login, quality_grade, captive_cultivated,
         latitude, longitude, common_name,
         iconic_taxon_name, taxon_class_name, taxon_order_name,
         taxon_family_name, taxon_genus_name, taxon_species_name,
         ha_animal, charisma_score) |>
  filter(!is.na(charisma_score))


