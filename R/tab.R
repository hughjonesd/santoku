

#' @rdname chop
#' @export
#' @examples
#' tab(1:10, c(2, 5, 8))
#'
tab <- function (
         x,
         breaks,
         labels    = lbl_intervals(),
         extend    = NULL,
         left      = TRUE,
         close_end = TRUE,
         raw       = NULL,
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
      raw       = raw,
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
tab_width <- function (
               x,
               width,
               start,
               ...,
               left = sign(width) > 0
             ) {
  default_table(
    chop_width(x = x, width = width, start = start, ..., left = left)
  )
}


#' @rdname chop_evenly
#' @export
#' @order 3
tab_evenly <- function (
                x,
                intervals,
                ...
              ) {
  default_table(
    chop_evenly(x = x, intervals = intervals, ...)
  )
}


#' @rdname chop_proportions
#' @export
#' @order 3
tab_proportions <- function (
                     x,
                     proportions,
                     ...,
                     raw = TRUE
                   ) {
  default_table(
    chop_proportions(x = x, proportions = proportions, ..., raw = raw)
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
tab_n <- function (
           x,
           n,
           ...,
           tail = "split"
         ) {
  default_table(chop_n(x = x, n = n, ..., tail = tail))
}


#' @rdname chop_mean_sd
#' @export
#' @order 3
#' @examples
#' tab_mean_sd(1:10)
#'
tab_mean_sd <- function (
                 x,
                 sds = 1:3,
                 ...,
                 raw = FALSE
               ) {
  default_table(chop_mean_sd(x = x, sds = sds, ..., raw = raw))
}


#' @rdname chop_pretty
#' @export
#' @order 3
#' @examples
#' tab_pretty(1:10)
#'
tab_pretty <- function (x, n = 5, ...) {
  default_table(chop_pretty(x = x, n = n, ...))
}


#' @rdname chop_quantiles
#' @export
#' @order 3
#' @examples
#' set.seed(42)
#' tab_quantiles(rnorm(100), probs = 1:3/4, raw = TRUE)
#'
tab_quantiles <- function (
                   x,
                   probs,
                   ...,
                   left      = is.numeric(x),
                   raw       = FALSE
                 ) {
  default_table(
    chop_quantiles(x = x, probs = probs, ..., left = left, raw = raw)
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
tab_equally <- function (
                 x,
                 groups,
                 ...,
                 left      = is.numeric(x),
                 raw       = TRUE
               ) {
  default_table(
    chop_equally(x = x, groups = groups, ..., left = left, raw = raw)
  )
}


#' @rdname chop_fn
#' @export
#' @order 3
tab_fn <- function (
            x,
            fn,
            ...,
            extend = NULL,
            left = TRUE,
            close_end = TRUE,
            raw = NULL,
            drop = TRUE
          ) {
  default_table(
    chop_fn(x = x, fn = fn, ..., extend = extend, left = left,
              close_end = close_end, raw = raw, drop = drop)
  )
}


#' @rdname chop_spikes
#' @export
#' @order 3
tab_spikes <- function (
                     x,
                     breaks,
                     n = NULL,
                     prop = NULL,
                     ...
                   ) {
  default_table(
    chop_spikes(x = x, breaks = breaks, n = n, prop = prop, ...)
  )
}


default_table <- function (x) {
  table(x, useNA = "ifany", dnn = NULL)
}