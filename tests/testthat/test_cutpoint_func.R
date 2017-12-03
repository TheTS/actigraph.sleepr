
library("actigraph.sleepr")
library("readr")
library("dplyr")

context("Activity scoring with cutpoints")
test_that("apply_cutpoints returns same result as ActiLife 6", {

  check_cutpoint <- function(cutpoints, agd){

    csv_file <- system.file("extdata", paste("GT3XPlus-RawData-Day01-",
                                             cutpoints, "-summary.csv", sep = ""),
                            package = "actigraph.sleepr")

    agdb_10s <- read_agd(agd_file) %>%
      apply_cutpoints(cutpoints)

    len <- length(attr(agdb_10s, "intensity_categories"))
    actilife <- read_csv(csv_file)
    actilife <- unname(unlist(actilife[1, 7:(7 + len - 1)]))
    agdb_10s <- as.vector(table(agdb_10s$activity) / 6)

    expect_equal(actilife, agdb_10s)
  }

  agd_file <- system.file("extdata", "GT3XPlus-RawData-Day01.agd",
                          package = "actigraph.sleepr")

  check_cutpoint("freedson_adult", agd_file)
  check_cutpoint("freedson_adult_vm", agd_file)
  check_cutpoint("freedson_children", agd_file)
  check_cutpoint("evenson_children", agd_file)
  check_cutpoint("mattocks_children", agd_file)
  check_cutpoint("puyau_children", agd_file)
})
test_that("apply_cutpoints with non-wear removed returns same result as ActiLife 6", {

  csv_file <- system.file("extdata", "GT3XPlus-RawData-Day01-evenson_children_nwr-summary.csv",
                          package = "actigraph.sleepr")

  agd_file <- system.file("extdata", "GT3XPlus-RawData-Day01.agd",
                          package = "actigraph.sleepr")

  agdb <- read_agd(agd_file) %>%
    collapse_epochs(60) %>%
    apply_weartime() %>%
    apply_cutpoints("evenson_children") %>%
    filter(wear > 0)

  len <- length(attr(agdb, "intensity_categories"))

  agdb <- as.vector(table(agdb$activity))

  actilife <- read_csv(csv_file)
  actilife <- unname(unlist(actilife[1, 7:(7 + len - 1)]))

  expect_equal(actilife, agdb)
})

context("Activity summary with weartime filter")
test_that("apply_cutpoints and apply_weartime_filter returns same result as ActiLife 6", {

  csv_file <- system.file("extdata", "GT3XPlus-RawData-Day01-evenson_children_7h-summary.csv",
                          package = "actigraph.sleepr")

  agd_file <- system.file("extdata", "GT3XPlus-RawData-Day01.agd",
                          package = "actigraph.sleepr")

  agdb <- read_agd(agd_file) %>%
    collapse_epochs(60) %>%
    apply_weartime() %>%
    apply_cutpoints("evenson_children") %>%
    summarise_agd("1 day") %>%
    apply_weartime_filter(hours = 7, days = 1)

  agdb <- unname(unlist(agdb[1, c(5:8, 2:3)]))

  actilife <- read_csv(csv_file)
  actilife <- unname(unlist(actilife[1, 3:8]))

  expect_equal(actilife, agdb)
})
