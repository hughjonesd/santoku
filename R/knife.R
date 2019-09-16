

#' Create a cutting function
#'
#' `knife()` returns a one-argument function for cutting data.
#'
#' @param ... Parameters for [kut()].
#'
#' @export
#'
#' @examples
#' kut_six <- knife(breaks = -2:2, labels = lbl_LETTERS())
#' kut_six(rnorm(10))
#' kut_six(rnorm(10))
knife <- function (...) {
  list(...) # force evaluation
  function (x) kut(x, ...)
}