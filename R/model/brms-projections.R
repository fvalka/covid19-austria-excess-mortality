#' Draw predictions from the posterior distribution and add them to the
#' provided data.frame 
#' 
#' The relevant new columns added are:
#' - .prediction this contains the draws 
#' - .draw this contains the sequential number of the draw (1...1000)
#' 
#' @param model Model from which the predictions are drawn 
#' @param data data.frame containing the data, inc. input parameters, for which the predictions are drawn
#' 
#' @return data.frame containing the original data and enriched with predictions 
draw_predictions <- function(model, data) {
  data |>
    tidybayes::add_predicted_draws(model, ndraws = 1000)
}

#' Calculate the weekly totals for prediction draws which are still age
#' structured. 
#' 
#' @param prediction_draws Posterior draws from a model which has an age structure
#' 
#' @return Weekly sums of predictions and deaths 
summarize_weekly_predictions <- function(prediction_draws) {
  prediction_draws |>
    group_by(year, week, week_start, week_end, .draw) |>
    summarise(deaths = sum(deaths),
              .prediction = sum(.prediction)) |>
    mutate(excess = deaths - .prediction) |>
    ungroup() |>
    group_by(.draw) |>
    arrange(week_start) |>
    mutate(cum_expected = cumsum(.prediction),
           cum_excess = cumsum(excess),
           cum_deaths = cumsum(deaths)) 
}

combine_predictions <- function(...) {
  dplyr::bind_rows(list(...)) |>
    ungroup() |>
    arrange(week_start) |>
    group_by(.draw) |>
    arrange(week_start) |>
    mutate(cum_expected = cumsum(.prediction),
           cum_excess = cumsum(excess),
           cum_deaths = cumsum(deaths)) 
}