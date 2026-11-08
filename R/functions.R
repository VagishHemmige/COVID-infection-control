# Purpose: helper functions used by the analysis scripts.
# Needs: the packages attached by R/setup.R. Produces: functions only.
# Each function takes its inputs as arguments and reads no global objects.

## ---- add-exact-intervals
# Adds the weekly estimates of analysis-plan.md section 8.1: the percentage
# of healthcare-personnel tests positive, with an exact binomial interval,
# and the HAI rate, with an exact Poisson interval using patient-days as the
# exposure. `weekly` has one row per week with the columns Positives, Tested,
# HAI and Ptdays.
add_exact_intervals <- function(weekly, conf_level, rate_per) {
  positivity <- binom.exact(
    weekly$Positives,
    weekly$Tested,
    conf.level = conf_level
  )
  hai <- pois.exact(
    weekly$HAI,
    weekly$Ptdays,
    conf.level = conf_level
  )

  weekly |>
    mutate(
      percent_positive = 100 * positivity$proportion,
      percent_lower = 100 * positivity$lower,
      percent_upper = 100 * positivity$upper,
      hai_rate = rate_per * hai$rate,
      hai_rate_lower = rate_per * hai$lower,
      hai_rate_upper = rate_per * hai$upper
    )
}

## ---- build-fitted-line
# Predicted values from a fitted model for every week, for drawing its line.
# The week just before the intervention week appears twice, once without and
# once with the intervention, so the line shows the jump at the intervention.
# `scale` turns the prediction into the plotted unit: 100 for a percentage
# from a logistic model, or the rate denominator (1,000) for a Poisson model,
# whose prediction is per patient-day because Ptdays is set to 1.
build_fitted_line <- function(model, first_week, last_week, intervention_week, scale) {
  break_week <- intervention_week - 1e-4

  before <- tibble(
    Week = c(first_week:(intervention_week - 1), break_week),
    Intervention = FALSE
  )
  after <- tibble(
    Week = c(break_week, intervention_week:last_week),
    Intervention = TRUE
  )

  bind_rows(before, after) |>
    mutate(
      Week2 = Week - intervention_week,
      Ptdays = 1,
      fitted_value = scale * predict(model, newdata = pick(everything()), type = "response")
    )
}

## ---- predict-at-intervention-week
# The paper's headline contrast (analysis-plan.md section 8.2): the predicted
# value in the intervention week without and with the intervention, and the
# P value of the intervention term. The models centre week at the
# intervention week (Week2 = 0), so the intervention term is that contrast.
predict_at_intervention_week <- function(model, scale) {
  tibble(
    Week2 = 0,
    Intervention = c(FALSE, TRUE),
    Ptdays = 1
  ) |>
    mutate(
      scenario = if_else(Intervention, "With face shields", "Without face shields"),
      predicted = scale * predict(model, newdata = pick(everything()), type = "response"),
      p_value = coef(summary(model))["InterventionTRUE", "Pr(>|z|)"]
    ) |>
    select(scenario, predicted, p_value)
}

## ---- plot-weekly-series
# One weekly series as in Figure 1: points sized by tests or patient-days,
# 95% intervals, a red line between the last week before and the first week
# with the intervention, and, when `fitted` is given, a model's fitted line in
# blue. Columns are passed unquoted, for example y = percent_positive.
plot_weekly_series <- function(weekly,
                               y,
                               lower,
                               upper,
                               size,
                               y_label,
                               size_label,
                               line_week,
                               week_breaks,
                               week_labels,
                               size_range,
                               fitted = NULL,
                               x_label = "Week") {
  weekly_plot <- ggplot(weekly) +
    geom_point(aes(x = Week, y = {{ y }}, size = {{ size }})) +
    geom_errorbar(
      aes(x = Week, ymin = {{ lower }}, ymax = {{ upper }}),
      width = 0.2
    ) +
    geom_vline(xintercept = line_week, color = "red") +
    scale_x_continuous(
      breaks = week_breaks,
      labels = week_labels,
      minor_breaks = NULL
    ) +
    scale_size(range = size_range) +
    labs(x = x_label, y = y_label, size = size_label) +
    theme_light() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1, size = 6),
      axis.title.y = element_text(size = 10),
      legend.justification = c(0, 0.5)
    )

  # geom_path() draws the fitted values in the order given, so the two points
  # at the break week join as a vertical step
  if (!is.null(fitted)) {
    weekly_plot <- weekly_plot +
      geom_path(data = fitted, aes(x = Week, y = fitted_value), color = "blue")
  }

  weekly_plot
}
