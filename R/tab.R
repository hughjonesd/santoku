

#' Tabulate data by intervals
#'
#' These functions call [chop()] and friends, and call [table()]
#' on the result.
#'
#' @param drop,... Passed to `chop`
#'
#' @return A [table()].
#'
#' @export
#'
#' @examples
#' tab(rnorm(100), -2:2)
tab <- function (...) {
  default_table(chop(...))
}


#' @rdname tab
#' @export
tab_width <- function (...) {
  default_table(chop_width(...))
}


#' @rdname tab
#' @export
tab_size <- function (...) {
  default_table(chop_size(...))
}


default_table <- function (x) table(x, useNA = "ifany")