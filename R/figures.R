# Purpose: draw the weekly series, the exploratory model plots, Figure 1 and
# Figure 2, and save the figures to figures/ (gitignored: made from the
# study data).
# Needs: weekly and harris (R/prepare_data.R); positivity_models, hai_models,
# positivity_fitted and hai_fitted (R/models.R); intervention_start,
# intervention_line_week, labelled_weeks, week_labels, point_size_range,
# hai_rate_per and the Harris County scale factors (R/setup.R);
# plot_weekly_series() (R/functions.R).
# Produces: weekly_plots, exploratory_plots, figure_1a, figure_1b, figure_2.

## ---- plot-weekly-series
# The observed series with 95% intervals, before any model (analysis-plan.md
# section 8.1)
weekly_plots <- list(
  positivity = plot_weekly_series(
    weekly,
    y = percent_positive,
    lower = percent_lower,
    upper = percent_upper,
    size = Tested,
    y_label = "Proportion of tests positive with 95% CIs",
    size_label = "Tested",
    line_week = intervention_line_week,
    week_breaks = labelled_weeks,
    week_labels = week_labels,
    size_range = point_size_range
  ),
  hai = plot_weekly_series(
    weekly,
    y = hai_rate,
    lower = hai_rate_lower,
    upper = hai_rate_upper,
    size = Ptdays,
    y_label = "HAI rate per 1000 patient-days with 95% CIs",
    size_label = "Ptdays",
    line_week = intervention_line_week,
    week_breaks = labelled_weeks,
    week_labels = week_labels,
    size_range = point_size_range
  )
)

## ---- plot-exploratory-models
# The three exploratory models' fitted lines over the observed series
# (analysis-plan.md section 8.3). Not reported in the article.
exploratory_models <- c("its1_week", "its2_intervention", "its3_level_change")

exploratory_plots <- list(
  positivity = map(exploratory_models, \(model) {
    plot_weekly_series(
      weekly,
      y = percent_positive,
      lower = percent_lower,
      upper = percent_upper,
      size = Tested,
      y_label = "Proportion of tests positive with 95% CIs",
      size_label = "Tested",
      line_week = intervention_line_week,
      week_breaks = labelled_weeks,
      week_labels = week_labels,
      size_range = point_size_range,
      fitted = positivity_fitted[[model]]
    )
  }) |>
    set_names(exploratory_models),
  hai = map(exploratory_models, \(model) {
    plot_weekly_series(
      weekly,
      y = hai_rate,
      lower = hai_rate_lower,
      upper = hai_rate_upper,
      size = Ptdays,
      y_label = "HAI rate per 1000 patient-days with 95% CIs",
      size_label = "Ptdays",
      line_week = intervention_line_week,
      week_breaks = labelled_weeks,
      week_labels = week_labels,
      size_range = point_size_range,
      fitted = hai_fitted[[model]]
    )
  }) |>
    set_names(exploratory_models)
)

## ---- plot-figure-1
# Figure 1 (analysis-plan.md section 8.4): the published segmented model.
# The size legend of panel A reads "# patients tested", as in the original
# code, although the points are sized by healthcare-personnel tests.
figure_1a <- plot_weekly_series(
  weekly,
  y = percent_positive,
  lower = percent_lower,
  upper = percent_upper,
  size = Tested,
  y_label = "Percentage of HCP \ntests positive",
  size_label = "# patients tested",
  line_week = intervention_line_week,
  week_breaks = labelled_weeks,
  week_labels = week_labels,
  size_range = point_size_range,
  fitted = positivity_fitted$its4_segmented,
  x_label = NULL
)

figure_1b <- plot_weekly_series(
  weekly,
  y = hai_rate,
  lower = hai_rate_lower,
  upper = hai_rate_upper,
  size = Ptdays,
  y_label = "HAI rate per\n1000 patient-days",
  size_label = "Patient-days",
  line_week = intervention_line_week,
  week_breaks = labelled_weeks,
  week_labels = week_labels,
  size_range = point_size_range,
  fitted = hai_fitted$its4_segmented
)

## ---- prepare-figure-2-lines
# Figure 2 is drawn by date. As in the original code, its fitted line joins
# the published model's predictions at the observed weeks, without the step
# at the intervention that Figure 1 shows. Ptdays is set to 1 so the HAI
# prediction is a rate per patient-day.
weekly_by_date <- weekly |>
  mutate(
    positivity_fitted = 100 * predict(
      positivity_models$its4_segmented,
      newdata = weekly,
      type = "response"
    ),
    hai_fitted = hai_rate_per * predict(
      hai_models$its4_segmented,
      newdata = mutate(weekly, Ptdays = 1),
      type = "response"
    )
  )

# The day before face shields began
intervention_line_date <- intervention_start - 1

## ---- plot-figure-2
# Figure 2 (analysis-plan.md section 8.4): Figure 1's series by date, with
# daily Harris County cases as grey bars on a second y-axis. The bars are
# divided by a scale factor to share the left axis, and the second axis
# multiplies them back.
figure_2a <- ggplot(harris) +
  geom_point(
    data = weekly_by_date,
    aes(x = Date, y = percent_positive, size = Tested)
  ) +
  theme_light() +
  geom_vline(xintercept = intervention_line_date, color = "red") +
  geom_errorbar(
    data = weekly_by_date,
    aes(x = Date, ymin = percent_lower, ymax = percent_upper),
    width = 0.2,
    color = "#5A5656"
  ) +
  geom_line(
    data = weekly_by_date,
    aes(x = Date, y = positivity_fitted),
    color = "blue"
  ) +
  labs(size = "# patients tested") +
  theme(
    legend.justification = c(0, 0.5),
    axis.title.y = element_text(size = 10),
    axis.title.x = element_blank()
  ) +
  scale_size(range = point_size_range) +
  geom_col(aes(x = Date, y = epicurve_Harris / harris_scale_positivity), alpha = 0.2) +
  scale_y_continuous(
    name = "Percentage of HCP \ntests positive",
    sec.axis = sec_axis(
      \(x) x * harris_scale_positivity,
      name = "Daily COVID-19 cases\nin Harris County"
    )
  )

figure_2b <- ggplot(harris) +
  geom_point(
    data = weekly_by_date,
    aes(x = Date, y = hai_rate, size = Ptdays)
  ) +
  theme_light() +
  geom_vline(xintercept = intervention_line_date, color = "red") +
  geom_errorbar(
    data = weekly_by_date,
    aes(x = Date, ymin = hai_rate_lower, ymax = hai_rate_upper),
    width = 0.2
  ) +
  geom_line(
    data = weekly_by_date,
    aes(x = Date, y = hai_fitted),
    color = "blue"
  ) +
  geom_col(aes(x = Date, y = epicurve_Harris / harris_scale_hai), alpha = 0.2) +
  scale_y_continuous(
    name = "HAI rate per\n1000 patient-days",
    sec.axis = sec_axis(
      \(x) x * harris_scale_hai,
      name = "Daily COVID-19 cases\nin Harris County"
    )
  ) +
  scale_size(range = point_size_range) +
  labs(size = "Patient-days") +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_text(size = 10),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 6)
  )

figure_2 <- plot_grid(figure_2a, figure_2b, ncol = 1, align = "v")

## ---- save-figures
# As in the original code, Figure 1's panels are saved as TIFF files without
# a set size, so ggsave() uses the size of the current graphics device.
# Figure 2 was not saved by the original code; it is saved here the same way.
dir.create("figures", showWarnings = FALSE)
ggsave(file.path("figures", "figure_1a.tiff"), figure_1a)
ggsave(file.path("figures", "figure_1b.tiff"), figure_1b)
ggsave(file.path("figures", "figure_2.tiff"), figure_2)
