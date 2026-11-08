# Purpose: run the analysis in dependency order.
# Run from the project root in a fresh session, by a person authorized to use
# the study data. Before the first run, set COVID_IC_DATA_DIR in .Renviron to
# the folder holding "Surveillance manuscript2 9-19.xlsx" and
# "Harris_data.csv", and restart R.

source("R/setup.R")
source("R/functions.R")
source("R/prepare_data.R")  # weekly surveillance data and Harris County cases
source("R/models.R")        # four models per outcome; the segmented model is the published one
source("R/figures.R")       # Figures 1 and 2, saved to figures/
