

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
tab <- function (..., drop = FALSE) {
  default_table(chop(..., drop = drop))
}


#' @rdname tab
#' @export
tab_width <- function (..., drop = FALSE) {
  default_table(chop_width(..., drop = drop))
}


#' @rdname tab
#' @export
tab_size <- function (..., drop = FALSE) {
  default_table(chop_size(..., drop = drop))
}


default_table <- function (x) table(x, useNA = "ifany")