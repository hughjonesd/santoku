

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
    qs <- stats::quantile(x, probs, na.rm = TRUE, ...)

    if (anyNA(qs)) return(empty_breaks()) # data was all NA

    non_dupes <- ! duplicated(qs)
    qs <- qs[non_dupes]
    probs <- probs[non_dupes]

    # order matters in the stanza below:
    breaks <- create_lr_breaks(qs, left, close_end)
    left_vec <- attr(breaks, "left")
    needs <- needs_extend(breaks, x)
    if (extend %||% (needs & LEFT) > 0) {
      if (
              length(qs) == 0 ||
              qs[1] > -Inf ||
              (qs[1] == -Inf && ! left_vec[1]))
            {
        probs <- c(0, probs)
      }
    }
    if (extend %||% (needs & RIGHT) > 0) {
      if (
              length(qs) == 0 ||
              qs[length(qs)] < Inf ||
              (qs[length(qs)] == Inf && left_vec[length(left_vec)])
            ) {
        probs <- c(probs, 1)
      }
    }
    breaks <- maybe_extend(breaks, x, extend)

    class(breaks) <- c("quantileBreaks", class(breaks))
    attr(breaks, "scaled_endpoints") <- probs * 100

    breaks
  }
}


#' @rdname chop_quantiles
#'
#' @export
#' @order 3
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
    needs <- needs_extend(breaks, x)
    breaks <- maybe_extend(breaks, x, extend)

    if (extend %||% (needs & LEFT) > 0) {
      sds <- c(-Inf, sds)
    }
    if (extend %||% (needs & RIGHT) > 0) {
      sds <- c(sds, Inf)
    }

    class(breaks) <- c("sdBreaks", class(breaks))
    attr(breaks, "scaled_endpoints") <- sds

    breaks
  }
}

#' Equal-width intervals for dates or datetimes
#'
#' `brk_width` can be used with time interval classes from base R or the
#' `lubridate` package.
#'
#' @name brk_width-for-datetime
#'
#' @param width A [difftime()], [lubridate::Period] or [lubridate::Duration]
#'   object
#' @param start An object that can be converted by [as.POSIXct()]
#'
#' @details
#' If `width` is a Period object, [lubridate::add_with_rollback()] is used
#' to calculate the widths. This can be useful for e.g. calendar months.
#'
#' @examples
#'
#' if (requireNamespace("lubridate")) {
#'   year2001 <- as.Date("2001-01-01") + days(0:364)
#'   tab_width(year2001, months(1))
#' }
#'
NULL

#' @rdname chop_width
#' @export
#' @order 2
brk_width <- function (width, start) UseMethod("brk_width")


#' @rdname brk_width-for-datetime
#' @export
brk_width.difftime <- function (width, start) {
  width <- as.numeric(width, units = "secs")
  if (! missing(start)) start <- as.numeric(as.POSIXct(start))
  NextMethod()
}


#' @rdname brk_width-for-datetime
#' @export
brk_width.Duration <- function (width, start) {
  width <- as.numeric(width)
  if (! missing(start)) start <- as.numeric(as.POSIXct(start))
  NextMethod()
}


#' @rdname brk_width-for-datetime
#' @export
brk_width.Period <- function (width, start) {
  sm <- missing(start)
  if (! sm) {
    assert_that(is.scalar(start))
    start <- as.POSIXct(start)
  }

  # TODO: why not use this same logic for Duration?
  function (x, extend) {
    # x will be numeric, converted via POSIXct.
    x <- as.POSIXct(x, origin = "1970-01-01 00:00.00 UTC")
    if (sm) start <- quiet_min(x[is.finite(x)])
    # finite if x has any non-NA finite elements:
    max_x <- quiet_max(x[is.finite(x)])

    if (is.finite(start) && is.finite(max_x)) {
      seq_end <- max_x
      if (as.numeric(max_x - start) %% as.numeric(width) != 0 ||
          max_x == start) {
        # extend to cover all data / ensure at least one interval
        seq_end <- seq_end %m+% width
      }
      # alternative to seq, using Period arithmetic
      # We find the number n of widths that gets beyond seq_end
      # and add (width * 0:n) to start
      # normally this would be ceiling((seq_end - start)/width)
      # we calculate it roughly using a Duration
      n_intervals <- ceiling((seq_end - start)/as.duration(width))
      breaks <- start %m+% (seq(0, n_intervals) * width)
      if (max(breaks) < seq_end) breaks <- c(breaks, max(breaks) %m+% width)
    } else {
      return(empty_breaks())
    }

    # these now get converted to seconds
    breaks <- create_left_breaks(breaks)
    breaks <- maybe_extend(breaks, x, extend)

    breaks
  }
}

#' @rdname chop_width
#' @export
#' @order 2
brk_width.default <- function (width, start) {
  assert_that(is.scalar(width), width > 0)

  sm <- missing(start)
  if (! sm) assert_that(is.scalar(start))

  function (x, extend, left, close_end) {
    if (sm) start <- quiet_min(x[is.finite(x)])
    # finite if x has any non-NA finite elements:
    max_x <- quiet_max(x[is.finite(x)])
    if (is.finite(start) && is.finite(max_x)) {
      breaks <- seq(start, max_x, width)
      # length(breaks) == 1L captures when start == max_x
      if (breaks[length(breaks)] < max_x || length(breaks) == 1L) {
        breaks <- c(breaks, breaks[length(breaks)] + width)
      }
    } else {
      return(empty_breaks())
    }

    breaks <- create_lr_breaks(breaks, left, close_end)
    breaks <- maybe_extend(breaks, x, extend)

    breaks
  }
}


#' @rdname chop_width
#' @export
#' @order 2
brk_evenly <- function(intervals) {
  assert_that(is.count(intervals))

  function (x, extend, left, close_end) {
    min_x <- quiet_min(x[is.finite(x)])
    max_x <- quiet_max(x[is.finite(x)])
    if (max_x - min_x <= 0) return(empty_breaks())

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
    breaks <- create_lr_breaks(breaks, left, close_end)
    breaks <- maybe_extend(breaks, x, extend)

    breaks
  }
}


#' @param breaks A numeric vector.
#' @name breaks-doc
#' @return A (function which returns an) object of class `breaks`.
NULL


#' Left- or right-closed breaks
#'
#' \lifecycle{questioning}
#'
#' These functions are in the "questioning" stage because they clash with the
#' `left` argument to [chop()] and friends.
#'
#' @inherit breaks-doc params return
#'
#' @name brk-left-right
#'
#' @details
#' These functions override the `left` argument of [chop()].
#'
#' @examples
#' chop(5:7, brk_left(5:7))
#'
#' chop(5:7, brk_right(5:7))
#'
#' chop(5:7, brk_left(5:7))
#'
NULL


#' @export
#' @rdname brk-left-right
brk_left <- function (breaks) {
  if (is.function(breaks)) {
    lifecycle::deprecate_stop("0.4.0", "brk_left.function()",
          details = "Please use the `left` argument to `chop()` instead.")
  }
  assert_that(noNA(breaks))
  breaks <- sort(breaks)

  function(x, extend, left, close_end) {
    if (! left) warning("`left` argument to `brk_left()` ignored")
    breaks <- create_lr_breaks(breaks, left = TRUE, close_end)
    maybe_extend(breaks, x, extend)
  }
}


#' @export
#' @rdname brk-left-right
brk_right <- function (breaks) {
  if (is.function(breaks)) {
    lifecycle::deprecate_stop("0.4.0", "brk_right.function()",
      details = "Please use the `left` argument to `chop()` instead.")
  }
  assert_that(noNA(breaks))
  breaks <- sort(breaks)

  function (x, extend, left, close_end) {
    if (left) warning("`left` argument to `brk_right()` ignored")
    breaks <- create_lr_breaks(breaks, left = FALSE, close_end)
    maybe_extend(breaks, x, extend)
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


#' Create a `breaks` object manually
#'
#' @param breaks A numeric vector which must be sorted.
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
#' Singleton breaks are created by repeating a number in `breaks`.
#' Singletons must be closed on both sides, so if there is a repeated number
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
print.breaks <- function (x, ...) cat(format(x))


#' @rdname breaks-class
#' @export
is.breaks <- function (x, ...) inherits(x, "breaks")

