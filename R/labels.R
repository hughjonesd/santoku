
#' @name label-doc
#' @param fmt A format. Can be a string, passed into [base::sprintf()] or [format()]
#'   methods; or a one-argument formatting function.
#' @param raw Logical. Always use raw `breaks` in labels, rather than e.g. quantiles
#'   or standard deviations?
#' @param symbol String: symbol to use for the dash.
#' @param ... Arguments passed to format methods.
#'
#' @return A vector of labels for `chop`, or a function that creates labels.
NULL


#' @name first-last-doc
#' @param first String: override label for the first category. Passed to
#'   [sprintf()] or [format()], so you can write e.g. `first = "< %s"` to create
#' a label like `"< 18"`.
#' @param last String: override label for the last category. Passed to
#'   [sprintf()] or [format()].
#' @details

NULL


#' Label chopped intervals using set notation
#'
#' @inherit label-doc
#' @inherit first-last-doc
#'
#' @family labelling functions
#'
#' @details
#'
#' Mathematical set notation is as follows:
#'
#' * \code{[a, b]}: all numbers `x` where `a <= x <= b`;
#' * \code{(a, b)}: all numbers where `a < x < b`;
#' * \code{[a, b)}: all numbers where `a <= x < b`;
#' * \code{(a, b]}: all numbers where `a < x <= b`;
#' * \code{{a}}: just the number `a`.
#'
#'
#' @export
#'
#' @examples
#'
#' tab(-10:10, c(-3, 0, 0, 3),
#'       labels = lbl_intervals())
#'
#' tab_evenly(runif(20), 10,
#'       labels = lbl_intervals(fmt = percent))
#'
lbl_intervals <- function (raw = FALSE, fmt = NULL, first = NULL, last = NULL) {
  assert_that(
          is.flag(raw),
          is.string(first) || is.null(first),
          is.string(last) || is.null(last)
        )

  function (breaks) {
    assert_that(is.breaks(breaks))
    left <- attr(breaks, "left")
    # less ugly than do.call:
    elabels <-  if (is.null(fmt)) {
                  endpoint_labels(breaks, raw = raw)
                } else {
                  endpoint_labels(breaks, raw = raw, fmt = fmt)
                }

    len_b <- length(breaks)
    if (len_b < 1L) return(character(0))

    lb <- elabels[-len_b]
    rb <- elabels[-1]
    l_closed <- left[-len_b]
    r_closed <- ! left[-1]

    len_i <- len_b - 1
    singletons <- singletons(breaks)
    left_symbol <- rep("(", len_i)
    left_symbol[l_closed] <- "["

    right_symbol <- rep(")", len_i)
    right_symbol[r_closed] <- "]"

    sets <- paste0(left_symbol, lb, ", ", rb, right_symbol)
    sets[singletons] <- sprintf("{%s}", lb[singletons])

    if (! is.null(first)) {
      sets[1] <- endpoint_labels(breaks[2], raw = raw, fmt = first)
    }
    if (! is.null(last)) {
      sets[length(sets)] <- endpoint_labels(breaks[length(breaks)-1], raw = raw,
                                              fmt = last)
    }

    return(sets)
  }
}


#' Label chopped intervals with arbitrary formatting
#'
#' \lifecycle{questioning}
#'
#' These labels let you format breaks arbitrarily, using either a string
#' (passed to [sprintf()]) or a function.
#'
#' @param fmt1 Format for breaks consisting of a single value.
#' @inherit label-doc params return
#'
#' @details
#' If `fmt` is a function, it must accept two arguments, representing the
#' left and right endpoints of each interval.
#'
#' If `breaks` are non-numeric, you can only use `"%s"` in a string `fmt`.
#' `breaks` will be converted to character in this case.
#'
#' `lbl_format()` is in the "questioning" stage. As an alternative, consider
#' using [lbl_dash()] or [lbl_intervals()] with the `fmt` argument.
#'
#' @family labelling functions
#'
#' @export
#'
#' @examples
#'
#' tab(1:10, c(1,3, 3, 7),
#'       label = lbl_format("%.3g to %.3g"))
#' tab(1:10, c(1,3, 3, 7),
#'       label = lbl_format("%.3g to %.3g", "Exactly %.3g"))
#'
#' percent2 <- function (x, y) {
#'   sprintf("%.2f%% - %.2f%%", x*100, y*100)
#' }
#' tab(runif(100), c(0.25, 0.5, .75),
#'       labels = lbl_format(percent2))
lbl_format <- function(fmt, fmt1 = "%.3g", raw = FALSE) {
  assert_that(is_format(fmt), is_format(fmt1), is.flag(raw))

  function (breaks) {
    stopifnot(is.breaks(breaks))
    len_b <- length(breaks)

    labels <- character(len_b - 1)
    singletons <- singletons(breaks)

    # no formatting: `lbl_format()` takes that over for itself.
    elabels <- scaled_endpoints(breaks, raw = raw)

    if (is.string(fmt) && ! is.numeric(elabels)) {
      elabels <- as.character(elabels)
    }

    l <- elabels[-len_b]
    r <- elabels[-1]


    labels <- apply_format(fmt, l, r)
    labels[singletons] <- apply_format(fmt1, l[singletons])

    return(labels)
  }
}


#' Label chopped intervals like 1-4, 4-5, ...
#'
#' This label style is user-friendly, but doesn't distinguish between
#' left- and right-closed intervals. It's good for continuous data
#' where you don't expect points to be exactly on the breaks.
#'
#' If you don't want unicode output, use `lbl_dash("-")`.
#'
#' @inherit label-doc
#'
#' @inherit first-last-doc
#'
#' @family labelling functions
#'
#' @export
#'
#' @examples
#' chop(1:10, c(2, 5, 8), lbl_dash())
#'
#' chop(1:10, c(2, 5, 8), lbl_dash(" to ", fmt = "%.1f"))
#'
#' chop(1:10, c(2, 5, 8), lbl_dash(first = "< %s"))
#'
#' pretty <- function (x) prettyNum(x, big.mark = ",", digits = 1)
#' chop(runif(10) * 10000, c(3000, 7000), lbl_dash(" to ", fmt = pretty))
lbl_dash <- function (symbol = em_dash(), raw = FALSE, fmt = NULL, first = NULL,
                      last = NULL) {
  assert_that(
          is.string(symbol),
          is.flag(raw),
          is.null(fmt) || is_format(fmt),
          is.string(first) || is.null(first),
          is.string(last) || is.null(last)
        )

  function (breaks) {
    elabels <-  if (is.null(fmt)) {
                  endpoint_labels(breaks, raw = raw)
                } else {
                  endpoint_labels(breaks, raw = raw, fmt = fmt)
                }

    len_b <- length(breaks)
    singletons <- singletons(breaks)

    l <- elabels[-len_b]
    r <- elabels[-1]

    labels <- paste0(l, symbol, r)
    labels[singletons] <- l[singletons]

    if (! is.null(first)) labels[1] <- endpoint_labels(breaks[2], raw = raw,
                                                        fmt = first)
    if (! is.null(last)) labels[length(labels)] <- endpoint_labels(
                                                        breaks[length(breaks)-1],
                                                        raw = raw, fmt = last)
    return(labels)
  }
}


#' Label chopped intervals by their left or right endpoints
#'
#' This is useful when the left endpoint unambiguously indicates the
#' interval. In other cases it may give errors due to duplicate labels.
#'
#' @inherit label-doc
#' @param left Flag. Use left endpoint or right endpoint?
#'
#' @export
#'
#' @examples
#' chop(1:10, c(2, 5, 8), lbl_endpoint(left = TRUE))
#' chop(1:10, c(2, 5, 8), lbl_endpoint(left = FALSE))
#' if (requireNamespace("lubridate")) {
#'   tab_width(
#'           as.Date("2000-01-01") + 0:365,
#'          months(1),
#'          labels = lbl_endpoint(fmt = "%b")
#'        )
#' }
lbl_endpoint <- function (fmt = NULL, raw = FALSE, left = TRUE) {
  assert_that(is.null(fmt) || is_format(fmt), is.flag(raw), is.flag(left))

  function (breaks) {
    elabels <- if (! is.null(fmt)) {
                 endpoint_labels(breaks, raw, fmt)
               } else {
                 endpoint_labels(breaks, raw)
               }
    if (left) elabels[-length(elabels)] else elabels[-1]
  }
}


#' Label discrete data
#'
#' \lifecycle{experimental}
#'
#' `lbl_discrete` creates labels for discrete data such as integers.
#' For example, breaks
#' `c(1, 3, 4, 6, 7)` are labelled: `"1 - 2", "3", "4 - 5", "6 - 7"`.
#'
#' @inherit label-doc
#' @inherit first-last-doc
#'
#' @details
#' No check is done that the data is discrete-valued. If it isn't, then
#' these labels may be misleading. Here, discrete-valued means that if
#' `x < y`, then `x <= y - 1`.
#'
#' Be aware that Date objects may have non-integer values. See [Date].
#'
#' @family labelling functions
#'
#' @export
#'
#' @examples
#' tab(1:7, c(1, 3, 5), lbl_discrete())
#'
#' tab(1:7, c(3, 5), lbl_discrete(first = "<= %s"))
#'
#' # Misleading labels for non-integer data
#' chop(2.5, c(1, 3, 5), lbl_discrete())
lbl_discrete <- function (symbol = em_dash(), fmt = NULL, first = NULL, last = NULL) {
  assert_that(
          is.string(symbol),
          is.null(fmt) || is_format(fmt),
          is.string(first) || is.null(first),
          is.string(last) || is.null(last)
        )

  function (breaks) {
    assert_that(all(ceiling(as.numeric(breaks)) == floor(as.numeric(breaks))),
          msg = "Non-integer breaks")

    len_b <- length(breaks)
    singletons <- singletons(breaks)
    left <- attr(breaks, "left")
    breaks <- unclass_breaks(breaks)

    l <- breaks[-len_b]
    r <- breaks[-1]
    left_l <- left[-len_b]
    left_r <- left[-1]

    # if you're right-closed we add 1 to your left endpoint:
    l[! left_l] <- l[! left_l] + 1
    # if you're left-closed we deduct 1 from your right endpoint:
    r[left_r] <- r[left_r] - 1
    # sometimes this makes the two endpoints the same:
    singletons <- singletons | r == l

    no_integers <- r < l
    if (any(no_integers)) {
      warning("Intervals containing no integers are labelled as \"--\"")
    }

    if (! is.null(fmt)) {
      l <- apply_format(fmt, l)
      r <- apply_format(fmt, r)
    }

    labels <- paste0(l, symbol, r)
    labels[singletons] <- l[singletons]
    labels[no_integers] <- "--"

    if (! is.null(first)) labels[1] <- endpoint_labels(r[1], raw = FALSE,
                                                       fmt = first)
    if (! is.null(last)) labels[length(labels)] <- endpoint_labels(
                                                     l[length(l)],
                                                     raw = FALSE, fmt = last)

    return(labels)
  }
}


#' Label chopped intervals in sequence
#'
#' `lbl_seq` labels intervals sequentially, using numbers or letters.
#'
#' @param start String. A template for the sequence. See below.
#'
#' @details
#'`start` shows the first element of the sequence. It must contain exactly *one*
#' character out of the set "a", "A", "i", "I" or "1". For later elements:
#'
#' * "a" will be replaced by "a", "b", "c", ...
#' * "A" will be replaced by "A", "B", "C", ...
#' * "i" will be replaced by lower-case Roman numerals "i", "ii", "iii", ...
#' * "I" will be replaced by upper-case Roman numerals "I", "II", "III", ...
#' * "1" will be replaced by numbers "1", "2", "3", ...
#'
#' Other characters will be retained as-is.
#'
#' @family labelling functions
#'
#' @export
#'
#' @examples
#' chop(1:10, c(2, 5, 8), lbl_seq())
#'
#' chop(1:10, c(2, 5, 8), lbl_seq("i."))
#'
#' chop(1:10, c(2, 5, 8), lbl_seq("(A)"))
lbl_seq <- function(start = "a") {
  assert_that(is.string(start))
  # check like contains just one of a, A, i, I, 1
  match <- gregexpr("(a|A|i|I|1)", start)[[1]]
  if (length(match) > 1) stop("More than one a/A/i/I/1 found in `start`: ", start)
  if (match == -1) stop("No a/A/i/I/1 found in `start`: ", start)
  # replace that with the format-string and call lbl_manual appropriately
  key <- substr(start, match, match)
  fmt <- sub("(a|A|i|I|1)", "%s", start)

  res <- switch(key,
    "a" = lbl_manual(letters, fmt),
    "A" = lbl_manual(LETTERS, fmt),
    "i" = function (breaks) {
           sprintf(fmt, tolower(utils::as.roman(seq(1L, length(breaks) - 1))))
         },
    "I" = function (breaks) {
           sprintf(fmt, utils::as.roman(seq(1L, length(breaks) - 1)))
         },
    "1" = function (breaks) {
            sprintf(fmt, seq(1L, length(breaks) - 1))
          }
    )

  return(res)
}


#' Label chopped intervals in a user-defined sequence
#'
#' `lbl_manual()` uses an arbitrary sequence to label
#' intervals. If the sequence is too short, it will be pasted with itself and
#' repeated.
#'
#' @param sequence A character vector of labels.
#' @inherit label-doc params return
#'
#' @family labelling functions
#'
#' @export
#'
#' @examples
#' chop(1:10, c(2, 5, 8), lbl_manual(c("w", "x", "y", "z")))
#'
#' # if labels need repeating:
#' chop(1:10, 1:10, lbl_manual(c("x", "y", "z")))
lbl_manual <- function (sequence, fmt = "%s") {
  assert_that(is_format(fmt))

  if (anyDuplicated(sequence) > 0L) stop("`sequence` contains duplicate items")
  function (breaks) {
    ls <- sequence
    latest <- ls
    while (length(breaks) - 1 > length(ls)) {
      latest <- paste0(latest, sequence)
      ls <- c(ls, latest)
    }
    apply_format(fmt, ls[seq(1L, length(breaks) - 1)])
  }
}
