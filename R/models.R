# Purpose: fit the interrupted time series models for both outcomes, and
# build their tables, fitted lines and, for the published model, the
# predicted values at the intervention week.
# Needs: weekly (R/prepare_data.R); intervention_week and hai_rate_per
# (R/setup.R); build_fitted_line() and predict_at_intervention_week()
# (R/functions.R).
# Produces: positivity_models and hai_models (fitted models), their tables,
# their fitted lines, and positivity_at_break and hai_at_break.

## ---- define-model-terms
# The right-hand side of each model (analysis-plan.md sections 8.2 and 8.3).
# its4_segmented is the model reported in the article; the other three are
# exploratory and were not reported. Week2 is the week centred at the
# intervention week, so in its4_segmented the Intervention term is the
# contrast at week 13 and the interaction term is the change in slope.
model_terms <- c(
  its1_week = "Week",
  its2_intervention = "Intervention",
  its3_level_change = "Intervention + Week",
  its4_segmented = "Intervention * Week2"
)

## ---- fit-positivity-models
# Logistic regression of positive healthcare-personnel tests out of tests
# performed
positivity_models <- map(model_terms, \(terms) {
  glm(
    as.formula(str_c("cbind(Positives, Tested - Positives) ~ ", terms)),
    family = binomial,
    data = weekly
  )
})

## ---- fit-hai-models
# Poisson regression of weekly HAI counts, with log patient-days as an offset
hai_models <- map(model_terms, \(terms) {
  glm(
    as.formula(str_c("HAI ~ ", terms)),
    offset = log(Ptdays),
    family = poisson(link = "log"),
    data = weekly
  )
})

## ---- tabulate-models
# Odds ratios (positivity) and incidence rate ratios (HAI), as in the
# original code. In its4_segmented, the Week2 ratio compares each week with
# the one before it before the intervention, and the interaction ratio
# compares that week-to-week change after the intervention with the change
# before it.
positivity_tables <- map(positivity_models, tbl_regression, exponentiate = TRUE)
hai_tables <- map(hai_models, tbl_regression, exponentiate = TRUE)

## ---- build-fitted-lines
first_week <- min(weekly$Week)
last_week <- max(weekly$Week)

positivity_fitted <- map(
  positivity_models,
  build_fitted_line,
  first_week = first_week,
  last_week = last_week,
  intervention_week = intervention_week,
  scale = 100
)
hai_fitted <- map(
  hai_models,
  build_fitted_line,
  first_week = first_week,
  last_week = last_week,
  intervention_week = intervention_week,
  scale = hai_rate_per
)

## ---- predict-at-intervention-week
# The values the article reports from the published model: the predicted
# percentage positive and HAI rate at week 13 without and with face shields,
# and the P value of the intervention term
positivity_at_break <- predict_at_intervention_week(
  positivity_models$its4_segmented,
  scale = 100
)
hai_at_break <- predict_at_intervention_week(
  hai_models$its4_segmented,
  scale = hai_rate_per
)
