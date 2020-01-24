

#' Create a chopping function
#'
#' `knife()` returns a one-argument function for chopping data.
#'
#' @param ... Parameters for [chop()].
#'
#' @return A function.
#'
#' @export
#'
#' @examples
#' chop_six <- knife(breaks = -2:2, labels = lbl_seq("A."))
#' chop_six(rnorm(10))
#' chop_six(rnorm(10))
knife <- function (...) {
  list(...) # force evaluation
  function (x) chop(x, ...)
}