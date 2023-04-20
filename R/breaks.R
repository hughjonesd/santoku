
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

    breaks <- create_lr_breaks(qs, left)

    needs <- needs_extend(breaks, x, extend, left, close_end)
    if ((needs & LEFT) > 0)  probs <- c(0, probs)
    if ((needs & RIGHT) > 0) probs <- c(probs, 1)
    breaks <- extend_and_close(breaks, x, extend, left, close_end)

    class(breaks) <- c("quantileBreaks", class(breaks))
    attr(breaks, "scaled_endpoints") <- probs
    names(breaks) <- names(probs)

    breaks
  }
}


#' @rdname chop_equally
#'
#' @export
#' @order 2
brk_equally <- function (groups) {
  assert_that(is.count(groups))

  brq <- brk_quantiles(seq(0L, groups)/groups)

  function (x, extend, left, close_end) {
    breaks <- brq(x = x, extend = extend, left = left, close_end = close_end)

    if (length(breaks) < groups + 1) {
      warning("Fewer than ", groups, " intervals created")
    }

    breaks
  }
}


#' @rdname chop_mean_sd
#' @export
#' @order 2
#' @importFrom lifecycle deprecated
brk_mean_sd <- function (sds = 1:3, sd = deprecated()) {
  if (lifecycle::is_present(sd)) {
    lifecycle::deprecate_soft(
            when = "0.7.0",
            what = "brk_mean_sd(sd)",
            with = "brk_mean_sd(sds = 'vector of sds')"
          )
    assert_that(is.number(sd), sd > 0)
    # we start from 0 but remove the 0
    # this works for e.g. sd = 0.5, whereas seq(1L, sd, 1L) would not:
    sds <- seq(0L, sd, 1L)[-1]
    if (! sd %in% sds) sds <- c(sds, sd)
  }

  assert_that(is.numeric(sds), all(sds > 0))

  function (x, extend, left, close_end) {
    x_mean <- mean(x, na.rm = TRUE)
    x_sd <- stats::sd(x, na.rm = TRUE)

    if (is.na(x_mean) || is.na(x_sd) || x_sd == 0) {
      return(empty_breaks())
    }

    # add negative sds, then scale them by mean and sd
    sds <- sort(sds)
    sds <- c(-rev(sds), 0, sds)
    breaks <- sds * x_sd + x_mean
    breaks <- create_lr_breaks(breaks, left)

    needs <- needs_extend(breaks, x, extend, left, close_end)
    if ((needs & LEFT) > 0) sds <- c(-Inf, sds)
    if ((needs & RIGHT) > 0) sds <- c(sds, Inf)
    breaks <- extend_and_close(breaks, x, extend, left, close_end)

    class(breaks) <- c("sdBreaks", class(breaks))
    attr(breaks, "scaled_endpoints") <- sds

    breaks
  }
}



#' @rdname chop_pretty
#'
#' @export
#' @order 2
brk_pretty <- function (n = 5, ...) {
  assert_that(is.count(n))

  function (x, extend, left, close_end) {
    breaks <- base::pretty(x, n = n, ...)
    if (length(breaks) == 0 || is.null(breaks)) {
      return(empty_breaks())
    }

    breaks <- create_extended_breaks(breaks, x, extend, left, close_end)

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


#' @rdname chop_n
#' @export
#' @order 2
brk_n <- function (n, tail = "split") {
  assert_that(is.count(n), tail == "split" || tail == "merge")

  function (x, extend, left, close_end) {
    xs <- sort(x, decreasing = ! left, na.last = NA) # remove NAs
    if (length(xs) < 1L) return(empty_breaks())

    dupes <- duplicated(xs)
    breaks <- xs[0] # ensures breaks has type of xs
    last_x <- xs[length(xs)]

    # Idea of the algorithm:
    # Loop:
    # if there are no dupes, just take a sequence of each nth element
    #   starting at 1, and exit
    # if there are remaining dupes, then take the first element
    # set m to the (n+1)th element which would normally be next
    # if element m is a dupe:
    #   - we need to go up, otherwise elements to the left will be in the next
    #     interval, and this interval will be too small
    #   - so set m to the next non-dupe (i.e. strictly larger) element
    # now delete the first m-1 elements
    # And repeat
    while (TRUE) {
      if (! any(dupes)) {
        breaks <- c(breaks, xs[seq(1L, length(xs), n)])
        if (tail == "merge") {
          if (length(xs) %% n > 0) breaks <- breaks[-length(breaks)]
        }
        break
      } else {
        breaks <- c(breaks, xs[1])
        m <- n + 1
        if (length(xs) <= n || all(dupes[-(1:m-1)])) {
          if (tail == "merge") {
            if (length(xs) < n) breaks <- breaks[-length(breaks)]
          }
          break
        }
        if (dupes[m]) {
          m <- m + match(FALSE, dupes[-(1:m)])
        }
        xs <- xs[-(1:(m-1))]
        dupes <- dupes[-(1:(m-1))]
      }
    }

    breaks <- c(breaks, last_x)
    if (! left) breaks <- rev(breaks)
    breaks <- create_extended_breaks(breaks, x, extend, left, close_end)

    breaks
  }
}


#' @param breaks A numeric vector.
#' @name breaks-doc
#' @return A function which returns an object of class `breaks`.
NULL


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
    create_extended_breaks(breaks, x, extend, left, close_end)
  }
}


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


  function (x, extend, left, close_end) {
    if (! left) warning("Ignoring `left` with `brk_manual()`")
    if (close_end) warning("Ignoring `close_end` with `brk_manual()`")
    breaks <- create_breaks(breaks, left_vec)
    breaks <- extend_and_close(breaks, x, extend, left, close_end)
  }
}

#' @rdname chop_fn
#' @export
#' @order 2
brk_fn <- function (fn, ...) {
  assert_that(is.function(fn))

  function (x, extend, left, close_end) {
    breaks <- fn(x, ...)
    # some functions (e.g. quantile()) return a named vector
    # which might create surprise labels:
    breaks <- unname(breaks)
    assert_that(is.numeric(breaks))
    if (length(breaks) == 0) {
      return(empty_breaks())
    }

    breaks <- create_extended_breaks(breaks, x, extend, left, close_end)

    breaks
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
