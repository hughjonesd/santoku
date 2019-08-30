

extend_breaks <- function (breaks) {
  if (length(breaks) == 0 || breaks[1] > -Inf) {
    left <- attr(breaks, "left")
    breaks <- c(-Inf, breaks) # deletes attributes inc class
    breaks <- brk_manual(breaks, c(TRUE, left))
  }

  if (breaks[length(breaks)] < Inf) {
    left <- attr(breaks, "left")
    breaks <- c(breaks, Inf) # deletes attributes inc class
    breaks <- brk_manual(breaks, c(left, FALSE))
  }

  return(breaks)
}


singletons <- function (breaks) {
  dv <- diff(breaks)
  dv == 0L | is.nan(dv) # is.nan could be from Inf, Inf
}


old_categorize <- function (x, breaks) {
  stopifnot(is.breaks(breaks))
  stopifnot(is.numeric(x))

  result <- rep(NA_integer_, length(x))

  left <- attr(breaks, "left")
  for (i in seq(1, length(breaks) - 1)) {
    lb <- breaks[i]
    rb <- breaks[i + 1]
    lower_closed <- left[i]
    upper_closed <- ! left[i + 1]
    above_lower <- if(lower_closed) lb <= x else lb < x
    below_upper <- if(upper_closed) x <= rb else x < rb
    within <- above_lower & below_upper
    # ! is.na ensures NAs stay as NA
    result[within & ! is.na(within)] <- i
  }

  return(result)
}

