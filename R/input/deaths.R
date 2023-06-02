#' Downloads deaths by week and 5-year age group from the Statistik Austria
#' open government data. 
#' 
#' Source: https://data.statistik.gv.at/web/meta.jsp?dataset=OGD_gest_kalwo_alter_GEST_KALWOCHE_5J_100
#' 
download_statistik_austria_weekly_deaths_by_age_group <- function() {
  deaths_by_age_groups_desc <- od_table("OGD_gest_kalwo_alter_GEST_KALWOCHE_5J_100")
  deaths_by_age_groups <- deaths_by_age_groups_desc$tabulate()
  
  deaths_by_age_groups |>
    rename(age = `5 years age group of deceased`,
           sex = `Gender of deceased`,
           week_start = `Calendar week`,
           deaths = `Number of deaths`) |>
    group_by(week_start, age, sex) |>
    summarise(deaths = sum(deaths)) |>
    ungroup() |>
    group_by(week_start) |>
    complete(age, sex,
             fill = list(deaths = 0)) |>
    mutate(age = tolower(age),
           week = isoweek(week_start),
           week_end = week_start + days(6)) |>
    mutate(year = year(week_end))
}

download_statistik_austria_weekly_deaths <- function() {
  deaths_by_age_groups_desc <- od_table("OGD_gest_kalwo_GEST_KALWOCHE_100")
  deaths_by_age_groups <- deaths_by_age_groups_desc$tabulate()
  
  deaths_by_age_groups |>
    rename(age = `Age group of deceased`,
           sex = `Gender of deceased`,
           week_start = `Calendar week`,
           deaths = `Number of deaths`) |>
    group_by(week_start) |>
    summarise(deaths = sum(deaths)) |>
    ungroup() |>
    mutate(week = isoweek(week_start),
           week_end = week_start + days(6)) |>
    mutate(year = year(week_end))
}