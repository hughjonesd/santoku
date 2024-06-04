

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
#' @param extend Logical. If `TRUE`, always extend breaks to `+/-Inf`. If `NULL`,
#'   extend breaks to `min(x)` and/or `max(x)` only if necessary. If `NULL`, never
#'   extend.
#' @param left Logical. Left-closed or right-closed breaks?
#' @param close_end Logical. Close last break at right? (If `left` is `FALSE`,
#'   close first break at left?)
#' @param raw Logical. Use raw values in labels?
#' @param drop Logical. Drop unused levels from the result?
#'
#' @details
#'
#' `x` may be a numeric vector, or more generally, any vector which can be
#' compared with `<` and `==` (see [Ops][groupGeneric]). In particular [Date]
#' and [date-time][DateTimeClasses] objects are supported. Character vectors
#' are supported with a warning.
#'
#' ## Breaks
#'
#' `breaks` may be a vector or a function.
#'
#' If it is a vector, `breaks` gives the break endpoints. Repeated values create
#' singleton intervals. For example `breaks = c(1, 3, 3, 5)` creates 3
#' intervals: \code{[1, 3)}, \code{{3}} and \code{(3, 5]}.
#'
#' If `breaks` is a function, it is called with the `x`, `extend`, `left` and
#' `close_end` arguments, and should return an object of class `breaks`.
#' Use `brk_*` functions to create a variety of data-dependent breaks.
#'
#' Names of `breaks` may be used for labels. See "Labels" below.
#'
#' ## Options for breaks
#'
#' By default, left-closed intervals are created. If `left` is `FALSE`,
#' right-closed intervals are created.
#'
#' If `close_end` is `TRUE` the final break (or first break if `left` is `FALSE`)
#' will be closed at both ends. This guarantees that all values `x` with
#' `min(breaks) <= x <= max(breaks)` are included in the intervals.
#'
#' Before version 0.9.0, `close_end` was `FALSE` by default, and also behaved
#' differently with respect to extended breaks: see "Extending intervals" below.
#'
#' Using [mathematical set notation][lbl_intervals()]:
#'
#' * If `left` is `TRUE` and `close_end` is `TRUE`, breaks will look like
#'   \code{[b1, b2), [b2, b3) ... [b_n-1, b_n]}.
#' * If `left` is `FALSE` and `close_end` is `TRUE`, breaks will look like
#'    \code{[b1, b2], (b2, b3] ... (b_n-1, b_n]}.
#' * If `left` is `TRUE` and `close_end` is `FALSE`, all breaks will look like
#'   \code{...[b1, b2) ...}.
#' * If `left` is `FALSE` and `close_end` is `FALSE`, all breaks will look like
#'   \code{...(b1, b2] ...}.
#'
#' ## Extending intervals
#'
#' If `extend` is `TRUE`, intervals will be extended to \code{[-Inf,
#' min(breaks))} and \code{(max(breaks), Inf]}.
#'
#' If `extend` is `NULL` (the default), intervals will be extended to
#' \code{[min(x), min(breaks))} and \code{(max(breaks), max(x)]}, *only* if
#' necessary -- i.e. if elements of `x` would be below or above the unextended
#' breaks.
#'
#' `close_end` is applied after breaks are extended, i.e. always to the very last
#' or very first break. This is a change from
#' previous behaviour. Up to version 0.8.0, `close_end` was applied to the
#' user-specified intervals, then `extend` was applied. Note that
#' if breaks are extended, then the extended break is always closed anyway.
#'
#' ## Labels
#'
#' `labels` may be a character vector. It should have the same length as the
#' (possibly extended) number of intervals. Alternatively, `labels` may be a
#' `lbl_*` function such as [lbl_seq()].
#'
#' If `breaks` is a named vector, then non-zero-length names of `breaks` will be
#' used as labels for the interval starting at the corresponding element. This
#' overrides the `labels` argument (but unnamed breaks will still use `labels`).
#' This feature is `r lifecycle::badge("experimental")`.
#'
#' If `labels` is `NULL`, then integer codes will be returned instead of a
#' factor.
#'
#' If `raw` is `TRUE`, labels will show the actual numbers calculated by breaks.
#' If `raw` is `FALSE` then labels may show other objects, such
#' as quantiles for [chop_quantiles()] and friends, proportions of the range for
#'  [chop_proportions()], or standard deviations for [chop_mean_sd()].
#'
#'  If `raw` is `NULL` then `lbl_*` functions will use their default (usually
#'  `FALSE`). Otherwise, `raw` argument to `chop()` overrides `raw` arguments
#'  passed into `lbl_*` functions directly.
#'
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
#'
#' chop(1:7, c(2, 4, 6))
#'
#' chop(1:7, c(2, 4, 6), extend = FALSE)
#'
#' # Repeat a number for a singleton break:
#' chop(1:7, c(2, 4, 4, 6))
#'
#' chop(1:7, c(2, 4, 6), left = FALSE)
#'
#' chop(1:7, c(2, 4, 6), close_end = FALSE)
#'
#' chop(1:7, brk_quantiles(c(0.25, 0.75)))
#'
#' # A single break is fine if `extend` is not `FALSE`:
#' chop(1:7, 4)
#'
#' # Floating point inaccuracy:
#' chop(0.3/3, c(0, 0.1, 0.1, 1), labels = c("< 0.1", "0.1", "> 0.1"))
#'
#' # -- Labels --
#'
#' chop(1:7, c(Lowest = 1, Low = 2, Mid = 4, High = 6))
#'
#' chop(1:7, c(2, 4, 6), labels = c("Lowest", "Low", "Mid", "High"))
#'
#' chop(1:7, c(2, 4, 6), labels = lbl_dash())
#'
#' # Mixing names and other labels:
#' chop(1:7, c("<2" = 1, 2, 4, ">=6" = 6), labels = lbl_dash())
#'
#' # -- Non-standard types --
#'
#' chop(as.Date("2001-01-01") + 1:7, as.Date("2001-01-04"))
#'
#' suppressWarnings(chop(LETTERS[1:7], "D"))
#'
#'
chop <- function (x, breaks,
          labels    = lbl_intervals(),
          extend    = NULL,
          left      = TRUE,
          close_end = TRUE,
          raw       = NULL,
          drop      = TRUE
        ) {
  assert_that(
          is.flag(extend) || is.null(extend),
          is.flag(left),
          is.flag(close_end),
          is.flag(drop),
          is.flag(raw) || is.null(raw)
        )

  if (! is.function(breaks)) breaks <- brk_default(breaks)
  breaks <- breaks(x, extend, left, close_end)
  assert_that(is.breaks(breaks), length(breaks) >= 2L)

  codes <- categorize(x, breaks)

  if (is.null(labels)) return(codes)

  lbls <- if (is.function(labels)) {
    if (is.null(raw)) labels(breaks) else labels(breaks, raw = raw)
  } else {
    labels
  }
  lbls <- add_break_names(lbls, breaks)
  stopifnot(length(lbls) == length(breaks) - 1)

  real_codes <- if (drop) unique(codes[! is.na(codes)]) else TRUE
  if (anyDuplicated(lbls[real_codes])) {
    stop("Duplicate labels found: ", paste(lbls, collapse = ", "))
  }

  result <- factor(codes, levels = seq.int(length(breaks) - 1L),
        labels = lbls)
  if (drop) result <- droplevels(result)

  return(result)
}


#' @rdname chop
#' @export
kiru <- chop


#' Chop data precisely (for programmers)
#'
#' `fillet()` calls [chop()] with `extend = FALSE` and `drop = FALSE`. This
#' ensures that you get only the `breaks` and `labels` you ask for. When
#' programming, consider using `fillet()` instead of `chop()`.
#'
#' @inheritParams chop
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
fillet <- function (
            x,
            breaks,
            labels    = lbl_intervals(),
            left      = TRUE,
            close_end = TRUE,
            raw       = NULL
          ) {
  chop(x, breaks, labels, left = left, close_end = close_end, extend = FALSE,
      raw = raw, drop = FALSE)
}


#' Chop by quantiles
#'
#' `chop_quantiles()` chops data by quantiles.
#' `chop_deciles()` is a convenience function which chops into deciles.
#'
#' @param probs A vector of probabilities for the quantiles. If `probs` has
#'   names, these will be used for labels.
#' @param ... For `chop_quantiles`, passed to [chop()]. For `brk_quantiles()`,
#'   passed to [stats::quantile()] or [Hmisc::wtd.quantile()].
#' @param weights `NULL` or numeric vector of same length as `x`. If not
#'   `NULL`, [Hmisc::wtd.quantile()] is used to calculate weighted quantiles.
#'
#' @inheritParams chop
#' @inherit chop-doc params return
#'
#' @details
#' For non-numeric `x`, `left` is set to `FALSE` by default. This works better
#' for calculating "type 1" quantiles, since they round down. See
#' [stats::quantile()].
#'
#' If `x` contains duplicates, consecutive quantiles may be the same number
#' so that some intervals get merged.
#'
#' @family chopping functions
#'
#' @export
#' @order 1
#'
#' @examples
#' chop_quantiles(1:10, 1:3/4)
#'
#' chop_quantiles(1:10, c(Q1 = 0, Q2 = 0.25, Q3 = 0.5, Q4 = 0.75))
#'
#' chop(1:10, brk_quantiles(1:3/4))
#'
#' chop_deciles(1:10)
#'
#' # to label by the quantiles themselves:
#' chop_quantiles(1:10, 1:3/4, raw = TRUE)
#'
#' # duplicates:
#' tab_quantiles(c(1, 1, 1, 2, 3), 1:5/5)
#'
chop_quantiles <- function(
                    x,
                    probs,
                    ...,
                    left      = is.numeric(x),
                    raw       = FALSE,
                    weights   = NULL
                  ) {
  chop(x, brk_quantiles(probs, weights = weights), ..., left = left, raw = raw)
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
#' @details
#' `chop_equally()` uses [brk_quantiles()] under the hood. If `x` has duplicate
#' elements, you may get fewer `groups` than requested. If so, a warning will
#' be emitted. See the examples.
#'
#'
#'
#' @family chopping functions
#'
#' @export
#' @order 1
#' @examples
#' chop_equally(1:10, 5)
#'
#' # You can't always guarantee `groups` groups:
#' dupes <- c(1, 1, 1, 2, 3, 4, 4, 4)
#' quantile(dupes, 0:4/4)
#' chop_equally(dupes, 4)
chop_equally <- function (
                  x,
                  groups,
                  ...,
                  labels    = lbl_intervals(),
                  left      = is.numeric(x),
                  close_end = TRUE,
                  raw       = TRUE
                ) {
  chop(x, brk_equally(groups), ..., labels = labels, left = left,
         close_end = close_end, raw = raw)
}


#' Chop by standard deviations
#'
#' Intervals are measured in standard deviations on either side of the
#' mean.
#'
#' In version 0.7.0, these functions changed to specifying `sds` as a vector.
#' To chop 1, 2 and 3 standard deviations around the mean, write
#' `chop_mean_sd(x, sds = 1:3)` instead of `chop_mean_sd(x, sd = 3)`.
#'
#' @param sds Positive numeric vector of standard deviations.
#' @param sd  `r lifecycle::badge("deprecated")`
#'
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
#' @importFrom lifecycle deprecated
chop_mean_sd <- function (
                  x,
                  sds = 1:3,
                  ...,
                  raw = FALSE,
                  sd  = deprecated()
                ) {
  chop(x, brk_mean_sd(sds = sds, sd = sd), ..., raw = raw)
}


#' Chop using pretty breakpoints
#'
#' `chop_pretty()` uses [base::pretty()] to calculate breakpoints
#' which are 1, 2 or 5 times a power of 10. These look nice in graphs.
#'
#' [base::pretty()] tries to return `n+1` breakpoints, i.e. `n` intervals, but
#' note that this is not guaranteed. There are methods for Date and POSIXct
#' objects.
#'
#' For fine-grained control over [base::pretty()] parameters, use
#' `chop(x, brk_pretty(...))`.
#'
#' @inheritParams chop
#' @inherit chop-doc params return
#' @param n Positive integer passed to [base::pretty()]. How many intervals to chop into?
#' @param ... Passed to [chop()] by `chop_pretty()` and `tab_pretty()`; passed
#'   to [base::pretty()] by `brk_pretty()`.
#'
#' @export
#' @order 1
#'
#' @examples
#' chop_pretty(1:10)
#'
#' chop(1:10, brk_pretty(n = 5, high.u.bias = 0))
#'
chop_pretty <- function (x, n = 5, ...) {
  chop(x, brk_pretty(n = n), ...)
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

#' Chop into fixed-sized groups
#'
#' `chop_n()` creates intervals containing a fixed number of elements.
#'
#' @param n Integer. Number of elements in each interval.
#' @inheritParams chop
#' @param tail String. What to do if the final interval has fewer than `n` elements?
#'   `"split"` to keep it separate. `"merge"` to merge it with the neighbouring
#'   interval.
#' @inherit chop-doc params return
#'
#'
#' @details
#'
#' The algorithm guarantees that intervals contain no more than `n` elements, so
#' long as there are no duplicates in `x` and `tail = "split"`. It also
#' guarantees that intervals contain no fewer than `n` elements, except possibly
#' the last interval (or first interval if `left` is `FALSE`).
#'
#' To ensure that all intervals contain at least `n` elements (so long as there
#' are at least `n` elements in `x`!) set `tail = "merge"`.
#'
#' If `tail = "split"` and there are intervals containing duplicates with more
#' than `n` elements, a warning is given.
#'
#' @export
#' @order 1
#' @family chopping functions
#' @examples
#' chop_n(1:10, 5)
#'
#' chop_n(1:5, 2)
#' chop_n(1:5, 2, tail = "merge")
#'
#' # too many duplicates
#' x <- rep(1:2, each = 3)
#' chop_n(x, 2)
#'
chop_n <- function (
            x,
            n,
            ...,
            close_end = TRUE,
            tail = "split"
          ) {
  res <- chop(x, brk_n(n, tail = tail), ..., close_end = close_end)
  if (tail == "split" && max(tabulate(res)) > n) {
    warning("Some intervals contain more than ", n, " elements")
  }

  res
}

#' Chop using an existing function
#'
#' `chop_fn()` is a convenience wrapper: `chop_fn(x, foo, ...)`
#' is the same as `chop(x, foo(x, ...))`.
#'
#' @param fn A function which returns a numeric vector of breaks.
#' @param ... Further arguments to `fn`
#' @inheritParams chop
#' @inherit chop-doc params return
#'
#' @export
#' @order 1
#' @family chopping functions
#' @examples
#'
#' if (requireNamespace("scales")) {
#'   chop_fn(rlnorm(10), scales::breaks_log(5))
#'   # same as
#'   # x <- rlnorm(10)
#'   # chop(x, scales::breaks_log(5)(x))
#' }
#'
chop_fn <- function (
             x,
             fn,
             ...,
             extend = NULL,
             left = TRUE,
             close_end = TRUE,
             raw = NULL,
             drop = TRUE
) {
  chop(x, brk_fn(fn, ...), extend = extend, left = left, close_end = close_end,
         raw = raw, drop = drop)
}
