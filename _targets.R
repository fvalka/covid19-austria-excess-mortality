# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes) 

# Set target options:
tar_option_set(
  packages = c("tibble", "here", "ggplot2", "ggdist", "dplyr", "lubridate",
               "brms", "tidybayes", "reshape2", "RcppRoll", "STATcubeR",
               "readr", "tidyr"), 
  format = "rds"
)

# tar_make_future() configuration (okay to leave alone):
# Install packages {{future}}, {{future.callr}}, and {{future.batchtools}} to allow use_targets() to configure tar_make_future() options.

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# source("other_functions.R") # Source other scripts as needed. # nolint

# Replace the target list below with your own:
list(
  tar_target(
    name = projected_population,
    command = download_statistik_austria_population(),
    cue = tar_cue_age(name = deaths_by_age_groups,
                      age = as.difftime(3, units = "days"))
  ),
  tar_target(
    deaths_by_age_groups,
    download_statistik_austria_weekly_deaths(),
    cue = tar_cue_age(name = deaths_by_age_groups,
                      age = as.difftime(3, units = "hours"))
  ),
  tar_target(
    deaths_combined,
    combine_deaths_and_pop(deaths_by_age_groups, projected_population)
  ),
  tar_target(
    deaths_weekly_totals,
    weekly_totals_for_deaths(deaths_combined)
  ),
  tar_target(
    deaths_combined_normalized,
    normalize_deaths_for_model(deaths_combined)
  ),
  tar_target(
    deaths_pre_pandemic_normalized,
    filter_deaths_pre_pandemic(deaths_combined_normalized)
  ),
  tar_target(
    deaths_pandemic_normalized,
    filter_deaths_pandemic(deaths_combined_normalized)
  ),
  tar_change(
    model_main_weekly_age_structured,
    fit_brms_weekl_age_structured_model(deaths_pre_pandemic_normalized),
    change = digest::digest(deaths_pre_pandemic_normalized, algo="sha512")
  ),
  tar_target(
    model_sensitivty_analysis_no_age_structure,
    fit_brms_weekly_no_age_structure_model(deaths_weekly_totals |> filter(year < 2020))
  ),
  tar_target(
    prediction_draws_model_main, 
    draw_predictions(model_main_weekly_age_structured, deaths_pandemic_normalized)
  ),
  tar_target(
    prediction_weekly_totals_model_main,
    summarize_weekly_predictions(prediction_draws_model_main)
  )
)