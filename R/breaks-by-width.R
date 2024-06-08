
#' Equal-width intervals for dates or datetimes
#'
#' `brk_width()` can be used with time interval classes from base R or the
#' `lubridate` package.
#'
#' @param width A scalar [difftime], [Period][lubridate::Period-class] or
#'   [Duration][lubridate::Duration-class] object.
#'
#' @param start A scalar of class [Date] or [POSIXct][DateTimeClasses].
#'   Can be omitted.
#'
#' @details
#' If `width` is a Period, [`lubridate::add_with_rollback()`][`lubridate::m+`]
#' is used to calculate the widths. This can be useful for e.g. calendar months.
#'
#' @examples
#'
#' if (requireNamespace("lubridate")) {
#'   year2001 <- as.Date("2001-01-01") + 0:364
#'   tab_width(year2001, months(1),
#'         labels = lbl_discrete(" to ", fmt = "%e %b %y"))
#' }
#'
#' @name brk_width-for-datetime
NULL


#' @rdname chop_width
#' @export
#' @order 2
brk_width <- function (width, start) UseMethod("brk_width")


#' @rdname brk_width-for-datetime
#' @export
brk_width.Duration <- function (width, start) {
  loadNamespace("lubridate")
  width <- lubridate::make_difftime(as.numeric(width))
  NextMethod()
}


#' @rdname chop_width
#' @export
#' @order 2
brk_width.default <- function (width, start) {
  assert_that(is.scalar(width))

  sm <- missing(start)
  if (! sm) assert_that(is.scalar(start))

  function (x, extend, left, close_end) {
    # finite if x has any non-NA finite elements:
    min_x <- quiet_min(x[is.finite(x)])
    max_x    <- quiet_max(x[is.finite(x)])

    if (sm) {
      start <- if (sign(width) > 0) min_x else max_x
    }
    until <- if (sign(width) > 0) max_x else min_x

    if (is.finite(start) && is.finite(until)) {
      breaks <- sequence_width(width, start, until)
    } else {
      return(empty_breaks())
    }

    if (sign(width) <= 0) breaks <- rev(breaks)

    breaks <- create_extended_breaks(breaks, x, extend, left, close_end)

    breaks
  }
}


#' @rdname chop_evenly
#' @export
#' @order 2
brk_evenly <- function(intervals) {
  assert_that(is.count(intervals))

  function (x, extend, left, close_end) {
    min_x <- quiet_min(x[is.finite(x)])
    max_x <- quiet_max(x[is.finite(x)])
    if (sign(max_x - min_x) <= 0) return(empty_breaks())

    breaks <- seq(min_x, max_x, length.out = intervals + 1L)
    breaks <- create_extended_breaks(breaks, x, extend, left, close_end)

    breaks
  }
}


#' @rdname chop_proportions
#' @export
#' @order 2
brk_proportions <- function(proportions) {
  assert_that(is.numeric(proportions), noNA(proportions),
                all(proportions >= 0), all(proportions <= 1))
  proportions <- sort(proportions)

  function (x, extend, left, close_end) {
    min_x <- quiet_min(x[is.finite(x)])
    max_x <- quiet_max(x[is.finite(x)])
    range_x <- max_x - min_x
    if (sign(range_x) <= 0) return(empty_breaks())

    breaks <- min_x + range_x * proportions
    breaks <- create_lr_breaks(breaks, left)

    scaled_endpoints <- proportions
    needs <- needs_extend(breaks, x, extend, left, close_end)
    if ((needs & LEFT) > 0) scaled_endpoints <- c(0, scaled_endpoints)
    if ((needs & RIGHT) > 0) scaled_endpoints <- c(scaled_endpoints, 1)
    breaks <- extend_and_close(breaks, x, extend, left, close_end)

    attr(breaks, "scaled_endpoints") <- scaled_endpoints
    names(breaks) <- names(scaled_endpoints)

    breaks
  }
}