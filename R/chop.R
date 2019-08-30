

#' @name chop-doc
#' @param x A numeric vector.
#' @param breaks,...  Passed to `chop`.
NULL


#' Cut numeric data into intervals
#'
#' `chop` cuts `x` into intervals. It returns a factor of the same
#' length as `x`, representing which interval contains each elements of `x`.
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
#' or a function. If it is a vector, `breaks`
#' gives the break endpoints. Repeated values create singleton intervals.
#' For example `breaks = c(1, 3, 3, 5)` creates 3 intervals: `[1, 3)`, `{3}`
#' and `(3, 5]`. Default breaks are left-closed except the end; for right-closed
#' breaks see [brk_right()].
#'
#' If `breaks` is a function it is called with a single argument, `x`, and
#' returns the break endpoints.
#'
#' `labels` may be a character vector or a function. If it is a character
#' vector it should have the same length as the number of intervals - i.e.
#' one more than `length(breaks)` if `extend` is `TRUE`, one less otherwise.
#'
#' If `labels` is a function it should take an object of class `breaks` and
#' return an appropriate character vector. If `labels` is `NULL` a simple
#' vector of integers is returned.
#'
#' If `extend` is `TRUE`, intervals will be extended to `-Inf, min(breaks))` and
#'     `(max(breaks), Inf`, unless those endpoints are already infinite.
#'
#' `NA` values in `x`, and values which are outside the endpoints, return `NA`.
#'
#' @return
#' A [factor], or an integer if `labels` is `NULL`, of the same length as `x`,
#' representing the intervals containing the value of `x`.
#'
#' @export
#'
#' @seealso cut
#'
#' @examples
#' chop(1:3, 2)
#' chop(rnorm(10), -2:2)
#' chop(rnorm(10), -2:2, extend = FALSE)
#' chop(rnorm(10), brk_quantiles(c(0.25, 0.75)))
#' chop(rnorm(10), -2:2, labels = lbl_dash())
chop <- function (x, breaks,
        labels = lbl_intervals(),
        extend = TRUE,
        drop   = TRUE
      ) {

  if (is.function(breaks))  {
    breaks <- breaks(x)
    stopifnot(is.breaks(breaks))
  } else if (! is.breaks(breaks)) {
    breaks <- brk_left(breaks)
  }
  if (extend) breaks <- extend_breaks(breaks)

  if (is.function(labels)) labels <- labels(breaks)
  stopifnot(length(labels) == length(breaks) - 1)

  codes <- categorize(x, breaks)
  result <- factor(codes, levels = seq.int(length(breaks) - 1L),
        labels = labels)
  if (drop) result <- droplevels(result)

  return(result)
}


#' Chop by quantiles.
#'
#' `chop_quantiles` chops data by quantiles. `chop_equal` chops
#' data into equal-sized groups.
#'
#' @param quantiles A vector of quantiles. You don't need to include 0 or 1.
#' @param labels See [chop()].
#' @inherit chop-doc params return
#'
#' @export
#'
#' @examples
#' chop_quantiles(rnorm(10), c(1/3, 2/3))
chop_quantiles <- function(x, quantiles, labels = lbl_quantiles(quantiles), ...) {
  chop(x, brk_quantiles(quantiles), labels = labels, ...)
}


#' @rdname chop_quantiles
#'
#' @param n Number of groups
#'
#' @export
#'
#' @examples
#' chop_equal(rnorm(10), 5)
chop_equal <- function(x, n, labels = lbl_intervals(), ...) {
  chop_quantiles(x, seq(1, n - 1)/n, labels = labels, ...)
}


#' Chop into equal-width intervals
#'
#' `chop_width()` chops `x` into intervals of equal width.
#'
#' @inherit chop-doc params return
#' @inherit brk_width params
#'
#' @export
#'
#' @examples
#' chop_width(rnorm(10), 2)
#' chop_width(0:10, 2)
chop_width <- function (x, width, start, ...) {
  chop(x, brk_width(width, start), ...)
}


#' Chop into fixed-sized groups
#'
#' @param size Size of groups to return.
#' @inherit chop-doc params return
#'
#' @export
#'
#' @examples
#' chop_size(1:10, 6)
chop_size <- function (x, size, ...) {
  chop(x, brk_size(size), ...)
}