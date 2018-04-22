#' actigraphr
#'
#' This package implements three standard algorithms for sleep detection from ActiGraph data: Sadeh, Cole-Kripke and Tudor-Locke.
#'
#' In addition to the help pages, see the README page on \href{https://github.com/TheTS/actigraphr}{github} for examples.
#'
#' @name actigraphr
#' @docType package
#' @useDynLib actigraphr, .registration = TRUE
#' @import dplyr ggplot2
#' @importFrom assertthat assert_that has_name
#' @importFrom rlang .data quo_text
#' @importFrom tidyr gather spread unnest
#' @importFrom purrr map map2
#' @importFrom data.table rleid
#' @importFrom zoo na.locf na.trim na.spline
#' @importFrom RcppRoll roll_mean roll_sd roll_sum
#' @importFrom lubridate duration ymd_hms time_length is.POSIXct floor_date wday seconds
#' @importFrom stringr str_replace
NULL
