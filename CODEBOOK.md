# CODEBOOK
## Economic Conditions in Native American Communities: A Data Portrait
**Author:** Shan Jiang
**Last Updated:** March 2026

Data source: U.S. Census Bureau, American Community Survey (ACS) 5-Year Estimates

---

## KEY TERMINOLOGY

**AIAN** = American Indian and Alaska Native. Census Bureau's official classification for Indigenous peoples of the continental U.S. and Alaska.

**"AIAN alone"** = Identified ONLY as AIAN on the Census race question. Does not include people who identify as AIAN and another race. This is the standard classification used in policy research and by CICD.

**Universe** = The population a variable counts. Numerator and denominator of any rate must share the same universe. Mismatched universes produce meaningless rates.

**ACS variable naming:**
```
B/C + table number + race letter + _cell number
Example: C23002C_004
  C     = collapsed table (for race iteration)
  23002 = table number (employment status)
  C     = AIAN alone
  _004  = cell (male 16-64 in labor force)
```
B = detailed table. C = collapsed table designed for race-group comparisons (fewer age groups).

---

## DATA SOURCES

| Source Table | Full Name | Universe | Race Group | Used In |
|-------------|-----------|----------|------------|---------|
| C23002C | Sex by Age by Employment Status | AIAN alone civ. noninst. pop 16+ | AIAN alone | 01, 02, 03 |
| B23025 | Employment Status | Total civ. noninst. pop 16+ | All races | 01, 02, 03 |
| B20017C | Median Earnings | Full-time year-round workers 16+ | AIAN alone | 01, 02, 03 |
| B20017 | Median Earnings | Full-time year-round workers 16+ | All races | 01, 02, 03 |
| B17001C | Poverty Status | Pop for whom poverty determined | AIAN alone | 01, 02, 03 |
| B17001 | Poverty Status | Pop for whom poverty determined | All races | 01, 02, 03 |
| B19013C | Median Household Income | Households | AIAN householder | 01, 02, 03 |
| B19013 | Median Household Income | Households | All householders | 01, 02, 03 |
| B19301C | Per Capita Income | Total population | AIAN alone | 01, 02, 03 |
| B19301 | Per Capita Income | Total population | All races | 01, 02, 03 |
| B25003C | Tenure | Occupied housing units | AIAN householder | 01, 02, 03 |
| B25003 | Tenure | Occupied housing units | All householders | 01, 02, 03 |
| B02001 | Race | Total population | All races | 01, 02, 04 |

### Tables Considered but Excluded

| Table | Reason Excluded |
|-------|-----------------|
| B25070 (Gross Rent as % of Income) | No AIAN-specific breakdown available. Cannot support AIAN vs. total comparison framework. |
| B23002C (detailed, B prefix) | Does not exist. C23002C (collapsed, C prefix) is the correct table for race-iterated employment data. |

---

## VINTAGE YEARS

| Label | ACS Year | Coverage Window | Analytical Purpose |
|-------|----------|----------------|--------------------|
| yr1 | 2015 | 2011–2015 | Post-financial-crisis baseline |
| yr2 | 2019 | 2015–2019 | Pre-pandemic baseline |
| yr3 | 2023 | 2019–2023 | Most recent; post-pandemic |

Windows share one boundary year each (2015 overlaps between yr1 and yr2; 2019 overlaps between yr2 and yr3). Each pair is 80% independent (4 of 5 years unique). Truly non-overlapping 5-year windows would require 5-year spacing (e.g., 2013, 2018, 2023), but 2018 cannot capture the full pre-pandemic picture.

**Income dollar basis:** Each vintage reports income in its own inflation-adjusted dollars (2023 ACS = 2023 dollars, etc.). Cross-vintage income comparisons reflect nominal vintage-year values. CPI adjustment to a common base year would be needed for rigorous real-income trend analysis. Ratios (AIAN/total within the same vintage) partially control for this, since both groups are reported in the same year's dollars.

---

## SECTION 1: LABOR MARKET VARIABLES

### 1A. AIAN Employment Status (C23002C)

**Universe:** AIAN alone civilian noninstitutional population 16+

"Civilian noninstitutional" **excludes:** active duty military, incarcerated individuals, residents of nursing homes, psychiatric facilities, and other institutional group quarters.

**Analytical implication:** AIAN incarceration rates exceed 2x the national average. Excluding incarcerated individuals means ACS labor statistics likely **understate** the true extent of labor market exclusion in AIAN communities.

**Age groups:** C23002C uses two groups only: 16–64 and 65+.

| Variable Code | Our Name | Definition |
|--------------|----------|------------|
| C23002C_001 | aian_total_16plus | Total AIAN alone civ. noninst. pop 16+ (LFPR denominator) |
| C23002C_004 | aian_male_lf_1664 | Male 16-64, in labor force |
| C23002C_007 | aian_male_emp_1664 | Male 16-64, employed |
| C23002C_008 | aian_male_unemp_1664 | Male 16-64, unemployed |
| C23002C_011 | aian_male_lf_65plus | Male 65+, in labor force |
| C23002C_012 | aian_male_emp_65plus | Male 65+, employed |
| C23002C_013 | aian_male_unemp_65plus | Male 65+, unemployed |
| C23002C_017 | aian_fem_lf_1664 | Female 16-64, in labor force |
| C23002C_020 | aian_fem_emp_1664 | Female 16-64, employed |
| C23002C_021 | aian_fem_unemp_1664 | Female 16-64, unemployed |
| C23002C_024 | aian_fem_lf_65plus | Female 65+, in labor force |
| C23002C_025 | aian_fem_emp_65plus | Female 65+, employed |
| C23002C_026 | aian_fem_unemp_65plus | Female 65+, unemployed |

### 1B. Total Population Employment Status (B23025)

**Universe:** Total civilian noninstitutional population 16+ (all races)

| Variable Code | Our Name | Definition |
|--------------|----------|------------|
| B23025_001 | total_pop_16plus | Total civ. noninst. pop 16+ |
| B23025_002 | total_lf | In labor force |
| B23025_004 | total_employed | Civilian employed |
| B23025_005 | total_unemployed | Civilian unemployed |

### 1C. Median Earnings (B20017C / B20017)

**Universe:** Full-time, year-round civilian workers 16+ (35+ hrs/week, 50–52 weeks/year)

**Limitation:** Part-time and seasonal workers are excluded. If AIAN communities have higher proportions of part-time/seasonal workers — which research suggests given reservation labor market conditions — the earnings comparison **understates** the true gap.

| Variable Code | Our Name | Definition |
|--------------|----------|------------|
| B20017C_001 | aian_earnings | AIAN alone median individual earnings (USD) |
| B20017_001 | total_earnings | Total population median individual earnings (USD) |

### 1D. Labor Market Derived Indicators (02_clean.R)

**AIAN Labor Force Total:**
```
aian_lf_total = sum of all aian_*_lf_* variables (4 sex × age groups)
```

**AIAN Unemployed Total:**
```
aian_unemp_total = sum of all aian_*_unemp_* variables (4 sex × age groups)
```

**AIAN Unemployment Rate:**
```
aian_unemp_rate = aian_unemp_total / aian_lf_total × 100
```
Share of AIAN labor force that is actively seeking work but unemployed. Does NOT capture discouraged workers who have stopped looking.

**Total Unemployment Rate:**
```
total_unemp_rate = total_unemployed / total_lf × 100
```

**Unemployment Gap (pp):**
```
unemp_gap = aian_unemp_rate − total_unemp_rate
```
Positive = AIAN unemployment exceeds total rate.

**Unemployment Ratio:**
```
unemp_ratio = aian_unemp_rate / total_unemp_rate
```
How many times higher AIAN unemployment is vs. total.

**AIAN Labor Force Participation Rate (LFPR):**
```
aian_lfpr = aian_lf_total / aian_total_16plusE × 100
```
**CRITICAL:** Denominator is `aian_total_16plusE` (C23002C_001, AIAN alone pop 16+), NOT `total_pop_16plusE` (B23025_001, all races). An earlier version of this code used the wrong denominator, producing LFPR values < 5%. Corrected in the current version.

**Total LFPR:**
```
total_lfpr = total_lf / total_pop_16plus × 100
```

**LFPR Gap (pp):**
```
lfpr_gap = aian_lfpr − total_lfpr
```
Negative = AIAN participation is lower than total population.

**Earnings Ratio:**
```
earnings_ratio = aian_earnings / total_earnings
```
AIAN full-time workers earn X cents per $1 earned by total population. A ratio of 0.70 = 70 cents per dollar.

---

## SECTION 2: POVERTY AND INCOME VARIABLES

### 2A. Poverty Status (B17001C / B17001)

**Universe:** Population for whom poverty status is determined (excludes unrelated individuals under 15 and people in certain group quarters)

**Dollar basis:** Federal poverty thresholds, adjusted for family size and composition.

| Variable Code | Our Name | Definition |
|--------------|----------|------------|
| B17001C_001 | aian_total | AIAN pop in poverty universe |
| B17001C_002 | aian_below_poverty | AIAN below federal poverty line |
| B17001_001 | total_total | Total pop in poverty universe |
| B17001_002 | total_below_poverty | Total below poverty line |

### 2B. Median Household Income (B19013C / B19013)

**Universe (B19013C):** Households with an AIAN householder. NOTE: "AIAN householder" ≠ "AIAN alone population." This captures households *headed by* an AIAN person; other household members may not be AIAN. Comparison with B19013 (all householders) is standard practice but the universe distinction should be noted.

**Universe (B19013):** All householder households.

| Variable Code | Our Name | Definition |
|--------------|----------|------------|
| B19013C_001 | aian_median_income | Median HH income, AIAN householder (USD) |
| B19013_001 | total_median_income | Median HH income, all householders (USD) |

### 2C. Per Capita Income (B19301C / B19301)

**Universe:** Total population (AIAN alone / all races). Per capita income accounts for household size differences. If AIAN households tend to be larger, household income comparisons may understate individual-level disparities.

| Variable Code | Our Name | Definition |
|--------------|----------|------------|
| B19301C_001 | aian_per_capita | Per capita income, AIAN alone (USD) |
| B19301_001 | total_per_capita | Per capita income, total (USD) |

### 2D. Poverty and Income Derived Indicators (02_clean.R)

**Poverty Rates:**
```
aian_poverty_rate  = aian_below_poverty / aian_total × 100
total_poverty_rate = total_below_poverty / total_total × 100
```

**Poverty Gap (pp):**
```
poverty_gap = aian_poverty_rate − total_poverty_rate
```

**Income Ratio:**
```
income_ratio = aian_median_income / total_median_income
```

**Per Capita Ratio:**
```
per_capita_ratio = aian_per_capita / total_per_capita
```

---

## SECTION 3: HOUSING VARIABLES

### 3A. Housing Tenure (B25003C / B25003)

**Universe (B25003C):** Occupied housing units with AIAN householder.
**Universe (B25003):** All occupied housing units.
**Years:** 2023 only. Housing tenure changes slowly; a cross-sectional snapshot is sufficient.

| Variable Code | Our Name | Definition |
|--------------|----------|------------|
| B25003C_001 | aian_total_units | Total occupied units, AIAN householder |
| B25003C_002 | aian_owner | Owner-occupied, AIAN householder |
| B25003C_003 | aian_renter | Renter-occupied, AIAN householder |
| B25003_001 | total_total_units | Total occupied housing units |
| B25003_002 | total_owner | Owner-occupied |
| B25003_003 | total_renter | Renter-occupied |

### Structural Context for Indian Country Housing

Federal trust land status on reservations creates structural barriers to conventional mortgage lending:
- Trust land = federal government holds title
- No individual title = no collateral for bank mortgage
- No mortgage access = homeownership suppressed regardless of income

Federal responses include HUD Section 184, USDA Native CDFI Relending Program, and VA Native American Direct Loan (expanded 2023). Structural barriers — land fractionation, infrastructure gaps, geographic remoteness — remain only partially addressed. This is why AIAN homeownership gaps persist even across income levels.

### 3B. Housing Derived Indicators (02_clean.R)

```
aian_ownership_rate  = aian_owner / aian_total_units × 100
total_ownership_rate = total_owner / total_total_units × 100
ownership_gap        = total_ownership_rate − aian_ownership_rate
```
Note: `ownership_gap` uses total − AIAN (positive = total exceeds AIAN), unlike unemployment and poverty gaps which use AIAN − total.

---

## SECTION 4: MAP VARIABLES

### 4A. Race Counts (B02001)

**Universe:** Total population.
**Geography:** Minnesota counties (87 counties).
**Years:** 2023 only.
**Geometry:** Retrieved with `geometry = TRUE` in tidycensus, returning an sf object with TIGER/Line shapefiles for direct use with `geom_sf()`.

| Variable Code | Our Name | Definition |
|--------------|----------|------------|
| B02001_001 | total_pop | Total population |
| B02001_004 | aian_pop | AIAN alone population |

**AIAN Population Share:**
```
aian_share = aian_pop / total_pop × 100
```

### Minnesota Counties with Significant AIAN Populations

Counties with >5% AIAN share (2023 data) correspond to federally recognized reservation lands:

| County | AIAN Share | Associated Tribal Nation(s) |
|--------|-----------|---------------------------|
| Mahnomen | 35.7% | White Earth Nation |
| Beltrami | 19.4% | Red Lake Nation, Leech Lake |
| Cass | 8.9% | Leech Lake Band of Ojibwe |
| Clearwater | 7.1% | White Earth Nation |
| Cook | 6.3% | Grand Portage Band |

---

## SECTION 5: ANALYSIS-LEVEL DERIVED INDICATORS (03_analysis.R)

### 5A. Trend Changes

For each indicator, three change values are computed:
```
chg_1519 = value_2019 − value_2015   (pre-pandemic trend)
chg_1923 = value_2023 − value_2019   (pandemic-era change)
chg_1523 = value_2023 − value_2015   (full-period change)
```
Applied to: unemployment rate, unemployment gap, LFPR, earnings ratio, poverty rate, poverty gap, income ratio.

Negative change in rates/gaps = improvement. Positive change in ratios = improvement.

### 5B. LFPR-Unemployment Divergence

```
divergent = (unemployment declined) AND (LFPR also declined)
```
Flags states where falling unemployment may reflect labor force exit rather than genuine employment gains. Particularly relevant for South Dakota, where AIAN LFPR fell 7.1 pp (2015→2023) while unemployment fell 8.1 pp.

### 5C. Pandemic-Era Asymmetry

```
asymmetry = aian_change − total_change   (2019 → 2023)
```
Positive asymmetry = AIAN fared worse (or improved less) than total population. Negative = AIAN improved more. Computed for unemployment and poverty rates.

**Note:** ACS 5-year estimates smooth annual volatility. The 2023 vintage captures net change across the entire pandemic period, not peak-to-trough impact. Observed improvements coincided with federal relief (CARES Act, ARP tribal allocations) but this analysis cannot isolate the causal contribution.

### 5D. Cross-State Snapshot (2023)

All disparity dimensions combined into a single table (`snapshot_2023`) for ranking. South Dakota ranked worst across all six dimensions: unemployment gap, LFPR gap, earnings ratio, poverty gap, income ratio, and ownership gap.

---

## OUTPUT FILES

### Raw Data (data/raw/, from 01_data_pull.R)

| File | Contents | Rows |
|------|----------|------|
| labor_2023.rds | Labor market variables, 2023 | 4 states |
| labor_2019.rds | Labor market variables, 2019 | 4 states |
| labor_2015.rds | Labor market variables, 2015 | 4 states |
| poverty_2023.rds | Poverty/income variables, 2023 | 4 states |
| poverty_2019.rds | Poverty/income variables, 2019 | 4 states |
| poverty_2015.rds | Poverty/income variables, 2015 | 4 states |
| housing_2023.rds | Housing tenure variables, 2023 | 4 states |
| mn_county_map.rds | MN county race counts + geometry | 87 counties |

### Clean Data (data/clean/, from 02_clean.R)

| File | Contents | Rows |
|------|----------|------|
| labor_clean.rds | Labor indicators, all vintages | 12 (4 states × 3 years) |
| poverty_clean.rds | Poverty/income indicators, all vintages | 12 (4 states × 3 years) |
| housing_clean.rds | Housing indicators, 2023 | 4 states |
| mn_map_clean.rds | MN county AIAN share + geometry | 87 counties |

### Analysis Outputs (data/analysis/, from 03_analysis.R)

| File | Contents | Rows |
|------|----------|------|
| labor_trend.rds | Trend changes across vintages | 4 states |
| poverty_trend.rds | Poverty trend changes | 4 states |
| pandemic_labor.rds | Unemployment asymmetry (2019→2023) | 4 states |
| pandemic_poverty.rds | Poverty asymmetry (2019→2023) | 4 states |
| snapshot_2023.rds | All 2023 indicators combined | 4 states |
| divergence.rds | LFPR-unemployment divergence flags | 4 states |

### Figures (output/figures/, from 04_visualize.R)

| File | Description |
|------|-------------|
| fig1_unemployment_comparison.png | AIAN vs total unemployment, 2023, grouped bar |
| fig2_lfpr_unemployment_divergence.png | LFPR vs unemployment trend, faceted line |
| fig3_poverty_trend.png | Poverty rate 2015–2023, faceted line |
| fig4_homeownership_comparison.png | AIAN vs total homeownership, 2023, grouped bar |
| fig5_mn_aian_population_map.png | MN county AIAN share, choropleth |

---

## VARIABLE QUICK REFERENCE

| Our Name | Census Code | Section | Description |
|----------|------------|---------|-------------|
| aian_total_16plus | C23002C_001 | Labor | AIAN pop 16+ (LFPR denominator) |
| aian_male_lf_1664 | C23002C_004 | Labor | AIAN male 16-64 in LF |
| aian_male_emp_1664 | C23002C_007 | Labor | AIAN male 16-64 employed |
| aian_male_unemp_1664 | C23002C_008 | Labor | AIAN male 16-64 unemployed |
| aian_male_lf_65plus | C23002C_011 | Labor | AIAN male 65+ in LF |
| aian_male_emp_65plus | C23002C_012 | Labor | AIAN male 65+ employed |
| aian_male_unemp_65plus | C23002C_013 | Labor | AIAN male 65+ unemployed |
| aian_fem_lf_1664 | C23002C_017 | Labor | AIAN female 16-64 in LF |
| aian_fem_emp_1664 | C23002C_020 | Labor | AIAN female 16-64 employed |
| aian_fem_unemp_1664 | C23002C_021 | Labor | AIAN female 16-64 unemployed |
| aian_fem_lf_65plus | C23002C_024 | Labor | AIAN female 65+ in LF |
| aian_fem_emp_65plus | C23002C_025 | Labor | AIAN female 65+ employed |
| aian_fem_unemp_65plus | C23002C_026 | Labor | AIAN female 65+ unemployed |
| total_pop_16plus | B23025_001 | Labor | Total pop 16+ (all races) |
| total_lf | B23025_002 | Labor | Total in labor force |
| total_employed | B23025_004 | Labor | Total employed |
| total_unemployed | B23025_005 | Labor | Total unemployed |
| aian_earnings | B20017C_001 | Labor | AIAN median earnings (USD) |
| total_earnings | B20017_001 | Labor | Total median earnings (USD) |
| aian_total | B17001C_001 | Poverty | AIAN poverty universe |
| aian_below_poverty | B17001C_002 | Poverty | AIAN below poverty line |
| total_total | B17001_001 | Poverty | Total poverty universe |
| total_below_poverty | B17001_002 | Poverty | Total below poverty line |
| aian_median_income | B19013C_001 | Income | AIAN median HH income (USD) |
| total_median_income | B19013_001 | Income | Total median HH income (USD) |
| aian_per_capita | B19301C_001 | Income | AIAN per capita income (USD) |
| total_per_capita | B19301_001 | Income | Total per capita income (USD) |
| aian_total_units | B25003C_001 | Housing | Occupied units, AIAN householder |
| aian_owner | B25003C_002 | Housing | Owner-occupied, AIAN |
| aian_renter | B25003C_003 | Housing | Renter-occupied, AIAN |
| total_total_units | B25003_001 | Housing | Total occupied units |
| total_owner | B25003_002 | Housing | Owner-occupied, total |
| total_renter | B25003_003 | Housing | Renter-occupied, total |
| aian_pop | B02001_004 | Map | AIAN alone population |
| total_pop | B02001_001 | Map | Total population |
