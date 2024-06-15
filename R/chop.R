

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
#' @param breaks A numeric vector of cut-points, or a function to create
#'   cut-points from `x`.
#' @param labels A character vector of labels or a function to create labels.
#' @param extend Logical. If `TRUE`, always extend breaks to `+/-Inf`. If `NULL`,
#'   extend breaks to `min(x)` and/or `max(x)` only if necessary. If `FALSE`, never
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
#' If it is a vector, `breaks` gives the interval endpoints. Repeating a value
#' creates a "singleton" interval, which contains only that value.
#' For example `breaks = c(1, 3, 3, 5)` creates 3 intervals:
#' \code{[1, 3)}, \code{{3}} and \code{(3, 5]}.
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
#'   \code{[b1, b2), [b2, b3) ... [b_(n-1), b_n]}.
#' * If `left` is `FALSE` and `close_end` is `TRUE`, breaks will look like
#'    \code{[b1, b2], (b2, b3] ... (b_(n-1), b_n]}.
#' * If `left` is `TRUE` and `close_end` is `FALSE`, all breaks will look like
#'   \code{... [b1, b2) ...}.
#' * If `left` is `FALSE` and `close_end` is `FALSE`, all breaks will look like
#'   \code{... (b1, b2] ...}.
#'
#' ## Extending intervals
#'
#' If `extend` is `TRUE`, intervals will be extended to \code{[-Inf,
#' min(breaks))} and \code{(max(breaks), Inf]}.
#'
#' If `extend` is `NULL` (the default), intervals will be extended to
#' \code{[min(x), min(breaks))} and \code{(max(breaks), max(x)]}, only if
#' necessary, i.e. only if elements of `x` would be outside the unextended
#' breaks.
#'
#' If `extend` is `FALSE`, intervals are never extended.
#'
#' Note that even when `extend = TRUE`, extended intervals will be
#' dropped from the factor levels if they contain no elements and `drop = TRUE`.
#'
#' `close_end` is only relevant if intervals are not extended;
#' extended intervals are always closed on the outside. This is a change from
#' previous behaviour. Up to version 0.8.0, `close_end` was applied to the
#' last user-specified interval, before any extended intervals were created.
#'
#' Since 1.1.0, infinity is represented as \eqn{\infty}{the infinity symbol} 
#' in breaks on unicode platforms. Set  `options(santoku.infinity = "Inf")` 
#' to get the old behaviour.
#'
#' ## Labels
#'
#' `labels` may be a character vector. It should have the same length as the
#' (possibly extended) number of intervals. Alternatively, `labels` may be a
#' `lbl_*` function such as [lbl_dash()].
#'
#' If `breaks` is a named vector, then names of `breaks` will be
#' used as labels for the interval starting at the corresponding element. This
#' overrides the `labels` argument (but unnamed breaks will still use `labels`).
#' This feature is `r lifecycle::badge("experimental")`.
#'
#' If `labels` is `NULL`, then integer codes will be returned instead of a
#' factor.
#'
#' If `raw` is `TRUE`, labels will show the actual interval endpoints, usually
#' numbers. If `raw` is `FALSE` then labels may show other objects, such
#' as quantiles for [chop_quantiles()] and friends, proportions of the range for
#' [chop_proportions()], or standard deviations for [chop_mean_sd()].
#'
#'  If `raw` is `NULL` then `lbl_*` functions will use their default (usually
#'  `FALSE`). Otherwise, the `raw` argument to `chop()` overrides `raw` arguments
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
