
#' @rdname chop_quantiles
#'
#' @export
#' @order 2
brk_quantiles <- function (probs, ..., weights = NULL, recalc_probs = FALSE) {
  assert_that(
          is.numeric(probs),
          noNA(probs),
          all(probs >= 0),
          all(probs <= 1),
          is.null(weights) || is.numeric(weights),
          is.flag(recalc_probs)
        )
  probs <- sort(probs)

  function (x, extend, left, close_end) {
    dots <- list(...)
    dots$x <- x
    if (! is.numeric(x) && ! "type" %in% names(dots)) dots$type <- 1
    dots$probs <- probs
    dots$na.rm <- TRUE

    qs <- if (is.null(weights)) {
      do.call(stats::quantile, dots)
    } else {
      rlang::check_installed("Hmisc",
                             reason = "to use `weights` in brk_quantiles()")
      dots$weights <- weights
      do.call(Hmisc::wtd.quantile, dots)
    }

    if (anyNA(qs)) return(empty_breaks()) # data was all NA

    if (anyDuplicated(qs) > 0L) {
      if (! recalc_probs) {
        warning("`x` has duplicate quantiles: break labels may be misleading")
      }
      # We use the left-most probabilities, so e.g. if 0%, 20% and 40% quantiles
      # are all the same number, we'll use the category [0%, 20%).
      # This means we always return intervals that the user asked for, though
      # they may be more misleading than e.g. [0%, 40%).
      illegal_dupes <- find_illegal_duplicates(qs)
      qs <- qs[! illegal_dupes]
      probs <- probs[! illegal_dupes]
    }

    breaks <- create_lr_breaks(qs, left)

    needs <- needs_extend(breaks, x, extend, left, close_end)
    if ((needs & LEFT) > 0)  probs <- c(0, probs)
    if ((needs & RIGHT) > 0) probs <- c(probs, 1)
    breaks <- extend_and_close(breaks, x, extend, left, close_end)

    class(breaks) <- c("quantileBreaks", class(breaks))

    if (recalc_probs) {
      probs <- calculate_ecdf_probs(x, breaks, weights)
    }

    attr(breaks, "scaled_endpoints") <- probs
    names(breaks) <- names(probs)

    breaks
  }
}


#' Calculate the proportions of `x` that is strictly/weakly less than
#' each break
#'
#' @param x A numeric vector
#' @param breaks A breaks object
#' @param weights A vector of weights. Non-NULL weights are unimplemented
#'
#' @return A vector of proportions of `x` that are strictly less than
#' left-closed breaks, and weakly less than right-closed breaks.
#'
#' @noRd
calculate_ecdf_probs <- function (x, breaks, weights) {
  if (! is.numeric(x)) {
    stop("`recalc_probs = TRUE` can only be used with numeric `x`")
  }
  if (! is.null(weights)) {
    stop("`recalc_probs = TRUE` cannot be used with non-null `weights`")
  }

  brk_vec <- unclass_breaks(breaks)
  left_vec <- attr(breaks, "left")

  # proportion of x that is weakly less than x
  prop_lte_brk <- stats::ecdf(x)(brk_vec)
  # proportion of x that is strictly less than x
  prop_lt_brk <- 1 - stats::ecdf(-x)(-brk_vec)
  probs <- ifelse(left_vec, prop_lt_brk, prop_lte_brk)

  # Suppose your breaks are [a, b].
  # You want to expand this?
  probs
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

    maybe_merge_tail <- function (breaks, tail) {
      if (tail == "merge" && length(breaks) > 1) {
        breaks <- breaks[-length(breaks)]
      }
      breaks
    }

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
        if (length(xs) %% n > 0) {
          breaks <- maybe_merge_tail(breaks, tail)
        }
        break
      }
      breaks <- c(breaks, xs[1])
      m <- n + 1
      if (length(xs) <= n || all(dupes[-seq_len(m - 1)])) {
        if (length(xs) < n) {
          breaks <- maybe_merge_tail(breaks, tail)
        }
        break
      }
      if (dupes[m]) {
        # the first non-dupe will be the next element that is different
        # we know there is one, because we checked above
        m <- m + match(FALSE, dupes[-(1:m)])
      }
      discard <- seq_len(m - 1)
      xs <- xs[-discard]
      dupes <- dupes[-discard]
    }

    breaks <- c(breaks, last_x)
    if (! left) breaks <- rev(breaks)
    breaks <- create_extended_breaks(breaks, x, extend, left, close_end)

    breaks
  }
}
