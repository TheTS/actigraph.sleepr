#' Re-integrate epochs
#'
#' Collapse post-filtered activity counts into larger epoch "buckets".
#' @param agdb A \code{tibble} (\code{tbl}) of activity data (at least) an \code{epochlength} attribute.
#' @param epoch_len_out Output (longer) epoch length in seconds, must be exact multiple of the input epoch length. Currently only \code{epoch_len_out} = 60 is supported.
#' @param use_incomplete logical. Set to \code{TRUE} to follow ActiLife convention, which collapses all observed epochs even if they are incomplete.
#' @return A \code{tibble} (\code{tbl}) of activity data collapsed into one-minute epochs.
#' @references ActiLife 6 User's Manual by the ActiGraph Software Department. 04/03/2012.
#' @details
#' Activity counts cannot be reintegrated into shorter epochs, e.g., 60s -> 10s. Currently, \code{collapse_epochs} integrates into 60s epochs only. This is not general but is sufficient for sleep analysis because the standard Sadeh and Cole-Kripke sleep algorithms were developed for 60s epoch data.
#'
#' Suppose we want to collapse from 15 to 60 seconds. A complete 60s epoch consists of four 15s epochs: 00, 15, 45 and 60. However, the first and last epochs would be incomplete if the device started/stopped collecting data mid-minute. ActiLife 6 uses these epochs anyway. For example, if only 45 and 60 are available for the first minute, then ActiLife will aggregate across these two epochs only. This is a reasonable approach to sleep analysis with the Sadeh and the Cole-Kripke algorithms which pad the beginning and the end of the time series with zeros anyway.
#' @examples
#' library("dplyr")
#' data("gtxplus1day")
#'
#' gtxplus1day %>%
#'   collapse_epochs(60)
#' @export

collapse_epochs <- function(agdb, epoch_len_out, use_incomplete = TRUE) {

  check_args_collapse_method(agdb, epoch_len_out)

  collapse_factor <- (epoch_len_out / attr(agdb, "epochlength"))

  if (collapse_factor == 1) return(agdb)

  # TODO: a more general approach to collapsing
  # might use the findInterval function
  # though care must be taken with "incomplete"
  # epochs at the start/end of the time series

  agdb <- agdb %>%
    do(collapse_epochs_(., epoch_len_out, collapse_factor, use_incomplete))

  attr(agdb, "epochlength") <- epoch_len_out
  attr(agdb, "epochcount") <- nrow(agdb)
  agdb
}

collapse_epochs_ <- function(data, epoch_len_out, collapse_factor, use_incomplete) {

  # Exclude lux which is summarised by `floor(mean(lux))`
  selected <- intersect(colnames(data),
                        c("axis1", "axis2", "axis3", "steps",
                          "inclineoff", "inclinestanding",
                          "inclinesitting", "inclinelying"))

  floor_factor <- ifelse(epoch_len_out > 60,
                            paste(epoch_len_out/60, "min"),
                            paste(epoch_len_out, "sec"))

  data <- data %>%
    select_at(vars("timestamp", selected)) %>%
    mutate(timestamp = floor_date(timestamp, floor_factor), n = 1L) %>%
    group_by(timestamp) %>%
    summarise_all(sum)

  if (!use_incomplete) {
    data <- data %>% filter(n == collapse_factor)
  }

  data %>% select(-n)
}
