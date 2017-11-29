#' Apply "cutpoints" to physical activity data
#'
#' Each epoch is assigned to an intensity category based on a set of "cutpoints".
#' @param agdb A \code{tibble} of activity data optained from \code{\link{read_agd}}.
#' @param cutpoints A set of cutpoints to use. This can one of several predefined strings, or a custom list (see below).
#' @param use_magnitude Logical. If true, the vector magnitude is used to measure activity intensity; otherwise the axis1 value is used. The default is \code{FALSE}. Note that several predifined cutpoints will override the default (e.g. 'freedson_adult_vm').
#' @param custom_cutpoints A list of custom cutpoints. This must be a list containing two vectors. The first contains count threshold ranges (must be an even number), and the second contains a list of category names. These names are used as column names when using \code{\link{summarise_agd}}.See below for an example.
#' @details All cutpoint values must be at the counts-per-minute (CPM) scale (60 sec epoch). However, you can still apply a set of cutpoints to data that has an \code{epochlength} of less that 60 seconds (the function adjusts the CPM values based on the \code{epochlength} attribute). The six sets of predefined cutpoints are:
#' \itemize{\item freedson_adult (1998)
#'          \item freedson_adult_vm (2011)
#'          \item freedson_children (2005)
#'          \item evenson_children (2008)
#'          \item mattocks_children (2007)
#'          \item puyau_children (2002)
#'          }
#' @return The input \code{tibble} of activity data with an additional \emph{'activity'} column. The cutpoint information is appended to the tibble attributes.
#' @references Freedson, P. S., et al. (1998). Calibration of the Computer Science and Applications, Inc. accelerometer. \emph{Medicine and Science in Sports and Exercise} 30(5): 777-781.
#' @references Sasaki, J. E., et al. (2011). Validation and comparison of ActiGraph activity monitors. \emph{Journal of Science and Medicine in Sport} 14(5): 411-416.
#' @references Freedson, P., et al. (2005). Calibration of Accelerometer Output for Children. \emph{Medicine & Science in Sports & Exercise} 37(11): S523-S530.
#' @references Evenson, K. R., et al. (2008). Calibration of two objective measures of physical activity for children. \emph{Journal of sports sciences} 24(14): 1557-1565.
#' @references Mattocks, C., et al. (2007). Calibration of an accelerometer during free‐living activities in children. \emph{Pediatric Obesity} 2(4): 218-226.
#' @references Puyau, M. R., et al. (2002). Validation and calibration of physical activity monitors in children. \emph{Obesity} 10(3): 150-157.
#' @examples
#' # Predefined cutpoints
#' agd <- read_agd(file = "test.agd") %>%
#'   apply_cutpoints(cutpoints = "evenson_child")
#'
#' # Custom cutpoints
#' my_cutpoints <- list(c(0, 100, 101, 1499, 1500, 3999, 4000, Inf),
#'                      c("sedentary", "light", "moderate", "vigorous")))
#'
#' agd <- read_agd(file = "test.agd") %>%
#'   apply_cutpoints(cutpoints = "custom",
#'                   custom_cutpoints = my_cutpoints)
#' @export
apply_cutpoints <- function(agdb,
                            cutpoints,
                            use_magnitude = FALSE,
                            custom_cutpoints = NULL) {

  cutpoints <- tolower(cutpoints)

  cutpoints_list <- c("freedson_adult", "freedson_adult_vm", "freedson_children",
  "evenson_children", "mattocks_children", "puyau_children", "custom")

  check_args_cutpoints(agdb, cutpoints, use_magnitude, custom_cutpoints, cutpoints_list)

  if (use_magnitude | cutpoints %in% c("freedson_adult_vm")) {
    agdb <- add_magnitude(agdb)
    var <- 'magnitude'
  } else
    var <- 'axis1'

  if (cutpoints == "freedson_adult")
    cp <- list(thresholds=c(0, 99, 100, 1951, 1952, 5724, 5725, Inf),
               categories=c("sedentary", "light", "moderate", "vigorous"))
  else if (cutpoints == "freedson_adult_vm")
    cp <- list(thresholds=c(0, 2690, 2691, 6166, 6167, 9642, 9643, Inf),
               categories=c("sedentary", "light", "moderate", "vigorous"))
  else if (cutpoints == "freedson_children")
    cp <- list(thresholds=c(0, 149, 150, 499, 500, 3999, 4000, 7599, 7600, Inf),
               categories=c("sedentary", "light", "moderate", "vigorous", "very_vigorous"))
  else if (cutpoints == "evenson_children")
    cp <- list(thresholds=c(0, 100, 101, 2295, 2296, 4011, 4012, Inf),
              categories=c("sedentary", "light", "moderate", "vigorous"))
  else if (cutpoints == "mattocks_children")
    cp <- list(thresholds=c(0, 100, 101, 3580, 3581, 6129, 6130, Inf),
               categories=c("sedentary", "light", "moderate", "vigorous"))
  else if (cutpoints == "puyau_children")
    cp <- list(thresholds=c(0, 799, 800, 3199, 3200, 8199, 8200, Inf),
               categories=c("sedentary", "light", "moderate", "vigorous"))
  else if (cutpoints == "custom")
    cp <- custom_cutpoints

  cp[[1]] <- matrix(cp[[1]], ncol = 2, byrow = TRUE)
  cp[[1]] <- apply(cp[[1]], c(1, 2), function(x) x / (60 / attr(agdb, "epochlength")))

  agdb$activity <- NA

  for (i in 1:nrow(cp[[1]])) {
    agdb$activity <- ifelse((agdb[, var] >= cp[[1]][i, 1]) & (agdb[,var] <= cp[[1]][i, 2]), i, agdb$activity)
  }

  agdb$activity <- as.integer(agdb$activity)

  agdb <- structure(agdb,
            intensity_cutpoints = cutpoints,
            intensity_thresholds = cp[[1]],
            intensity_categories = cp[[2]],
            intensity_magnitude = use_magnitude)

  return(agdb)
}
