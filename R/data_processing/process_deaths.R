combine_deaths_and_pop <- function(deaths, population) {
  age_group_diff <- setdiff(population$age,
                            deaths$age)
  stopifnot(length(age_group_diff) == 0)
  
  deaths |>
    left_join(population)
}

weekly_totals_for_deaths <- function(deaths_combined) {
  deaths_combined |>
    group_by(year, week, week_start, week_end) |>
    summarise(deaths = sum(deaths))
}

filter_deaths_pre_pandemic <- function(deaths_combined) {
  deaths_combined |>
    filter(year < 2020)
}

filter_deaths_pandemic <- function(deaths_combined) {
  deaths_combined |>
    filter(year >= 2020)
}

normalize_deaths_for_model <- function(deaths_pop_combined) {
  pop_norm_factor <- deaths_pop_combined |>
    ungroup() |>
    group_by(age, sex) |>
    summarise(pop_norm_factor = mean(deaths)/mean(pop),
              pop_min = min(pop))
  
  first_year <- min(deaths_pop_combined$year)
  
  deaths_pop_combined_norm <- deaths_pop_combined |>
    left_join(pop_norm_factor) |>
    mutate(mean_deaths = pop*pop_norm_factor,
           mean_deaths_log = log(mean_deaths),
           pop_rel = pop/pop_min,
           year_rel = year - first_year)
  
  deaths_pop_combined_norm
}