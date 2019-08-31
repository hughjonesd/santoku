

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