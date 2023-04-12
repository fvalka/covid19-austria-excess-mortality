#' Fit the main brms model to the provided data 
#' 
#' The model is a GAM containing splines for a yearly trend with knots at every 
#' 4th year and cyclic cubic splines for weekly seasonal trends with 53 knots 
#' 
#' The model is age and sex structured. 
#' 
#' @param deaths_pop_combined_pre_pandemic data.frame containg the deaths and population, already normalized, in the fit period 
#' 
#' @return Fitted brms model object 
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