

#' Deprecated
#'
#' `knife()` is deprecated in favour of [purrr::partial()].
#'
#' @param ... Parameters for [chop()].
#'
#' @return A function.
#'
#' @export
knife <- function (...) {
  .Deprecated("purrr::partial")
  list(...) # force evaluation
  function (x) chop(x, ...)
}