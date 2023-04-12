#' Age levels used in the model and plots
pop_age_levels <- 
  c("up to 4 years old",
    "5 to 9 years old",
    "10 to 14 years old", 
    "15 to 19 years old", 
    "20 to 24 years old", 
    "25 to 29 years old", 
    "30 to 34 years old", 
    "35 to 39 years old", 
    "40 to 44 years old", 
    "45 to 49 years old",
    "50 to 54 years old", 
    "55 to 59 years old", 
    "60 to 64 years old", 
    "65 to 69 years old", 
    "70 to 74 years old", 
    "75 to 79 years old", 
    "80 to 84 years old", 
    "85 to 89 years old", 
    "90 to 94 years old",
    "95 plus years old")

#' Downloads up-to-date beginning of year population projections by 5 year age group
#' from Statistik Austrias open government data 
#' 
#' Source: https://data.statistik.gv.at/web/meta.jsp?dataset=OGD_bevjahresanf_PR_BEVJA_7
download_statistik_austria_population <- function() {
  projected_pop_desc <- od_table("OGD_bevjahresanf_PR_BEVJA_7")
  projected_pop <- projected_pop_desc$tabulate() 
  
  projected_pop |>
    rename(age = `Alter in 5-Jahresgruppen`,
           sex = `Sex <2>`,
           pop = `Main scenario (mean fertility, life expectancy, immigration)`,
           year_start = `Year (1952-2075)`) |>
    mutate(year = year(year_start),
           age = tolower(age)) |>
    group_by(year, age, sex) |>
    summarise(pop = sum(pop))
}