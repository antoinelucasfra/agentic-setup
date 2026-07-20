---
name: datanalysis
description: >
  Generic data cleaning and variable screening pipeline template.
  Adapted from the awesome-copilot datanalysis-credit-risk skill — generalized for any domain.
  USE FOR: data quality assessment, missing value analysis, variable selection, EDA preprocessing,
  feature screening before modeling.
  Covers: data loading, missing rate analysis, low-information variable removal, stability filtering
  (PSI), noise denoising, high-correlation removal, and cleaning report generation.
---

# Data Cleaning and Variable Screening Skill

A structured pipeline for assessing and cleaning datasets before analysis or modeling.
Adapted from the [datanalysis-credit-risk](https://github.com/github/awesome-copilot/tree/main/skills/datanalysis-credit-risk)
skill in awesome-copilot.

---

## Pipeline Steps (execute independently — never delete original data)

| Step | Name | What it does |
|------|------|-------------|
| 1 | **Load Data** | Read raw data, parse types, validate schema |
| 2 | **Sample Overview** | Row count, target distribution, stratification by group if applicable |
| 3 | **Hold-out Separation** | Separate train / test / OOS if applicable |
| 4 | **Filter Bad Periods** | Remove time slices with insufficient samples or extreme imbalance |
| 5 | **Missing Rate Analysis** | Calculate per-column missing rates overall and by group |
| 6 | **Drop High-Missing Columns** | Remove columns with missing rate > threshold (default: 60%) |
| 7 | **Drop Low-Information Columns** | Remove columns with near-zero variance or very low IV/mutual info |
| 8 | **Stability Filtering (PSI)** | Remove columns with high PSI (distribution drift across time/groups) |
| 9 | **Null Importance Denoising** | Permutation importance to filter noise features |
| 10 | **Correlation Filtering** | Remove highly correlated redundant columns (threshold: r > 0.9) |
| 11 | **Export Report** | Generate Excel/HTML report with decision rationale at each step |

---

## Key Parameters

```python
# Data identification
DATE_COL = "date"           # time column for PSI / stability checks
TARGET_COL = "target"       # outcome/label column
GROUP_COL = "group"         # stratification column (optional)
KEY_COLS = ["id"]           # primary key columns (always keep)

# Thresholds
MISSING_THRESHOLD = 0.6     # drop column if missing > 60%
PSI_THRESHOLD = 0.1         # drop column if PSI > 0.1
CORRELATION_THRESHOLD = 0.9 # drop column if r > 0.9 with another kept column

# IV / information value (for classification tasks)
IV_THRESHOLD = 0.02         # drop column if IV < 0.02
```

---

## Usage Pattern

```python
from pathlib import Path
import pandas as pd

# Load
df = pd.read_parquet(DATA_PATH)

# Step 5: missing rates
missing = df.isnull().mean().rename("missing_rate").to_frame()
print(missing[missing["missing_rate"] > MISSING_THRESHOLD])

# Step 6: drop high-missing columns
cols_to_drop = missing[missing["missing_rate"] > MISSING_THRESHOLD].index.tolist()
df_clean = df.drop(columns=cols_to_drop)

# Step 10: correlation matrix
corr = df_clean.select_dtypes("number").corr().abs()
upper = corr.where(pd.np.triu(pd.np.ones(corr.shape), k=1).astype(bool))
high_corr_cols = [col for col in upper.columns if any(upper[col] > CORRELATION_THRESHOLD)]
df_final = df_clean.drop(columns=high_corr_cols)
```

---

## R Equivalent (tidyverse)

```r
library(dplyr)
library(recipes)

# Missing rate by column
missing_rates <- df |>
  summarise(across(everything(), ~mean(is.na(.)))) |>
  tidyr::pivot_longer(everything(), names_to = "col", values_to = "missing_rate")

# Drop high-missing columns
high_missing <- missing_rates |> dplyr::filter(missing_rate > 0.6) |> dplyr::pull(col)
df_clean <- df |> dplyr::select(-dplyr::all_of(high_missing))

# Correlation filtering (via recipes)
rec <- recipes::recipe(target ~ ., data = df_clean) |>
  recipes::step_corr(recipes::all_numeric_predictors(), threshold = 0.9) |>
  recipes::prep()
df_final <- recipes::bake(rec, df_clean)
```

---

## Output Report Contents

1. **Summary** — steps executed, columns dropped at each stage
2. **Missing Rate Details** — full table of missing rates per column
3. **Dropped Columns Log** — which columns were dropped at which step and why
4. **Stability (PSI) Details** — PSI per column per period
5. **Correlation Map** — heatmap of surviving columns
6. **Final Column List** — columns retained for modeling


