

#' Syntactic sugar
#'
#' `exactly` lets you write `chop(x, c(1, exactly(2), 3))`. This
#' is the same as `chop(x, c(1, 2, 2, 3))` but conveys your intent more
#' clearly.
#'
#' @param x A numeric vector.
#'
#' @return `rep(x, each = 2)`.
#' @export
#'
#' @examples
#' tab(1:5, exactly(3))
exactly <- function (x) rep(x, each = 2)


singletons <- function (breaks) {
  dv <- diff(breaks)
  dv == 0L | is.nan(dv) # is.nan could be from Inf, Inf
}


`%||%` <- function (x, y) if (is.null(x)) y else x