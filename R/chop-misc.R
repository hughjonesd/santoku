

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

