

#' @name chop-doc
#' @param x A numeric vector.
#' @param breaks,labels,...  Passed to `chop`.
#' @return
#' For  `chop_*` functions, a factor of the same length as `x`.
NULL


#' Cut numeric data into intervals
#'
#' `chop` cuts `x` into intervals. It returns a factor of the same
#' length as `x`, representing which interval contains each element of `x`.
#'
#'
#' @param x A numeric vector.
#' @param breaks See below.
#' @param labels See below.
#' @param extend Logical. Extend breaks to `+/-Inf`?
#' @param drop Logical. Drop unused levels from the result?
#'
#' @details
#' `breaks` may be a numeric vector, an object of class [breaks][breaks-class],
#' or a function.
#'
#' If it is a vector, `breaks` gives the break endpoints.Repeated values create
#' singleton intervals. For example `breaks = c(1, 3, 3, 5)` creates 3
#' intervals: \code{[1, 3)}, \code{{3}} and \code{(3, 5]}. Default breaks are
#' left-closed except the end; for right-closed breaks see [brk_right()].
#'
#' If `breaks` is a function it is called with a single argument, `x`, and
#' returns an object of class `breaks`.
#'
#' `labels` may be a character vector. It should have the same length as the
#'  number of intervals. Alternatively, use a `lbl_` function such as
#'  [lbl_numerals()].
#'
#'
#' If `extend` is `TRUE`, intervals will be extended to \code{[-Inf,
#' min(breaks))} and \code{(max(breaks), Inf]}, unless those endpoints are
#' already infinite. If `extend` is `NULL` (the default), intervals will
#' be extended only if the data is outside their range.
#'
#' `NA` values in `x`, and values which are outside the (extendeD) endpoints,
#' return `NA`.
#'
#' @return
#' A [factor] of the same length as `x`, representing the intervals containing
#' the value of `x`.
#'
#' @export
#'
#' @family chopping functions
#'
#' @seealso cut
#'
#' @examples
#' chop(1:3, 2)
#'
#' chop(1:10, c(2, 5, 8))
#'
#' chop(1:10, c(2, 5, 8), extend = FALSE)
#'
#' chop(1:10, c(2, 5, 5, 8))
#'
#' chop(1:10, brk_quantiles(c(0.25, 0.75)))
#'
#' chop(1:10, c(2, 5, 8), labels = lbl_dash())
#'
chop <- function (x, breaks, labels,
        extend = NULL,
        drop   = TRUE
      ) {
  assert_that(is.numeric(x), is.function(breaks) || is.breaks(breaks) ||
        is.numeric(breaks))
  if (is.function(breaks))  {
    breaks <- breaks(x, extend)
  }
  if (! is.breaks(breaks)) {
    breaks <- sort(breaks)
    breaks <- brk_left(breaks)(x, extend)
  }
  assert_that(is.breaks(breaks), length(breaks) >= 2L)

  if (missing(labels)) labels <- NULL
  labels <- labels %||% lbl_intervals()
  if (is.function(labels)) labels <- labels(breaks)

  stopifnot(length(labels) == length(breaks) - 1)
  if (anyDuplicated(labels)) stop("Duplicate labels found: ",
        paste(labels, collapse = ", "))

  codes <- categorize(x, breaks)
  result <- factor(codes, levels = seq.int(length(breaks) - 1L),
        labels = labels)
  if (drop) result <- droplevels(result)

  return(result)
}


#' Chop by quantiles
#'
#' `chop_quantiles` chops data by quantiles. `chop_equally` chops
#' data into equal-sized groups. `chop_deciles` is a convenience shortcut and
#' chops into deciles.
#'
#' @param probs A vector of probabilities for the quantiles.
#' @inherit chop-doc params return
#'
#' @family chopping functions
#'
#' @export
#'
#' @examples
#' chop_quantiles(rnorm(10), 1:3/4)
#' chop(rnorm(10), brk_quantiles(1:3/4))
chop_quantiles <- function(x, probs, ...) {
  chop(x, brk_quantiles(probs), ...)
}


#' @rdname chop_quantiles
#' @export
chop_deciles <- function(x, ...) {
  chop_quantiles(x, 1:9/10, ...)
}


#' @rdname chop_quantiles
#'
#' @param groups Number of groups.
#'
#' @export
#'
#' @examples
#' chop_equally(rnorm(10), 5)
chop_equally <- function (x, groups, ...) {
  chop_quantiles(x, seq(0, groups)/groups, ...)
}


#' Chop by standard deviations
#'
#' @param sd Whole number: include `sd` standard deviations on each side of
#'   the mean.
#' @inherit chop-doc params return
#'
#' @family chopping functions
#'
#' @export
#'
#' @examples
#' chop_mean_sd(1:10)
#'
#' chop(1:10, brk_mean_sd())
#'
chop_mean_sd <- function (x, sd = 3, ...) {
  chop(x, brk_mean_sd(sd), ...)
}


#' Chop into equal-width intervals
#'
#' `chop_width()` chops `x` into intervals of width `width`. `chop_evenly`
#' chops `x` into `groups` intervals of equal width.
#'
#' @param width Width of intervals.
#' @param start Leftpoint of first interval. By default the lowest finite `x`.
#' @inherit chop-doc params return
#'
#' @family chopping functions
#'
#' @export
#'
#' @examples
#' chop_width(1:10, 2)
#'
#' chop_width(1:10, 2, start = 0)
#'
#' chop(1:10, brk_width(2, 0))
#'
#' chop_evenly(1:10, 5)
#'
chop_width <- function (x, width, start, ...) {
  chop(x, brk_width(width, start), ...)
}


#' @rdname chop_width
#'
#' @param groups Integer: number of intervals to create.
#'
#' @export
chop_evenly <- function (x, groups, ...) {
  chop(x, brk_evenly(groups), ...)
}


#' Chop into fixed-sized groups
#'
#' `chop_n()` creates intervals containing a fixed number of elements. One
#' interval may have fewer elements.
#'
#' @param n Integer: number of elements in each interval.
#' @inherit chop-doc params return
#'
#' @export
#'
#' @family chopping functions
#'
#' @examples
#' table(chop_n(1:10, 5))
#'
#' table(chop_n(1:10, 4))
#'
chop_n <- function (x, n, ...) {
  chop(x, brk_n(n), ...)
}