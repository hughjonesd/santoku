
#' @name breaks-doc
#' @return A (function returning an) object of class `breaks`.
NULL

#' Breaks using quantiles
#'
#' @param quantiles Vector of quantiles
#' @param ... Arguments passed to [quantile()]
#'
#' @inherit breaks-doc return
#'
#' @export
#'
#' @examples
#' chop(c(1, 1, 2, 2, 3, 4), brk_quantiles(1:3/4))
brk_quantiles <- function (quantiles, ...) {
  force(quantiles)
  function (x) {
    qs <- stats::quantile(x, quantiles, na.rm = TRUE, ...)
    qs <- sort(qs)
    brk_left(qs)
  }
}


#' Title
#'
#' @param sd Whole number: include `sd` standard deviations on each side of
#'   the mean.
#' @inherit breaks-doc params return
#'
#' @export
#'
#' @examples
#' tab(rnorm(20), brk_mean_sd())
brk_mean_sd <- function (sd = 3) {
  force(sd)
  stopifnot(sd >= 0)
  if (sd != round(sd)) stop("`sd` must be a whole number")
  function (x) {
    x_m <- mean(x, na.rm = TRUE)
    x_sd <- sd(x, na.rm = TRUE)

    breaks <- if (is.na(x_m) || x_sd == 0) {
      numeric(0)
    } else {
      s1 <- seq(x_m, x_m - sd * x_sd, - x_sd)
      s2 <- seq(x_m, x_m + sd * x_sd, x_sd)
      c(sort(s1), s2[-1])
    }

    brk_left(breaks)
  }
}


#' Equal-width breaks
#'
#' `brk_width()` creates breaks of equal width.
#'
#' @param width Width of intervals.
#' @param start Leftpoint of first interval. By default the lowest finite `x`.
#'
#' @inherit breaks-doc return
#'
#' @export
#'
#' @examples
#' chop(runif(10), brk_width(0.2, 0))
brk_width <- function (width, start) {
  stopifnot(is.numeric(width))
  stopifnot(width > 0)
  sm <- missing(start)
  function (x) {
    if (sm) start <- suppressWarnings(min(x[is.finite(x)]))
    # finite if x has any non-NA finite elements:
    max_x <- suppressWarnings(max(x[is.finite(x)]))
    breaks <- if (is.finite(start) && is.finite(max_x)) {
      seq_end <- max_x
      if ((max_x - start) %% width != 0) seq_end <- seq_end + width
      seq(start, seq_end, width)
    } else {
      numeric(0)
    }

    brk_left(breaks)
  }
}


#' Fixed-size breaks
#'
#' `brk_size()` creates intervals containing a fixed number of (non-NA)
#' elements. One interval may have fewer elements.
#'
#' @param size Integer size of breaks
#' @inherit breaks-doc return
#'
#' @export
#'
#' @examples
#' chop(runif(10), brk_size(2))
brk_size <- function (size) {
  force(size)
  function (x) {
    x <- sort(x) # remove NAs
    breaks <- if (length(x) < 1L) numeric(0) else x[seq(1L, length(x), size)]
    brk_left(breaks, close_end = FALSE)
  }
}


#' Left- or right-closed breaks
#'
#' @param breaks A numeric vector which must be sorted.
#' @param close_end Logical: close the rightmost endpoint (`brk_left()`)
#'   / leftmost endpoint (`brk_right()`)?
#'
#' @inherit breaks-doc return
#'
#' @name brk-left-right
#'
#' @examples
#' chop(1:3, brk_left(1:3))
#' chop(1:3, brk_right(1:3))
#' chop(1:3, brk_left(1:3, FALSE))
NULL


#' @rdname brk-left-right
#' @export
brk_left <- function (breaks, close_end = TRUE) UseMethod("brk_left")


#' @rdname brk-left-right
#' @export
brk_right <- function (breaks, close_end = TRUE) UseMethod("brk_right")


#' @export
brk_left.default <- function (breaks, close_end = TRUE) {
  left <- rep(TRUE, length(breaks))

  st <- singletons(breaks)
  left[which(st) + 1] <- FALSE

  if (close_end) left[length(left)] <- FALSE

  brk_manual(breaks, left)
}


#' @export
brk_right.default <- function (breaks, close_end = TRUE) {
  left <- rep(FALSE, length(breaks))

  s <- singletons(breaks)
  left[s] <- TRUE

  if (close_end) left[1] <- TRUE

  brk_manual(breaks, left)
}


#' @export
brk_left.function <- function (breaks, close_end = TRUE) {
  function(...) brk_left(breaks(...), close_end = close_end)
}


#' @export
brk_right.function <- function (breaks, close_end = TRUE) {
  function(...) brk_right(breaks(...), close_end = close_end)
}


#' Create a `breaks` object manually
#'
#' @param vec A numeric vector which must be sorted.
#' @param left A logical vector, the same length as `vec`. Is break left-closed?
#'
#' @inherit breaks-doc return
#'
#' @details
#'
#' All breaks must be closed on exactly one side, like `..., x) [x, ...`
#' (left-closed) or `..., x) [x, ...` (right-closed).
#'
#' For example, if `vec = 1:3` and `left = c(TRUE, FALSE, TRUE)`, then the
#' resulting intervals are
#' \preformatted{
#' T        F       T
#' [ 1,  2 ] ( 2, 3 )
#' }
#'
#' Singleton breaks are created by repeating a number in `vec`.
#' Singletons must be closed on both sides, so if there is a repeated number
#' at indices `i`, `i+1`, `left[i]` must be `TRUE` and `left[i+1]` must be
#' `FALSE`.
#'
#' @export
#'
#' @examples
#' lbrks <- brk_manual(1:3, rep(TRUE, 3))
#' chop(1:3, lbrks, extend = FALSE)
#' rbrks <- brk_manual(1:3, rep(FALSE, 3))
#' chop(1:3, rbrks, extend = FALSE)
#'
#' brks_singleton <- brk_manual(
#'       c(1,    2,    2,     3),
#'       c(TRUE, TRUE, FALSE, TRUE))
#'
#' chop(1:3, brks_singleton, extend = FALSE)
brk_manual <- function (vec, left) {
  if (anyNA(vec)) stop("`x` contained NAs")
  stopifnot(is.numeric(vec))
  stopifnot(all(vec == sort(vec)))
  stopifnot(is.logical(left))
  stopifnot(length(left) == length(vec))

  singletons <- singletons(vec)
  if (any(singletons[-1] & singletons[-length(singletons)])) {
    stop("`x` contained more than two consecutive equal values")
  }

  l_singletons <- c(singletons, FALSE)
  r_singletons <- c(FALSE, singletons)
  stopifnot(all(left[l_singletons]))
  stopifnot(all(! left[r_singletons]))

  structure(vec, left = left, class = "breaks")
}


#' Class representing a set of intervals
#'
#' @param x A breaks object
#' @param ... Unused
#'
#' @name breaks-class
NULL


#' @rdname breaks-class
#' @export
format.breaks <- function (x, ...) {
  if (length(x) < 2) return("Breaks object with no complete intervals")
  paste(lbl_intervals()(x), collapse = " ")
}


#' @rdname breaks-class
#' @export
print.breaks <- function (x, ...) cat(format(x))


#' @rdname breaks-class
#' @export
is.breaks <- function (x, ...) inherits(x, "breaks")

