

#' Deprecated
#'
#' \lifecycle{soft-deprecated}
#' `knife()` is deprecated in favour of [purrr::partial()].
#'
#' @param ... Parameters for [chop()].
#'
#' @return A function.
#'
#' @export
knife <- function (...) {
  lifecycle::deprecate_warn("0.4.0", "knife()", with = "purrr::partial()",
        id = "knife")
  list(...) # force evaluation
  function (x) chop(x, ...)
}