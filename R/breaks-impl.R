
# implementation for breaks class


#' Create a breaks object
#'
#' @param obj A sorted vector or a `breaks` object.
#' @param left A logical vector, same length as `obj`.
#'
#' @return A breaks object
#'
#' @noRd
#'
#'
create_breaks <- function (obj, left) UseMethod("create_breaks")


create_breaks.Date <- function (obj, left) {
  obj <- as.POSIXct(obj)
  create_breaks(obj, left)
}


create_breaks.POSIXct <- function (obj, left) {
  obj <- as.numeric(obj)
  create_breaks(obj, left)
}


create_breaks.default <- function (obj, left) {
  if (anyNA(obj)) stop("`x` contained NAs")
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


empty_breaks <- function () {
  create_breaks(c(-Inf, Inf), c(TRUE, FALSE))
}


NEITHER <- as.raw(0)
LEFT    <- as.raw(1)
RIGHT   <- as.raw(2)
BOTH <- LEFT | RIGHT


needs_extend <- function (breaks, x) {
  if (length(breaks) < 2L) return(BOTH)
  needs <- NEITHER

  left <- attr(breaks, "left")
  min_x <- quiet_min(x)
  max_x <- quiet_max(x)
  if (min_x < min(breaks) || (! left[1] && min_x == min(breaks))) {
    needs <- needs | LEFT
  }
  if (max_x > max(breaks) || (left[length(left)] && max_x == max(breaks))) {
    needs <- needs | RIGHT
  }

  return(needs)
}


maybe_extend <- function (breaks, x, extend) {
  extend_flags <- if (is.null(extend)) {
    needs_extend(breaks, x)
  } else if (extend) BOTH else NEITHER

  # chooses either min(x) or -Inf
  choose_endpoint <- function (x, alt, extend, fn) {
    if (! is.null(extend)) return(alt)
    ep <- fn(x)
    if (is.finite(ep)) return(ep) else return(alt)
  }

  if ((extend_flags & LEFT) > 0) {
    left <- attr(breaks, "left")
    # we add a break if the first break is above -Inf *or* if it is (-Inf. ...
    if (length(breaks) == 0 || breaks[1] > -Inf || ! left[1]) {
      leftmost_break <- choose_endpoint(x, -Inf, extend, fn = quiet_min)
      breaks <- c(leftmost_break, breaks) # deletes attributes inc class
      breaks <- create_breaks(breaks, c(TRUE, left))
    }
  }

  if ((extend_flags & RIGHT) > 0) {
    left <- attr(breaks, "left")
    # add a break if the last break is finite, or if it is ..., +Inf)
    if (breaks[length(breaks)] < Inf || left[length(left)]) {
      rightmost_break <- choose_endpoint(x, Inf, extend, fn = quiet_max)
      breaks <- c(breaks, rightmost_break) # deletes attributes inc class
      breaks <- create_breaks(breaks, c(left, FALSE))
    }
  }

  return(breaks)
}

#' A hack for brk_left/right.function
#'
#' Ensures extended breaks aren't affected
#'
#' @param breaks Breaks object
#' @param extend Passed in from chop
#' @param needs_ex Calculated earlier: did breaks need extending
#' @param orig_left Leftness before create_left/right_breaks was called
#' @return Fixed breaks
#'
#' @noRd
#'
fix_extended_breaks <- function (breaks, extend, needs_ex, orig_left) {
  will_ex_left  <- isTRUE(extend) || (is.null(extend) && (needs_ex & LEFT) > 0)
  will_ex_right <- isTRUE(extend) || (is.null(extend) && (needs_ex & RIGHT) > 0)

  if (will_ex_left) attr(breaks, "left")[2] <- orig_left[2]
  penult <- length(breaks) - 1
  if (will_ex_right) attr(breaks, "left")[penult] <- orig_left[penult]

  breaks
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

  for (digits in seq(4L, 22L)) {
    res <- formatC(num, digits = digits, width = -1)
    if (anyDuplicated(res[want_unique]) == 0L) break
  }

  if (anyDuplicated(res[want_unique]) > 0L) {
    stop("Could not format breaks to avoid duplicates")
  }

  return(res)
}
