# =============================================================
# 01_data_pull.R
# Purpose: Pull ACS 5-year data from Census API via tidycensus
# Author: Shan Jiang
# Last Updated: March 2026
#
# Retrieves AIAN and total population socioeconomic data for
# four Ninth District states (MN, MT, ND, SD) across three
# ACS 5-year vintages (2015, 2019, 2023).
#
# Output: 8 .rds files saved to data/raw/
# Terminology, universes, and variable details: see CODEBOOK.md
# =============================================================

library(tidycensus)
library(tidyverse)
library(sf)

target_states <- c("MN", "MT", "ND", "SD")

yr3 <- 2023  # covers 2019-2023: post-pandemic
yr2 <- 2019  # covers 2015-2019: pre-pandemic baseline
yr1 <- 2015  # covers 2011-2015: post-financial-crisis baseline


# =============================================================
# SECTION 1: LABOR MARKET DATA
# Tables: C23002C, B23025, B20017C, B20017
# Universes and limitations: see CODEBOOK.md
# =============================================================

labor_vars <- c(
  
  # AIAN alone civilian noninstitutional pop 16+
  aian_total_16plus      = "C23002C_001",
  
  # AIAN Male Employment Status
  aian_male_lf_1664      = "C23002C_004",  # In labor force, male 16-64
  aian_male_emp_1664     = "C23002C_007",  # Employed, male 16-64
  aian_male_unemp_1664   = "C23002C_008",  # Unemployed, male 16-64
  aian_male_lf_65plus    = "C23002C_011",  # In labor force, male 65+
  aian_male_emp_65plus   = "C23002C_012",  # Employed, male 65+
  aian_male_unemp_65plus = "C23002C_013",  # Unemployed, male 65+
  
  # AIAN Female Employment Status
  aian_fem_lf_1664       = "C23002C_017",  # In labor force, female 16-64
  aian_fem_emp_1664      = "C23002C_020",  # Employed, female 16-64
  aian_fem_unemp_1664    = "C23002C_021",  # Unemployed, female 16-64
  aian_fem_lf_65plus     = "C23002C_024",  # In labor force, female 65+
  aian_fem_emp_65plus    = "C23002C_025",  # Employed, female 65+
  aian_fem_unemp_65plus  = "C23002C_026",  # Unemployed, female 65+
  
  # Total population employment (all races, civilian noninst. 16+)
  total_pop_16plus = "B23025_001",
  total_lf         = "B23025_002",
  total_employed   = "B23025_004",
  total_unemployed = "B23025_005",
  
  # Median earnings (full-time year-round workers 16+)
  aian_earnings  = "B20017C_001",
  total_earnings = "B20017_001"
)

labor_2023 <- get_acs(
  geography = "state",
  variables = labor_vars,
  state     = target_states,
  year      = yr3,
  survey    = "acs5",
  output    = "wide"
)

labor_2019 <- get_acs(
  geography = "state",
  variables = labor_vars,
  state     = target_states,
  year      = yr2,
  survey    = "acs5",
  output    = "wide"
)

labor_2015 <- get_acs(
  geography = "state",
  variables = labor_vars,
  state     = target_states,
  year      = yr1,
  survey    = "acs5",
  output    = "wide"
)

cat("Labor market data pulled:",
    nrow(labor_2023), "states (2023),",
    nrow(labor_2019), "states (2019),",
    nrow(labor_2015), "states (2015)\n")


# =============================================================
# SECTION 2: POVERTY AND INCOME DATA
# Tables: B17001C, B17001, B19013C, B19013, B19301C, B19301
# Universes and limitations: see CODEBOOK.md
# =============================================================

poverty_vars <- c(
  
  # Poverty status
  aian_total         = "B17001C_001",  # AIAN poverty universe
  aian_below_poverty = "B17001C_002",  # AIAN below poverty line
  total_total         = "B17001_001",  # Total poverty universe
  total_below_poverty = "B17001_002",  # Total below poverty line
  
  # Median household income (inflation-adjusted to vintage year)
  aian_median_income  = "B19013C_001", # AIAN householder
  total_median_income = "B19013_001",  # All householders
  
  # Per capita income (inflation-adjusted to vintage year)
  aian_per_capita  = "B19301C_001",
  total_per_capita = "B19301_001"
)

poverty_2023 <- get_acs(
  geography = "state",
  variables = poverty_vars,
  state     = target_states,
  year      = yr3,
  survey    = "acs5",
  output    = "wide"
)

poverty_2019 <- get_acs(
  geography = "state",
  variables = poverty_vars,
  state     = target_states,
  year      = yr2,
  survey    = "acs5",
  output    = "wide"
)

poverty_2015 <- get_acs(
  geography = "state",
  variables = poverty_vars,
  state     = target_states,
  year      = yr1,
  survey    = "acs5",
  output    = "wide"
)

cat("Poverty data pulled:",
    nrow(poverty_2023), "states (2023),",
    nrow(poverty_2019), "states (2019),",
    nrow(poverty_2015), "states (2015)\n")


# =============================================================
# SECTION 3: HOUSING DATA
# Tables: B25003C, B25003 (tenure only)
# Cost burden (B25070) excluded: no AIAN-specific breakdown.
# Universes and structural context: see CODEBOOK.md
# =============================================================

housing_vars <- c(
  
  # AIAN housing tenure (AIAN householder)
  aian_total_units = "B25003C_001",
  aian_owner       = "B25003C_002",
  aian_renter      = "B25003C_003",
  
  # Total population housing tenure
  total_total_units = "B25003_001",
  total_owner       = "B25003_002",
  total_renter      = "B25003_003"
)

housing_2023 <- get_acs(
  geography = "state",
  variables = housing_vars,
  state     = target_states,
  year      = yr3,
  survey    = "acs5",
  output    = "wide"
)

cat("Housing data pulled:", nrow(housing_2023), "states\n")


# =============================================================
# SECTION 4: MINNESOTA COUNTY MAP DATA
# Table: B02001 (race counts)
# geometry = TRUE returns sf object with TIGER/Line shapefiles
# =============================================================

map_vars <- c(
  aian_pop  = "B02001_004",  # AIAN alone population
  total_pop = "B02001_001"   # Total population
)

mn_county_map <- get_acs(
  geography = "county",
  variables = map_vars,
  state     = "MN",
  year      = yr3,
  survey    = "acs5",
  output    = "wide",
  geometry  = TRUE
)

cat("Map data pulled:", nrow(mn_county_map), "Minnesota counties\n")


# =============================================================
# VARIABLE VALIDATION
# =============================================================

cat("\nValidating all variables exist in ACS 2023...\n")

vars_2023 <- load_variables(2023, "acs5", cache = TRUE)

all_vars <- c(
  "C23002C_001",
  "C23002C_004", "C23002C_007", "C23002C_008",
  "C23002C_011", "C23002C_012", "C23002C_013",
  "C23002C_017", "C23002C_020", "C23002C_021",
  "C23002C_024", "C23002C_025", "C23002C_026",
  "B23025_001", "B23025_002", "B23025_004", "B23025_005",
  "B20017C_001", "B20017_001",
  "B17001C_001", "B17001C_002",
  "B17001_001",  "B17001_002",
  "B19013C_001", "B19013_001",
  "B19301C_001", "B19301_001",
  "B25003C_001", "B25003C_002", "B25003C_003",
  "B25003_001",  "B25003_002",  "B25003_003",
  "B02001_004",  "B02001_001"
)

found   <- all_vars[all_vars %in% vars_2023$name]
missing <- all_vars[!all_vars %in% vars_2023$name]

cat("Variables found:", length(found), "/", length(all_vars), "\n")
if (length(missing) > 0) {
  cat("MISSING VARIABLES — DO NOT PROCEED:\n")
  print(missing)
} else {
  cat("All variables validated. Safe to proceed.\n")
}


# =============================================================
# SAVE RAW DATA
# =============================================================

dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)

saveRDS(labor_2023,     "data/raw/labor_2023.rds")
saveRDS(labor_2019,     "data/raw/labor_2019.rds")
saveRDS(labor_2015,     "data/raw/labor_2015.rds")
saveRDS(poverty_2023,   "data/raw/poverty_2023.rds")
saveRDS(poverty_2019,   "data/raw/poverty_2019.rds")
saveRDS(poverty_2015,   "data/raw/poverty_2015.rds")
saveRDS(housing_2023,   "data/raw/housing_2023.rds")
saveRDS(mn_county_map,  "data/raw/mn_county_map.rds")

cat("\nAll raw data saved to data/raw/\n")
cat("  labor_2023.rds / labor_2019.rds / labor_2015.rds\n")
cat("  poverty_2023.rds / poverty_2019.rds / poverty_2015.rds\n")
cat("  housing_2023.rds\n")
cat("  mn_county_map.rds\n")
cat("\nNext step: run 02_clean.R\n")