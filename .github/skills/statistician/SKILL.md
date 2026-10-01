---
name: statistician
description: Design or audit statistical analyses, check assumptions, compute tests and uncertainty from supplied data, and report reproducible results. Use for hypothesis tests, effect sizes, confidence intervals, or prospective power analysis.
---

# Statistician

Analyze supplied data, not expected outcomes. If data or a defensible analysis
plan is missing, report what is needed; do not fill the gap with example results.
In reviewer/audit mode, do not modify the manuscript, data, or existing analyses.

## 1. Establish the Design

Clarify the research question, estimand (the quantity to estimate), outcome type,
experimental unit, sample sizes, pairing/repeated measures, clustering,
confounders, missingness, and planned comparisons. Separate confirmatory tests
from exploratory analyses. Honor preregistered decisions and record deviations.

Specify the significance level, one- or two-sided alternative, confidence level,
and multiple-testing family before inspecting significance. Do not treat repeated
runs, folds, or measurements of the same unit as independent participants.

## 2. Choose a Defensible Method

| Design / objective | Candidate method and caveat |
|--------------------|----------------------------|
| Difference in means, independent groups | Welch's t-test (`equal_var=False`) when mean-based inference is appropriate; pooled-variance t-test needs an equal-variance justification |
| Difference in paired means | Paired t-test; assess the paired differences, not each group's marginal normality |
| Independent ordinal/distributional comparison | Mann-Whitney U; not automatically a test of medians without additional distributional assumptions |
| Paired rank-based comparison | Wilcoxon signed-rank requires appropriate symmetry of differences; consider another design-appropriate method when this is not defensible |
| More than two independent groups | ANOVA, Welch ANOVA, or an appropriate regression; Kruskal-Wallis answers a rank/distributional question |
| Repeated or clustered observations | Repeated-measures or mixed-effects methods; account for dependence and the method's assumptions |
| Categorical outcomes | Chi-squared or Fisher's exact for suitable independent tables; matched outcomes need matched-data methods |
| Association / prediction | Pearson, Spearman, or a suitable regression according to the estimand and outcome; correlation is not causation |

These are starting points, not an automatic decision tree. Nonparametric methods
also have assumptions and may answer a different question. Permutation and
bootstrap procedures must preserve the sampling/assignment structure.

For multiple comparisons, identify the family and justify family-wise error
control (for example Holm) or false discovery rate control (for example
Benjamini-Hochberg under appropriate conditions). Report the chosen adjustment
and both raw and adjusted p-values where relevant.

## 3. Check Assumptions

Use design review, sample sizes, diagnostic plots, residuals or paired
differences, and domain knowledge. A non-significant Shapiro-Wilk or Levene test
does not prove an assumption; do not choose a test solely by a normality-test
p-value. Do not transform outcomes or switch tests repeatedly to obtain a
desired result. Justify sensitivity analyses and disclose their results.

## 4. Execute Reproducibly

Save the analysis under the paper's `analysis/` directory and run from the
repository root using [the analysis helper](scripts/run-analysis.sh):

```bash
.github/skills/statistician/scripts/run-analysis.sh papers/<name> analysis/run.py --args --seed 42
```

The helper runs Python in the `research-latex` image, with the paper mounted at
`/paper`. The script argument is relative to the paper directory; extra arguments
after `--args` are forwarded unchanged. Docker must be available.

Record the input file hashes, analysis script, exclusions, sample sizes after
missing-data handling, random seed/resampling counts, package versions, and
Docker image ID. An unpinned image tag alone does not establish reproducibility.
Fail explicitly on missing data, invalid inputs, or non-finite results.

Write results to `output/analysis/`. Use a shape such as this **unexecuted
template**, replacing values only with actual computations:

```json
{
  "status": "not_run",
  "test_name": null,
  "estimand": null,
  "alternative": "two-sided",
  "statistic": null,
  "degrees_of_freedom": null,
  "p_value": null,
  "adjusted_p_value": null,
  "adjustment_method": null,
  "effect_size": {"metric": null, "value": null},
  "confidence_interval": {"estimand": null, "level": 0.95, "low": null, "high": null, "method": null},
  "sample_sizes": {},
  "assumption_checks": [],
  "limitations": []
}
```

Use valid JSON (`allow_nan=False` in Python). Explain unavailable quantities
rather than writing `NaN`, `Infinity`, or a fabricated estimate.

## 5. Report

- Report the effect direction, magnitude, uncertainty, sample sizes, test
  statistic, applicable degrees of freedom, and exact p-values with suitable
  precision. Do not round a small p-value to zero.
- Name the estimand for every confidence interval: a CI for the mean difference
  is not a CI for Cohen's d. State the effect-size convention and interval method.
- Distinguish statistical from practical significance. A non-significant result
  is not evidence of equivalence; equivalence/noninferiority needs an appropriate
  design and justified margin.
- Match the venue's reporting style. Generate LaTeX prose/tables from the saved
  results, not hand-copied example numbers.
- Keep diagnostic plots in `output/analysis/`. For publication figures, export
  reproducible SVG plots and hand off to `illustrator`/`svg-renderer`; do not
  manually alter plotted results for appearance.

## 6. Power and Precision

Prefer prospective sample-size planning or sensitivity analysis using a
scientifically justified effect, alpha, target power, allocation, and design.
State the assumed effect and the units required per group. Do not use
"observed power" calculated from the observed effect as additional evidence for
an already-completed significance test; report effect uncertainty instead.

For a simple independent two-group design, `TTestIndPower.solve_power` may help
with planning; round required sample sizes upward and account separately for
attrition, clustering, and multiplicity. Do not generalize this calculation to
more complex designs without justification.

## Method References

- [SciPy: independent t-tests and Welch's option](https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.ttest_ind.html)
- [SciPy: Mann-Whitney U assumptions and interpretation](https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.mannwhitneyu.html)
- [statsmodels: two-group power planning](https://www.statsmodels.org/stable/generated/statsmodels.stats.power.TTestIndPower.solve_power.html)
