#' Read acceleration and timestamp from a log.bin file
#'
#' Note, this passes a raw vector to c++ for parsing
#'
#' @param fid A file connection able to read binary
#' @param accScale Scale factor to return acceleration in g
read_acceleration <- function(fid, accScale) {
  x <- 1
  data <- list()
  time <- list()

  # First byte is the seperator
  while (length(readChar(fid, 1, useBytes = TRUE)) > 0) {

    # Record type - 1 byte
    type <- readBin(fid, integer(), size = 1)

    # Unix timestamp - 4 bytes
    ts <- readBin(fid, integer(), size = 4)

    # Size of payload (in bytes) - 2 bytes
    size <- readBin(fid, integer(), size = 2)

    # Type 0 is ACTIVITY
    if (type == 0L) {
      if (x==1) prevTs <- ts - 1

      # For missing samples - impute last yxz values
      if (ts - prevTs != 1)
        while (ts - prevTs != 1) {
          data[[x]] <- data[[x-1]]
          prevTs <- prevTs + 1
          time[[x]] <- prevTs
          x <- x + 1
        }

      data[[x]] <- read_activityC(readBin(fid, raw(), size), accScale)
      time[[x]] <- ts
      prevTs <- ts
      x <- x + 1

    } else {
      readChar(fid, size, useBytes = TRUE)
    }
    # Checksum - 1 byte
    readBin(fid, integer(), size = 1)
  }

  list(time = unlist(time), data = matrix(unlist(data), ncol = 3, byrow = TRUE))
}

#' Read the info.txt file inside a .gt3x
#' This contains key items to help parse activity data
#'
#' @param fid A file connection to the info.txt
read_info <- function(fid) {

  # Helper to convert .NET ticks to timestamp
  ticks_ts <- function(ticks) {
    as.POSIXct(ticks / 1e7, origin = '0001-01-01', tz = 'GMT')
  }

  info_file <- data.frame(key = readLines(fid)) %>%
    separate(key, c("key", "value"), ": ") %>%
    spread(key, value)
  info_file <- info_file %>%
    rename_all(funs(make.names(tolower(names(info_file))))) %>%
    mutate_at(vars(-device.type, -firmware, -serial.number,
                   -subject.name, -timezone), as.numeric) %>%
    mutate_at(vars(download.date, last.sample.time,
                   start.date, stop.date), ticks_ts)
}

#' Read raw data from .gt3x
#'
#' @param fileName Path to .gt3x file
#'
#' @export
read_gt3x <- function(fileName){

  info.con <- unz(fileName, "info.txt")
  log.con <- unz(fileName, "log.bin", open = "rb")

  info <- read_info(info.con)
  close(info.con)

  data <- read_acceleration(log.con, info$acceleration.scale)
  close(log.con)

  # Create 13-digit unix timestamp to preserve milliseconds
  time <- list()
  for (i in 1:(length(data$time)-1)) {
    time[[i]] <- seq(data$time[i] * 1e3, by = 1e3 / info$sample.rate,
                     length.out = info$sample.rate)
  }

  data <- data.frame(unlist(time), data$data[,c(2, 1, 3)])
  names(data) <- c("timestamp", "x", "y", "z")

  return(invisible(list(header = info, data = data)))
}
