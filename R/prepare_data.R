# Purpose: read the weekly surveillance data and the Harris County cases, and
# add the weekly estimates and the time series variables.
# Needs: R/setup.R (packages, data_dir, file names, intervention_week,
# confidence_level, hai_rate_per) and R/functions.R (add_exact_intervals()).
# Produces: weekly (one row per week) and harris (one row per day).
# Run only by a person authorized to use the data. AI agents never run it.

## ---- check-data-folder
if (data_dir == "") {
  stop(
    "COVID_IC_DATA_DIR is not set. Add it to .Renviron and restart R.",
    call. = FALSE
  )
}

## ---- read-surveillance-data
# One row per week. The original code expects these columns: Week, Date1 and
# Date2 (dates for the week), Tested and Positives (healthcare-personnel
# tests), HAI (possible and confirmed hospital-acquired infections together)
# and Ptdays (patient-days).
weekly_raw <- read_excel(file.path(data_dir, surveillance_file))

expected_columns <- c("Week", "Date1", "Date2", "Tested", "Positives", "HAI", "Ptdays")
missing_columns <- setdiff(expected_columns, names(weekly_raw))
if (length(missing_columns) > 0) {
  stop(
    "The surveillance workbook has no column named: ",
    str_flatten_comma(missing_columns),
    call. = FALSE
  )
}

## ---- add-weekly-estimates
# analysis-plan.md section 8.1
weekly <- weekly_raw |>
  mutate(
    Date1 = as.Date(Date1),
    Date2 = as.Date(Date2)
  ) |>
  add_exact_intervals(conf_level = confidence_level, rate_per = hai_rate_per)

## ---- add-time-series-variables
# analysis-plan.md sections 6 and 8.2. Intervention is TRUE from the
# intervention week on. Week2 is the week centred at the intervention week,
# so the intervention term in the models is the contrast at week 13.
weekly <- weekly |>
  mutate(
    Intervention = Week >= intervention_week,
    Week2 = Week - intervention_week
  )

## ---- add-plot-dates
# The date each week is drawn at in Figure 2, alongside the daily Harris
# County bars. Date2 is the last day of each week's range (recalled by the
# author, not documented in the data): a Friday, so two days before it is the
# Wednesday in the middle of the week. Week 1 began on Friday 17 April 2020,
# so its Date2 is that day; the original code drew it one day earlier. Both
# rules are kept as in the original code.
weekly <- weekly |>
  mutate(
    Date = if_else(Date2 == study_start, Date2 - 1, Date2 - 2)
  )

## ---- read-harris-county-data
# Daily COVID-19 cases in Harris County, from the Harris County Public Health
# COVID Data Dashboard "Epi Curve". The original code expects the columns
# Date (written month/day/two-digit year) and epicurve_Harris (cases).
harris <- read_csv(
  file.path(data_dir, harris_file),
  col_types = cols(Date = col_character(), .default = col_guess())
) |>
  mutate(Date = as.Date(Date, format = "%m/%d/%y"))
