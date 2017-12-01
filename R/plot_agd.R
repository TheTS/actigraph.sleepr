#' Plot activity values
#'
#' Plot a time series of activity values (by default, the counts on the vertical axis \emph{axis1}).
#' @param agdb A \code{tibble} (\code{tbl}) of activity data (at least) an \code{epochlength} attribute.
#' @param var The activity variable (unquoted) to plot on the y-axis.
#' @param color Activity line color.
#' @param nrow,ncol Number of rows and columns. Relevant only if the activity data is grouped.
#' @examples
#' library("dplyr")
#' data("gtxplus1day")
#' data <- gtxplus1day %>%
#'   collapse_epochs(60) %>%
#'   apply_cole_kripke()
#'
#' plot_activity(data, axis1, color = "gray")
#' plot_activity(data, axis1, color = "sleep")
#' @export
plot_activity <- function(agdb, var, color = "black",
                          nrow = NULL, ncol = NULL) {
  var <- enquo(var)
  if (color %in% names(agdb)) {
    p <- ggplot(agdb, aes_string("timestamp", quo_text(var),
                                 color = color, fill = color)) +
      geom_col()
  } else {
    p <- ggplot(agdb, aes_string("timestamp", quo_text(var))) +
      geom_col(color = color, fill = color)
  }
  if (is.grouped_df(agdb)) {
    p <- p +
      facet_wrap(as.character(groups(agdb)),
                 nrow = nrow, ncol = ncol,
                 scales = "free_x")
  }
  p + theme_light() + labs(x = "time")
}
#' Plot activity and periods
#'
#' Plot activity values as a time series and periods as polygons.
#' @inheritParams plot_activity
#' @param periods A \code{tibble} of periods with at least two columns \code{start_var} and \code{end_var}.
#' @param act_var The activity variable (unquoted) to plot on the y-axis.
#' @param start_var The variable (unquoted) which indicates when the time periods start.
#' @param end_var The variable (unquoted) which indicates when the time periods end.
#' @param fill Polygon fill color.
#' @examples
#' library("dplyr")
#' library("lubridate")
#' data("gtxplus1day")
#'
#' # Detect sleep periods using Sadeh as the sleep/awake algorithm
#' # and Tudor-Locke as the sleep period algorithm
#' periods_sleep <- gtxplus1day %>%
#'   collapse_epochs(60) %>%
#'   apply_cole_kripke() %>%
#'   apply_tudor_locke(min_sleep_period = 60)
#'
#' plot_activity_period(gtxplus1day, periods_sleep, axis1,
#'                      in_bed_time, out_bed_time)
#' @export
plot_activity_period <- function(agdb, periods, act_var,
                                 start_var, end_var,
                                 color = "black", fill = "#525252",
                                 ncol = NULL, nrow = NULL) {
  act_var <- enquo(act_var)
  start_var <- enquo(start_var)
  end_var <- enquo(end_var)
  plot_activity(agdb, !!act_var, color = color,
                nrow = nrow, ncol = ncol) +
    geom_rect(data = periods,
              aes_string(xmin = quo_text(start_var), ymin = 0,
                         xmax = quo_text(end_var), ymax = Inf),
              inherit.aes = FALSE,
              fill = fill, alpha = 0.2)
}

#' Plot activity summaries
#'
#' Plot a grouped timeseries of activity values. The plot is organised (faceted) by date and coloured based on cutpoint categories.
#' @param agdb_summary A \code{tibble} (\code{tbl}) of activity data obtained from  \code{\link{summarise_agd}}.
#' @param start_date The first day of data to plot. Default is \code{NULL} (plots all data).
#' @param end_date The last day of data to plot. efault is \code{NULL} (plots all data).
#' @param colours Colours are chosen by default, but a vector of custom colours can be passed in. The vector length should be equal to cutpoint categories + 1 (for non-wear time).
#' @examples
#' data("gtxplus1day")
#'
#' agdb_summary <- gtxplus1day %>%
#'   apply_weartime() %>%
#'   apply_cutpoints("evenson_children") %>%
#'   summarise_agd(time = "1 hour")
#'
#' plot_activity_summary(agdb_summary)
#'
#' # Plot selected days only
#' plot_activity_summary(agdb_summary, start_date = '2012-06-27',
#'                             end_date = '2012-06-28')
#'
#' # Plot with custom colours
#' plot_activity_summary(agdb_summary, colours = c(2:6))
#' @export
plot_activity_summary <- function(agdb_summary,
                                  start_date = NULL,
                                  end_date = NULL,
                                  colours = NULL) {

  cols <- c("non_wear", rev(tolower(attr(agdb_summary, "intensity_categories"))))

  data <- agdb_summary %>%
    select(c("timestamp", cols)) %>%
    gather("activity", "minutes", -.data$timestamp) %>%
    arrange(.data$timestamp) %>%
    mutate(date = as.Date.factor(.data$timestamp)) %>%
    mutate(date = paste(.data$date, "\n", weekdays(.data$date)),
           time = strftime(.data$timestamp, format = "%H:%M:%S"),
           activity = factor(.data$activity, levels = cols, labels = cols))

  if (!is.null(start_date) & !is.null(end_date)) {
    start_date <- as.Date(start_date)
    end_date <- as.Date(end_date)
    data <- data %>% filter((.data$date >= start_date) & (.data$date <= end_date))
  }

  if (is.null(colours))
    colours <- c("cornsilk2", "firebrick2", "orange", "lightgoldenrod2",
                 "royalblue1", 'lightblue', "skyblue", 2:length(cols))

  ggplot(data, aes_string(x = "time", y = "minutes", fill = "activity")) +
    geom_col() +
    facet_grid(date~., switch = "both") +
    labs(title = paste("Name: ", attr(agdb_summary, "subjectname")),
         x = "", y = "", fill = "") +
    theme(axis.text.x = element_text(angle = 90),
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      strip.text.y = element_text(face = "bold.italic"),
      legend.position = "right") +
    scale_fill_manual(values = colours[1:length(cols)])
}
