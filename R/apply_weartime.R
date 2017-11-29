#' Append a weartime column to an activity data frame
#'
#' This function wraps either the \code{\link{apply_choi}} or \code{\link{apply_troiano}} functions to calculate weartime, and appends a \emph{'wear'} column to the input \code{tibble}.
#' @param agdb A \code{tibble} of activity data optained from \code{\link{read_agd}}.
#' @param fun The weartime function to employ (either \code{apply_troiano} or \code{apply_choi}). The default is \code{apply_troiano}.
#' @param ... Additional parameters passed to the weartime function if the default parameters are not suitable.
#' @return The input \code{tibble} of activity data with an additional \emph{'wear'} column.
#' @seealso \code{\link{apply_choi}}, \code{\link{apply_troiano}}
#' @examples
#'  agd <- read_agd(file = "test.agd") %>%
#'   apply_weartime() %>%
#'   apply_cutpoints("evenson_children")
#'
#'  # With additional arguments passed to the weartime function
#'  agd <- read_agd(file = "test.agd") %>%
#'   apply_weartime(fun = apply_troiano, min_period_len = 30) %>%
#'   apply_cutpoints("evenson_children")
#' @export
apply_weartime <- function(agdb, fun = apply_troiano, ...){
  non_wear <- agdb %>%
    collapse_epochs(60) %>%
    fun(...)

  wear <- complement_periods(non_wear, agdb, period_start, period_end)
  wear <- combine_epochs_periods(agdb, wear, period_start, period_end)
  wear$wear <- ifelse(is.na(wear$period_id), 0L, 1L)
  select(wear, -period_id)
}
