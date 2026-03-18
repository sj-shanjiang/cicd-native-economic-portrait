# =============================================================
# 03_analysis.R
# Purpose: Trend, cross-state, and disparity analysis
# Author: Shan Jiang
# Last Updated: March 2026
#
# Workflow: Load clean data → Trend analysis →
#           Pandemic impact → Cross-state comparison →
#           Key findings → CICD implications
#
# Input: data/clean/ (from 02_clean.R)
# Output: data/analysis/ (.rds files for 04_visualize.R)
# =============================================================

library(tidyverse)

labor_clean   <- readRDS("data/clean/labor_clean.rds")
poverty_clean <- readRDS("data/clean/poverty_clean.rds")
housing_clean <- readRDS("data/clean/housing_clean.rds")

cat("Clean data loaded\n")
cat("  Labor:", nrow(labor_clean), "rows\n")
cat("  Poverty:", nrow(poverty_clean), "rows\n")
cat("  Housing:", nrow(housing_clean), "rows\n")


# =============================================================
# ANALYSIS 1: TRENDS (2015 → 2019 → 2023)
#
# Three ACS 5-year windows allow us to distinguish 
# pre-pandemic trend from pandemic-era changes.
# =============================================================

cat("\n=== ANALYSIS 1: TRENDS ===\n")

# -------------------------------------------------------------
# 1A: Labor Market Trends
# -------------------------------------------------------------

labor_trend <- labor_clean %>%
  select(state_name, year,
         aian_unemp_rate, total_unemp_rate, unemp_gap,
         aian_lfpr, total_lfpr, lfpr_gap,
         earnings_ratio) %>%
  pivot_wider(
    names_from  = year,
    values_from = c(aian_unemp_rate, total_unemp_rate, unemp_gap,
                    aian_lfpr, total_lfpr, lfpr_gap,
                    earnings_ratio),
    names_sep   = "_"
  ) %>%
  mutate(
    # Unemployment rate changes (negative = improvement)
    unemp_chg_1519 = round(aian_unemp_rate_2019 - aian_unemp_rate_2015, 1),
    unemp_chg_1923 = round(aian_unemp_rate_2023 - aian_unemp_rate_2019, 1),
    unemp_chg_1523 = round(aian_unemp_rate_2023 - aian_unemp_rate_2015, 1),
    
    # Gap changes (negative = gap narrowing)
    gap_chg_1519 = round(unemp_gap_2019 - unemp_gap_2015, 1),
    gap_chg_1923 = round(unemp_gap_2023 - unemp_gap_2019, 1),
    gap_chg_1523 = round(unemp_gap_2023 - unemp_gap_2015, 1),
    
    # LFPR changes (negative = more people leaving labor force)
    lfpr_chg_1519 = round(aian_lfpr_2019 - aian_lfpr_2015, 1),
    lfpr_chg_1923 = round(aian_lfpr_2023 - aian_lfpr_2019, 1),
    lfpr_chg_1523 = round(aian_lfpr_2023 - aian_lfpr_2015, 1),
    
    # Earnings ratio changes (positive = gap narrowing)
    earn_chg_1519 = round(earnings_ratio_2019 - earnings_ratio_2015, 3),
    earn_chg_1923 = round(earnings_ratio_2023 - earnings_ratio_2019, 3),
    earn_chg_1523 = round(earnings_ratio_2023 - earnings_ratio_2015, 3)
  )

cat("\n── AIAN Unemployment Rate Changes ──\n")
labor_trend %>%
  select(state_name,
         unemp_2015 = aian_unemp_rate_2015,
         unemp_2019 = aian_unemp_rate_2019,
         unemp_2023 = aian_unemp_rate_2023,
         unemp_chg_1519, unemp_chg_1923, unemp_chg_1523) %>%
  print()

cat("\n── Unemployment Gap Changes (AIAN - Total) ──\n")
labor_trend %>%
  select(state_name,
         gap_2015 = unemp_gap_2015,
         gap_2019 = unemp_gap_2019,
         gap_2023 = unemp_gap_2023,
         gap_chg_1519, gap_chg_1923, gap_chg_1523) %>%
  print()

cat("\n── AIAN LFPR Changes ──\n")
labor_trend %>%
  select(state_name,
         lfpr_2015 = aian_lfpr_2015,
         lfpr_2019 = aian_lfpr_2019,
         lfpr_2023 = aian_lfpr_2023,
         lfpr_chg_1519, lfpr_chg_1923, lfpr_chg_1523) %>%
  print()

cat("\n── Earnings Ratio Changes (AIAN / Total) ──\n")
labor_trend %>%
  select(state_name,
         earn_2015 = earnings_ratio_2015,
         earn_2019 = earnings_ratio_2019,
         earn_2023 = earnings_ratio_2023,
         earn_chg_1519, earn_chg_1923, earn_chg_1523) %>%
  print()

# -------------------------------------------------------------
# 1B: Poverty and Income Trends
# -------------------------------------------------------------

poverty_trend <- poverty_clean %>%
  select(state_name, year,
         aian_poverty_rate, total_poverty_rate, poverty_gap,
         income_ratio, per_capita_ratio) %>%
  pivot_wider(
    names_from  = year,
    values_from = c(aian_poverty_rate, total_poverty_rate, poverty_gap,
                    income_ratio, per_capita_ratio),
    names_sep   = "_"
  ) %>%
  mutate(
    # Poverty rate changes (negative = improvement)
    pov_chg_1519 = round(aian_poverty_rate_2019 - aian_poverty_rate_2015, 1),
    pov_chg_1923 = round(aian_poverty_rate_2023 - aian_poverty_rate_2019, 1),
    pov_chg_1523 = round(aian_poverty_rate_2023 - aian_poverty_rate_2015, 1),
    
    # Poverty gap changes (negative = gap narrowing)
    pov_gap_chg_1519 = round(poverty_gap_2019 - poverty_gap_2015, 1),
    pov_gap_chg_1923 = round(poverty_gap_2023 - poverty_gap_2019, 1),
    pov_gap_chg_1523 = round(poverty_gap_2023 - poverty_gap_2015, 1),
    
    # Income ratio changes (positive = gap narrowing)
    inc_chg_1519 = round(income_ratio_2019 - income_ratio_2015, 3),
    inc_chg_1923 = round(income_ratio_2023 - income_ratio_2019, 3),
    inc_chg_1523 = round(income_ratio_2023 - income_ratio_2015, 3)
  )

cat("\n── AIAN Poverty Rate Changes ──\n")
poverty_trend %>%
  select(state_name,
         pov_2015 = aian_poverty_rate_2015,
         pov_2019 = aian_poverty_rate_2019,
         pov_2023 = aian_poverty_rate_2023,
         pov_chg_1519, pov_chg_1923, pov_chg_1523) %>%
  print()

cat("\n── Poverty Gap Changes (AIAN - Total) ──\n")
poverty_trend %>%
  select(state_name,
         gap_2015 = poverty_gap_2015,
         gap_2019 = poverty_gap_2019,
         gap_2023 = poverty_gap_2023,
         pov_gap_chg_1519, pov_gap_chg_1923, pov_gap_chg_1523) %>%
  print()

cat("\n── Income Ratio Changes (AIAN HH / Total HH) ──\n")
poverty_trend %>%
  select(state_name,
         inc_2015 = income_ratio_2015,
         inc_2019 = income_ratio_2019,
         inc_2023 = income_ratio_2023,
         inc_chg_1519, inc_chg_1923, inc_chg_1523) %>%
  print()

# -------------------------------------------------------------
# 1C: LFPR vs Unemployment — Divergence Flag
#
# Falling unemployment + falling LFPR may indicate labor
# force exit rather than genuine employment improvement.
# This is particularly relevant for South Dakota.
# -------------------------------------------------------------

cat("\n── LFPR vs Unemployment Divergence ──\n")
cat("States where AIAN unemployment fell but LFPR also fell (2015→2023):\n")
cat("This pattern suggests people leaving the labor force,\n")
cat("not finding employment.\n\n")

divergence <- labor_trend %>%
  select(state_name,
         unemp_chg = unemp_chg_1523,
         lfpr_chg  = lfpr_chg_1523) %>%
  mutate(
    unemp_improved = unemp_chg < 0,
    lfpr_declined  = lfpr_chg < 0,
    divergent      = unemp_improved & lfpr_declined
  )

print(divergence)

divergent_states <- divergence %>% filter(divergent) %>% pull(state_name)
if (length(divergent_states) > 0) {
  cat("\nDivergent states:", paste(divergent_states, collapse = ", "), "\n")
  cat("Interpret unemployment improvement in these states with caution.\n")
} else {
  cat("\nNo divergent states found.\n")
}


# =============================================================
# ANALYSIS 2: PANDEMIC-ERA IMPACT (2019 → 2023)
#
# Compares AIAN vs total population changes during the
# pandemic window. Positive asymmetry = AIAN experienced
# a worse outcome (or less improvement) than total pop.
#
# NOTE: ACS 5-year estimates smooth annual volatility.
# The 2023 vintage (2019-2023) captures net change across
# the entire pandemic period, not peak-to-trough impact.
#
# Observed improvements during 2019→2023 coincided with
# substantial federal relief (CARES Act, ARP tribal
# allocations), but this analysis cannot isolate the
# causal contribution of those programs from broader
# economic recovery or demographic shifts.
# =============================================================

cat("\n=== ANALYSIS 2: PANDEMIC-ERA IMPACT (2019 → 2023) ===\n")

# Unemployment asymmetry
pandemic_labor <- labor_clean %>%
  filter(year %in% c(2019, 2023)) %>%
  select(state_name, year, aian_unemp_rate, total_unemp_rate) %>%
  pivot_wider(
    names_from  = year,
    values_from = c(aian_unemp_rate, total_unemp_rate),
    names_sep   = "_"
  ) %>%
  mutate(
    aian_chg  = round(aian_unemp_rate_2023 - aian_unemp_rate_2019, 1),
    total_chg = round(total_unemp_rate_2023 - total_unemp_rate_2019, 1),
    # Positive = AIAN fared worse (or improved less) than total
    asymmetry = round(aian_chg - total_chg, 1)
  )

cat("\n── Unemployment: Pandemic-Era Asymmetry ──\n")
pandemic_labor %>%
  select(state_name, aian_chg, total_chg, asymmetry) %>%
  print()

# Poverty asymmetry
pandemic_poverty <- poverty_clean %>%
  filter(year %in% c(2019, 2023)) %>%
  select(state_name, year, aian_poverty_rate, total_poverty_rate) %>%
  pivot_wider(
    names_from  = year,
    values_from = c(aian_poverty_rate, total_poverty_rate),
    names_sep   = "_"
  ) %>%
  mutate(
    aian_chg  = round(aian_poverty_rate_2023 - aian_poverty_rate_2019, 1),
    total_chg = round(total_poverty_rate_2023 - total_poverty_rate_2019, 1),
    asymmetry = round(aian_chg - total_chg, 1)
  )

cat("\n── Poverty: Pandemic-Era Asymmetry ──\n")
pandemic_poverty %>%
  select(state_name, aian_chg, total_chg, asymmetry) %>%
  print()

cat("\nInterpretation guide:\n")
cat("  Positive asymmetry = AIAN fared worse than total pop\n")
cat("  Negative asymmetry = AIAN improved more than total pop\n")
cat("  Zero = proportional change\n")


# =============================================================
# ANALYSIS 3: CROSS-STATE COMPARISON (2023 SNAPSHOT)
#
# Rankings across all disparity dimensions to identify
# which states show the deepest structural gaps.
# =============================================================

cat("\n=== ANALYSIS 3: CROSS-STATE COMPARISON (2023) ===\n")

# Combine all 2023 indicators into one summary table
snapshot_2023 <- labor_clean %>%
  filter(year == 2023) %>%
  select(state_name, aian_unemp_rate, unemp_gap,
         aian_lfpr, lfpr_gap, earnings_ratio) %>%
  left_join(
    poverty_clean %>%
      filter(year == 2023) %>%
      select(state_name, aian_poverty_rate, poverty_gap,
             income_ratio, per_capita_ratio),
    by = "state_name"
  ) %>%
  left_join(
    housing_clean %>%
      select(state_name, aian_ownership_rate, ownership_gap),
    by = "state_name"
  )

cat("\n── 2023 Disparity Dashboard ──\n")
print(snapshot_2023)

# Rank by worst gap in each dimension
cat("\n── Rankings by Worst Gap (2023) ──\n")

rankings <- tibble(
  dimension = c("Unemployment gap", "LFPR gap", "Earnings ratio",
                "Poverty gap", "Income ratio", "Ownership gap"),
  worst_state = c(
    snapshot_2023 %>% slice_max(unemp_gap)     %>% pull(state_name),
    snapshot_2023 %>% slice_min(lfpr_gap)       %>% pull(state_name),
    snapshot_2023 %>% slice_min(earnings_ratio) %>% pull(state_name),
    snapshot_2023 %>% slice_max(poverty_gap)    %>% pull(state_name),
    snapshot_2023 %>% slice_min(income_ratio)   %>% pull(state_name),
    snapshot_2023 %>% slice_max(ownership_gap)  %>% pull(state_name)
  ),
  worst_value = c(
    snapshot_2023 %>% slice_max(unemp_gap)     %>% pull(unemp_gap),
    snapshot_2023 %>% slice_min(lfpr_gap)       %>% pull(lfpr_gap),
    snapshot_2023 %>% slice_min(earnings_ratio) %>% pull(earnings_ratio),
    snapshot_2023 %>% slice_max(poverty_gap)    %>% pull(poverty_gap),
    snapshot_2023 %>% slice_min(income_ratio)   %>% pull(income_ratio),
    snapshot_2023 %>% slice_max(ownership_gap)  %>% pull(ownership_gap)
  )
)

print(rankings)

# Most improved state (2015→2023 unemployment gap narrowing)
cat("\n── Most Improved (Unemployment Gap, 2015→2023) ──\n")
labor_trend %>%
  select(state_name, gap_chg_1523) %>%
  arrange(gap_chg_1523) %>%
  print()


# =============================================================
# ANALYSIS 4: KEY FINDINGS AND CICD IMPLICATIONS
# =============================================================

cat("\n=== ANALYSIS 4: KEY FINDINGS ===\n")

cat("\n── Finding 1: South Dakota stands apart ──\n")
cat("SD shows the worst disparities across all dimensions:\n")
cat("  AIAN poverty rate: 45.2% (vs 12.0% total)\n")
cat("  AIAN unemployment: 15.1% (vs 3.0% total)\n")
cat("  AIAN homeownership: 38.3% (vs 68.6% total)\n")
cat("  Poverty gap of 33.2 pp is the widest in the study.\n")

cat("\n── Finding 2: Unemployment decline may mask labor force exit ──\n")
cat("SD AIAN unemployment fell from 23.2% to 15.1% (2015→2023),\n")
cat("but LFPR simultaneously declined from 56.5% to 49.4%.\n")
cat("This suggests a significant portion of the apparent\n")
cat("improvement reflects people leaving the labor force rather\n")
cat("than finding employment. By 2023, more than half of SD's\n")
cat("AIAN working-age population was outside the labor market.\n")

cat("\n── Finding 3: Poverty improved, but gaps persist ──\n")
cat("AIAN poverty rates declined across all four states between\n")
cat("2015 and 2023. However, the AIAN-total gap narrowed\n")
cat("meaningfully only in Minnesota (-2.3 pp) and North Dakota\n")
cat("(-7.9 pp). In South Dakota, the gap barely moved (-1.0 pp)\n")
cat("despite a 3.1 pp decline in the AIAN rate itself — because\n")
cat("the total population rate also improved.\n")

cat("\n── Finding 4: Earnings gaps show no clear convergence ──\n")
cat("AIAN-to-total earnings ratios fluctuated without a\n")
cat("consistent upward trend. Among full-time year-round\n")
cat("workers, AIAN earnings ranged from 60.5% (SD) to 76.0%\n")
cat("(MT) of the total population in 2023. Given that this\n")
cat("metric excludes part-time and seasonal workers — more\n")
cat("prevalent in reservation economies — the true earnings\n")
cat("gap is likely larger.\n")

cat("\n── Finding 5: Housing gap is structural ──\n")
cat("AIAN homeownership rates (38-49%) lag total rates (63-72%)\n")
cat("by 16-30 pp. This gap reflects structural barriers —\n")
cat("federal trust land status, land fractionation, infrastructure\n")
cat("gaps — that income improvement alone cannot close.\n")
cat("See CODEBOOK.md for structural context.\n")

cat("\n── Implications for CICD Data Products ──\n")
cat("1. The LFPR-unemployment divergence in South Dakota\n")
cat("   suggests that CICD's Native Labor Market Tracker\n")
cat("   should surface LFPR alongside unemployment — reporting\n")
cat("   unemployment alone risks overstating improvement.\n")
cat("\n")
cat("2. Cross-vintage trend analysis at this level of detail\n")
cat("   is not currently available in the Native Community\n")
cat("   Data Profiles (which report single-vintage snapshots).\n")
cat("   Adding a trend dimension could help tribal leaders and\n")
cat("   researchers assess whether conditions are improving or\n")
cat("   whether apparent gains mask deeper structural shifts.\n")
cat("\n")
cat("3. The persistent housing gap across all income levels\n")
cat("   reinforces the case for CICD's ongoing research on\n")
cat("   Native CDFI lending and Section 184 utilization — the\n")
cat("   barrier is access to mortgage products, not income.\n")


# =============================================================
# SAVE ANALYSIS OUTPUTS
# =============================================================

dir.create("data/analysis", recursive = TRUE, showWarnings = FALSE)

saveRDS(labor_trend,     "data/analysis/labor_trend.rds")
saveRDS(poverty_trend,   "data/analysis/poverty_trend.rds")
saveRDS(pandemic_labor,  "data/analysis/pandemic_labor.rds")
saveRDS(pandemic_poverty,"data/analysis/pandemic_poverty.rds")
saveRDS(snapshot_2023,   "data/analysis/snapshot_2023.rds")
saveRDS(divergence,      "data/analysis/divergence.rds")

cat("\n=== ANALYSIS OUTPUTS SAVED ===\n")
cat("  labor_trend.rds      — 4 states, trend changes\n")
cat("  poverty_trend.rds    — 4 states, trend changes\n")
cat("  pandemic_labor.rds   — 4 states, asymmetry\n")
cat("  pandemic_poverty.rds — 4 states, asymmetry\n")
cat("  snapshot_2023.rds    — 4 states, all dimensions\n")
cat("  divergence.rds       — LFPR-unemployment divergence\n")
cat("\nNext step: run 04_visualize.R\n")