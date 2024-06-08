
#' @rdname chop_quantiles
#'
#' @export
#' @order 2
brk_quantiles <- function (probs, ..., weights = NULL) {
  assert_that(
          is.numeric(probs),
          noNA(probs),
          all(probs >= 0),
          all(probs <= 1),
          is.null(weights) || is.numeric(weights)
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

    if (any(duplicated(qs))) {
      warning("`x` has non-unique quantiles: break labels may be misleading")
      dupe_middles <- find_duplicated_middles(qs)
      qs <- qs[! dupe_middles]
      probs <- probs[! dupe_middles]
    }

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
