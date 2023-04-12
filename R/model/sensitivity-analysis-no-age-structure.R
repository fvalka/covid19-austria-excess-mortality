#' A simplified model with no age structure, based upon the WHO Nature paper 
#' on global excess mortality (https://doi.org/10.1038/s41586-022-05522-2)
#' 
#' @param weekly_deaths_pre_pandemic Weekly totals of deaths 
#' 
#' @return Fitted brms model object 
fit_brms_weekly_no_age_structure_model <- function(weekly_deaths_pre_pandemic) {
  weekly_model <- brm(bf(deaths ~ s(year, k = 20) +
                           s(week, bs = "cc", k = 53)),
                      data = weekly_deaths_pre_pandemic,
                      family = negbinomial(),
                      chains = 4, cores = 4)
  
  weekly_model
}

