
load_covid_cases <- function(file_path) {
  read.csv2(file_path) |>
    filter(BundeslandID == 10) |>
    mutate(Time = as.Date(dmy_hms(Time))) 
}

match_covid_cases <- function(covid_cases_deaths, deaths_weekly_totals) {
  covid_cases_deaths |> 
    select(Time, AnzahlTotTaeglich ) |>
    rename(week_end=Time) |>
    left_join(deaths_weekly_totals) |>
    tidyr::fill(year, .direction = "up") |>
    tidyr::fill(week, .direction = "up") |>
    group_by(year, week) |>
    summarise(covid_deaths = sum(AnzahlTotTaeglich),
              week_start = min(week_end),
              week_end = max(week_end)) |>
    filter(!is.na(year)) |>
    mutate(week_start = week_end - days(6))
}