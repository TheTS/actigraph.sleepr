#' Append a weartime column to an activity data frame
#'
#' This function wraps either the \code{\link{apply_choi}} or \code{\link{apply_troiano}} functions to calculate weartime, and appends a \emph{'wear'} column to the input \code{tibble}.
#' @param agdb A \code{tibble} of activity data obtained from \code{\link{read_agd}}.
#' @param fun The weartime function to employ (either \code{apply_troiano} or \code{apply_choi}). The default is \code{apply_troiano}.
#' @param ... Additional arguments passed to the weartime function if the default arguments are not suitable.
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
    fun(...)

  agdb %>%
    combine_epochs_periods(non_wear, non_wear$period_start, non_wear$period_end) %>%
    mutate(wear = ifelse(is.na(period_id), 1L, 0L)) %>%
    select(-period_id)
}

#' Apply a weartime filter to an activity data frame
#'
#' This function takes a day-level summary as input, and will remove days if they do not meet a weartime criteria.
#' Generally in physical activity research, days are excluded if the accelerometer is not worn for a sufficient period of time.
#' @param agdb A day-level summary of activity data obtained from \code{\link{summarise_agd}} with the argument \code{time = "1 day"}.
#' @param hours The minimum required hours of weartime for a day to be considered valid.
#' @param days The minimum number of valid days for the dataset to be valid.
#' @param hours_we Same as \code{hours} except for weekend days. Default is same as \code{hours}.
#' @param days_we The minimum number of valid weekend days required for the dataset to be valid. Default is 0.
#' @details The \code{agdb} argument must be obtained from the \code{summarise_agd(time = "1 day")} function.
#' @details The \code{days} argument is inclusive of \code{days_we}. You can think of \code{(days = 5, days_we = 1)} as \emph{"Five days in total are required, one of which must be a weekend day"}.
#' @return The input \code{tibble} of activity data only containing rows (days) that meet the weartime criteria.
#' @seealso \code{\link{summarise_agd}}
#' @examples
#'  data("gtxplus1day")
#'
#'  summary <- gtxplus1day %>%
#'   apply_weartime() %>%
#'   apply_cutpoints("evenson_children") %>%
#'   summarise_agd("1 day")
#'
#'   summary %>% apply_weartime_filter(hours = 7, days = 3)
#'
#'   # Example using the IPEN-Adolescent criteria
#'   summary %>% apply_weartime_filter(hours = 10,
#'                                     days = 5,
#'                                     hours_we = 8,
#'                                     days_we = 1)
#'
#' @export
apply_weartime_filter <- function(agdb, hours , days,
                                  hours_we = hours, days_we = 0) {

  agdb %>%
    mutate(pid = attr(., "subjectname"),
           wend = wday(timestamp, week_start = 1) > 5) %>%
    filter((wear > (hours * 60) & !wend) |
             (wear > (hours_we * 60) & wend)) %>%
    group_by(pid) %>%
    filter((length(pid) >= days) &
             (sum(wend) >= days_we)) %>%
    select(-wend)
}
