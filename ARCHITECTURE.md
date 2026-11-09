# Architecture

The current implementation: scripts, data flow, and the objects passed between them. Written with the describe-design skill on 8 November 2026 against every script in `R/`. The scripts have been checked by reading only; they have not yet been run on the data.

## Running order

`R/main.R` sources the scripts in this order. Each script runs in the global environment and leaves the objects listed for later scripts.

| Order | Script | Needs | Produces | Data |
|---|---|---|---|---|
| 1 | `R/setup.R` | — | Attached packages; every constant | — |
| 2 | `R/functions.R` | Packages | Helper functions | — |
| 3 | `R/prepare_data.R` | 1, 2; `COVID_IC_DATA_DIR` | `weekly` (one row per week, with exact intervals, `Intervention`, `Week2` and the Figure 2 date); `harris` (one row per day) | Study data |
| 4 | `R/models.R` | 1, 2, 3 | `positivity_models`, `hai_models`; `positivity_tables`, `hai_tables`; `positivity_fitted`, `hai_fitted`; `positivity_at_break`, `hai_at_break` | Study data (model output) |
| 5 | `R/figures.R` | 1 to 4 | `weekly_plots`, `exploratory_plots`, `figure_1a`, `figure_1b`, `figure_2`; TIFF files in `figures/` | Outputs, gitignored |

## Data flow

```
Surveillance manuscript2 9-19.xlsx ── prepare_data.R ── weekly ─────────┐
  (Week, Date1, Date2, Tested, Positives, HAI, Ptdays)                   │
                                                                         ▼
                                   models.R ── positivity_models, hai_models
                                      │          (its1_week, its2_intervention,
                                      │           its3_level_change, its4_segmented)
                                      ├── positivity_tables, hai_tables
                                      ├── positivity_fitted, hai_fitted
                                      └── positivity_at_break, hai_at_break
                                                                         │
Harris_data.csv ── prepare_data.R ── harris ─────────────────────────────┤
  (Date, epicurve_Harris)                                                ▼
                                   figures.R ── weekly_plots, exploratory_plots,
                                                figure_1a, figure_1b, figure_2
                                                 └── figures/*.tiff
```

## Key mechanisms

- **One intervention week.** `intervention_week` in `setup.R` defines `Intervention` and `Week2` (`prepare_data.R`), the step in the fitted lines (`build_fitted_line()`), the week-13 contrast (`predict_at_intervention_week()`) and, through `intervention_line_week`, the vertical line in Figure 1. Figure 2's line uses `intervention_start` (the day before it).
- **The published model is centred at week 13.** `its4_segmented` is `Intervention * Week2`, with `Week2` zero at the intervention week, so its `Intervention` term is the contrast at week 13 and its interaction term is the change in slope. The other three models are exploratory (analysis-plan.md section 8.3).
- **Four models per outcome from one list.** `model_terms` in `models.R` names each model's right-hand side; the positivity and HAI models are fitted from it with `map()`, so both outcomes always have the same four models under the same names.
- **Poisson rates per patient-day.** HAI models take `offset = log(Ptdays)` in the `glm()` call. Prediction rows set `Ptdays` to 1, so a prediction is a rate per patient-day, scaled by `hai_rate_per` (1,000).
- **The fitted line's step.** `build_fitted_line()` repeats the week just before the intervention week once without and once with the intervention; `geom_path()` in `plot_weekly_series()` draws the pair as a vertical step. Figure 2 draws its line from predictions at the observed weeks, so it has no step, as in the original code.
- **Weekly intervals.** `add_exact_intervals()` adds exact binomial (positivity) and exact Poisson (HAI) 95% intervals with epitools.
- **Inputs are checked.** `prepare_data.R` stops if `COVID_IC_DATA_DIR` is not set or the workbook lacks any of the seven expected columns; the message names columns only.
- **One plotting function.** `plot_weekly_series()` draws every week-based plot (the weekly series, the exploratory plots and Figure 1); Figure 2 is built directly in `figures.R` because it is drawn by date with a second axis.

## Dependencies outside this repository

- **The study data**, in the folder named by `COVID_IC_DATA_DIR`: the weekly surveillance workbook and the Harris County extract. Neither is in the repository; their column names have not yet been checked against the code.
- **Packages** attached in `setup.R`: tidyverse, readxl, epitools, gtsummary and cowplot.

## Website

`_quarto.yml`, `index.qmd`, `404.qmd` and `styles.css` at the root; pages in `quarto/`. Each script has a code page of the same name (`setup.qmd`, `functions.qmd`, `prepare_data.qmd`, `models.qmd`, `figures.qmd`) that imports its labelled sections with `knitr::read_chunk()` and shows them without running them. The four project-document pages show the root files, and `about.qmd` describes the project. `.github/workflows/publish.yml` renders the site on pull requests and publishes it to `gh-pages` on each push to `main`.

## Tests

None. The code is shown on the site, not run, and no synthetic data are used.

## Code references

| Script | Labelled sections | Key symbols |
|---|---|---|
| `R/setup.R` | `load-packages`, `define-data-files`, `define-study-dates`, `define-week-labels`, `define-estimation-constants`, `define-plot-constants` | `data_dir`, `intervention_week`, `intervention_start`, `week_labels`, `hai_rate_per`, `intervention_line_week`, `harris_scale_positivity`, `harris_scale_hai` |
| `R/functions.R` | `add-exact-intervals`, `build-fitted-line`, `predict-at-intervention-week`, `plot-weekly-series` | `add_exact_intervals()`, `build_fitted_line()`, `predict_at_intervention_week()`, `plot_weekly_series()` |
| `R/prepare_data.R` | `check-data-folder`, `read-surveillance-data`, `add-weekly-estimates`, `add-time-series-variables`, `add-plot-dates`, `read-harris-county-data` | `weekly`, `harris` |
| `R/models.R` | `define-model-terms`, `fit-positivity-models`, `fit-hai-models`, `tabulate-models`, `build-fitted-lines`, `predict-published-week-13` | `model_terms`, `positivity_models`, `hai_models`, `positivity_at_break`, `hai_at_break` |
| `R/figures.R` | `plot-observed-series`, `plot-exploratory-models`, `plot-figure-1`, `prepare-figure-2-lines`, `plot-figure-2`, `save-figures` | `figure_1a`, `figure_1b`, `figure_2` |

## Glossary

| Term | Definition |
|---|---|
| `Week2` | Week minus the intervention week; zero at week 13 |
| `Intervention` | `TRUE` from week 13 (6 July 2020) on |
| HAI | Possible (days 5 to 13 after admission) and confirmed (day 14 on) hospital-acquired SARS-CoV-2 infections together |
| `Ptdays` | Inpatient days in the week |
| `its4_segmented` | The published model; `its1_week`, `its2_intervention` and `its3_level_change` are exploratory |
