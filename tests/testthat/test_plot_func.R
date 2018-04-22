
library("actigraphr")
library("dplyr")
library("readr")

context("Test plotting functions")
test_that("Test plot_activity", {

  # data <- gtxplus1day %>%
  #   collapse_epochs(60) %>%
  #   apply_cole_kripke()
  #
  # plot_activity(data, axis1, color = "gray")
  # plot_activity(data, axis1, color = "sleep")

})
test_that("Test plot_activity_period", {

  # periods_sleep <- gtxplus1day %>%
  #   collapse_epochs(60) %>%
  #   apply_cole_kripke() %>%
  #   apply_tudor_locke(min_sleep_period = 60)
  #
  # plot_activity_period(gtxplus1day, periods_sleep, axis1,
  #                      in_bed_time, out_bed_time)

})
test_that("Test plot_activity_summary", {

  # agdb_summary <- gtxplus1day %>%
  #   apply_weartime() %>%
  #   apply_cutpoints("evenson_children") %>%
  #   summarise_agd(time = "1 hour")
  #
  # plot_activity_summary(agdb_summary)
  #
  # # Plot selected days only
  # plot_activity_summary(agdb_summary, start_date = '2012-06-27',
  #                             end_date = '2012-06-28')
})
