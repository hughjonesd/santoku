

#' Replaces labels with names from the breaks vector
#'
#' Only non-zero-char names are used.
#'
#' @param labels Passed in from chop, possibly via a `lbl_*` function
#' @param breaks Breaks object created via a `brk_*` function. Some of
#'   these preserve names of a given argument (`brk_default()`,
#'   `brk_proportions()`, `brk_quantiles()`)
#'
#' @return The altered labels
#' @noRd
#'
add_break_names <- function(labels, breaks) {
  if (is.null(names(breaks))) return(labels)

  is_named <- nzchar(names(breaks))
  # These are possibly-extended breaks; last break is the rightmost endpoint
  # and any name is ignored:
  is_named[length(is_named)] <- FALSE
  break_names_for_labels <- names(breaks)[is_named]

  # length(labels) == length(breaks) - 1
  is_named <- is_named[-length(is_named)]
  labels[is_named] <- break_names_for_labels

  return(labels)
}


#' Return formatted strings for endpoints
#'
#' Methods will pick up a `scaled_endpoints`
#' attribute if one exists. This provides the numbers
#' for when `raw = FALSE`.
#'
#' Different breaks subclasses may have different default formats.
#'
#' A `.numeric` method exists so that formatted labels can be created
#' from e.g. midpoints or other things that aren't breaks
#' themselves.
#'
#' @param breaks Either a breaks object, or a numeric vector
#' @param raw Report raw numbers instead of e.g. quantiles?
#' @param fmt Format string or function
#' @param ... Not used
#'
#' @return A character vector of break endpoints.
#' @noRd
#'
endpoint_labels <- function (breaks, raw, fmt = NULL, ...) {
  UseMethod("endpoint_labels")
}


#' @export
endpoint_labels.numeric <- function (breaks, raw, fmt = NULL, ...) {
  elabels <- scaled_endpoints(breaks, raw = raw)

  elabels <- if (! is.null(fmt)) {
    apply_format(fmt, elabels)
  } else {
    unique_truncation(elabels)
  }

  return(elabels)
}


#' @export
endpoint_labels.integer <- endpoint_labels.numeric

#' @export
endpoint_labels.double <- endpoint_labels.numeric


#' @export
endpoint_labels.default <- function (breaks, raw, fmt = NULL, ...) {
  elabels <- scaled_endpoints(breaks, raw = raw)

  elabels <- if (! is.null(fmt)) {
    apply_format(fmt, elabels)
  } else {
    base::format(elabels)
  }

  return(elabels)
}


#' @export
endpoint_labels.Date <- function (breaks, raw, fmt = NULL, ...) {
  elabels <- scaled_endpoints(breaks, raw = raw)
  # this could be a number. If so, a `fmt` for `sprintf`
  # will work fine:
  if (! inherits(elabels, "Date")) return(NextMethod())

  # set default format
  if (is.null(fmt)) fmt <- "%F"

  elabels_chr <- apply_format(fmt, elabels)
  minus_inf <- is.infinite(elabels) & elabels < as.Date("1970-01-01")
  plus_inf  <- is.infinite(elabels) & elabels > as.Date("1970-01-01")
  elabels_chr[minus_inf] <- "-Inf"
  elabels_chr[plus_inf]  <- "Inf"

  elabels_chr
}


#' @export
endpoint_labels.POSIXt <- function (breaks, raw, fmt = NULL, ...) {
  elabels <- scaled_endpoints(breaks, raw = raw)
  # same comment as endpoint_labels.Date above:
  if (! inherits(elabels, "POSIXt")) return(NextMethod())

  # set default format
  if (is.null(fmt)) fmt <- "%F %H:%M:%S"

  elabels_chr <- apply_format(fmt, elabels)
  minus_inf <- is.infinite(elabels) & elabels < as.POSIXct("1970-01-01")
  plus_inf  <- is.infinite(elabels) & elabels > as.POSIXct("1970-01-01")
  elabels_chr[minus_inf] <- "-Inf"
  elabels_chr[plus_inf]  <- "Inf"

  elabels_chr
}


#' @export
endpoint_labels.quantileBreaks <- function (breaks, raw, fmt = NULL, ...) {
  if (raw) return(NextMethod())

  # set default format
  if (is.null(fmt)) fmt <- percent

  elabels <- scaled_endpoints(breaks, raw = FALSE)
  elabels <- apply_format(fmt, elabels)

  return(elabels)
}


#' @export
endpoint_labels.sdBreaks <- function (breaks, raw, fmt = NULL, ...) {
  if (raw) return(NextMethod())

  # set default format
  if (is.null(fmt)) fmt <- "%.3g sd"

  elabels <- scaled_endpoints(breaks, raw = FALSE)
  elabels <- apply_format(fmt, elabels)

  return(elabels)
}


#' Return numeric (or whatever) endpoints of breaks, possibly scaled
#'
#' @param breaks Breaks or numeric object
#' @param raw Logical. If `FALSE`, return endpoints scaled as e.g. sds or
#'   quantiles
#'
#' @return Numbers, dates, etc. with no `breaks` class.
#' @noRd
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
scaled_endpoints.default <- function (breaks, raw) {
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
  base::format(endpoint, fmt, ...)
}


#' @export
#' @method apply_format.character numeric
apply_format.character.numeric <- function (fmt, endpoint, ...) {
  sprintf(fmt, endpoint, ...)
}


#' @export
#' @method apply_format.character character
apply_format.character.character <- function (fmt, endpoint, ...) {
  sprintf(fmt, endpoint, ...)
}


#' @export
#' @method apply_format list
apply_format.list <- function (fmt, endpoint, ...) {
  UseMethod("apply_format.list", endpoint)
}


#' @export
#' @method apply_format.list default
apply_format.list.default <- function (fmt, endpoint, ...) {
  do.call(base::format, c(list(x = endpoint), fmt))
}


is_format <- function (fmt) is.string(fmt) || is.function(fmt) || is.list(fmt)

on_failure(is_format) <- function(call, env) {
  paste0(deparse(call$fmt), " is not a valid format (a string, list or function)")
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
    res <- formatC(num, digits = digits, width = -1L)
    if (anyDuplicated(res[want_unique]) == 0L) return(res)
  }

  stop("Could not format breaks to avoid duplicates")
}


em_dash <- function() {
  if (l10n_info()[["UTF-8"]]) "\u2014" else "-"
}