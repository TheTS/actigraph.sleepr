#' Append a weartime column to an activity data frame
#'
#' This function wraps either the \code{\link{apply_choi}} or \code{\link{apply_troiano}} functions to calculate weartime, and appends a \emph{'wear'} column to the input \code{tibble}.
#' @param agdb A \code{tibble} of activity data optained from \code{\link{read_agd}}.
#' @param fun The weartime function to employ (either \code{apply_troiano} or \code{apply_choi}). The default is \code{apply_troiano}.
#' @param ... Additional parameters passed to the weartime function if the default parameters are not suitable.
#' @return The input \code{tibble} of activity data with an additional \emph{'wear'} column.
#' @seealso \code{\link{apply_choi}}, \code{\link{apply_troiano}}
#' @examples
#'  data("gtxplus1day")
#'
#'  agd <- gtxplus1day %>%
#'   apply_weartime() %>%
#'   apply_cutpoints("evenson_children")
#'
#'  # With additional arguments passed to the weartime function
#'  agd <- gtxplus1day %>%
#'   apply_weartime(fun = apply_troiano, min_period_len = 30) %>%
#'   apply_cutpoints("evenson_children")
#' @export
apply_weartime <- function(agdb, fun = apply_troiano, ...){
  non_wear <- agdb %>%
    collapse_epochs(60) %>%
    fun(...)

  agdb %>%
    combine_epochs_periods(non_wear, non_wear$period_start, non_wear$period_end) %>%
    mutate(wear = ifelse(is.na(period_id), 1L, 0L)) %>% #TODO interp
    select_(.dots = '-period_id')
}
