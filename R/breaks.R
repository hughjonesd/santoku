

#' @rdname chop_quantiles
#'
#' @param ... Arguments passed to [quantile()].
#'
#' @export
brk_quantiles <- function (probs, ...) {
  assert_that(is.numeric(probs), noNA(probs), all(probs >= 0), all(probs <= 1))
  probs <- sort(probs)

  function (x, extend) {
    qs <- stats::quantile(x, probs, na.rm = TRUE, ...)
    if (anyNA(qs)) return(empty_breaks()) # data was all NA

    non_dupes <- ! duplicated(qs)
    qs <- qs[non_dupes]
    probs <- probs[non_dupes]

    # order matters in the stanza below:
    breaks <- create_left_breaks(qs)
    if (extend %||% needs_extend(breaks, x)) {
      if (length(qs) == 0 || qs[1] > -Inf) probs <- c(0, probs)
      if (length(qs) == 0 ||qs[length(qs)] < Inf) probs <- c(probs, 1)
    }
    breaks <- maybe_extend(breaks, x, extend)

    break_labels <- paste0(formatC(probs * 100, format = "fg"), "%")
    attr(breaks, "break_labels") <- break_labels

    breaks
  }
}


#' @rdname chop_mean_sd
#' @export
brk_mean_sd <- function (sd = 3) {
  assert_that(is.count(sd))

  function (x, extend) {
    x_m <- mean(x, na.rm = TRUE)
    x_sd <- sd(x, na.rm = TRUE)

    if (is.na(x_m) || is.na(x_sd) || x_sd == 0) {
      return(empty_breaks())
    }

    s1 <- seq(x_m, x_m - sd * x_sd, - x_sd)
    s2 <- seq(x_m, x_m + sd * x_sd, x_sd)
    breaks <- c(sort(s1), s2[-1])

    breaks <- create_left_breaks(breaks)
    was_extended <- extend %||% needs_extend(breaks, x)
    breaks <- maybe_extend(breaks, x, extend)

    break_labels <- seq(-sd, sd, 1)
    break_labels <- paste0(break_labels, " sd")
    if (was_extended) {
      break_labels <- c(-Inf, break_labels, Inf)
    }
    attr(breaks, "break_labels") <- break_labels

    breaks
  }
}



#' @rdname chop_width
#' @export
brk_width <- function (width, start) {
  assert_that(is.number(width), width > 0)

  sm <- missing(start)
  if (! sm) assert_that(is.number(start))

  function (x, extend) {
    if (sm) start <- suppressWarnings(min(x[is.finite(x)]))
    # finite if x has any non-NA finite elements:
    max_x <- suppressWarnings(max(x[is.finite(x)]))

    if (is.finite(start) && is.finite(max_x)) {
      seq_end <- max_x
      if ((max_x - start) %% width != 0 || max_x == start) {
        seq_end <- seq_end + width
      }
      breaks <- seq(start, seq_end, width)
    } else {
      return(empty_breaks())
    }

    breaks <- create_left_breaks(breaks)
    breaks <- maybe_extend(breaks, x, extend)

    breaks
  }
}


#' @rdname chop_width
#' @export
brk_evenly <- function(groups) {
  assert_that(is.count(groups))

  function (x, extend) {
    total_width <- suppressWarnings(max(x[is.finite(x)]) - min(x[is.finite(x)]))
    if (total_width <= 0) return(empty_breaks())
    brk_width(total_width/groups)(x, extend)
  }
}


#' @rdname chop_n
#' @export
brk_n <- function (n) {
  assert_that(is.count(n))

  function (x, extend) {
    xs <- sort(x) # remove NAs
    if (length(xs) < 1L) return(empty_breaks())

    breaks <-  xs[c(seq(1L, length(xs), n), length(xs))]
    breaks <- create_left_breaks(breaks, close_end = TRUE)
    breaks <- maybe_extend(breaks, x, extend)

    breaks
  }
}


#' @name breaks-doc
#' @return A (function which returns an) object of class `breaks`.
NULL


#' Left- or right-closed breaks
#'
#' @param breaks A numeric vector or a function.
#' @param close_end Logical: close the rightmost endpoint (`brk_left()`)
#'   / leftmost endpoint (`brk_right()`)?
#'
#' @inherit breaks-doc return
#'
#' @details
#' `brk_left` and `brk_right` can be used to wrap another `brk_*` function.
#'
#' @name brk-left-right
#'
#' @examples
#' chop(5:7, brk_left(5:7))
#'
#' chop(5:7, brk_right(5:7))
#'
#' chop(5:7, brk_left(5:7, FALSE))
#'
#' # wrapping another `brk_*` function:
#' chop(1:10, brk_right(brk_quantiles(1:3/4)))
#'
NULL


#' @rdname brk-left-right
#' @export
brk_left <- function (breaks, close_end = TRUE) {
  UseMethod("brk_left")
}

#' @rdname brk-left-right
#' @export
brk_right <- function (breaks, close_end = TRUE) {
  UseMethod("brk_right")
}


#' @export
brk_left.numeric <- function (breaks, close_end = TRUE) {
  assert_that(noNA(breaks), is.flag(close_end))
  breaks <- sort(breaks)
  breaks <- create_left_breaks(breaks, close_end)

  function(x, extend) {
    maybe_extend(breaks, x, extend)
  }
}


#' @export
brk_right.numeric <- function (breaks, close_end = TRUE) {
  assert_that(noNA(breaks), is.flag(close_end))
  breaks <- sort(breaks)
  breaks <- create_right_breaks(breaks, close_end)

  function (x, extend) {
    maybe_extend(breaks, x, extend)
  }
}


#' @export
brk_left.function <- function (breaks, close_end = TRUE) {
  assert_that(is.flag(close_end))

  function(x, extend) {
    breaks <- breaks(x, extend) # already contains left/labels and is extended
    create_left_breaks(breaks, close_end)
  }
}


#' @export
brk_right.function <- function (breaks, close_end = TRUE) {
  assert_that(is.flag(close_end))

  function(x, extend) {
    breaks <- breaks(x, extend)
    create_right_breaks(breaks, close_end)
  }
}


#' Create a `breaks` object manually
#'
#' @param breaks A numeric vector which must be sorted.
#' @param left A logical vector, the same length as `breaks`.
#'   Is break left-closed?
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
#' at indices `i`, `i+1`, `left[i]` must be `TRUE` and `left[i+1]` must be
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
brk_manual <- function (breaks, left) {
  assert_that(is.numeric(breaks), noNA(breaks), is.logical(left), noNA(left),
        length(left) == length(breaks))
  breaks <- create_breaks(breaks, left)

  function (x, extend) {
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

