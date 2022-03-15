

#' @rdname chop
#' @export
#' @examples
#' tab(1:10, c(2, 5, 8))
#'
tab <-
  function (
    x,
    breaks,
    labels    = lbl_intervals(),
    extend    = NULL,
    left      = TRUE,
    close_end = FALSE,
    drop      = TRUE
  ) {
  default_table(
    chop(
      x         = x,
      breaks    = breaks,
      labels    = labels,
      extend    = extend,
      left      = left,
      close_end = close_end,
      drop      = drop
    )
  )
}


#' @rdname chop_width
#' @export
#' @order 3
#' @examples
#' tab_width(1:10, 2, start = 0)
#'
tab_width <- function (x, width, start, ..., left = sign(width) > 0) {
  default_table(
    chop_width(
      x     = x,
      width = width,
      start = start,
      ...,
      left  = left
    )
  )
}


#' @rdname chop_evenly
#' @export
#' @order 3
tab_evenly <- function (x, intervals, ..., close_end = TRUE) {
    default_table(
      chop_evenly(
      x         = x,
      intervals = intervals,
      ...,
      close_end = close_end
    )
  )
}


#' @rdname chop_n
#' @export
#' @order 3
#' @examples
#' tab_n(1:10, 5)
#'
#' # fewer elements in one group
#' tab_n(1:10, 4)
#'
tab_n <- function (x, n, ..., close_end = TRUE) {
  default_table(chop_n(x = x, n = n, ..., close_end = close_end))
}


#' @rdname chop_mean_sd
#' @export
#' @order 3
#' @examples
#' tab_mean_sd(1:10)
#'
tab_mean_sd <- function (x, sd = 3, ...) {
  default_table(chop_mean_sd(x = x, sd = sd, ...))
}


#' @rdname chop_quantiles
#' @export
#' @order 3
#' @examples
#' set.seed(42)
#' tab_quantiles(rnorm(100), probs = 1:3/4, label = lbl_intervals(raw = TRUE))
#'
tab_quantiles <-
  function (x, probs, ..., left = is.numeric(x), close_end = TRUE) {
  default_table(
    chop_quantiles(
      x         = x,
      probs     = probs,
      ...,
      left      = left,
      close_end = close_end
    )
  )
}


#' @rdname chop_quantiles
#' @export
#' @order 3
tab_deciles <- function (x, ...) {
  default_table(chop_deciles(x = x, ...))
}


#' @rdname chop_equally
#' @export
#' @order 3
tab_equally <-
  function (x, groups, ..., left = is.numeric(x), close_end = TRUE) {
  default_table(
    chop_equally(
      x = x, groups = groups, ..., left = left, close_end = close_end
    )
  )
}


default_table <- function (x) table(x, useNA = "ifany", dnn = NULL)