
#' @rdname chop_quantiles
#'
#' @export
#' @order 2
brk_quantiles <- function (probs, ...) {
  assert_that(
          is.numeric(probs),
          noNA(probs),
          all(probs >= 0),
          all(probs <= 1)
        )
  probs <- sort(probs)

  function (x, extend, left, close_end) {
    dots <- list(...)
    dots$x <- x
    if (! is.numeric(x) && ! "type" %in% names(dots)) dots$type <- 1
    dots$probs <- probs
    dots$na.rm <- TRUE
    qs <- do.call(stats::quantile, dots)

    if (anyNA(qs)) return(empty_breaks()) # data was all NA

    non_dupes <- ! duplicated(qs)
    qs <- qs[non_dupes]
    probs <- probs[non_dupes]

    breaks <- create_lr_breaks(qs, left, close_end)

    needs <- needs_extend(breaks, x, extend)
    if ((needs & LEFT) > 0)  probs <- c(0, probs)
    if ((needs & RIGHT) > 0) probs <- c(probs, 1)
    breaks <- maybe_extend(breaks, x, extend)

    class(breaks) <- c("quantileBreaks", class(breaks))
    attr(breaks, "scaled_endpoints") <- probs

    breaks
  }
}


#' @rdname chop_equally
#'
#' @export
#' @order 2
brk_equally <- function (groups) {
  assert_that(is.count(groups))
  brk_quantiles(seq(0, groups)/groups)
}


#' @rdname chop_mean_sd
#' @export
#' @order 2
brk_mean_sd <- function (sd = 3) {
  assert_that(is.number(sd), sd > 0)

  function (x, extend, left, close_end) {
    x_m <- mean(x, na.rm = TRUE)
    x_sd <- sd(x, na.rm = TRUE)

    if (is.na(x_m) || is.na(x_sd) || x_sd == 0) {
      return(empty_breaks())
    }

    # work out the "sds" first, then scale them by mean and sd
    sds_plus <- seq(0, sd, 1L)
    if (! sd %in% sds_plus) sds_plus <- c(sds_plus, sd)
    sds_minus <- -1 * sds_plus[-1]
    sds_minus <- sort(sds_minus)
    sds <- c(sds_minus, sds_plus)

    breaks <- sds * x_sd + x_m
    breaks <- create_lr_breaks(breaks, left, close_end)

    needs <- needs_extend(breaks, x, extend)
    if ((needs & LEFT) > 0) sds <- c(-Inf, sds)
    if ((needs & RIGHT) > 0) sds <- c(sds, Inf)
    breaks <- maybe_extend(breaks, x, extend)

    class(breaks) <- c("sdBreaks", class(breaks))
    attr(breaks, "scaled_endpoints") <- sds

    breaks
  }
}

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

    breaks <- create_lr_breaks(breaks, left, close_end)
    breaks <- maybe_extend(breaks, x, extend)

    breaks
  }
}


#' Return a sequence of width `width`
#'
#' @param width An object representing a width
#' @param start Element to start from
#' @param until Result must be just long enough to cover this element
#'
#' @return A sequence of breaks
#' @noRd
sequence_width <- function(width, start, until) {
  UseMethod("sequence_width")
}


#' @export
sequence_width.default <- function (width, start, until) {
  breaks <- seq(start, until, width)

  too_short <- if (sign(width) > 0) {
    breaks[length(breaks)] < until
  } else {
    breaks[length(breaks)] > until
  }

  # length(breaks) == 1L captures when start == max_x
  if (too_short || length(breaks) == 1L) {
    breaks <- c(breaks, breaks[length(breaks)] + width)
  }

  breaks
}


#' @export
sequence_width.Period <- function(width, start, until) {
  loadNamespace("lubridate")

  if (as.numeric(until - start) %% as.numeric(width) != 0 || until == start) {
    # extend to cover all data / ensure at least one interval
    until <- lubridate::add_with_rollback(until, width)
  }
  # alternative to seq, using Period arithmetic
  # We find the number n of widths that gets beyond seq_end
  # and add (width * 0:n) to start
  # normally this would be ceiling((seq_end - start)/width)
  # we calculate it roughly using a Duration
  n_intervals <- ceiling((until - start)/lubridate::as.duration(width))
  breaks <- lubridate::add_with_rollback(start, (seq(0, n_intervals) * width))

  last_break <- breaks[length(breaks)]
  too_short <- if (width > 0) {
     last_break < until
  } else {
    last_break > until
  }
  if (too_short) {
    breaks <- c(breaks, lubridate::add_with_rollback(last_break, width))
  }

  breaks
}


#' @rdname chop_width
#' @export
#' @order 2
brk_evenly <- function(intervals) {
  assert_that(is.count(intervals))

  function (x, extend, left, close_end) {
    min_x <- quiet_min(x[is.finite(x)])
    max_x <- quiet_max(x[is.finite(x)])
    if (sign(max_x - min_x) <= 0) return(empty_breaks())

    breaks <- seq(min_x, max_x, length.out = intervals + 1L)
    breaks <- create_lr_breaks(breaks, left, close_end)
    maybe_extend(breaks, x, extend)
  }
}


#' @rdname chop_n
#' @export
#' @order 2
brk_n <- function (n) {
  assert_that(is.count(n))

  function (x, extend, left, close_end) {
    xs <- sort(x) # remove NAs
    if (length(xs) < 1L) return(empty_breaks())

    breaks <-  xs[c(seq(1L, length(xs), n), length(xs))]
    s1tons <- singletons(breaks)
    # gets rid of the first of every "triplet", including overlapping triplets:
    illegal <- which(s1tons[-1] & s1tons[-length(s1tons)])
    if (length(illegal) > 0) breaks <- breaks[-illegal]
    breaks <- create_lr_breaks(breaks, left, close_end)
    breaks <- maybe_extend(breaks, x, extend)

    breaks
  }
}


#' Create a standard set of breaks
#'
#' @inherit breaks-doc params return
#' @export
#'
#' @examples
#'
#' chop(1:10, c(2, 5, 8))
#' chop(1:10, brk_default(c(2, 5, 8)))
#'
brk_default <- function (breaks) {
  assert_that(noNA(breaks))

  function (x, extend, left, close_end) {
    breaks <- create_lr_breaks(breaks, left, close_end)
    maybe_extend(breaks, x, extend)
  }
}


#' @param breaks A numeric vector.
#' @name breaks-doc
#' @return A (function which returns an) object of class `breaks`.
NULL


#' Create a `breaks` object manually
#'
#' @param breaks A vector, which must be sorted.
#' @param left_vec A logical vector, the same length as `breaks`.
#'   Specifies whether each break is left-closed or right-closed.
#'
#' @inherit breaks-doc return
#'
#' @details
#'
#' All breaks must be closed on exactly one side, like `..., x) [x, ...`
#' (left-closed) or `..., x) [x, ...` (right-closed).
#'
#' For example, if `breaks = 1:3` and `left = c(TRUE, FALSE, TRUE)`, then the
#' resulting intervals are \preformatted{
#' T        F       T
#' [ 1,  2 ] ( 2, 3 )
#' }
#'
#' Singleton breaks are created by repeating a number in `breaks`. Singletons
#' must be closed on both sides, so if there is a repeated number
#' at indices `i`, `i+1`, `left[i]` *must* be `TRUE` and `left[i+1]` must be
#' `FALSE`.
#'
#' @export
#'
#' @examples
#' lbrks <- brk_manual(1:3, rep(TRUE, 3))
#' chop(1:3, lbrks, extend = FALSE)
#'
#' rbrks <- brk_manual(1:3, rep(FALSE, 3))
#' chop(1:3, rbrks, extend = FALSE)
#'
#' brks_singleton <- brk_manual(
#'       c(1,    2,    2,     3),
#'       c(TRUE, TRUE, FALSE, TRUE))
#'
#' chop(1:3, brks_singleton, extend = FALSE)
#'
brk_manual <- function (breaks, left_vec) {
  assert_that(
          is.numeric(breaks),
          noNA(breaks),
          is.logical(left_vec),
          noNA(left_vec),
          length(left_vec) == length(breaks)
        )
  breaks <- create_breaks(breaks, left_vec)

  function (x, extend, left, close_end) {
    if (! left) warning("Ignoring `left` with `brk_manual()`")
    if (close_end) warning("Ignoring `close_end` with `brk_manual()`")
    maybe_extend(breaks, x, extend)
  }
}


#' Class representing a set of intervals
#'
#' @param x A breaks object
#' @param ... Unused
#'
#' @name breaks-class
NULL


#' @rdname breaks-class
#' @export
format.breaks <- function (x, ...) {
  if (length(x) < 2) return("Breaks object: no complete intervals")
  paste0("Breaks object: ", paste(lbl_intervals()(x), collapse = " "))
}


#' @rdname breaks-class
#' @export
print.breaks <- function (x, ...) cat(format(x, ...))


#' @rdname breaks-class
#' @export
is.breaks <- function (x, ...) inherits(x, "breaks")

on_failure(is.breaks) <- function (call, env) {
  paste0(deparse(call$x), " is not an object of class `breaks`")
}
