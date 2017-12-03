#' Summarises activity data over a specified time period
#'
#' Summarises activity data over a time period.
#' @param agdb A \code{tibble} of activity data passed through \code{\link{read_agd}}, \code{\link{apply_weartime}}, and \code{\link{apply_cutpoints}}. This needs to contain an \emph{'activity'} and \emph{'wear'} column.
#' @param time The time interval that data is summarised. Valid options inclide \code{"sec", "min", "hour", "day"}. See \code{\link{cut.POSIXt}} for more details. The default time is \code{"1 hour"}.
#' @details The data are scaled to minutes (e.g. minutes of light intensity activity per hour) where appropriate. If the input \code{agdb} contains incline and steps data, this will also be summarised.
#' @return A \code{tibble} of summary activity data where rows correspond to the chosen \code{time} interval.
#' @examples
#' data("gtxplus1day")
#'
#' agd <- gtxplus1day %>%
#'   apply_weartime() %>%
#'   apply_cutpoints("freedson_children") %>%
#'   summarise_agd(time = "1 hour")
#'
#' @export
summarise_agd <- function(agdb, time = "1 hour") {

  check_args_summary(agdb, c("activity", "wear"))

  cols <- tolower(attr(agdb, "intensity_categories"))
  agdb$non_wear <- ifelse(agdb$wear == 0, attr(agdb, "epochlength"), 0)
  agdb$wear <- ifelse(agdb$wear == 1, attr(agdb, "epochlength"), 0)

  for (i in 1:length(cols)) {
    agdb[,cols[i]] <- ifelse(agdb$activity == i & agdb$non_wear==0, attr(agdb, "epochlength"), 0)
  }

  cols <- intersect(c("timestamp", "steps", "wear", "non_wear",
    cols, grep('incline', names(agdb), value = TRUE)), names(agdb))

  agdb %>%
    select(cols) %>%
    mutate_if(is.numeric, as.integer) %>%
    mutate_at(vars(-matches('steps'), -.data$timestamp), funs(./60)) %>%
    group_by(timestamp = cut(.data$timestamp, time)) %>%
    summarise_all(funs(sum(.))) %>%
    mutate_if(is.numeric, funs(round(., 2))) %>%
    mutate_if(is.factor, as.POSIXct)
}
