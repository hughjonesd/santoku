

#' Hacked version of [vctrs::vec_cast_common()]
#'
#' @param x,y Vectors to cast
#'
#' @return A list of two vectors of the same class; or
#' errors, if that isn't possible.
#'
#' This almost always defers to `vctrs::vec_cast_common()`.
#'
#' Often, we are more relaxed than `vctrs` because
#' we have a more specific use case (comparing numeric
#' values). So e.g. we're fine with comparing a `ts`
#' object to a number, whereas other binary
#' operations might not make sense.
#'
#' @noRd
#'
santoku_cast_common <- function (x, y) {
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


# The rawNamespace below means NAMESPACE gets both the S3method() and the
# export() tag.

#' @export
#' @rdname santoku-cast
#' @method santoku_cast_common default
#' @rawNamespace export(santoku_cast_common.default)
santoku_cast_common.default <- function (x, y) {
  UseMethod("santoku_cast_common.default", object = y)
}


#' @export
santoku_cast_common.default.default <- function (x, y) {
  vctrs::vec_cast_common(x, y)
}

# Specific default.x methods are in their sections below.


# ==== double ====

# We have specific double methods just to catch bit64 objects

#' @export
#' @rdname santoku-cast
#' @method santoku_cast_common double
#' @rawNamespace export(santoku_cast_common.double)
santoku_cast_common.double <- function (x, y) {
  UseMethod("santoku_cast_common.double", object = y)
}


#' @export
santoku_cast_common.double.default <- function (x, y) {
  # almost always delegate to default
  santoku_cast_common.default(x, y)
}


#' @export
santoku_cast_common.double.integer64 <- function (x, y) {
  loadNamespace("bit64")
  # we cast the integer64 to double.
  # See santoku_cast_common.integer64.double below for why.
  list(x, as.double(y))
}


# ==== Date ====

# We delegate to vctrs for Date+numeric (which gives an error)
# Not obvious how to interpret conversion of Date to numeric


#' @export
#' @rdname santoku-cast
#' @method santoku_cast_common Date
#' @rawNamespace export(santoku_cast_common.Date)
santoku_cast_common.Date <- function (x, y) {
  UseMethod("santoku_cast_common.Date", object = y)
}


#' @export
santoku_cast_common.Date.Date <- function (x, y) {
  list(x, y)
}


#' @export
santoku_cast_common.Date.POSIXct <- function (x, y) {
  list(as.POSIXct(x), y)
}


# ==== POSIXct ====

# We delegate to vctrs for POSIXct/numeric, see Date above

#' @export
#' @rdname santoku-cast
#' @method santoku_cast_common POSIXct
#' @rawNamespace export(santoku_cast_common.POSIXct)
santoku_cast_common.POSIXct <- function (x, y) {
  UseMethod("santoku_cast_common.POSIXct", object = y)
}


#' @export
santoku_cast_common.POSIXct.POSIXct <- function (x, y) {
  list(x, y)
}


#' @export
santoku_cast_common.POSIXct.Date <- function (x, y) {
  list(x, as.POSIXct(y))
}


# ==== ts ====

#' @export
#' @rdname santoku-cast
#' @method santoku_cast_common ts
#' @rawNamespace export(santoku_cast_common.ts)
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


# ==== zoo ====

#' @export
#' @rdname santoku-cast
#' @method santoku_cast_common zoo
#' @rawNamespace export(santoku_cast_common.zoo)
santoku_cast_common.zoo <- function (x, y) {
  UseMethod("santoku_cast_common.zoo", object = y)
}

# we don't have a zoo.zoo method because returning
# two zoo objects would cause comparisons to only
# work where the indices are the same. So, we always
# work on the underlying data.

#' @export
santoku_cast_common.zoo.default <- function (x, y) {
  loadNamespace("zoo")
  santoku_cast_common(zoo::coredata(x), y)
}

#' @export
santoku_cast_common.default.zoo <- function (x, y) {
  loadNamespace("zoo")
  santoku_cast_common(x, zoo::coredata(y))
}


# ==== integer64 ====

#' @export
#' @rdname santoku-cast
#' @method santoku_cast_common integer64
#' @rawNamespace export(santoku_cast_common.integer64)
santoku_cast_common.integer64 <- function (x, y) {
  UseMethod("santoku_cast_common.integer64", object = y)
}


#' @export
santoku_cast_common.integer64.integer64 <- function (x, y) {
  list(x, y)
}


#' @export
santoku_cast_common.integer64.double <- function (x, y) {
  loadNamespace("bit64")
  # we cast the integer64 to double.
  # This may lose precision, but if so, it gives a warning.
  # If we cast double to integer64, then
  # e.g. chop(as.integer64(1:5), 2.5)
  # silently converts 2.5 to 2 and gives a wrong answer
  list(as.double(x), y)
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


# ==== hexmode ====

#' @export
#' @rdname santoku-cast
#' @method santoku_cast_common hexmode
#' @rawNamespace export(santoku_cast_common.hexmode)
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


# ==== octmode ====

#' @export
#' @rdname santoku-cast
#' @method santoku_cast_common octmode
#' @rawNamespace export(santoku_cast_common.octmode)
santoku_cast_common.octmode <- function (x, y) {
  UseMethod("santoku_cast_common.octmode", object = y)
}


#' @export
santoku_cast_common.octmode.octmode <- function (x, y) {
  list(x, y)
}


#' @export
santoku_cast_common.octmode.default <- function (x, y) {
  santoku_cast_common(as.numeric(x), y)
}


#' @export
santoku_cast_common.default.octmode <- function (x, y) {
  santoku_cast_common(x, as.numeric(y))
}