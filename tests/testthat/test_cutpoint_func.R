
library("actigraphr")
library("readr")
library("dplyr")

context("Activity scoring with cutpoints")
test_that("apply_cutpoints returns same result as ActiLife 6 - 10s epoch", {

  check_cutpoint <- function(cutpoints, agd){

    agdb_10s <- read_agd(agd) %>%
      apply_cutpoints(cutpoints)

    len <- length(attr(agdb_10s, "intensity_categories"))
    actilife <- read_csv(csv_file) %>%
      filter(Epoch == 10 & Cutpoints == cutpoints)
    actilife <- unname(unlist(actilife[1, 7:(7 + len - 1)]))
    agdb_10s <- as.vector(table(agdb_10s$activity) / 6)

    expect_equal(actilife, agdb_10s)
  }

  csv_file <- system.file("extdata", "GT3XPlus-RawData-Day01-Cutpoints.csv",
                          package = "actigraphr")

  agd_file <- system.file("extdata", "GT3XPlus-RawData-Day01.agd",
                          package = "actigraphr")

  check_cutpoint("freedson_adult", agd_file)
  check_cutpoint("freedson_adult_vm", agd_file)
  check_cutpoint("freedson_children", agd_file)
  check_cutpoint("evenson_children", agd_file)
  check_cutpoint("mattocks_children", agd_file)
  check_cutpoint("puyau_children", agd_file)
})
test_that("apply_cutpoints returns same result as ActiLife 6 - 30s and 60s epoch", {

  check_cutpoint <- function(cutpoints, agd, epoch){

    agdb_10s <- read_agd(agd) %>%
      collapse_epochs(epoch) %>%
      apply_cutpoints(cutpoints)

    len <- length(attr(agdb_10s, "intensity_categories"))
    actilife <- read_csv(csv_file) %>%
      filter(Epoch == epoch & Cutpoints == cutpoints & is.na(Nonwear_algorithm))
    actilife <- unname(unlist(actilife[1, 7:(7 + len - 1)]))
    agdb_10s <- as.vector(table(agdb_10s$activity) / (60 / epoch))

    expect_equal(actilife, agdb_10s)
  }

  csv_file <- system.file("extdata", "GT3XPlus-RawData-Day01-Cutpoints.csv",
                          package = "actigraphr")

  agd_file <- system.file("extdata", "GT3XPlus-RawData-Day01.agd",
                          package = "actigraphr")

  check_cutpoint("evenson_children", agd_file, 30)
  check_cutpoint("evenson_children", agd_file, 60)
})
test_that("apply_cutpoints with non-wear removed returns same result as ActiLife 6", {

  check_cutpoint <- function(agd, epoch, algorithm){

    agdb_10s <- read_agd(agd) %>%
      collapse_epochs(epoch)

    if (algorithm == "troiano") {
      agdb_10s <- agdb_10s %>% apply_weartime()
    } else {
      agdb_10s <- agdb_10s %>% apply_weartime(apply_choi)
    }

    agdb_10s <- agdb_10s %>%
      apply_cutpoints("evenson_children") %>%
      filter(wear == 1)

    len <- length(attr(agdb_10s, "intensity_categories"))
    actilife <- read_csv(csv_file) %>%
      filter(Epoch == epoch &
             Cutpoints == "evenson_children" &
             Nonwear_algorithm == algorithm)
    actilife <- unname(unlist(actilife[1, 7:(7 + len - 1)]))
    agdb_10s <- as.vector(table(agdb_10s$activity) / (60 / epoch))

    expect_equal(actilife, agdb_10s)
  }


  csv_file <- system.file("extdata", "GT3XPlus-RawData-Day01-Cutpoints.csv",
                          package = "actigraphr")

  agd_file <- system.file("extdata", "GT3XPlus-RawData-Day01.agd",
                          package = "actigraphr")

  for (epoch in c(10, 30, 60)) {
    for (algorithm in c("troiano", "choi")) {

      check_cutpoint(agd_file, epoch, algorithm)

    }
  }
})
test_that("apply_cutpoints returns same result as ActiLife 6 - custom cutpoints", {

  # Odd number of categories

  # Custom list format check

})

context("Activity summary with weartime filter")
test_that("apply_cutpoints and apply_weartime_filter returns same result as ActiLife 6", {

  csv_file <- system.file("extdata", "GT3XPlus-RawData-Day01-evenson_children_7h-summary.csv",
                          package = "actigraphr")

  agd_file <- system.file("extdata", "GT3XPlus-RawData-Day01.agd",
                          package = "actigraphr")

  agdb <- read_agd(agd_file) %>%
    collapse_epochs(60) %>%
    apply_weartime() %>%
    apply_cutpoints("evenson_children") %>%
    summarise_agd("1 day") %>%
    apply_weartime_filter(hours = 7, days = 1)

  agdb <- unname(unlist(agdb[1, c(8:11, 5:6)]))

  actilife <- read_csv(csv_file)
  actilife <- unname(unlist(actilife[1, 3:8]))

  expect_equal(actilife, agdb)
})
