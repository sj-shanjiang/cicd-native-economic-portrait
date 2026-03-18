# =============================================================
# 04_visualize.R
# Purpose: Generate publication-ready exhibits
# Author: Shan Jiang
# Last Updated: March 2026
#
# Produces 5 core exhibits for the analysis report.
# All charts use a consistent theme and color palette.
#
# Input: data/clean/ and data/analysis/ (from 02 and 03)
# Output: output/figures/ (.png files)
# =============================================================

library(tidyverse)
library(sf)
library(scales)

# Load data
labor_clean   <- readRDS("data/clean/labor_clean.rds")
poverty_clean <- readRDS("data/clean/poverty_clean.rds")
housing_clean <- readRDS("data/clean/housing_clean.rds")
mn_map_clean  <- readRDS("data/clean/mn_map_clean.rds")
snapshot_2023 <- readRDS("data/analysis/snapshot_2023.rds")

cat("Data loaded for visualization\n")


# =============================================================
# SHARED THEME AND PALETTE
# =============================================================

AIAN_COLOR  <- "#1B4F72"
TOTAL_COLOR <- "#AED6F1"

theme_cicd <- function() {
  theme_minimal(base_size = 12) +
    theme(
      plot.title       = element_text(face = "bold", size = 13, hjust = 0),
      plot.subtitle    = element_text(size = 10, color = "gray40", hjust = 0),
      plot.caption     = element_text(size = 8, color = "gray50", hjust = 0),
      legend.position  = "bottom",
      legend.title     = element_blank(),
      panel.grid.minor = element_blank(),
      plot.margin      = margin(10, 15, 10, 10)
    )
}

dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

SOURCE_NOTE <- "Source: U.S. Census Bureau, American Community Survey 5-Year Estimates. Author analysis."


# =============================================================
# FIGURE 1: UNEMPLOYMENT RATE COMPARISON (2023)
# Grouped bar chart — AIAN vs total, four states
# =============================================================

cat("\nGenerating Figure 1: Unemployment Rate Comparison...\n")

fig1_data <- labor_clean %>%
  filter(year == 2023) %>%
  select(state_name, aian_unemp_rate, total_unemp_rate) %>%
  pivot_longer(
    cols      = c(aian_unemp_rate, total_unemp_rate),
    names_to  = "group",
    values_to = "rate"
  ) %>%
  mutate(
    group = recode(group,
                   "aian_unemp_rate"  = "American Indian & Alaska Native",
                   "total_unemp_rate" = "Total Population"
    ),
    # Order states by AIAN rate for visual impact
    state_name = fct_reorder(state_name, rate, .fun = max, .desc = TRUE)
  )

fig1 <- ggplot(fig1_data, aes(x = state_name, y = rate, fill = group)) +
  geom_col(position = "dodge", width = 0.65) +
  geom_text(
    aes(label = paste0(rate, "%")),
    position = position_dodge(width = 0.65),
    vjust = -0.4, size = 3.2
  ) +
  scale_fill_manual(values = c(
    "American Indian & Alaska Native" = AIAN_COLOR,
    "Total Population"                = TOTAL_COLOR
  )) +
  scale_y_continuous(
    labels = label_percent(scale = 1),
    expand = expansion(mult = c(0, 0.15))
  ) +
  labs(
    title    = "Unemployment Rate: AIAN vs. Total Population (2023)",
    subtitle = "Federal Reserve Ninth District States — ACS 5-Year Estimates",
    x = NULL, y = "Unemployment Rate (%)",
    caption  = SOURCE_NOTE
  ) +
  theme_cicd()

ggsave("output/figures/fig1_unemployment_comparison.png",
       fig1, width = 9, height = 5.5, dpi = 150, bg = "white")

cat("  Saved: fig1_unemployment_comparison.png\n")


# =============================================================
# FIGURE 2: LFPR vs UNEMPLOYMENT TREND — DIVERGENCE
# Dual-indicator line chart showing the disconnect between
# falling unemployment and falling LFPR.
# Focus: all four states, faceted.
# =============================================================

cat("Generating Figure 2: LFPR vs Unemployment Divergence...\n")

fig2_data <- labor_clean %>%
  select(state_name, year, aian_unemp_rate, aian_lfpr) %>%
  pivot_longer(
    cols      = c(aian_unemp_rate, aian_lfpr),
    names_to  = "indicator",
    values_to = "value"
  ) %>%
  mutate(
    indicator = recode(indicator,
                       "aian_unemp_rate" = "AIAN Unemployment Rate",
                       "aian_lfpr"       = "AIAN Labor Force Participation Rate"
    )
  )

fig2 <- ggplot(fig2_data, aes(x = year, y = value,
                              color = indicator, shape = indicator)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  geom_text(
    aes(label = paste0(value, "%")),
    vjust = -1, size = 2.8, show.legend = FALSE
  ) +
  facet_wrap(~ state_name, nrow = 1) +
  scale_color_manual(values = c(
    "AIAN Unemployment Rate"                 = "#C0392B",
    "AIAN Labor Force Participation Rate"    = AIAN_COLOR
  )) +
  scale_x_continuous(breaks = c(2015, 2019, 2023)) +
  scale_y_continuous(
    labels = label_percent(scale = 1),
    limits = c(0, 65)
  ) +
  labs(
    title    = "AIAN Unemployment Rate vs. Labor Force Participation (2015–2023)",
    subtitle = "Falling unemployment paired with falling LFPR suggests labor force exit, not employment gains",
    x = NULL, y = NULL,
    caption  = SOURCE_NOTE
  ) +
  theme_cicd() +
  theme(
    legend.position  = "bottom",
    strip.text       = element_text(face = "bold", size = 10),
    panel.spacing    = unit(1, "lines")
  )

ggsave("output/figures/fig2_lfpr_unemployment_divergence.png",
       fig2, width = 12, height = 5.5, dpi = 150, bg = "white")

cat("  Saved: fig2_lfpr_unemployment_divergence.png\n")


# =============================================================
# FIGURE 3: POVERTY RATE TREND (2015–2023)
# Faceted line chart — AIAN vs total, four states
# =============================================================

cat("Generating Figure 3: Poverty Rate Trend...\n")

fig3_data <- poverty_clean %>%
  select(state_name, year, aian_poverty_rate, total_poverty_rate) %>%
  pivot_longer(
    cols      = c(aian_poverty_rate, total_poverty_rate),
    names_to  = "group",
    values_to = "rate"
  ) %>%
  mutate(
    group = recode(group,
                   "aian_poverty_rate"  = "American Indian & Alaska Native",
                   "total_poverty_rate" = "Total Population"
    )
  )

fig3 <- ggplot(fig3_data, aes(x = year, y = rate,
                              color = group, shape = group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  geom_text(
    aes(label = paste0(rate, "%")),
    vjust = -1, size = 2.8, show.legend = FALSE
  ) +
  facet_wrap(~ state_name, nrow = 1) +
  scale_color_manual(values = c(
    "American Indian & Alaska Native" = AIAN_COLOR,
    "Total Population"                = TOTAL_COLOR
  )) +
  scale_x_continuous(breaks = c(2015, 2019, 2023)) +
  scale_y_continuous(
    labels = label_percent(scale = 1),
    limits = c(0, 55)
  ) +
  labs(
    title    = "Poverty Rate: AIAN vs. Total Population (2015–2023)",
    subtitle = "AIAN rates declined in all states, but the gap persists — especially in South Dakota",
    x = NULL, y = "Poverty Rate (%)",
    caption  = SOURCE_NOTE
  ) +
  coord_cartesian(clip = "off") +
  theme_cicd() +
  theme(
    strip.text    = element_text(face = "bold", size = 10),
    panel.spacing = unit(1.2, "lines"),
    plot.margin   = margin(10, 15, 10, 20)
  )

ggsave("output/figures/fig3_poverty_trend.png",
       fig3, width = 13, height = 5.5, dpi = 150, bg = "white")

cat("  Saved: fig3_poverty_trend.png\n")


# =============================================================
# FIGURE 4: HOMEOWNERSHIP RATE COMPARISON (2023)
# Grouped bar chart — AIAN vs total, four states
# =============================================================

cat("Generating Figure 4: Homeownership Rate Comparison...\n")

fig4_data <- housing_clean %>%
  select(state_name, aian_ownership_rate, total_ownership_rate) %>%
  pivot_longer(
    cols      = c(aian_ownership_rate, total_ownership_rate),
    names_to  = "group",
    values_to = "rate"
  ) %>%
  mutate(
    group = recode(group,
                   "aian_ownership_rate"  = "American Indian & Alaska Native",
                   "total_ownership_rate" = "Total Population"
    ),
    state_name = fct_reorder(state_name, rate, .fun = min)
  )

fig4 <- ggplot(fig4_data, aes(x = state_name, y = rate, fill = group)) +
  geom_col(position = "dodge", width = 0.65) +
  geom_text(
    aes(label = paste0(rate, "%")),
    position = position_dodge(width = 0.65),
    vjust = -0.4, size = 3.2
  ) +
  scale_fill_manual(values = c(
    "American Indian & Alaska Native" = AIAN_COLOR,
    "Total Population"                = TOTAL_COLOR
  )) +
  scale_y_continuous(
    labels = label_percent(scale = 1),
    expand = expansion(mult = c(0, 0.15)),
    limits = c(0, 85)
  ) +
  labs(
    title    = "Homeownership Rate: AIAN vs. Total Population (2023)",
    subtitle = "Structural barriers — federal trust land, land fractionation — suppress AIAN homeownership across all states",
    x = NULL, y = "Homeownership Rate (%)",
    caption  = SOURCE_NOTE
  ) +
  theme_cicd()

ggsave("output/figures/fig4_homeownership_comparison.png",
       fig4, width = 9, height = 5.5, dpi = 150, bg = "white")

cat("  Saved: fig4_homeownership_comparison.png\n")


# =============================================================
# FIGURE 5: MINNESOTA COUNTY MAP — AIAN POPULATION SHARE
# Choropleth map showing geographic concentration of AIAN
# populations across Minnesota's 87 counties.
# =============================================================

cat("Generating Figure 5: Minnesota AIAN Population Map...\n")

# Label counties with >5% AIAN share
mn_labels <- mn_map_clean %>%
  filter(aian_share > 5) %>%
  mutate(
    centroid = st_centroid(geometry),
    lon = st_coordinates(centroid)[, 1],
    lat = st_coordinates(centroid)[, 2]
  )

fig5 <- ggplot(mn_map_clean) +
  geom_sf(aes(fill = aian_share), color = "white", linewidth = 0.2) +
  geom_text(
    data = mn_labels,
    aes(x = lon, y = lat,
        label = paste0(county_name, "\n", round(aian_share, 1), "%")),
    size = 2.5, fontface = "bold", color = "white",
    lineheight = 0.9
  ) +
  scale_fill_gradient(
    low  = "#D6EAF8",
    high = AIAN_COLOR,
    name = "AIAN Share (%)",
    labels = function(x) paste0(x, "%"),
    breaks = c(0, 5, 10, 20, 30)
  ) +
  labs(
    title    = "AIAN Population Share by County — Minnesota (2023)",
    subtitle = "Counties with >5% AIAN population labeled",
    caption  = paste0(SOURCE_NOTE,
                      "\nNote: AIAN alone population as percentage of total county population.")
  ) +
  theme_void(base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold", size = 13, hjust = 0),
    plot.subtitle = element_text(size = 10, color = "gray40", hjust = 0),
    plot.caption  = element_text(size = 8, color = "gray50", hjust = 0),
    legend.position = c(0.82, 0.32),
    plot.margin   = margin(10, 10, 10, 10)
  )

ggsave("output/figures/fig5_mn_aian_population_map.png",
       fig5, width = 7, height = 8, dpi = 150, bg = "white")

cat("  Saved: fig5_mn_aian_population_map.png\n")


# =============================================================
# SUMMARY
# =============================================================

cat("\n=== ALL FIGURES SAVED TO output/figures/ ===\n")
cat("  fig1_unemployment_comparison.png\n")
cat("  fig2_lfpr_unemployment_divergence.png\n")
cat("  fig3_poverty_trend.png\n")
cat("  fig4_homeownership_comparison.png\n")
cat("  fig5_mn_aian_population_map.png\n")
cat("\nNext step: write README.md and prepare GitHub repo\n")