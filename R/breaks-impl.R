
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
create_breaks <- function (obj, left) {
  if (anyNA(obj)) stop("`x` contained NAs")
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

  break_labels <- attr(obj, "break_labels") %||%
        unique_truncation(as.numeric(obj))

  structure(obj, left = left, break_labels = break_labels, class = "breaks")
}


create_lr_breaks <- function (obj, left, close_end) {
  assert_that(is.flag(left), is.flag(close_end))
  left_vec <- rep(left, length(obj))

  st <- singletons(obj)
  left_vec[which(st)]     <- TRUE
  left_vec[which(st) + 1] <- FALSE

  if (left && close_end) left_vec[length(left_vec)] <- FALSE
  if (! left && close_end) left_vec[1] <- TRUE

  create_breaks(obj, left_vec)
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
    # this needs to be repeated, because we may have added a break in the stanza
    # above:
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
