
#' @name label-doc
#' @param fmt String, list or function. A format for break endpoints.
#' @param raw `r lifecycle::badge("deprecated")`. Use the `raw` argument to [chop()]
#'   instead.
#' @param symbol String: symbol to use for the dash.
#' @param ... Arguments passed to format methods.
#'
#' @section Formatting endpoints:
#'
#' If `fmt` is not `NULL` then it is used to format the endpoints.
#'
#' * If `fmt` is a string, then numeric endpoints will be formatted by
#'   `sprintf(fmt, breaks)`; other endpoints, e.g. [Date] objects, will be
#'   formatted by `format(breaks, fmt)`.
#'
#' * If `fmt` is a list, then it will be used as arguments to [format].
#'
#' * If `fmt` is a function, it should take a vector of numbers (or other objects
#'   that can be used as breaks) and return a character vector. It may be helpful
#'   to use functions from the `{scales}` package, e.g. [scales::label_comma()].
#'
#' @return A function that creates a vector of labels.
NULL


#' @name first-last-doc
#' @param single Glue string: label for singleton intervals. See [lbl_glue()]
#'   for details. If `NULL`, singleton intervals will be labelled the same way
#'   as other intervals.
#' @param first Glue string: override label for the first category. Write e.g.
#'   `first = "<{r}"` to create a label like `"<18"`. See [lbl_glue()]
#'   for details.
#' @param last String: override label for the last category. Write e.g.
#'   `last = ">{l}"` to create a label like `">65"`. See [lbl_glue()]
#'   for details.
NULL


#' Label chopped intervals using set notation
#'
#' These labels are the most exact, since they show you whether
#' intervals are "closed" or "open", i.e. whether they include their endpoints.
#'
#' Mathematical set notation looks like this:
#'
#' * \code{[a, b]}: all numbers `x` where `a <= x <= b`;
#' * \code{(a, b)}: all numbers where `a < x < b`;
#' * \code{[a, b)}: all numbers where `a <= x < b`;
#' * \code{(a, b]}: all numbers where `a < x <= b`;
#' * \code{{a}}: just the number `a` exactly.
#'
#' @inherit label-doc
#' @inherit first-last-doc
#'
#' @family labelling functions
#'
#' @export
#'
#' @examples
#'
#' tab(-10:10, c(-3, 0, 0, 3),
#'       labels = lbl_intervals())
#'
#' tab(-10:10, c(-3, 0, 0, 3),
#'       labels = lbl_intervals(fmt = list(nsmall = 1)))
#'
#' tab_evenly(runif(20), 10,
#'       labels = lbl_intervals(fmt = percent))
#'
lbl_intervals <- function (
                   fmt    = NULL,
                   single = "{{{l}}}",
                   first  = NULL,
                   last   = NULL,
                   raw    = FALSE
                 ) {
  if (! isFALSE(raw)) {
    lifecycle::deprecate_warn("0.9.0", "lbl_intervals(raw)", "chop(raw)")
  }
  interval_glue <- "{ifelse(l_closed, '[', '(')}{l}, {r}{ifelse(r_closed, ']', ')')}"
  lbl_glue(label = interval_glue, single = single, fmt = fmt, first = first,
             last = last, raw = raw)
}


#' Label discrete data
#'
#' `lbl_discrete()` creates labels for discrete data, such as integers.
#' For example, breaks
#' `c(1, 3, 4, 6, 7)` are labelled: `"1-2", "3", "4-5", "6-7"`.
#'
#' @inherit label-doc
#' @param unit Minimum difference between distinct values of data.
#'   For integers, 1.
#' @inherit first-last-doc
#'
#' @details
#' No check is done that the data are discrete-valued. If they are not, then
#' these labels may be misleading. Here, discrete-valued means that if
#' `x < y`, then `x <= y - unit`.
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
#' tab(1:7, c(3, 5), lbl_discrete(first = "<= {r}"))
#'
#' tab(1:7 * 1000, c(1, 3, 5) * 1000, lbl_discrete(unit = 1000))
#'
#' # Misleading labels for non-integer data
#' chop(2.5, c(1, 3, 5), lbl_discrete())
#'
lbl_discrete <- function (
                  symbol = em_dash(),
                  unit = 1L,
                  fmt = NULL,
                  single = NULL,
                  first = NULL,
                  last = NULL
                ) {
  assert_that(
          is.string(symbol),
          is.scalar(unit),
          is.null(fmt) || is_format(fmt),
          is.string(single) || is.null(single),
          is.string(first) || is.null(first),
          is.string(last) || is.null(last)
        )

  function (breaks, raw = NULL) {
    assert_that(all(ceiling(as.numeric(breaks)) == floor(as.numeric(breaks))),
          msg = "Non-integer breaks")

    len_breaks <- length(breaks)
    singletons <- singletons(breaks)
    left <- attr(breaks, "left")
    breaks <- unclass_breaks(breaks)

    l <- breaks[-len_breaks]
    r <- breaks[-1]
    left_l <- left[-len_breaks]
    left_r <- left[-1]

    # if you're right-closed we add `unit` to your left endpoint:
    l[! left_l] <- l[! left_l] + unit
    # if you're left-closed we deduct `unit` from your right endpoint:
    r[left_r] <- r[left_r] - unit
    # sometimes this makes the two endpoints the same:
    singletons <- singletons | r == l

    too_small <- r < l
    if (any(too_small)) {
      warning("Intervals smaller than `unit` are labelled as \"--\"")
    }

    labels_l <- endpoint_labels(l, raw = FALSE, fmt = fmt)
    labels_r <- endpoint_labels(r, raw = FALSE, fmt = fmt)

    labels <- paste0(labels_l, symbol, labels_r)
    labels[singletons] <- labels_l[singletons]
    labels[too_small] <- "--"

    l_closed <- left_l
    # r_closed is used for "]" in labels so need to switch it here:
    r_closed <- ! left_r

    if (! is.null(single)) {
      labels[singletons] <- glue::glue(single, l = labels_l[singletons],
                                         r = labels_r[singletons],
                                         l_closed = l_closed[singletons],
                                         r_closed = r_closed[singletons])
    }

    if (! is.null(first)) {
      labels[1] <- glue::glue(first, l = labels_l[1], r = labels_r[1],
                              l_closed = l_closed[1], r_closed = r_closed[1])
    }

    if (! is.null(last)) {
      ll <- len_breaks - 1
      labels[ll] <- glue::glue(last, l = labels_l[ll], r = labels_r[ll],
                               l_closed = l_closed[ll], r_closed = r_closed[ll])
    }

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
#' chop(1:10, c(2, 5, 8), lbl_dash(first = "<{r}"))
#'
#' pretty <- function (x) prettyNum(x, big.mark = ",", digits = 1)
#' chop(runif(10) * 10000, c(3000, 7000), lbl_dash(" to ", fmt = pretty))
lbl_dash <- function (
              symbol = em_dash(),
              fmt    = NULL,
              single = "{l}",
              first  = NULL,
              last   = NULL,
              raw    = FALSE
            ) {
  if (! isFALSE(raw)) {
    lifecycle::deprecate_warn("0.9.0", "lbl_dash(raw)", "chop(raw)")
  }

  label_glue <- paste0("{l}", symbol, "{r}")
  lbl_glue(label = label_glue, fmt = fmt, single = single, first = first,
           last = last, raw = raw)
}