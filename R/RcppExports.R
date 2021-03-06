# Generated by using Rcpp::compileAttributes() -> do not edit by hand
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#' Convert a vector of raw bytes to yxz g values
#'
#' Raw activity samples packed into 12-bit values in YXZ order.
#'
#' @param bytes A RawVector
#' @param scale Scale factor to return acceleration in g
#' @return A NumericVector of g values in yxz order
#'
read_activityC <- function(bytes, scale) {
    .Call(`_actigraphr_read_activityC`, bytes, scale)
}

wle <- function(counts, activity_threshold, spike_tolerance, spike_stoplevel) {
    .Call(`_actigraphr_wle`, counts, activity_threshold, spike_tolerance, spike_stoplevel)
}

overlap <- function(start, end) {
    .Call(`_actigraphr_overlap`, start, end)
}

