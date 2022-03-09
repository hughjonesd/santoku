

#' @name chop-doc
#' @param ... Passed to [chop()].
#' @return
#' `chop_*` functions return a [`factor`] of the same length as `x`.
#'
#' `brk_*` functions return a [`function`] to create `breaks`.
#'
#' `tab_*` functions return a contingency [table()].
NULL


#' Cut data into intervals
#'
#' `chop()` cuts `x` into intervals. It returns a [`factor`] of the same length as
#' `x`, representing which interval contains each element of `x`.
#' `kiru()` is an alias for `chop`.
#' `tab()` calls `chop()` and returns a contingency [table()] from the result.
#'
#' @param x A vector.
#' @param breaks A numeric vector of cut-points or a function to create
#'   cut-points from `x`.
#' @param labels A character vector of labels or a function to create labels.
#' @param extend Logical. Extend breaks to `+/-Inf`?
#' @param left Logical. Left-closed breaks?
#' @param close_end Logical. Close last break at right? (If `left` is `FALSE`,
#'   close first break at left?)
#' @param drop Logical. Drop unused levels from the result?
#'
#' @details
#'
#' `x` may be numeric, or a [Date or Date-Time][DateTimeClasses].
#'
#' ## Breaks
#'
#' `breaks` may be a numeric vector or a function.
#'
#' If it is a vector, `breaks` gives the break endpoints. Repeated values create
#' singleton intervals. For example `breaks = c(1, 3, 3, 5)` creates 3
#' intervals: \code{[1, 3)}, \code{{3}} and \code{(3, 5]}.
#'
#' If `breaks` is a function it is called with the `x`, `extend`, `left` and
#' `close_end` arguments, and should return an object of class `breaks`.
#' Use `brk_*` functions in this context, to create a variety of data-dependent
#' breaks.
#'
#' ## Options for breaks
#'
#' By default, left-closed intervals are created. If `left` is `FALSE`, right-
#' closed intervals are created.
#'
#' If `close_end` is `TRUE` the end break will be closed at both ends, ensuring
#' that all values `y` with `min(x) <= y <= max(x)` are included in the default
#' intervals.
#'
#' Overall:
#'
#' * If `left` is `TRUE` and `close_end` is `TRUE`, breaks will look like
#'   \code{[x1, x2), [x2, x3) ... [x_n-1, x_n]}.
#' * If `left` is `FALSE` and `close_end` is `TRUE`, breaks will look like
#'    \code{[x1, x2], (x2, x3] ... (x_n-1, x_n]}.
#' * If `left` is `TRUE` and `close_end` is `FALSE`, all breaks will look like
#'   \code{...[x1, x2) ...}.
#' * If `left` is `FALSE` and `close_end` is `FALSE`, all breaks will look like
#'   \code{...(x1, x2] ...}.
#'
#' ## Extending intervals
#'
#' If `extend` is `TRUE`, intervals will be extended to \code{[-Inf,
#' min(breaks))} and \code{(max(breaks), Inf]}.
#'
#' If `extend` is `NULL` (the default), intervals will be extended to
#' \code{[min(x), min(breaks))} and \code{(max(breaks), max(x)]}, *only* if
#' necessary -- i.e. if `min(x) < min(breaks)` and `max(x) > max(breaks)`
#' respectively.
#'
#' Extending intervals, either by `extend = NULL` or `extend = TRUE`,
#' *always* leaves the central, non-extended intervals unchanged. In particular,
#' `close_end` applies to the central intervals, not to the extended ones.
#' For example, if `breaks = c(1, 3, 5)` and `close_end = TRUE`, the resulting
#' breaks will be
#'
#' \code{[1, 3), [3, 5]}
#'
#' and if `extend = TRUE` the result will be
#'
#' \code{[-Inf, 1), [1, 3), [3, 5], (5, Inf]}
#'
#'
#' ## Labels
#'
#' `labels` may be a character vector. It should have the same length as the
#' number of intervals. Alternatively, use a `lbl_*` function such as
#' [lbl_seq()].
#'
#' If `labels` is `NULL`, then integer codes will be returned instead of a
#' factor.
#'
#' ## Miscellaneous
#'
#' `NA` values in `x`, and values which are outside the extended endpoints,
#' return `NA`.
#'
#' `kiru()` is a synonym for `chop()`. If you load `{tidyr}`, you can use it to
#' avoid confusion with `tidyr::chop()`.
#'
#' Note that `chop()`, like all of R, uses binary arithmetic. Thus, numbers may
#' not be exactly equal to what you think they should be. There is an example
#' below.
#'
#' @return
#' `chop()` returns a [`factor`] of the same length as `x`, representing the
#' intervals containing the value of `x`.
#'
#' `tab()` returns a contingency [table()].
#'
#' @export
#'
#' @family chopping functions
#'
#' @seealso [base::cut()], [`non-standard-types`] for chopping objects that
#'   aren't numbers.
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
#' chop(1:10, c(2, 5, 8), left = FALSE)
#'
#' chop(1:10, c(2, 5, 8), close_end = TRUE)
#'
#' chop(1:10, brk_quantiles(c(0.25, 0.75)))
#'
#' chop(1:10, c(2, 5, 8), labels = lbl_dash())
#'
#' # floating point inaccuracy:
#' chop(0.3/3, c(0, 0.1, 0.1, 1), labels = c("< 0.1", "0.1", "> 0.1"))
#'
chop <- function (x, breaks,
        labels    = lbl_intervals(),
        extend    = NULL,
        left      = TRUE,
        close_end = FALSE,
        drop      = TRUE
      ) {
  assert_that(
          is.flag(left),
          is.flag(close_end),
          is.flag(drop)
        )
  if (! is.function(breaks)) breaks <- brk_default(breaks)
  breaks <- breaks(x, extend, left, close_end)
  assert_that(is.breaks(breaks), length(breaks) >= 2L)

  codes <- categorize(x, breaks)

  if (is.null(labels)) return(codes)

  if (is.function(labels)) labels <- labels(breaks)
  stopifnot(length(labels) == length(breaks) - 1)

  real_codes <- if (drop) unique(codes[! is.na(codes)]) else TRUE
  if (anyDuplicated(labels[real_codes])) {
    stop("Duplicate labels found: ", paste(labels, collapse = ", "))
  }

  result <- factor(codes, levels = seq.int(length(breaks) - 1L),
        labels = labels)
  if (drop) result <- droplevels(result)

  return(result)
}


#' @rdname chop
#' @export
kiru <- chop


#' Chop data precisely (for programmers)
#'
#' @inheritParams chop
#'
#' @details
#' `fillet()` calls [chop()] with `extend = FALSE` and `drop = FALSE`. This
#' ensures that you get only the `breaks` and `labels` you ask for. When
#' programming, consider using `fillet()` instead of `chop()`.
#'
#' @return `fillet()` returns a [`factor`] of the same length as `x`, representing
#'   the intervals containing the value of `x`.
#'
#' @family chopping functions
#'
#' @export
#'
#' @examples
#' fillet(1:10, c(2, 5, 8))
fillet <- function (x, breaks, labels = lbl_intervals(), left = TRUE, close_end = FALSE) {
  chop(x, breaks, labels, left = left, close_end = close_end, extend = FALSE,
      drop = FALSE)
}


#' Chop by quantiles
#'
#' `chop_quantiles()` chops data by quantiles.
#' `chop_deciles()` is a convenience shortcut and chops into deciles.
#'
#' @param probs A vector of probabilities for the quantiles.
#' @param ... Passed to [chop()], or for `brk_quantiles()` to
#'   [stats::quantile()].
#' @inheritParams chop
#' @inherit chop-doc params return
#'
#' @details
#' Note that these functions set `close_end = TRUE` by default.
#' This helps ensure that e.g. `chop_quantiles(x, c(0, 1/3, 2/3, 1)`
#' will split the data into three equal-sized groups.
#'
#' For non-numeric `x`, `left` is set to `FALSE` by default. This works better
#' for calculating "type 1" quantiles, since they round down. See
#' [stats::quantile()].
#'
#' @family chopping functions
#'
#' @export
#' @order 1
#'
#' @examples
#' chop_quantiles(1:10, 1:3/4)
#'
#' chop(1:10, brk_quantiles(1:3/4))
#'
#' chop_deciles(1:10)
#'
#' # to label by the quantiles themselves:
#' chop_quantiles(1:10, 1:3/4, lbl_intervals(raw = TRUE))
#'
chop_quantiles <- function(
        x,
        probs,
        ...,
        left      = is.numeric(x),
        close_end = TRUE
      ) {
  chop(x, brk_quantiles(probs), ..., left = left, close_end = close_end)
}


#' @rdname chop_quantiles
#' @export
#' @order 1
chop_deciles <- function(x, ...) {
  chop_quantiles(x, 0:10/10, ...)
}


#' Chop equal-sized groups
#'
#' `chop_equally()` chops `x` into groups with an equal number of elements.
#'
#' @param groups Number of groups.
#' @inheritParams chop
#' @inherit chop-doc params return
#'
#' @family chopping functions
#'
#' @export
#' @order 1
#' @examples
#' chop_equally(1:10, 5)
#'
chop_equally <- function (x, groups, ..., left = is.numeric(x), close_end = TRUE) {
  chop(x, brk_equally(groups), ..., left = left, close_end = close_end)
}


#' Chop by standard deviations
#'
#' Intervals of width 1 standard deviation are included on either side of the
#' mean.
#' The outermost pair of intervals will be shorter if `sd` is not a whole
#' number.
#'
#'
#' @param sd Positive number: include up to `sd` standard deviations.
#' @inheritParams chop
#' @inherit chop-doc params return
#'
#' @family chopping functions
#'
#' @export
#' @order 1
#'
#' @examples
#' chop_mean_sd(1:10)
#'
#' chop(1:10, brk_mean_sd())
#'
chop_mean_sd <- function (x, sd = 3, ...) {
  chop(x, brk_mean_sd(sd), ...)
}


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
chop_width <- function (x, width, start, ..., left = sign(width) > 0) {
  chop(x, brk_width(width, start), left = left, ...)
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
chop_evenly <- function (x, intervals, ..., close_end = TRUE) {
  chop(x, brk_evenly(intervals), ..., close_end = close_end)
}


#' Chop into fixed-sized groups
#'
#' `chop_n()` creates intervals containing a fixed number of elements. One
#' interval may have fewer elements.
#'
#' @param n Integer: number of elements in each interval.
#' @inheritParams chop
#' @inherit chop-doc params return
#'
#' @details
#' Note that `chop_n()` sets `close_end = TRUE` by default.
#'
#' Groups may be larger than `n`, if there are too many duplicated elements
#' in `x`. If so, a warning is given.
#'
#' @export
#' @order 1
#'
#' @family chopping functions
#'
#' @examples
#' chop_n(1:10, 5)
#'
#' # too many duplicates
#' x <- rep(1:2, each = 3)
#' chop_n(x, 2)
#'
chop_n <- function (x, n, ..., close_end = TRUE) {
  res <- chop(x, brk_n(n), ..., close_end = close_end)
  if (max(tabulate(res)) > n) {
    warning("Some intervals contain more than ", n, " elements")
  }

  res
}
