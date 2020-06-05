

#' @rdname chop_quantiles
#'
#' @export
#' @order 2
brk_quantiles <- function (probs, ...) {
  assert_that(is.numeric(probs), noNA(probs), all(probs >= 0), all(probs <= 1))
  probs <- sort(probs)

  function (x, extend, left, close_end) {
    qs <- stats::quantile(x, probs, na.rm = TRUE, ...)
    if (anyNA(qs)) return(empty_breaks()) # data was all NA

    non_dupes <- ! duplicated(qs)
    qs <- qs[non_dupes]
    probs <- probs[non_dupes]

    # order matters in the stanza below:
    breaks <- create_lr_breaks(qs, left, close_end)
    needs <- needs_extend(breaks, x)
    if (extend %||% (needs & LEFT) > 0) {
      if (
              length(qs) == 0 ||
              qs[1] > -Inf ||
              (qs[1] == -Inf && ! left[1]))
            {
        probs <- c(0, probs)
      }
    }
    if (extend %||% (needs & RIGHT) > 0) {
      if (
              length(qs) == 0 ||
              qs[length(qs)] < Inf ||
              (qs[length(qs)] == Inf && left[length(left)])
            ) {
        probs <- c(probs, 1)
      }
    }
    breaks <- maybe_extend(breaks, x, extend)

    break_labels <- paste0(formatC(probs * 100, format = "fg"), "%")
    attr(breaks, "break_labels") <- break_labels

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
  assert_that(is.count(sd))

  function (x, extend, left, close_end) {
    x_m <- mean(x, na.rm = TRUE)
    x_sd <- sd(x, na.rm = TRUE)

    if (is.na(x_m) || is.na(x_sd) || x_sd == 0) {
      return(empty_breaks())
    }

    s1 <- seq(x_m, x_m - sd * x_sd, - x_sd)
    s2 <- seq(x_m, x_m + sd * x_sd, x_sd)
    breaks <- c(sort(s1), s2[-1])

    breaks <- create_lr_breaks(breaks, left, close_end)
    needs <- needs_extend(breaks, x)
    breaks <- maybe_extend(breaks, x, extend)

    break_labels <- seq(-sd, sd, 1)
    break_labels <- paste0(break_labels, " sd")
    if (extend %||% (needs & LEFT) > 0) {
      break_labels <- c(-Inf, break_labels)
    }
    if (extend %||% (needs & RIGHT) > 0) {
      break_labels <- c(break_labels, Inf)
    }
    attr(breaks, "break_labels") <- break_labels

    breaks
  }
}



#' @rdname chop_width
#' @export
#' @order 2
brk_width <- function (width, start) {
  assert_that(is.number(width), width > 0)

  sm <- missing(start)
  if (! sm) assert_that(is.number(start))

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


#' @name breaks-doc
#' @return A (function which returns an) object of class `breaks`.
NULL


#' Left- or right-closed breaks
#'
#' \lifecycle{questioning}
#'
#' These functions are "questioning" because they clash with the
#' `left` argument to [chop()] and friends.
#'
#' @param breaks A numeric vector.
#'
#' @inherit breaks-doc return
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
brk_right <- function (breaks) {
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
#' @param breaks
#'
#' @inherit breaks-doc return
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

