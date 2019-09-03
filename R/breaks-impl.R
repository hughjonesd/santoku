
# implementation for breaks class


#' Create a breaks object
#'
#' @param obj A sorted vector or a `breaks` object.
#' @param left A logical vector, same length as `vec`.
#'
#' @return A breaks object
#'
#' @noRd
#'
create_breaks <- function (obj, left) {
  if (anyNA(obj)) stop("`vec` contained NAs")
  stopifnot(is.numeric(obj))
  stopifnot(all(obj == sort(obj)))
  stopifnot(is.logical(left))
  stopifnot(length(left) == length(obj))

  singletons <- singletons(obj)
  if (any(singletons[-1] & singletons[-length(singletons)])) {
    stop("`x` contained more than two consecutive equal values")
  }

  l_singletons <- c(singletons, FALSE)
  r_singletons <- c(FALSE, singletons)
  stopifnot(all(left[l_singletons]))
  stopifnot(all(! left[r_singletons]))

  break_labels <- attr(obj, "break_labels") %||% unique_truncation(obj)

  structure(obj, left = left, break_labels = break_labels, class = "breaks")
}


create_left_breaks <- function (obj, close_end = TRUE) {
  left <- rep(TRUE, length(obj))

  st <- singletons(obj)
  left[which(st) + 1] <- FALSE

  if (close_end) left[length(left)] <- FALSE

  create_breaks(obj, left)
}


create_right_breaks <- function (obj, close_end = TRUE) {
  left <- rep(FALSE, length(obj))

  st <- singletons(obj)
  left[which(st)] <- TRUE

  if (close_end) left[1L] <- TRUE

  create_breaks(obj, left)
}


needs_extend <- function (breaks, x) {
  suppressWarnings(
          min(x, na.rm = TRUE) < min(breaks) ||
          max(x, na.rm = TRUE) > max(breaks)
        )
}


maybe_extend <- function (breaks, x, extend) {
  extend <- extend %||% needs_extend(breaks, x)
  if (extend) breaks <- extend_breaks(breaks)

  return(breaks)
}


extend_breaks <- function (breaks) {
  if (length(breaks) == 0 || breaks[1] > -Inf) {
    left <- attr(breaks, "left")
    breaks <- c(-Inf, breaks) # deletes attributes inc class
    breaks <- create_breaks(breaks, c(TRUE, left))
  }

  if (breaks[length(breaks)] < Inf) {
    left <- attr(breaks, "left")
    breaks <- c(breaks, Inf) # deletes attributes inc class
    breaks <- create_breaks(breaks, c(left, FALSE))
  }

  return(breaks)
}


#' Truncates `num` to look nice, while preserving uniqueness
#'
#' @param num
#'
#' @return A character vector
#'
#' @noRd
#'
unique_truncation <- function (num) {
  want_unique <- ! duplicated(num) # "real" duplicates are allowed!
  # we keep the first of each duplicate set.
  res <- format(num, trim = TRUE)
  if (! anyDuplicated(res[want_unique])) return(res)

  min_digits <- min(getOption("digits", 7), 21)
  for (digits in seq(min_digits, 22L)) {
    res <- formatC(num, digits = digits, width = -1)
    if (anyDuplicated(res[want_unique]) == 0L) break
  }

  if (anyDuplicated(res[want_unique]) > 0L) {
    stop("Could not format breaks to avoid duplicates")
  }

  return(res)
}