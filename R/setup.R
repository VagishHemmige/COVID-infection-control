# Purpose: attach packages and define every constant shared by the scripts.
# Needs: nothing. Produces: attached packages and named constants.
# The data are located only through the COVID_IC_DATA_DIR environment
# variable, set in .Renviron by the person authorized to run the analysis.

## ---- load-packages
library(tidyverse)  # dplyr, readr, stringr, ggplot2
library(readxl)     # the weekly surveillance workbook
library(epitools)   # exact binomial and Poisson confidence intervals
library(gtsummary)  # model tables
library(cowplot)    # Figure 2: two panels stacked

## ---- define-data-files
data_dir <- Sys.getenv("COVID_IC_DATA_DIR")
surveillance_file <- "Surveillance manuscript2 9-19.xlsx"
harris_file <- "Harris_data.csv"

## ---- define-study-dates
# analysis-plan.md section 6. Week 1 begins on Friday 17 April 2020; weeks 2
# onward begin on Mondays. Week 13, beginning 6 July 2020, is the first week
# with universal face shields.
study_start <- as.Date("2020-04-17")
intervention_start <- as.Date("2020-07-06")
study_end <- as.Date("2020-09-07")
intervention_week <- 13

## ---- define-week-labels
# Axis labels for weeks 2 to 22: the Monday each week begins
labelled_weeks <- 2:22
week_label_dates <- seq(
  as.Date("2020-04-20"),
  by = "week",
  length.out = length(labelled_weeks)
)
week_labels <- str_c(
  format(week_label_dates, "%b"),
  " ",
  as.integer(format(week_label_dates, "%d"))
)

## ---- define-estimation-constants
# analysis-plan.md section 8.1
confidence_level <- 0.95
hai_rate_per <- 1000  # HAI rate per 1,000 patient-days

## ---- define-plot-constants
# The vertical line falls between the last week before the intervention and
# the first week with it
intervention_line_week <- intervention_week - 0.5
point_size_range <- c(1, 3)

# Figure 2 puts daily Harris County cases on a second y-axis. The original
# code scaled the cases by 3780 / 22 for the positivity panel and 3780 / 7 for
# the HAI panel; the same factors are kept here.
harris_scale_positivity <- round(3780 / 22)
harris_scale_hai <- round(3780 / 7)
