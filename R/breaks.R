
#' @name breaks-doc
#' @return A (function which returns an) object of class `breaks`.
NULL


#' Breaks using quantiles
#'
#' @param probs Vector of probabilities for quantiles
#' @param ... Arguments passed to [quantile()]
#'
#' @inherit breaks-doc return
#'
#' @export
#'
#' @examples
#' chop(c(1, 1, 2, 2, 3, 4), brk_quantiles(1:3/4))
brk_quantiles <- function (probs, ...) {
  force(probs)
  function (x, extend) {
    extend <- extend %||% needs_extend(probs, c(0, 1)) # hacky
    if (extend) probs <- c(0, probs, 1)
    qs <- stats::quantile(x, probs, na.rm = TRUE, ...)
    qs <- sort(qs)

    breaks <- create_left_breaks(qs)

    break_labels <- paste0(formatC(probs * 100, format = "fg"), "%")
    attr(breaks, "break_labels") <- break_labels

    breaks
  }
}


#' Break into standard deviations around the mean
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
  function (x, extend) {
    x_m <- mean(x, na.rm = TRUE)
    x_sd <- sd(x, na.rm = TRUE)

    breaks <- if (is.na(x_m) || x_sd == 0) {
      numeric(0)
    } else {
      s1 <- seq(x_m, x_m - sd * x_sd, - x_sd)
      s2 <- seq(x_m, x_m + sd * x_sd, x_sd)
      c(sort(s1), s2[-1])
    }

    breaks <- create_left_breaks(breaks)
    breaks <- maybe_extend(breaks, x, extend)

    break_labels <- seq(-sd, sd, 1)
    break_labels <- paste0(break_labels, " sd")
    if (extend %||% needs_extend(breaks, x)) {
      break_labels <- c(-Inf, break_labels, Inf)
    }
    attr(breaks, "break_labels") <- break_labels

    breaks
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
  function (x, extend) {
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

    breaks <- create_left_breaks(breaks)
    breaks <- maybe_extend(breaks, x, extend)

    breaks
  }
}


#' Breaks with a fixed number of elements
#'
#' `brk_n()` creates intervals containing a fixed number of elements. One
#' interval may have fewer elements.
#'
#' @param n Integer: number of elements in each interval.
#' @inherit breaks-doc return
#'
#' @export
#'
#' @examples
#' tab(runif(10), brk_n(2))
brk_n <- function (n) {
  force(n)
  function (x, extend) {
    x <- sort(x) # remove NAs
    breaks <- if (length(x) < 1L) numeric(0) else x[seq(1L, length(x), n)]
    # `close_end = FALSE` is necessary, or one group gets bigger:
    breaks <- create_left_breaks(breaks, close_end = FALSE)
    breaks <- maybe_extend(breaks, x, extend)

    breaks
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
#' chop(5:7, brk_left(5:7))
#' chop(5:7, brk_right(5:7))
#' chop(5:7, brk_left(5:7, FALSE))
NULL


#' @rdname brk-left-right
#' @export
brk_left <- function (breaks, close_end = TRUE) UseMethod("brk_left")


#' @rdname brk-left-right
#' @export
brk_right <- function (breaks, close_end = TRUE) UseMethod("brk_right")


#' @export
brk_left.default <- function (breaks, close_end = TRUE) {
  function(x, extend) {
    breaks <- create_left_breaks(breaks, close_end)
    breaks <- maybe_extend(breaks, x, extend)
    breaks
  }
}


#' @export
brk_right.default <- function (breaks, close_end = TRUE) {
  function (x, extend) {
    breaks <- create_right_breaks(breaks, close_end)
    breaks <- maybe_extend(breaks, x, extend)
    breaks
  }
}


#' @export
brk_left.function <- function (breaks, close_end = TRUE) {
  function(x, extend) {
    breaks <- breaks(x, extend) # already contains left/labels and is extended
    create_left_breaks(breaks, close_end)
  }
}


#' @export
brk_right.function <- function (breaks, close_end = TRUE) {
  function(x, extend) {
    breaks <- breaks(x, extend)
    create_right_breaks(breaks, close_end)
  }
}


#' Create a `breaks` object manually
#'
#' @param breaks A numeric vector which must be sorted.
#' @param left A logical vector, the same length as `breaks`.
#'   Is break left-closed?
#'
#' @inherit breaks-doc return
#'
#' @details
#'
#' All breaks must be closed on exactly one side, like `..., x) [x, ...`
#' (left-closed) or `..., x) [x, ...` (right-closed).
#'
#' For example, if `breaks = 1:3` and `left = c(TRUE, FALSE, TRUE)`, then the
#' resulting intervals are \preformatted{
#' T        F       T
#' [ 1,  2 ] ( 2, 3 )
#' }
#'
#' Singleton breaks are created by repeating a number in `breaks`.
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
brk_manual <- function (breaks, left) {
  function (x, extend) {
    breaks <- create_breaks(breaks, left)

    breaks <- maybe_extend(breaks, x, extend)

    breaks
  }
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

