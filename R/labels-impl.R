
endpoint_labels <- function (breaks, raw, fmt, ...) {
  UseMethod("endpoint_labels")
}


#' @export
endpoint_labels.default <- function (breaks, raw, fmt = NULL, ...) {
  elabels <- scaled_endpoints(breaks, raw = raw)

  elabels <- if (! is.null(fmt)) {
    apply_format(fmt, elabels)
  } else {
    unique_truncation(elabels)
  }

  return(elabels)
}


#' @export
endpoint_labels.Date <- function (breaks, raw, fmt = "%F") {
  elabels <- scaled_endpoints(breaks, raw = raw)
  # this could be a number. If so, a `fmt` for `sprintf`
  # will work fine:
  if (! inherits(elabels, "Date")) return(NextMethod())

  elabels_chr <- apply_format(fmt, elabels)
  minus_inf <- is.infinite(elabels) & elabels < as.Date("1970-01-01")
  plus_inf  <- is.infinite(elabels) & elabels > as.Date("1970-01-01")
  elabels_chr[minus_inf] <- "-Inf"
  elabels_chr[plus_inf]  <- "Inf"

  elabels_chr
}


#' @export
endpoint_labels.POSIXt <- function (breaks, raw, fmt = "%F %H:%M:%S") {
  elabels <- scaled_endpoints(breaks, raw = raw)
  # same comment as endpoint_labels.Date above:
  if (! inherits(elabels, "POSIXt")) return(NextMethod())

  elabels_chr <- apply_format(fmt, elabels)
  minus_inf <- is.infinite(elabels) & elabels < as.POSIXct("1970-01-01")
  plus_inf  <- is.infinite(elabels) & elabels > as.POSIXct("1970-01-01")
  elabels_chr[minus_inf] <- "-Inf"
  elabels_chr[plus_inf]  <- "Inf"

  elabels_chr
}


#' @export
endpoint_labels.quantileBreaks <- function (breaks, raw, fmt = percent) {
  if (raw) return(NextMethod())

  elabels <- scaled_endpoints(breaks, raw = FALSE)
  elabels <- apply_format(fmt, elabels)

  return(elabels)
}


#' @export
endpoint_labels.sdBreaks <- function (breaks, raw, fmt = "%.3g sd") {
  if (raw) return(NextMethod())

  elabels <- scaled_endpoints(breaks, raw = FALSE)
  elabels <- apply_format(fmt, elabels)

  return(elabels)
}


scaled_endpoints <- function (breaks, raw) {
  UseMethod("scaled_endpoints")
}


#' @export
scaled_endpoints.breaks <- function (breaks, raw) {
  if (raw) {
    unclass_breaks(breaks)
  } else {
    attr(breaks, "scaled_endpoints") %||% unclass_breaks(breaks)
  }
}


#' @export
scaled_endpoints.numeric <- function (breaks, raw) {
  if (raw) {
    breaks
  } else {
    attr(breaks, "scaled_endpoints") %||% breaks
  }
}


#' Apply `fmt` to an object
#'
#' @param fmt A one-argument function, or a character string.
#' @param endpoint Endpoints of a break. Various classes.
#'
#' @return A character vector.
#' @noRd
apply_format <- function (fmt, endpoint, ...) {
  UseMethod("apply_format")
}


#' @export
apply_format.function <- function (fmt, endpoint, ...) {
  fmt(endpoint, ...)
}


#' @export
#' @method apply_format character
apply_format.character <- function (fmt, endpoint, ...) {
  UseMethod("apply_format.character", endpoint)
}


#' @export
#' @method apply_format.character default
apply_format.character.default <- function (fmt, endpoint, ...) {
  format(endpoint, fmt, ...)
}


#' @export
#' @method apply_format.character numeric
apply_format.character.numeric <- function (fmt, endpoint, ...) {
  # suppressWarnings avoids "One argument not used" for first/last labels
  # in lbl_dash()
  suppressWarnings(sprintf(fmt, endpoint, ...))
}


#' @export
#' @method apply_format.character character
apply_format.character.character <- function (fmt, endpoint, ...) {
  sprintf(fmt, endpoint, ...)
}


is_format <- function (fmt) is.string(fmt) || is.function(fmt)

on_failure(is_format) <- function(call, env) {
  paste0(deparse(call$fmt), " is not a valid format (a string or function)")
}


#' Truncates `num` to look nice, while preserving uniqueness
#'
#' @param num A numeric vector.
#'
#' @return A character vector
#' @noRd
unique_truncation <- function (num) {
  want_unique <- ! duplicated(num) # "real" duplicates are allowed!
                                   # we keep the first of each duplicate set.

  for (digits in seq(4L, 22L)) {
    res <- formatC(num, digits = digits, width = -1)
    if (anyDuplicated(res[want_unique]) == 0L) break
  }

  if (anyDuplicated(res[want_unique]) > 0L) {
    stop("Could not format breaks to avoid duplicates")
  }

  return(res)
}


em_dash <- function() {
  if (l10n_info()[["UTF-8"]]) "\u2014" else "-"
}

