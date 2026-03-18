# =============================================================
# 02_clean.R
# Purpose: data quality check, descriptive statistics, generate 
#          key indicators
# Author: Shan Jiang
# Last Updated: March 2026
#
# Workflow: load → quality check → raw overview → build indicators →
#           indicator summary → save
#
# Key decisions and known limitations: see CODEBOOK.md
# =============================================================

library(tidyverse)
library(sf)

# -------------------------------------------------------------
# HELPER FUNCTIONS
# -------------------------------------------------------------

# This pattern comes from my STATA habit — always check the denominator
# before dividing. Adapted to R's ifelse syntax from the JHU course.
safe_pct <- function(numerator, denominator) {
  ifelse(
    is.na(denominator) | denominator == 0,
    NA_real_,
    round(numerator / denominator * 100, 1)
  )
}

safe_ratio <- function(numerator, denominator) {
  ifelse(
    is.na(denominator) | denominator == 0,
    NA_real_,
    round(numerator / denominator, 3)
  )
}

state_labels <- c(
  "27" = "Minnesota",
  "30" = "Montana",
  "38" = "North Dakota",
  "46" = "South Dakota"
)

describe_dataset <- function(df, label) {
  cat("\n──", label, "──\n")
  # pivot_longer lets me summarize all variables at once instead of one by one
  df %>%
    select(NAME, ends_with("E")) %>%
    pivot_longer(-NAME, names_to = "variable", values_to = "value") %>%
    group_by(variable) %>%
    summarise(
      min    = min(value,    na.rm = TRUE),
      median = median(value, na.rm = TRUE),
      max    = max(value,    na.rm = TRUE),
      mean   = round(mean(value, na.rm = TRUE), 0),
      .groups = "drop"
    ) %>%
    print()
}

# Check MOE reliability for AIAN estimates
# If the margin of error is more than 50% of the estimate, it's unreliable
# Learned about MOE interpretation from Census Bureau documentation
check_moe <- function(df, label) {
  cat("\nMOE reliability check —", label, "\n")
  
  # Get just the AIAN estimate columns (ending in E) and their MOE pairs (ending in M)
  est_cols <- df %>% select(starts_with("aian") & ends_with("E")) %>% names()
  
  flagged <- 0
  for (col in est_cols) {
    moe_col <- str_replace(col, "E$", "M")
    if (!moe_col %in% names(df)) next
    
    for (i in 1:nrow(df)) {
      est_val <- df[[col]][i]
      moe_val <- df[[moe_col]][i]
      if (is.na(est_val) | is.na(moe_val) | est_val <= 0) next
      
      moe_pct <- round(moe_val / est_val * 100, 1)
      if (moe_pct > 50) {
        cat("  WARNING:", df$NAME[i], "—", col, "=", est_val,
            ", MOE =", moe_val, "(", moe_pct, "%)\n")
        flagged <- flagged + 1
      }
    }
  }
  
  if (flagged == 0) {
    cat("  PASS — No unreliable estimates (MOE > 50%)\n")
  } else {
    cat("  Total flagged:", flagged, "\n")
  }
}


# =============================================================
# STEP 1: LOAD RAW DATA
# =============================================================

labor_2023   <- readRDS("data/raw/labor_2023.rds")
labor_2019   <- readRDS("data/raw/labor_2019.rds")
labor_2015   <- readRDS("data/raw/labor_2015.rds")
poverty_2023 <- readRDS("data/raw/poverty_2023.rds")
poverty_2019 <- readRDS("data/raw/poverty_2019.rds")
poverty_2015 <- readRDS("data/raw/poverty_2015.rds")
housing_2023 <- readRDS("data/raw/housing_2023.rds")
mn_map_raw   <- readRDS("data/raw/mn_county_map.rds")

cat("Raw data loaded successfully\n")


# =============================================================
# STEP 2: DATA QUALITY CHECKS
# =============================================================

cat("\n=== STEP 2: DATA QUALITY CHECKS ===\n")

datasets <- list(
  "labor_2023"   = labor_2023,
  "labor_2019"   = labor_2019,
  "labor_2015"   = labor_2015,
  "poverty_2023" = poverty_2023,
  "poverty_2019" = poverty_2019,
  "poverty_2015" = poverty_2015,
  "housing_2023" = housing_2023
)

# ── QC 2A: Missing Values ──
cat("\n── QC 2A: Missing Values ──\n")

missing_summary <- tibble(dataset = character(), n_missing = integer())
for (name in names(datasets)) {
  df <- datasets[[name]]
  n_missing <- df %>% select(ends_with("E")) %>% is.na() %>% sum()
  missing_summary <- bind_rows(missing_summary, tibble(dataset = name, n_missing = n_missing))
}

print(missing_summary)

if (all(missing_summary$n_missing == 0)) {
  cat("RESULT: PASS — No missing values\n")
} else {
  cat("RESULT: WARNING — Missing values detected. Investigate before proceeding.\n")
}

# ── QC 2B: Duplicate Rows ──
cat("\n── QC 2B: Duplicate Rows ──\n")

dup_count <- tibble(dataset = character(), n_duplicates = integer())
for (name in names(datasets)) {
  df <- datasets[[name]]
  n_dup <- sum(duplicated(df$GEOID))
  dup_count <- bind_rows(dup_count, tibble(dataset = name, n_duplicates = n_dup))
}

print(dup_count)

if (all(dup_count$n_duplicates == 0)) {
  cat("RESULT: PASS — No duplicate rows\n")
} else {
  cat("RESULT: WARNING — Duplicates detected. Check get_acs() calls.\n")
}

# ── QC 2C: Zero Values in AIAN Variables ──
cat("\n── QC 2C: Zero Values in AIAN Variables ──\n")

zero_total <- 0
labor_datasets <- list(
  "labor_2023" = labor_2023, "labor_2019" = labor_2019, "labor_2015" = labor_2015
)
for (name in names(labor_datasets)) {
  df <- labor_datasets[[name]]
  zeros <- df %>%
    select(NAME, starts_with("aian"), -ends_with("M")) %>%
    select(NAME, ends_with("E")) %>%
    pivot_longer(-NAME, names_to = "variable", values_to = "value") %>%
    filter(value == 0)
  cat(name, "— zero values:", nrow(zeros), "\n")
  if (nrow(zeros) > 0) print(zeros)
  zero_total <- zero_total + nrow(zeros)
}

if (zero_total == 0) {
  cat("RESULT: PASS — No zero values\n")
} else {
  cat("RESULT: REVIEW —", zero_total, "zero values found.\n")
  cat("Check whether zeros reflect genuine zero counts (MOE = 0)\n")
  cat("or potential suppression (MOE > 0). Small subgroups (e.g.,\n")
  cat("AIAN 65+ in ND) commonly produce genuine zeros.\n")
}

# ── QC 2D: MOE Reliability ──
cat("\n── QC 2D: MOE Reliability (flag if MOE > 50%) ──\n")

check_moe(labor_2023,   "labor 2023")
check_moe(labor_2019,   "labor 2019")
check_moe(labor_2015,   "labor 2015")
check_moe(poverty_2023, "poverty 2023")
check_moe(poverty_2019, "poverty 2019")
check_moe(poverty_2015, "poverty 2015")
check_moe(housing_2023, "housing 2023")

cat("\nMOE checks complete — review any warnings above\n")

# ── QC 2E: Logical Consistency (all years) ──
cat("\n── QC 2E: Logical Consistency ──\n")

# Labor: employed <= labor force (all three vintages)
cat("\nLabor — employed <= labor force:\n")
labor_logic <- tibble()
for (yr in c("2023", "2019", "2015")) {
  df <- list("2023" = labor_2023, "2019" = labor_2019, "2015" = labor_2015)[[yr]]
  result <- df %>%
    mutate(
      male_1664_ok   = aian_male_emp_1664E   <= aian_male_lf_1664E,
      male_65plus_ok = aian_male_emp_65plusE  <= aian_male_lf_65plusE,
      fem_1664_ok    = aian_fem_emp_1664E    <= aian_fem_lf_1664E,
      fem_65plus_ok  = aian_fem_emp_65plusE   <= aian_fem_lf_65plusE,
      total_ok       = total_employedE        <= total_lfE,
      year = yr
    ) %>%
    select(NAME, year, male_1664_ok, male_65plus_ok,
           fem_1664_ok, fem_65plus_ok, total_ok)
  labor_logic <- bind_rows(labor_logic, result)
}

print(labor_logic)
labor_all_pass <- all(unlist(select(labor_logic, ends_with("_ok"))))

# Poverty: below_poverty <= universe (all three vintages)
cat("\nPoverty — below_poverty <= universe:\n")
poverty_logic <- tibble()
for (yr in c("2023", "2019", "2015")) {
  df <- list("2023" = poverty_2023, "2019" = poverty_2019, "2015" = poverty_2015)[[yr]]
  result <- df %>%
    mutate(
      aian_ok  = aian_below_povertyE <= aian_totalE,
      total_ok = total_below_povertyE <= total_totalE,
      year = yr
    ) %>%
    select(NAME, year, aian_ok, total_ok)
  poverty_logic <- bind_rows(poverty_logic, result)
}

print(poverty_logic)
poverty_all_pass <- all(unlist(select(poverty_logic, ends_with("_ok"))))

# Housing: owner + renter <= total
cat("\nHousing — tenure consistency:\n")
housing_logic <- housing_2023 %>%
  mutate(
    aian_ok  = (aian_ownerE + aian_renterE) <= aian_total_unitsE,
    total_ok = (total_ownerE + total_renterE) <= total_total_unitsE
  ) %>%
  select(NAME, aian_ok, total_ok)

print(housing_logic)
housing_all_pass <- all(unlist(select(housing_logic, ends_with("_ok"))))

if (all(labor_all_pass, poverty_all_pass, housing_all_pass)) {
  cat("RESULT: PASS — All logical consistency checks passed\n")
} else {
  cat("RESULT: WARNING — Logical inconsistency detected. Investigate.\n")
}

# ── QC 2F: Cross-Vintage Consistency ──
cat("\n── QC 2F: Cross-Vintage Consistency ──\n")
cat("Checking total population 16+ across vintages for plausibility\n\n")

vintage_check <- bind_rows(
  labor_2015 %>% select(NAME, GEOID, total_pop = total_pop_16plusE) %>% mutate(year = 2015),
  labor_2019 %>% select(NAME, GEOID, total_pop = total_pop_16plusE) %>% mutate(year = 2019),
  labor_2023 %>% select(NAME, GEOID, total_pop = total_pop_16plusE) %>% mutate(year = 2023)
) %>%
  arrange(GEOID, year) %>%
  group_by(GEOID, NAME) %>%
  mutate(
    pct_change = round((total_pop / lag(total_pop) - 1) * 100, 1)
  ) %>%
  ungroup()

print(vintage_check)

# Flag any vintage-to-vintage change > 30% as suspicious
large_swings <- vintage_check %>% filter(abs(pct_change) > 30)
if (nrow(large_swings) == 0) {
  cat("RESULT: PASS — No implausible population swings (>30%) between vintages\n")
} else {
  cat("RESULT: WARNING —", nrow(large_swings), "large swings detected:\n")
  print(large_swings)
}

cat("\n=== QC COMPLETE ===\n")


# =============================================================
# STEP 3A: RAW DATA OVERVIEW
# Quick sanity check on raw variable magnitudes before
# indicator construction.
# =============================================================

cat("\n=== STEP 3A: RAW DATA OVERVIEW ===\n")

describe_dataset(labor_2023,   "Labor Market 2023")
describe_dataset(poverty_2023, "Poverty & Income 2023")
describe_dataset(housing_2023, "Housing 2023")

cat("\n── Quick magnitude checks ──\n")
cat("AIAN total_16plus range:",
    paste(range(labor_2023$aian_total_16plusE), collapse = " – "), "\n")
cat("AIAN median earnings: $",
    median(labor_2023$aian_earningsE),
    " vs total: $", median(labor_2023$total_earningsE), "\n")
cat("AIAN median HH income: $",
    median(poverty_2023$aian_median_incomeE),
    " vs total: $", median(poverty_2023$total_median_incomeE), "\n")


# =============================================================
# STEP 4: INDICATOR CONSTRUCTION
# =============================================================

cat("\n=== STEP 4: INDICATOR CONSTRUCTION ===\n")

# -------------------------------------------------------------
# 4A: LABOR MARKET INDICATORS
#
# LFPR denominator: aian_total_16plusE (C23002C_001)
# Corrected from earlier version that used total_pop_16plusE
# (B23025_001, all races) — a universe mismatch.
# -------------------------------------------------------------

clean_labor <- function(df, year_label) {
  df %>%
    mutate(
      state_name = state_labels[GEOID],
      year       = year_label,
      
      # Sum AIAN labor force across all age/sex groups
      aian_lf_total = rowSums(
        cbind(
          aian_male_lf_1664E,  aian_male_lf_65plusE,
          aian_fem_lf_1664E,   aian_fem_lf_65plusE
        ),
        na.rm = TRUE
      ),
      
      # Sum AIAN unemployed across all age/sex groups
      aian_unemp_total = rowSums(
        cbind(
          aian_male_unemp_1664E,  aian_male_unemp_65plusE,
          aian_fem_unemp_1664E,   aian_fem_unemp_65plusE
        ),
        na.rm = TRUE
      ),
      
      # Rates and gaps
      aian_unemp_rate  = safe_pct(aian_unemp_total, aian_lf_total),
      total_unemp_rate = safe_pct(total_unemployedE, total_lfE),
      unemp_gap        = round(aian_unemp_rate - total_unemp_rate, 1),
      unemp_ratio      = safe_ratio(aian_unemp_rate, total_unemp_rate),
      
      aian_lfpr  = safe_pct(aian_lf_total, aian_total_16plusE),
      total_lfpr = safe_pct(total_lfE, total_pop_16plusE),
      lfpr_gap   = round(aian_lfpr - total_lfpr, 1),
      
      aian_earnings  = aian_earningsE,
      total_earnings = total_earningsE,
      earnings_ratio = safe_ratio(aian_earningsE, total_earningsE)
      
    ) %>%
    select(
      GEOID, state_name, year,
      aian_lf_total, aian_unemp_total,
      aian_unemp_rate, total_unemp_rate, unemp_gap, unemp_ratio,
      aian_lfpr, total_lfpr, lfpr_gap,
      aian_earnings, total_earnings, earnings_ratio
    )
}

labor_2023_clean <- clean_labor(labor_2023, 2023)
labor_2019_clean <- clean_labor(labor_2019, 2019)
labor_2015_clean <- clean_labor(labor_2015, 2015)

labor_clean <- bind_rows(
  labor_2023_clean, labor_2019_clean, labor_2015_clean
) %>%
  arrange(state_name, year)

cat("Labor indicators constructed:", nrow(labor_clean), "rows\n")

# -------------------------------------------------------------
# 4B: POVERTY AND INCOME INDICATORS
# -------------------------------------------------------------

clean_poverty <- function(df, year_label) {
  df %>%
    mutate(
      state_name = state_labels[GEOID],
      year       = year_label,
      
      aian_poverty_rate  = safe_pct(aian_below_povertyE, aian_totalE),
      total_poverty_rate = safe_pct(total_below_povertyE, total_totalE),
      poverty_gap        = round(aian_poverty_rate -
                                   total_poverty_rate, 1),
      
      aian_median_income  = aian_median_incomeE,
      total_median_income = total_median_incomeE,
      income_ratio        = safe_ratio(aian_median_incomeE,
                                       total_median_incomeE),
      
      aian_per_capita  = aian_per_capitaE,
      total_per_capita = total_per_capitaE,
      per_capita_ratio = safe_ratio(aian_per_capitaE,
                                    total_per_capitaE)
    ) %>%
    select(
      GEOID, state_name, year,
      aian_poverty_rate, total_poverty_rate, poverty_gap,
      aian_median_income, total_median_income, income_ratio,
      aian_per_capita, total_per_capita, per_capita_ratio
    )
}

poverty_2023_clean <- clean_poverty(poverty_2023, 2023)
poverty_2019_clean <- clean_poverty(poverty_2019, 2019)
poverty_2015_clean <- clean_poverty(poverty_2015, 2015)

poverty_clean <- bind_rows(
  poverty_2023_clean, poverty_2019_clean, poverty_2015_clean
) %>%
  arrange(state_name, year)

cat("Poverty indicators constructed:", nrow(poverty_clean), "rows\n")

# -------------------------------------------------------------
# 4C: HOUSING INDICATORS
# Homeownership only. See CODEBOOK.md for structural context.
# -------------------------------------------------------------

housing_clean <- housing_2023 %>%
  mutate(
    state_name = state_labels[GEOID],
    year       = 2023,
    
    aian_ownership_rate  = safe_pct(aian_ownerE, aian_total_unitsE),
    total_ownership_rate = safe_pct(total_ownerE, total_total_unitsE),
    ownership_gap        = round(total_ownership_rate -
                                   aian_ownership_rate, 1)
  ) %>%
  select(
    GEOID, state_name, year,
    aian_ownership_rate, total_ownership_rate, ownership_gap
  )

cat("Housing indicators constructed:", nrow(housing_clean), "states\n")

# -------------------------------------------------------------
# 4D: MINNESOTA COUNTY MAP
# -------------------------------------------------------------

mn_map_clean <- mn_map_raw %>%
  mutate(
    county_name = str_remove(NAME, " County, Minnesota"),
    aian_share  = safe_pct(aian_popE, total_popE)
  ) %>%
  select(
    GEOID, county_name,
    aian_pop  = aian_popE,
    total_pop = total_popE,
    aian_share, geometry
  )

cat("Map data cleaned:", nrow(mn_map_clean), "Minnesota counties\n")
cat("Counties with >5% AIAN:",
    sum(mn_map_clean$aian_share > 5,  na.rm = TRUE), "\n")
cat("Counties with >10% AIAN:",
    sum(mn_map_clean$aian_share > 10, na.rm = TRUE), "\n")


# =============================================================
# STEP 3B: INDICATOR SUMMARY
# Descriptive statistics on constructed indicators — the
# numbers that drive analysis and visualization.
# =============================================================

cat("\n=== STEP 3B: INDICATOR SUMMARY ===\n")

cat("\n── Labor Market (2023) ──\n")
labor_clean %>%
  filter(year == 2023) %>%
  select(state_name, aian_unemp_rate, total_unemp_rate,
         unemp_gap, aian_lfpr, total_lfpr, lfpr_gap,
         earnings_ratio) %>%
  print()

cat("\n── Labor Market Trends (all years) ──\n")
labor_clean %>%
  select(state_name, year, aian_unemp_rate, unemp_gap,
         aian_lfpr, lfpr_gap, earnings_ratio) %>%
  arrange(state_name, year) %>%
  print(n = 12)

cat("\n── Poverty & Income (2023) ──\n")
poverty_clean %>%
  filter(year == 2023) %>%
  select(state_name, aian_poverty_rate, total_poverty_rate,
         poverty_gap, income_ratio, per_capita_ratio) %>%
  print()

cat("\n── Poverty Trends (all years) ──\n")
poverty_clean %>%
  select(state_name, year, aian_poverty_rate, poverty_gap,
         income_ratio, per_capita_ratio) %>%
  arrange(state_name, year) %>%
  print(n = 12)

cat("\n── Housing (2023) ──\n")
housing_clean %>%
  select(state_name, aian_ownership_rate,
         total_ownership_rate, ownership_gap) %>%
  print()

cat("\n── Key Findings ──\n")
cat("Worst unemployment gap (2023):",
    labor_clean %>% filter(year == 2023) %>%
      slice_max(unemp_gap) %>% pull(state_name),
    "at", labor_clean %>% filter(year == 2023) %>%
      slice_max(unemp_gap) %>% pull(unemp_gap), "pp\n")
cat("Worst poverty gap (2023):",
    poverty_clean %>% filter(year == 2023) %>%
      slice_max(poverty_gap) %>% pull(state_name),
    "at", poverty_clean %>% filter(year == 2023) %>%
      slice_max(poverty_gap) %>% pull(poverty_gap), "pp\n")
cat("Worst ownership gap (2023):",
    housing_clean %>%
      slice_max(ownership_gap) %>% pull(state_name),
    "at", housing_clean %>%
      slice_max(ownership_gap) %>% pull(ownership_gap), "pp\n")


# =============================================================
# STEP 5: SAVE CLEAN DATASETS
# =============================================================

dir.create("data/clean", recursive = TRUE, showWarnings = FALSE)

saveRDS(labor_clean,   "data/clean/labor_clean.rds")
saveRDS(poverty_clean, "data/clean/poverty_clean.rds")
saveRDS(housing_clean, "data/clean/housing_clean.rds")
saveRDS(mn_map_clean,  "data/clean/mn_map_clean.rds")

cat("\n=== STEP 5: CLEAN DATA SAVED ===\n")
cat("  labor_clean.rds  —", nrow(labor_clean),
    "rows (4 states x 3 years)\n")
cat("  poverty_clean.rds —", nrow(poverty_clean),
    "rows (4 states x 3 years)\n")
cat("  housing_clean.rds —", nrow(housing_clean),
    "rows (4 states, 2023 only)\n")
cat("  mn_map_clean.rds  —", nrow(mn_map_clean),
    "Minnesota counties\n")
cat("\nNext step: run 03_analysis.R\n")