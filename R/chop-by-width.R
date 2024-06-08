
#' Chop into fixed-width intervals
#'
#' `chop_width()` chops `x` into intervals of fixed `width`.
#'
#' @param width Width of intervals.
#' @param start Starting point for intervals. By default the smallest
#'   finite `x` (largest if `width` is negative).
#' @inheritParams chop
#' @inherit chop-doc params return
#'
#' @details
#' If `width` is negative, `chop_width()` sets `left = FALSE` and intervals will
#' go downwards from `start`.
#'
#' @family chopping functions
#' @seealso [brk_width-for-datetime]
#'
#' @export
#' @order 1
#'
#' @examples
#' chop_width(1:10, 2)
#'
#' chop_width(1:10, 2, start = 0)
#'
#' chop_width(1:9, -2)
#'
#' chop(1:10, brk_width(2, 0))
#'
chop_width <- function (
                x,
                width,
                start,
                ...,
                left = sign(width) > 0
              ) {
  chop(x, brk_width(width, start), ..., left = left)
}


#' Chop into equal-width intervals
#'
#' `chop_evenly()` chops `x` into `intervals` intervals of equal width.
#'
#' @param intervals Integer: number of intervals to create.
#' @inheritParams chop
#' @inherit chop-doc params return
#'
#' @details `chop_evenly()` sets `close_end = TRUE` by default.
#'
#' @family chopping functions
#'
#' @export
#' @order 1
#' @examples
#' chop_evenly(0:10, 5)
#'
chop_evenly <- function (
                 x,
                 intervals,
                 ...,
                 close_end = TRUE
               ) {
  chop(x, brk_evenly(intervals), ..., close_end = close_end)
}


#' Chop into proportions of the range of x
#'
#' `chop_proportions()` chops `x` into `proportions` of its range, excluding
#' infinite values.
#'
#' By default, labels show the raw numeric endpoints. To label intervals by
#' the proportions, use `raw = FALSE`.
#'
#' @param proportions Numeric vector between 0 and 1: proportions of x's range.
#'   If `proportions` has names, these will be used for labels.
#' @inheritParams chop
#' @inherit chop-doc params return
#'
#' @export
#' @order 1
#' @family chopping functions
#' @examples
#' chop_proportions(0:10, c(0.2, 0.8))
#' chop_proportions(0:10, c(Low = 0, Mid = 0.2, High = 0.8))
#'
chop_proportions <- function (
                      x,
                      proportions,
                      ...,
                      raw    = TRUE
                    ) {
  chop(x, brk_proportions(proportions), ..., raw = raw)
}