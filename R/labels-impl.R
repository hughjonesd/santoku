
endpoint_labels <- function (breaks, raw, fmt, ...) {
  UseMethod("endpoint_labels")
}


#' @export
endpoint_labels.default <- function (breaks, raw, fmt = NULL, ...) {
  elabels <- scaled_endpoints(breaks, raw = raw)

  elabels <- if (! is.null(fmt)) {
    sprintf(fmt, elabels)
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

  elabels_chr <- format(elabels, fmt)
  minus_inf <- is.infinite(elabels) & elabels < as.Date("1970-01-01")
  plus_inf  <- is.infinite(elabels) & elabels > as.Date("1970-01-01")
  elabels_chr[minus_inf] <- "-Inf"
  elabels_chr[plus_inf]  <- "Inf"

  elabels_chr
}


#' @export
endpoint_labels.POSIXt <- function (breaks, raw, fmt = "%F %X") {
  elabels <- scaled_endpoints(breaks, raw = raw)
  # same comment as endpoint_labels.Date above:
  if (! inherits(elabels, "POSIXt")) return(NextMethod())

  elabels_chr <- format(elabels, fmt)
  minus_inf <- is.infinite(elabels) & elabels < as.POSIXct("1970-01-01")
  plus_inf  <- is.infinite(elabels) & elabels > as.POSIXct("1970-01-01")
  elabels_chr[minus_inf] <- "-Inf"
  elabels_chr[plus_inf]  <- "Inf"

  elabels_chr
}


#' @export
endpoint_labels.quantileBreaks <- function (breaks, raw, fmt = "%.3g%%") {
  if (raw) return(NextMethod())

  elabels <- scaled_endpoints(breaks, raw = FALSE)
  elabels <- sprintf(fmt, elabels)

  return(elabels)
}


#' @export
endpoint_labels.sdBreaks <- function (breaks, raw, fmt = "%.3g s.d.") {
  if (raw) return(NextMethod())

  elabels <- scaled_endpoints(breaks, raw = FALSE)
  elabels <- sprintf(fmt, elabels)

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


#' Truncates `num` to look nice, while preserving uniqueness
#'
#' @param num A numeric vector.
#' @param ... Arguments passed to formatC, except `digits` and `width`.
#'
#' @return A character vector
#' @noRd
unique_truncation <- function (num, ...) {
  want_unique <- ! duplicated(num) # "real" duplicates are allowed!
  # we keep the first of each duplicate set.

  dots <- list(...)
  dots$x <- num
  if (! "width" %in% names(dots)) dots$width <- -1
  if (! "digits" %in% names(dots)) dots$digits <- 4L

  for (digits in seq(dots$digits, 22L)) {
    dots$digits <- digits
    res <- do.call(formatC, dots)
    if (anyDuplicated(res[want_unique]) == 0L) break
  }

  if (anyDuplicated(res[want_unique]) > 0L) {
    stop("Could not format breaks to avoid duplicates")
  }

  return(res)
}
