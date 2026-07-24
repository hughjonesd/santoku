santoku_cast_common_impl <- function(x, y) {
  if (inherits(x, "zoo")) {
    loadNamespace("zoo")
    x <- zoo::coredata(x)
  }
  if (inherits(y, "zoo")) {
    loadNamespace("zoo")
    y <- zoo::coredata(y)
  }

  if (inherits(x, "ts")) x <- unclass(x)
  if (inherits(y, "ts")) y <- unclass(y)

  if (inherits(x, "hexmode") && inherits(y, "hexmode")) return(list(x, y))
  if (inherits(x, "octmode") && inherits(y, "octmode")) return(list(x, y))
  if (inherits(x, "hexmode") || inherits(x, "octmode")) x <- as.numeric(x)
  if (inherits(y, "hexmode") || inherits(y, "octmode")) y <- as.numeric(y)

  if (inherits(x, "Date") && inherits(y, "POSIXct")) {
    return(list(as.POSIXct(x), y))
  }
  if (inherits(x, "POSIXct") && inherits(y, "Date")) {
    return(list(x, as.POSIXct(y)))
  }
  if (
    (inherits(x, "Date") && inherits(y, "Date")) ||
    (inherits(x, "POSIXct") && inherits(y, "POSIXct"))
  ) {
    return(list(x, y))
  }

  x_integer64 <- inherits(x, "integer64")
  y_integer64 <- inherits(y, "integer64")
  if (x_integer64 || y_integer64) {
    loadNamespace("bit64")
    if (x_integer64 && y_integer64) return(list(x, y))

    if (x_integer64 && rlang::is_bare_double(y)) {
      return(list(as.double(x), y))
    }
    if (y_integer64 && rlang::is_bare_double(x)) {
      return(list(x, as.double(y)))
    }

    if (!x_integer64) x <- bit64::as.integer64(x)
    if (!y_integer64) y <- bit64::as.integer64(y)
    return(list(x, y))
  }

  vctrs::vec_cast_common(x, y)
}


#' Hacked version of [vctrs::vec_cast_common()]
#'
#' This is more relaxed than `vctrs` for classes that santoku only needs to
#' compare, such as `ts`, `zoo`, `hexmode`, and `octmode`.
#'
#' @noRd
santoku_cast_common <- function(x, y) {
  UseMethod("santoku_cast_common")
}


#' Internal functions
#'
#' @name santoku-cast
#' @param x,y Vectors to cast.
#'
#' @return A list.
#' @keywords internal
#'
#' These are internal functions. Do not use.
NULL


# The rawNamespace tags mean NAMESPACE gets both S3method() and export().

#' @export
#' @rdname santoku-cast
#' @method santoku_cast_common default
#' @rawNamespace export(santoku_cast_common.default)
santoku_cast_common.default <- function(x, y) {
  santoku_cast_common_impl(x, y)
}


#' @export
#' @rdname santoku-cast
#' @method santoku_cast_common double
#' @rawNamespace export(santoku_cast_common.double)
santoku_cast_common.double <- function(x, y) {
  santoku_cast_common_impl(x, y)
}


#' @export
#' @rdname santoku-cast
#' @method santoku_cast_common Date
#' @rawNamespace export(santoku_cast_common.Date)
santoku_cast_common.Date <- function(x, y) {
  santoku_cast_common_impl(x, y)
}


#' @export
#' @rdname santoku-cast
#' @method santoku_cast_common POSIXct
#' @rawNamespace export(santoku_cast_common.POSIXct)
santoku_cast_common.POSIXct <- function(x, y) {
  santoku_cast_common_impl(x, y)
}


#' @export
#' @rdname santoku-cast
#' @method santoku_cast_common ts
#' @rawNamespace export(santoku_cast_common.ts)
santoku_cast_common.ts <- function(x, y) {
  santoku_cast_common_impl(x, y)
}


#' @export
#' @rdname santoku-cast
#' @method santoku_cast_common zoo
#' @rawNamespace export(santoku_cast_common.zoo)
santoku_cast_common.zoo <- function(x, y) {
  santoku_cast_common_impl(x, y)
}


#' @export
#' @rdname santoku-cast
#' @method santoku_cast_common integer64
#' @rawNamespace export(santoku_cast_common.integer64)
santoku_cast_common.integer64 <- function(x, y) {
  santoku_cast_common_impl(x, y)
}


#' @export
#' @rdname santoku-cast
#' @method santoku_cast_common hexmode
#' @rawNamespace export(santoku_cast_common.hexmode)
santoku_cast_common.hexmode <- function(x, y) {
  santoku_cast_common_impl(x, y)
}


#' @export
#' @rdname santoku-cast
#' @method santoku_cast_common octmode
#' @rawNamespace export(santoku_cast_common.octmode)
santoku_cast_common.octmode <- function(x, y) {
  santoku_cast_common_impl(x, y)
}
