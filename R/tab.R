

#' Tabulate data by intervals
#'
#' These functions call their related `kut_xxx` function, and call [table()]
#' on the result.
#'
#' @param ... Passed to `kut`
#'
#' @return A [table()].
#'
#' @export
#'
#' @examples
#' tab(1:10, c(2, 5, 8))
#'
#' tab_mean_sd(1:10)
tab <- function (...) {
  default_table(kut(...))
}


#' @rdname tab
#' @export
tab_width <- function (...) {
  default_table(kut_width(...))
}


#' @rdname tab
#' @export
tab_evenly <- function (...) {
  default_table(kut_evenly(...))
}


#' @rdname tab
#' @export
tab_n <- function (...) {
  default_table(kut_n(...))
}


#' @rdname tab
#' @export
tab_mean_sd <- function (...) {
  default_table(kut_mean_sd(...))
}


default_table <- function (x) table(x, useNA = "ifany")