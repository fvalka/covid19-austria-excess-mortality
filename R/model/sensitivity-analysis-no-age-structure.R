fit_brms_weekly_no_age_structure_model <- function(weekly_deaths_pre_pandemic) {
  weekly_model <- brm(bf(deaths ~ s(year, k = 20) +
                           s(week, bs = "cc", k = 53)),
                      data = weekly_deaths_pre_pandemic,
                      family = negbinomial(),
                      chains = 4, cores = 4)
  
  weekly_model
}