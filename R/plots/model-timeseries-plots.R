#' Plots a timeseries using stat_lineribbon elements to show the 
#' median 50%, 70% and 90% CIs 
#' 
#' @param timeseries data.frame of the timeseries to plot
#' @param model_parameter column name in timeseries to plot 
plot_model_timeseries <- function(timeseries, model_parameter) {
  timeseries |>
    ggplot(aes(x=week_start)) +
    geom_hline(yintercept = 0) +
    stat_lineribbon(aes(y = {{model_parameter}}, 
                        alpha = stat(level), 
                        color="Excess Deaths", 
                        fill="Excess Deaths"), 
                    .width = c(.9, .7, .5)) +
    scale_alpha_ordinal(range=c(0.2, 0.5)) +
    ggsci::scale_color_npg() +
    ggsci::scale_fill_npg() +
    scale_x_date(date_minor_breaks = "month") +
    ggpubr::theme_pubr() +
    labs(x="Date",
         y="Deaths ",
         color=NULL,
         fill=NULL,
         alpha="CI") + 
    theme(legend.position="bottom")
}