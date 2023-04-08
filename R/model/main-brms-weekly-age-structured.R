fit_brms_weekl_age_structured_model <- function(deaths_pop_combined_pre_pandemic) {
  model_weekly_age_structured <- brm(bf(deaths ~ 0 + (0 + mean_deaths_log || age:sex) + 
                                          s(year, k = 5) +
                                          s(week, bs = "cc", k = 53)),
                                     data = deaths_pop_combined_pre_pandemic,
                                     family = negbinomial(),
                                     chains = 4, 
                                     cores = 4,
                                     iter = 3000,
                                     thin = 4,
                                     control = list(max_treedepth = 12))
  
  model_weekly_age_structured
}