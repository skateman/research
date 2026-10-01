---
name: data-processor
description: Inspect, clean, transform, and summarize supplied datasets for analysis. Use for data quality checks, missingness, merges, descriptive statistics, and reproducible exploratory plots while preserving raw observations.
---

# Data Processor Skill

You prepare data for statistical analysis and paper reporting. Given raw datasets, you clean, transform, and summarize them, producing analysis-ready outputs that the **statistician** skill and paper-writing agents can consume. In audit-only mode, report issues without changing data or manuscript files.

## When to Use

This skill is invoked by agents (typically **Drafter**, **Writer**) or directly by the user when:
- Raw data needs cleaning before analysis (missing values, outliers, type mismatches)
- Data from multiple sources needs merging or reshaping
- Descriptive statistics and summary tables are needed for the paper
- Exploratory visualizations are needed to understand the data before hypothesis testing

## Prerequisites

- The `research-latex` Docker image must include Python scientific packages (pandas, numpy, scipy, matplotlib)
- Data files must be accessible in the paper directory

## Supported Input Formats

| Format | Extension | Library |
|--------|-----------|---------|
| CSV / TSV | `.csv`, `.tsv` | `pandas.read_csv()` |
| JSON | `.json` | `pandas.read_json()` |
| Excel (modern) | `.xlsx` | `pandas.read_excel()` with optional `openpyxl` |
| Excel (legacy) | `.xls` | `pandas.read_excel()` with optional `xlrd` |
| Parquet | `.parquet` | `pandas.read_parquet()` with optional `pyarrow` or `fastparquet` |
| SQLite | `.db`, `.sqlite` | `pandas.read_sql()` |
| Fixed-width | `.txt`, `.dat` | `pandas.read_fwf()` |

The Docker image does not promise these optional Excel/Parquet engines. Check
availability when that format is requested; report a missing dependency and
update the image deliberately rather than silently switching formats or
installing packages in a disposable container.

## Procedure

### 1. Ingest and Inspect

Identify the observation unit, data provenance, expected schema, identifiers,
encoding, units, and privacy constraints. Load the data and produce an initial
profile without printing sensitive participant records:

```python
import pandas as pd

df = pd.read_csv("data/raw/experiment.csv")
print(f"Shape: {df.shape}")
print(f"Columns: {list(df.columns)}")
print(f"Data types:\n{df.dtypes}")
print(f"Missing values:\n{df.isnull().sum()}")
```

Report:
- Number of rows and columns
- Column names and data types
- Missing value counts per column
- Obvious data quality issues (duplicates, impossible values)

### 2. Clean

Address data quality issues. Document every cleaning decision:

**Missing values:**
- Profile missingness by variable, group, and observation unit
- Choose deletion or imputation from the study design, missingness assumptions,
  and downstream estimand, not a universal percentage threshold
- Confirm consequential cleaning decisions with the user or follow an approved
  analysis plan; do not silently mean-impute or drop incomplete observations
- Document the strategy chosen and the number of rows affected

**Outliers:**
- Detect with IQR method (values beyond Q1 − 1.5×IQR or Q3 + 1.5×IQR) or z-scores (|z| > 3)
- Do **not** automatically remove outliers — flag them and let the user decide
- If removed, report how many and the impact on summary statistics

**Type corrections:**
- Parse dates, convert categorical strings to category dtype, fix numeric columns stored as strings
- Standardize category labels (e.g., "Male"/"male"/"M" → consistent coding)

**Duplicates:**
- Identify and report duplicate rows
- Distinguish confirmed duplicate records from legitimate repeated measurements
  or different participants with identical values. Remove only records confirmed
  redundant under the study's identifier rules and approved cleaning plan.

### 3. Transform

Apply transformations as needed for downstream analysis:

- **Normalization / Standardization** — z-score or min-max scaling
- **Log transforms** — for right-skewed distributions
- **Encoding** — one-hot or ordinal encoding for categorical variables
- **Aggregation** — group-by summaries for hierarchical data
- **Pivoting / Melting** — reshape wide ↔ long format
- **Feature engineering** — derived columns (differences, ratios, interactions)

Check join cardinality and report unmatched or multiplied rows after merges. For
predictive evaluation, split data before fitting imputation, scaling, or feature
selection; fit transformations on training data only to avoid leakage.

Save transformed data to `data/processed/`:

```
data/
├── raw/              # Original, untouched data
├── processed/        # Cleaned and transformed data
└── codebook.md       # Variable descriptions and transformations applied
```

### 4. Describe

Produce descriptive statistics for the paper:

**Continuous variables:**
```python
desc = df[continuous_cols].describe()
# Add: skewness, kurtosis, normality test p-values
```

**Categorical variables:**
```python
for col in categorical_cols:
    print(df[col].value_counts(normalize=True))
```

Output a LaTeX-ready descriptive statistics table. The following numbers are
illustrative formatting examples, not results to copy into a manuscript:

```latex
\begin{table}[t]
\centering
\caption{Descriptive statistics of study variables.}
\label{tab:descriptive}
\footnotesize
\begin{tabular}{@{}lcccccc@{}}
\toprule
\textbf{Variable} & \textbf{$N$} & \textbf{Mean} & \textbf{SD} & \textbf{Min} & \textbf{Max} & \textbf{Skew} \\
\midrule
Age & 120 & 34.2 & 8.7 & 18 & 65 & 0.42 \\
Score & 120 & 72.1 & 15.3 & 28 & 99 & $-$0.31 \\
\bottomrule
\end{tabular}
\end{table}
```

### 5. Visualize (Optional)

Generate exploratory plots under `output/analysis/`. For publication plots,
export reproducible SVG from the plotting code for the **@illustrator** agent
and **svg-renderer** skill to refine and convert; never redraw empirical values:

- **Distribution plots** — histograms or kernel density estimates for continuous variables
- **Box plots** — group comparisons
- **Scatter plots** — bivariate relationships
- **Correlation heatmaps** — for datasets with many numeric variables
- **Missing data patterns** — heatmap of missingness

All plots should use a clean, academic style:

```python
import matplotlib
matplotlib.use('Agg')  # Non-interactive backend
import matplotlib.pyplot as plt

plt.rcParams.update({
    'font.family': 'serif',
    'font.size': 10,
    'figure.figsize': (3.5, 2.5),  # Single-column IEEE width
    'figure.dpi': 300,
    'savefig.bbox': 'tight',
    'axes.grid': False,
})
```

Keep diagnostics separate from publication figures. Save approved publication
SVGs to `figures/` and include their converted PDFs in LaTeX.

### 6. Produce a Codebook

Generate `data/codebook.md` from the actual data and approved decisions. This
example illustrates the format only:

```markdown
# Data Codebook

## Source
- **File**: experiment.csv
- **Collected**: 2024-01-15
- **N (raw)**: 150
- **N (after cleaning)**: 147

## Cleaning Log
1. Removed 3 confirmed duplicate records under the approved identifier rule
2. Imputed 5 missing Age values with median (34)
3. Recoded Gender: "M"/"F"/"Male"/"Female" → "male"/"female"

## Variables

| Variable | Type | Description | Values/Range |
|----------|------|-------------|-------------|
| participant_id | ID | Unique identifier | 1–150 |
| condition | Categorical | Experimental group | control, treatment |
| age | Continuous | Age in years | 18–65 |
| score | Continuous | Task performance | 0–100 |
```

## Execution

Save the script in the paper's `analysis/` directory. Run from the repository root
using [the processing helper](scripts/run-processing.sh):

```bash
.github/skills/data-processor/scripts/run-processing.sh papers/<name> analysis/process.py --args --seed 42
```

The script path is relative to the paper directory. Arguments after `--args` are
forwarded unchanged. Record input hashes, script version, cleaning decisions,
random seeds, package versions, and the Docker image ID; an image tag alone does
not guarantee reproducibility.

## Output Structure

After processing, the paper directory should contain:

```
data/
├── raw/                     # Original data (never modified)
│   └── experiment.csv
├── processed/               # Cleaned, analysis-ready data
│   └── experiment_clean.csv
├── codebook.md              # Variable descriptions and cleaning log
output/
└── analysis/                # Descriptive stats JSON and diagnostic plots
    ├── descriptive.json
    └── distributions.png    # Exploratory plots (if generated)
```

## Important Rules

- **Never modify raw data files** — always read from `data/raw/`, write to `data/processed/`
- **Document every decision** — cleaning choices go in the codebook, not just in code comments
- **Be transparent about data loss** — report how many rows/values were removed or imputed
- **Do not fabricate data** — only process actual data provided by the user
- **Confirm consequential cleaning** — follow the approved analysis plan or ask before deleting observations, imputing values, or changing the unit of analysis
- **Use the container** — all Python execution happens in Docker for reproducibility
- **Save scripts** — processing scripts go in `analysis/` directory so steps are reproducible
