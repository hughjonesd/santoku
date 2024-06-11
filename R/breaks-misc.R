
#' Create a `breaks` object manually
#'
#' @param breaks A vector, which must be sorted.
#' @param left_vec A logical vector, the same length as `breaks`.
#'   Specifies whether each break is left-closed or right-closed.
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
#' Singleton breaks are created by repeating a number in `breaks`. Singletons
#' must be closed on both sides, so if there is a repeated number
#' at indices `i`, `i+1`, `left[i]` *must* be `TRUE` and `left[i+1]` must be
#' `FALSE`.
#'
#' `brk_manual()` ignores `left` and `close_end` arguments passed in
#' from [chop()], since `left_vec` sets these manually.
#' `extend` and `drop` arguments are respected as usual.
#'
#' @export
#'
#' @examples
#' lbrks <- brk_manual(1:3, rep(TRUE, 3))
#' chop(1:3, lbrks, extend = FALSE)
#'
#' rbrks <- brk_manual(1:3, rep(FALSE, 3))
#' chop(1:3, rbrks, extend = FALSE)
#'
#' brks_singleton <- brk_manual(
#'       c(1,    2,    2,     3),
#'       c(TRUE, TRUE, FALSE, TRUE))
#'
#' chop(1:3, brks_singleton, extend = FALSE)
#'
brk_manual <- function (breaks, left_vec) {
  assert_that(
          is.numeric(breaks),
          noNA(breaks),
          is.logical(left_vec),
          noNA(left_vec),
          length(left_vec) == length(breaks)
        )

  function (x, extend, left, close_end) {
    if (! left) warning("Ignoring `left` with `brk_manual()`")
    if (! close_end) warning("Ignoring `close_end` with `brk_manual()`")
    breaks <- create_breaks(breaks, left_vec)
    breaks <- extend_and_close(breaks, x, extend, left = TRUE, close_end = FALSE)

    breaks
  }
}


#' @rdname chop_fn
#' @export
#' @order 2
brk_fn <- function (fn, ...) {
  assert_that(is.function(fn))

  function (x, extend, left, close_end) {
    breaks <- fn(x, ...)
    # some functions (e.g. quantile()) return a named vector
    # which might create surprise labels:
    breaks <- unname(breaks)
    assert_that(is.numeric(breaks))
    if (length(breaks) == 0) {
      return(empty_breaks())
    }

    breaks <- create_extended_breaks(breaks, x, extend, left, close_end)

    breaks
  }
}


#' @rdname chop_pretty
#'
#' @export
#' @order 2
brk_pretty <- function (n = 5, ...) {
  assert_that(is.count(n))

  function (x, extend, left, close_end) {
    breaks <- base::pretty(x, n = n, ...)
    if (length(breaks) == 0 || is.null(breaks)) {
      return(empty_breaks())
    }

    breaks <- create_extended_breaks(breaks, x, extend, left, close_end)

    breaks
  }
}


#' @rdname chop_mean_sd
#' @export
#' @order 2
#' @importFrom lifecycle deprecated
brk_mean_sd <- function (sds = 1:3, sd = deprecated()) {
  if (lifecycle::is_present(sd)) {
    lifecycle::deprecate_warn(
            when = "0.7.0",
            what = "brk_mean_sd(sd)",
            with = "brk_mean_sd(sds = 'vector of sds')"
          )
    assert_that(is.number(sd), sd > 0)
    # we start from 0 but remove the 0
    # this works for e.g. sd = 0.5, whereas seq(1L, sd, 1L) would not:
    sds <- seq(0L, sd, 1L)[-1]
    if (! sd %in% sds) sds <- c(sds, sd)
  }

  assert_that(is.numeric(sds), all(sds > 0))

  function (x, extend, left, close_end) {
    x_mean <- mean(x, na.rm = TRUE)
    x_sd <- stats::sd(x, na.rm = TRUE)

    if (is.na(x_mean) || is.na(x_sd) || x_sd == 0) {
      return(empty_breaks())
    }

    # add negative sds, then scale them by mean and sd
    sds <- sort(sds)
    sds <- c(-rev(sds), 0, sds)
    breaks <- sds * x_sd + x_mean
    breaks <- create_lr_breaks(breaks, left)

    needs <- needs_extend(breaks, x, extend, left, close_end)
    if ((needs & LEFT) > 0) sds <- c(-Inf, sds)
    if ((needs & RIGHT) > 0) sds <- c(sds, Inf)
    breaks <- extend_and_close(breaks, x, extend, left, close_end)

    class(breaks) <- c("sdBreaks", class(breaks))
    attr(breaks, "scaled_endpoints") <- sds

    breaks
  }
}
