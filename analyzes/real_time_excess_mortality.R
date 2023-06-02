library(ggplot2)
library(dplyr)
library(ggdist)
library(patchwork)
library(targets)



deaths_weekly_totals <- tar_read("deaths_weekly_totals")
deaths_pandemic_normalized <- tar_read("deaths_pandemic_normalized")

last_week_age_grouped <- deaths_pandemic_normalized |>
  ungroup() |>
  filter(week_start == max(week_start)) |>
  select(age, sex, pop, pop_norm_factor, pop_min, mean_deaths, mean_deaths_log, pop_rel)

missing_weeks <- deaths_weekly_totals |>
  mutate(year_rel = year - 2020) |>
  filter(year >= 2020) |>
  filter(!(week_start %in% deaths_pandemic_normalized$week_start))

deaths_extended <- deaths_pandemic_normalized |>
  rbind(tidyr::crossing(missing_weeks, last_week_age_grouped))


predictions_deaths_extended <- draw_predictions(tar_read("model_main_weekly_age_structured"), deaths_extended)

predictions_deaths_extended |>
  group_by(week_start, .draw) |>
  summarise(.prediction = sum(.prediction)) |>
  left_join(deaths_weekly_totals |> select(week_start, deaths)) |>
  mutate(excess = deaths - .prediction) |>
  ggplot(aes(x=week_start)) +
  stat_lineribbon(aes(y = .prediction, fill_ramp = stat(level), color="Expected Deaths", fill="Expected Deaths"), .width = c(.9, .7, .5), alpha=0.6) +
  geom_point(aes(color="Actual Deaths", y=deaths)) +
  geom_line(aes(color="Actual Deaths", y=deaths)) +
  ggsci::scale_color_npg() +
  ggsci::scale_fill_npg() +
  scale_x_date(date_minor_breaks = "month") +
  theme_bw() +
  labs(x="Week",
       y="Excess Deaths ",
       color=NULL,
       fill=NULL,
       level="CI")


excess_estimate <- predictions_deaths_extended |>
  group_by(week_start, week_end, .draw) |>
  summarise(.prediction = sum(.prediction)) |>
  left_join(deaths_weekly_totals |> select(week_start, deaths)) |>
  mutate(excess = deaths - .prediction) |>
  ungroup() |>
  group_by(.draw) |>
  mutate(cum_expected = cumsum(.prediction),
         cum_excess = cumsum(excess),
         cum_deaths = cumsum(deaths)) 

covid_deaths <- tar_read("covid_cases_deaths") |>
  ungroup() |>
  arrange(week_start) |>
  mutate(cum_covid_deaths = cumsum(covid_deaths)) |>
  select(week_start, covid_deaths, cum_covid_deaths)

yearly_covid_deaths <- covid_deaths |>
  ungroup() |>
  mutate(year = year(week_start + days(6))) |>
  group_by(year) |>
  summarise(covid_deaths = sum(covid_deaths))

yearly_covid_deaths_statistik_at <- data.frame(
  year = c(2021, 2022),
  covid_deaths = c(4257+3600+1192, 8055)
)

color_scale_values <- c("Excess Deaths", "Reported COVID Deaths (EMS)", "Reported COVID Deaths (Statistik Austria)")

cumulative_excess_plot <- excess_estimate |>
  ggplot(aes(x=week_start)) +
  stat_lineribbon(aes(y = cum_excess, fill_ramp = stat(level), color="Excess Deaths", fill="Excess Deaths"), .width = c(.9, .7, .5), alpha=0.6) +
  geom_line(data=covid_deaths, aes(y=cum_covid_deaths, color="Reported COVID Deaths (EMS)")) +
  ggsci::scale_color_npg() +
  ggsci::scale_fill_npg() +
  scale_x_date(date_minor_breaks = "month") +
  ggpubr::theme_pubr() +
  labs(x="Week",
       y="Cumulative Excess Deaths ",
       color=NULL,
       fill=NULL,
       fill_ramp="CI") + 
  theme(legend.position="bottom")

weekly_excess_plot <- excess_estimate |>
  ggplot(aes(x=week_start)) +
  geom_hline(yintercept = 0) +
  stat_lineribbon(aes(y = excess, fill_ramp = stat(level), color="Excess Deaths", fill="Excess Deaths"), .width = c(.9, .7, .5), alpha=0.6) +
  geom_line(data=covid_deaths, aes(y=covid_deaths, color="Reported COVID Deaths (EMS)")) +
  ggsci::scale_color_npg() +
  ggsci::scale_fill_npg() +
  scale_x_date(date_minor_breaks = "month") +
  ggpubr::theme_pubr() +
  labs(x="Week",
       y="Weekly Excess Deaths ",
       color=NULL,
       fill=NULL,
       fill_ramp="CI") + 
  theme(legend.position="bottom")

(cumulative_excess_plot /
  weekly_excess_plot)  + plot_layout(guides = 'collect') & theme(legend.position = 'bottom')

yearly_excess_deaths_plot <- excess_estimate |>
  mutate(year=year(week_end)) |>
  ungroup() |>
  group_by(year, .draw) |>
  summarise(excess = sum(excess),
            expected = sum(.prediction)) |>
  ggplot(aes(y=excess, x=factor(year))) +
  geom_violin(draw_quantiles = c(0.5), aes(color="Excess Deaths")) +
  geom_point(data=yearly_covid_deaths, aes(y=covid_deaths, color="Reported COVID Deaths (EMS)"), size=4) +
  geom_point(data=yearly_covid_deaths_statistik_at, aes(y=covid_deaths, color="Reported COVID Deaths (Statistik Austria)"), size=4) +
  scale_y_continuous(limits = c(0, NA)) +
  ggsci::scale_color_npg(limits = color_scale_values) +
  ggsci::scale_fill_npg(limits = color_scale_values) +
  labs(y="Excess Deaths", x="Year") +
  ggpubr::theme_pubr() +
  labs(color=NULL)

yearly_pscore_plot <- excess_estimate |>
  mutate(year=year(week_end)) |>
  ungroup() |>
  group_by(year, .draw) |>
  summarise(excess = sum(excess),
            expected = sum(.prediction)) |>
  mutate(p_score = (excess/expected)) |>
  ggplot(aes(y=p_score, x=factor(year))) +
  geom_violin(draw_quantiles = c(0.5)) +
  scale_y_continuous(limits = c(0, NA), labels = scales::percent) +
  ggsci::scale_color_npg(limits = color_scale_values) +
  ggsci::scale_fill_npg(limits = color_scale_values) +
  labs(y="P-Score", x="Year") +
  ggpubr::theme_pubr()

(cumulative_excess_plot / weekly_excess_plot) | (yearly_excess_deaths_plot / yearly_pscore_plot)

(yearly_excess_deaths_plot | yearly_pscore_plot) + 
  plot_layout(guides = 'collect') & 
  theme(legend.position = 'bottom')

