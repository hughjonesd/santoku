#' Hacked version of [vctrs::vec_cast_common()]
#'
#' This is more relaxed than `vctrs` for classes that santoku only needs to
#' compare, such as `ts`, `zoo`, `hexmode`, and `octmode`.
#'
#' @noRd
santoku_cast_common <- function(x, y) {
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
