#' Combines a `data.frame` containing deaths per age group and week
#' with population data in 5 year age groups 
#' 
#' @param deaths data.frame containing deaths per age group and week
#' @param population data.frame containing population data in 5 year age groups
combine_deaths_and_pop <- function(deaths, population) {
  age_group_diff <- setdiff(population$age,
                            deaths$age)
  stopifnot(length(age_group_diff) == 0)
  
  deaths |>
    left_join(population)
}

#' Summarize deaths for weekly totals for all age groups
#' 
#' @param deaths_combined data.frame containing deaths for age groups and optionally population data 
weekly_totals_for_deaths <- function(deaths_combined) {
  deaths_combined |>
    group_by(year, week, week_start, week_end) |>
    summarise(deaths = sum(deaths))
}

#' Filter deaths to only include deaths before 2020
#' 
#' @param deaths_combined data.frame containing deaths for age groups and optionally population data 
filter_deaths_pre_pandemic <- function(deaths_combined) {
  deaths_combined |>
    filter(year < 2020)
}

#' Filter deaths for the pandemic time, meaning deaths in 2020 and later
#' 
#' @param deaths_combined data.frame containing deaths for age groups and optionally population data 
filter_deaths_pandemic <- function(deaths_combined) {
  deaths_combined |>
    filter(year >= 2020)
}

#' Calculates the mean death rate over all years to normalize the model 
#' such that regression parameters for each age group are around 1
#' 
#' @param deaths_pop_combined data.frame containing deaths and population by age groups and weeks
calculate_pop_norm_factors <- function(deaths_pop_combined) {
  deaths_pop_combined |>
    ungroup() |>
    group_by(age, sex) |>
    summarise(pop_norm_factor = mean(deaths)/mean(pop),
              pop_min = min(pop))
}

#' Calculates a constant normalization factor based upon mean deaths per mean 
#' population to improve the well posedness of the model 
#' 
#' And calculates log deaths to linearize the GAM in this parameter
#' 
#' @param deaths_pop_combined data.frame containing deaths and population by age groups and weeks
normalize_deaths_for_model <- function(deaths_pop_combined, pop_norm_factor) {
  
  
  first_year <- min(deaths_pop_combined$year)
  
  deaths_pop_combined_norm <- deaths_pop_combined |>
    left_join(pop_norm_factor) |>
    mutate(mean_deaths = pop*pop_norm_factor,
           mean_deaths_log = log(mean_deaths),
           pop_rel = pop/pop_min,
           year_rel = year - first_year)
  
  deaths_pop_combined_norm
}