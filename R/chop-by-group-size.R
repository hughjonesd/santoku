
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
#' @param use_ecdf Logical. Recalculate probabilities of quantiles using
#'   [`ecdf(x)`][stats::ecdf()]? See below.
#'
#' @inheritParams chop
#' @inherit chop-doc params return
#'
#' @details
#' For non-numeric `x`, `left` is set to `FALSE` by default. This works better
#' for calculating "type 1" quantiles, since they round down. See
#' [stats::quantile()].
#'
#' By default, `chop_quantiles()` shows the requested probabilities in the
#' labels. To show the numeric quantiles themselves, set `raw = TRUE`.
#'
#' When `x` contains duplicates, consecutive quantiles may be the same number. If
#' so, interval labels may be misleading, and if `use_ecdf = FALSE` a warning is
#' emitted. Set `use_ecdf = TRUE` to recalculate the probabilities of the quantiles
#' using the [empirical cumulative distribution function][stats::ecdf()] of `x`.
#' Doing so may give you different labels from what you expect, and will
#' remove any names from `probs`. See the example below.
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
#' # duplicate quantiles:
#' x <- c(1, 1, 1, 2, 3)
#' quantile(x, 1:5/5)
#' tab_quantiles(x, 1:5/5)
#' tab_quantiles(x, 1:5/5, use_ecdf = TRUE)
chop_quantiles <- function(
                    x,
                    probs,
                    ...,
                    labels    = if (raw) lbl_intervals() else
                                         lbl_intervals(single = NULL),
                    left      = is.numeric(x),
                    raw       = FALSE,
                    weights   = NULL,
                    use_ecdf  = FALSE
                  ) {
  chop(x, brk_quantiles(probs, weights = weights, use_ecdf = use_ecdf),
       labels = labels, ..., left = left, raw = raw)
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

