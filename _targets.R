library(targets)
library(tarchetypes) 

tar_option_set(
  packages = c("tibble", "here", "ggplot2", "ggdist", "dplyr", "lubridate",
               "brms", "tidybayes", "reshape2", "RcppRoll", "STATcubeR",
               "readr", "tidyr"), 
  format = "rds"
)

tar_source()

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
    prediction_draws_sensitivty_pre_pandemic, 
    draw_predictions(model_main_weekly_age_structured, deaths_pre_pandemic_normalized)
  ),
  tar_target(
    prediction_draws_sensitivty_analysis_no_age_structure,
    draw_predictions(model_sensitivty_analysis_no_age_structure, deaths_weekly_totals) 
  ),
  tar_target(
    prediction_weekly_totals_model_main,
    summarize_weekly_predictions(prediction_draws_model_main)
  ),
  tar_target(
    prediction_weekly_totals_sensitivty_pre_pandemic,
    summarize_weekly_predictions(prediction_draws_sensitivty_pre_pandemic)
  )
)
