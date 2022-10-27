

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
  if (anyNA(obj)) stop("breaks contained NAs")
  stopifnot(all(obj == sort(obj)))
  stopifnot(is.logical(left))
  stopifnot(length(left) == length(obj))

  singletons <- singletons(obj)
  if (any(singletons[-1] & singletons[-length(singletons)])) {
    stop("breaks contained more than two consecutive equal values")
  }

  l_singletons <- c(singletons, FALSE)
  r_singletons <- c(FALSE, singletons)
  stopifnot(all(left[l_singletons]))
  stopifnot(all(! left[r_singletons]))

  break_classes <- class(obj)
  if (! inherits(obj, "breaks")) break_classes <- c("breaks", break_classes)

  structure(obj, left = left, class = break_classes)
}


create_extended_breaks <- function (obj, x, extend, left, close_end) {
  brks <- create_lr_breaks(obj = obj, left = left)
  extend_and_close(breaks = brks, x = x, extend = extend, left = left,
                     close_end = close_end)
}


create_lr_breaks <- function (obj, left) {
  assert_that(is.flag(left))
  left_vec <- rep(left, length(obj))

  st <- singletons(obj)
  left_vec[which(st)]     <- TRUE
  left_vec[which(st) + 1] <- FALSE

  create_breaks(obj, left_vec)
}


empty_breaks <- function () {
  create_breaks(c(-Inf, Inf), c(TRUE, FALSE))
}


#' Extend `breaks` to the left or right according to `extend` parameter,
#' and close end according to `close_end` parameter
#'
#' @param breaks,x,extend,left,close_end All passed in from `chop()` via
#' a `brk_` inner function
#'
#' @return A `breaks` object.
#' @noRd
extend_and_close <- function (breaks, x, extend, left, close_end) {
  extend_flags <- needs_extend(breaks, x, extend, left, close_end)

  if ((extend_flags & LEFT) > 0) {
    breaks <- extend_endpoint_left(breaks, x, extend)
  }
  if ((extend_flags & RIGHT) > 0) {
    breaks <- extend_endpoint_right(breaks, x, extend)
  }

  breaks <- maybe_close_end(breaks, left = left, close_end = close_end)

  return(breaks)
}



NEITHER <- as.raw(0)
LEFT    <- as.raw(1)
RIGHT   <- as.raw(2)
BOTH <- LEFT | RIGHT


#' Reports if `breaks` will/should be extended.
#'
#' @param breaks A breaks object
#' @param x Data
#' @param extend,left,close_end Parameters passed into `chop`
#'
#' @return Returns LEFT or RIGHT or BOTH only if `breaks` *will*/*must* be
#' extended i.e. gain an extra break, on the respective sides.
#'
#' @details
#' If `extend` is `FALSE`, always returns `NEITHER`. If `breaks` is length
#' zero, always returns `BOTH`.
#'
#' If extend is `NULL` then `left` and `close_end` are taken into account.
#'
#' To test whether `breaks` will be extended on either side, use
#' `(needs & LEFT) > 0` or `(needs & RIGHT) > 0`.
#'
#' @noRd
needs_extend <- function (breaks, x, extend, left, close_end) {
  if (! is.null(extend) && ! extend) return(NEITHER)
  if (length(breaks) < 1L) return(BOTH)

  needs <- NEITHER

  # temporarily close the breaks, to see if unextended closed breaks need
  # extension
  breaks <- maybe_close_end(breaks, left = left, close_end = close_end)
  left_vec <- attr(breaks, "left")

  res <- santoku_cast_common(x, unclass_breaks(breaks))
  x <- res[[1]]
  breaks <- res[[2]]

  min_x <- quiet_min(x)
  max_x <- quiet_max(x)

  if (
          isTRUE(extend)      ||
          min_x < min(breaks) ||
          (! left_vec[1] && min_x == min(breaks))
        ) {
    # "... and if ..." the first break is finite, or will be left-open
    if (is_gt_minus_inf(breaks[1]) || ! left_vec[1]) {
      needs <- needs | LEFT
    }
  }

  if (
          isTRUE(extend)      ||
          max_x > max(breaks) ||
          (left_vec[length(left_vec)] && max_x == max(breaks))
        ) {
    # "... and if ..." the last break is finite, or will be left-closed (right-open)
    if (is_lt_inf(breaks[length(breaks)]) || left_vec[length(left_vec)]) {
      needs <- needs | RIGHT
    }
  }

  return(needs)
}


#' Close end of breaks if close_end is TRUE
#'
#' This never adds a break, it just changes the breaks' `left` attribute.
#' It leaves everything unchanged if `close_end` is `FALSE`.
#'
#' @param breaks,left,close_end Passed in from a `brk_` function
#'
#' @return New breaks object, with the end perhaps closed
#' @noRd
maybe_close_end <- function (breaks, left, close_end) {
  if (! close_end) return(breaks)

  left_vec <- attr(breaks, "left")
  if (left) {
    left_vec[length(left_vec)] <- FALSE
  } else {
    left_vec[1] <- TRUE
  }
  attr(breaks, "left") <- left_vec

  return(breaks)
}


#' Extend the left endpoint of a breaks object according to user parameters
#'
#' This always adds a new break, which is `-Inf` if `extend` is `TRUE`
#' and equal to the minimum of `x` if `extend` is `NULL`.
#'
#' It fixes the `left` attribute if a new singleton break is going to be
#' created.
#'
#' @param breaks,x,extend Passed in from a `brk_` inner function
#'
#' @return A new breaks object
#' @noRd
extend_endpoint_left <- function (breaks, x, extend) {
  left <- attr(breaks, "left")
  q <- quiet_min(x)
  # non-finite q could be Inf if x is empty. Not appropriate for a left endpoint!
  extra_break <- if (is.null(extend) && is_gt_minus_inf(q)) q else class_bounds(x)[1]
  res <- santoku_cast_common(extra_break, unclass_breaks(breaks))
  breaks <- vctrs::vec_c(res[[1]], res[[2]])
  # Ensure that a new "singleton" break has the right TRUE,FALSE left-closed
  # pattern
  if (length(breaks) > 1 && breaks[1] == breaks[2]) {
    left[1] <- FALSE
  }
  breaks <- create_breaks(breaks, c(TRUE, left))

  breaks
}


#' Extend the right endpoint of a breaks object according to user parameters
#'
#' This always adds a new break, which is `Inf` if `extend` is `TRUE`
#' and equal to the maximum of `x` if `extend` is `NULL`.
#'
#' It fixes the `left` attribute if a new singleton break is going to be
#' created.
#'
#' @param breaks,x,extend Passed in from a `brk_` inner function
#'
#' @return A new breaks object
#' @noRd
extend_endpoint_right <- function (breaks, x, extend) {
  left <- attr(breaks, "left")
  q <- quiet_max(x)
  extra_break <- if (is.null(extend) && is_lt_inf(q)) q else class_bounds(x)[2]
  # necessary because min() and max() may unclass things
  res <- santoku_cast_common(unclass_breaks(breaks), extra_break)
  breaks <- vctrs::vec_c(res[[1]], res[[2]])
  lb <- length(breaks)
  # Ensure that a new "singleton" break has the right TRUE,FALSE left-closed
  # pattern
  if (lb > 1 && breaks[lb] == breaks[lb - 1]) {
    left[length(left)] <- TRUE
  }
  breaks <- create_breaks(breaks, c(left, FALSE))

  breaks
}


is_lt_inf <- function (x) {
  x <- tryCatch(strict_as_numeric(x),
                  error = function (...) return(TRUE)
                )
  x < Inf
}


is_gt_minus_inf <- function (x) {
  x <- tryCatch(strict_as_numeric(x),
                  error = function (...) return(TRUE)
                )
  x > -Inf
}


#' Return the infimum and supremum of a class
#'
#' The default tries to cast `c(-Inf, Inf)` to the
#' class. If this fails, it returns `c(min(x), max(x))`
#' and emits a warning.
#'
#' @param x Only used for its class
#'
#' @return A length-two object
#' @noRd
class_bounds <- function (x) {
  UseMethod("class_bounds")
}


#' @export
class_bounds.numeric <- function (x) c(-Inf, Inf)


#' @export
class_bounds.POSIXct <- function (x) {
  as.POSIXct(c(-Inf, Inf), origin = "1970-01-01")
}


#' @export
class_bounds.Date <- function (x) {
  as.Date(c(-Inf, Inf), origin = "1970-01-01")
}


#' @export
class_bounds.difftime <- function (x) {
  as.difftime(c(-Inf, Inf), units = units(x))
}


#' @export
class_bounds.units <- function (x) {
  loadNamespace("units")
  # note: the units() call is from namespace base, not units
  units::set_units(c(-Inf, Inf), units(x), mode = "standard")
}


#' @export
class_bounds.integer64 <- function (x) {
  loadNamespace("bit64")
  bit64::lim.integer64()
}


#' @export
class_bounds.zoo <- function (x) {
  loadNamespace("zoo")
  zoo::zoo(c(-Inf, Inf))
}


#' @export
class_bounds.default <- function (x) {
  tryCatch(
    vctrs::vec_cast(c(-Inf, Inf), x),
    error = function(...) {
      warning("Class '", paste(class(x), collapse = "', '"),
              "' has no natural endpoints corresponding to +/-Inf for `extend = TRUE`;")
      c(quiet_min(x), quiet_max(x))
    }
  )
}


#' Removes the "breaks" class, and all subclasses, from a break object
#'
#' @param breaks A breaks object
#'
#' @return The object, with any remaining (super)classes
#' @noRd
unclass_breaks <- function (breaks) {
  assert_that(is.breaks(breaks))

  class_pos <- inherits(breaks, "breaks", which = TRUE)
  superclasses <- class(breaks)[-seq_len(class_pos)]

  class(breaks) <- if (length(superclasses) == 0 ) {
                     NULL
                   } else {
                     superclasses
                   }

  # this helps vec_cast_common deal with unusual types of breaks
  attr(breaks, "left") <- NULL

  breaks
}


#' Return a sequence of width `width`
#'
#' @param width An object representing a width
#' @param start Element to start from
#' @param until Result must be just long enough to cover this element
#'
#' @return A sequence of breaks
#' @noRd
sequence_width <- function(width, start, until) {
  UseMethod("sequence_width")
}


#' @export
sequence_width.default <- function (width, start, until) {
  breaks <- seq(start, until, width)

  too_short <- if (sign(width) > 0) {
    breaks[length(breaks)] < until
  } else {
    breaks[length(breaks)] > until
  }

  # length(breaks) == 1L captures when start == max_x
  if (too_short || length(breaks) == 1L) {
    breaks <- c(breaks, breaks[length(breaks)] + width)
  }

  breaks
}


#' @export
sequence_width.Period <- function(width, start, until) {
  loadNamespace("lubridate")

  if (as.numeric(until - start) %% as.numeric(width) != 0 || until == start) {
    # extend to cover all data / ensure at least one interval
    until <- lubridate::add_with_rollback(until, width)
  }
  # alternative to seq, using Period arithmetic
  # We find the number n of widths that gets beyond seq_end
  # and add (width * 0:n) to start
  # normally this would be ceiling((seq_end - start)/width)
  # we calculate it roughly using a Duration
  n_intervals <- ceiling((until - start)/lubridate::as.duration(width))
  breaks <- lubridate::add_with_rollback(start, (seq(0, n_intervals) * width))

  last_break <- breaks[length(breaks)]
  too_short <- if (width > 0) {
    last_break < until
  } else {
    last_break > until
  }
  if (too_short) {
    breaks <- c(breaks, lubridate::add_with_rollback(last_break, width))
  }

  breaks
}