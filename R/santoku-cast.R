

#' Hacked version of [vctrs::vec_cast_common()]
#'
#' This almost always defers to `vctrs::vec_cast_common()`.
#' As of version 0.7.0.9000 it picks up on `ts` objects
#' and `integer64` objects.
#'
#' @param x,y Vectors to cast
#'
#' @return A list of two vectors
#'
#' @noRd
#'
santoku_cast_common <- function (x, y) {
  UseMethod("santoku_cast_common")
}


#' @export
santoku_cast_common.default <- function (x, y) {
  UseMethod("santoku_cast_common.default", object = y)
}


#' @export
santoku_cast_common.default.default <- function (x, y) {
  vctrs::vec_cast_common(x, y)
}

# Specific default.x methods are in their sections below.

#' @export
santoku_cast_common.ts <- function (x, y) {
  UseMethod("santoku_cast_common.ts", object = y)
}


#' @export
santoku_cast_common.ts.default <- function (x, y) {
  # We recall so that we can pick up anything
  # unusual in y
  santoku_cast_common(unclass(x), y)
}


#' @export
santoku_cast_common.default.ts <- function (x, y) {
  santoku_cast_common(x, unclass(y))
}


#' @export
santoku_cast_common.integer64 <- function (x, y) {
  UseMethod("santoku_cast_common.integer64", object = y)
}


#' @export
santoku_cast_common.integer64.integer64 <- function (x, y) {
  list(x, y)
}


#' @export
santoku_cast_common.integer64.default <- function (x, y) {
  loadNamespace("bit64")
  santoku_cast_common(x, bit64::as.integer64(y))
}


#' @export
santoku_cast_common.default.integer64 <- function (x, y) {
  loadNamespace("bit64")
  santoku_cast_common(bit64::as.integer64(x), y)
}


#' @export
santoku_cast_common.hexmode <- function (x, y) {
  UseMethod("santoku_cast_common.hexmode", object = y)
}


#' @export
santoku_cast_common.hexmode.hexmode <- function (x, y) {
  # if both items are hexmode, OK fine.
  list(x, y)
}


#' @export
santoku_cast_common.hexmode.default <- function (x, y) {
  santoku_cast_common(as.numeric(x), y)
}


#' @export
santoku_cast_common.default.hexmode <- function (x, y) {
  santoku_cast_common(x, as.numeric(y))
}
