draw_predictions <- function(model, data) {
  data |>
    tidybayes::add_predicted_draws(model, ndraws = 1000)
}

summarize_weekly_predictions <- function(prediction_draws) {
  prediction_draws |>
    group_by(year, week, week_start, week_end, .draw) |>
    summarise(deaths = sum(deaths),
              .prediction = sum(.prediction))
}