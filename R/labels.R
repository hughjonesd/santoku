
#' @name label-doc
#' @param fmt String or function. A format for break endpoints.
#' @param raw `r lifecycle::badge("deprecated")`. Use the `raw` argument to [chop()]
#'   instead.
#' @param symbol String: symbol to use for the dash.
#' @param ... Arguments passed to format methods.
#'
#' @section Formatting endpoints:
#'
#' If `fmt` is not `NULL` then it is used to format the endpoints. If `fmt` is a
#' string then numeric endpoints will be formatted by `sprintf(fmt, breaks)`;
#' other endpoints, e.g. Date objects, will be formatted by `format(breaks,
#' fmt)`.
#'
#' If `fmt` is a function, it should take a vector of numbers (or other objects
#' that can be used as breaks) and return a character vector. It may be helpful
#' to use functions from the `{scales}` package, e.g. [scales::label_comma()].
#'
#' @return A function that creates a vector of labels.
NULL


#' @name first-last-doc
#' @param single Glue string: label for singleton intervals. See [lbl_glue()]
#'   for details.
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
#' @doctest
#'
#' @expect snapshot()
#' tab(-10:10, c(-3, 0, 0, 3),
#'       labels = lbl_intervals())
#'
#' set.seed(42)
#' @expect snapshot()
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
    lifecycle::deprecate_soft("0.9.0", "lbl_intervals(raw)", "chop(raw)")
  }
  interval_glue <- "{ifelse(l_closed, '[', '(')}{l}, {r}{ifelse(r_closed, ']', ')')}"
  lbl_glue(label = interval_glue, single = single, fmt = fmt, first = first,
             last = last, raw = raw)
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
#' @doctest
#'
#' @expect snapshot()
#' chop(1:10, c(2, 5, 8), lbl_dash())
#'
#' @expect snapshot()
#' chop(1:10, c(2, 5, 8), lbl_dash(" to ", fmt = "%.1f"))
#'
#' @expect snapshot()
#' chop(1:10, c(2, 5, 8), lbl_dash(first = "<{r}"))
#'
#' pretty <- function (x) prettyNum(x, big.mark = ",", digits = 1)
#' @expect snapshot()
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
    lifecycle::deprecate_soft("0.9.0", "lbl_dash(raw)", "chop(raw)")
  }

  label_glue <- paste0("{l}", symbol, "{r}")
  lbl_glue(label = label_glue, fmt = fmt, single = single, first = first,
           last = last, raw = raw)
}


#' Label chopped intervals by their midpoints
#'
#' This uses the midpoint of each interval for
#' its label.
#'
#' @inherit label-doc
#' @inherit first-last-doc
#'
#' @family labelling functions
#'
#' @export
#'
#' @doctest
#' @expect snapshot()
#' chop(1:10, c(2, 5, 8), lbl_midpoints())
lbl_midpoints <- function (
                   fmt    = NULL,
                   single = NULL,
                   first  = NULL,
                   last   = NULL,
                   raw    = FALSE
                 ) {
  if (! isFALSE(raw)) {
    lifecycle::deprecate_soft("0.9.0", "lbl_midpoints(raw)", "chop(raw)")
  }

  RAW <- raw # avoid "recursive default argument reference"
  function (breaks, raw = RAW) {
    assert_that(is.breaks(breaks))

    break_nums <- scaled_endpoints(breaks, raw = raw)
    l_nums <- break_nums[-length(break_nums)]
    r_nums <- break_nums[-1]
    # doing this, rather than (l_nums + r_nums)/2, works for e.g. Date objects:
    midpoints <- l_nums + (r_nums - l_nums)/2

    # we've applied raw already (anyway, midpoints is just a numeric)
    midpoints <- endpoint_labels(midpoints, raw = TRUE, fmt = fmt)

    gluer <- lbl_glue(label = "{m}", fmt = fmt, single = single, first = first,
                        last = last, m = midpoints)
    labels <- gluer(breaks, raw = raw)

    labels
  }
}


#' Label chopped intervals using the {glue} package
#'
#' Use `"{l}"` and `"{r}"` to show the left and right endpoints of the intervals.
#'
#' @inherit label-doc
#' @inherit first-last-doc params
#' @param label A glue string passed to [glue::glue()].
#' @param ... Further arguments passed to [glue::glue()].
#'
#' @details
#'
#' The following variables are available in the glue string:
#'
#' * `l` is a character vector of left endpoints of intervals.
#' * `r` is a character vector of right endpoints of intervals.
#' * `l_closed` is a logical vector. Elements are `TRUE` when the left
#'   endpoint is closed.
#' * `r_closed` is a logical vector, `TRUE` when the right endpoint is closed.
#'
#' Endpoints will be formatted by `fmt` before being passed to `glue()`.
#'
#' @family labelling functions
#'
#' @export
#'
#' @doctest
#' @expect snapshot()
#' tab(1:10, c(1, 3, 3, 7),
#'     label = lbl_glue("{l} to {r}", single = "Exactly {l}"))
#'
#' @expect snapshot()
#' tab(1:10 * 1000, c(1, 3, 5, 7) * 1000,
#'     label = lbl_glue("{l}-{r}", fmt = function(x) prettyNum(x, big.mark=',')))
#'
#' # reproducing lbl_intervals():
#' interval_left <- "{ifelse(l_closed, '[', '(')}"
#' interval_right <- "{ifelse(r_closed, ']', ')')}"
#' glue_string <- paste0(interval_left, "{l}", ", ", "{r}", interval_right)
#' @expect snapshot()
#' tab(1:10, c(1, 3, 3, 7), label = lbl_glue(glue_string, single = "{{{l}}}"))
#'
lbl_glue <- function (
              label,
              fmt    = NULL,
              single = NULL,
              first  = NULL,
              last   = NULL,
              raw    = FALSE,
              ...
            ) {
  assert_that(
    is.string(label),
    is.null(fmt) || is_format(fmt),
    is.string(first) || is.null(first),
    is.string(last) || is.null(last),
    is.flag(raw)
  )

  if (! isFALSE(raw)) {
    lifecycle::deprecate_soft("0.9.0", "lbl_glue(raw)", "chop(raw)")
  }

  RAW <- raw # avoid "recursive default argument reference"
  function (breaks, raw = RAW) {
    assert_that(is.breaks(breaks))

    len_breaks <- length(breaks)

    labels <- character(len_breaks - 1)

    elabels <- endpoint_labels(breaks, raw = raw, fmt = fmt)

    l <- elabels[-len_breaks]
    r <- elabels[-1]

    left <- attr(breaks, "left")
    # Breaks like [1, 2) [2, 3] have
    # left TRUE, TRUE, FALSE for breaks 1,2,3
    # The first two TRUEs say that the left brackets are closed
    # The last two TRUE & FALSE say that the right brackets are open
    # and closed respectively. So:
    l_closed <- left[-len_breaks]
    r_closed <- ! left[-1]

    # check ... for anything not in glue::glue args
    # effectively, we move any user-supplied arguments into
    # an environment specifically for glue
    # this is mostly to make the lbl_midpoints() hack
    # of passing in `m` work
    dots <- rlang::enexprs(...)
    glue_env <- new.env()
    not_glue_args <- setdiff(names(dots), names(formals(glue::glue)))
    for (nm in not_glue_args) {
      assign(deparse(dots[[nm]]),
               eval(dots[[nm]], parent.frame()),
               glue_env
             )
    }
    labels <- glue::glue(label, l = l, r = r, l_closed = l_closed,
                         r_closed = r_closed, ..., .envir = glue_env)

    if (! is.null(single)) {
      # which breaks are singletons?
      singletons <- singletons(breaks)

      labels[singletons] <- glue::glue(single,
                                         l = l[singletons],
                                         r = r[singletons],
                                         l_closed = l_closed[singletons],
                                         r_closed = r_closed[singletons],
                                         ...,
                                         .envir = glue_env
                                       )
    }

    if (! is.null(first)) {
      labels[1] <- glue::glue(first, l = l[1], r = r[1],
                                l_closed = l_closed[1],
                                r_closed = r_closed[1],
                                ...,
                                .envir = glue_env
                              )
    }

    if (! is.null(last)) {
      ll <- len_breaks - 1
      labels[ll] <- glue::glue(last, l = l[ll], r = r[ll],
                                 l_closed = l_closed[ll],
                                 r_closed = r_closed[ll],
                                 ...,
                                 .envir = glue_env
                               )
    }

    return(labels)
  }
}


#' Label chopped intervals by their left or right endpoints
#'
#' This is useful when the left endpoint unambiguously indicates the
#' interval. In other cases it may give errors due to duplicate labels.
#'
#' `lbl_endpoint()` is `r lifecycle::badge("deprecated")`. Do not use it.
#'
#' @inherit label-doc
#' @inherit first-last-doc
#' @param left Flag. Use left endpoint or right endpoint?
#'
#' @family labelling functions
#'
#' @export
#'
#' @doctest
#' @expect snapshot()
#' chop(1:10, c(2, 5, 8), lbl_endpoints(left = TRUE))
#' @expect snapshot()
#' chop(1:10, c(2, 5, 8), lbl_endpoints(left = FALSE))
#' if (requireNamespace("lubridate")) {
#' @expect snapshot()
#'   tab_width(
#'           as.Date("2000-01-01") + 0:365,
#'          months(1),
#'          labels = lbl_endpoints(fmt = "%b")
#'        )
#' }
#'
#' \dontrun{
#'   # This gives breaks `[1, 2) [2, 3) {3}` which lead to
#'   # duplicate labels `"2", "3", "3"`:
#' @expect length(levels(.), 2)
#'   chop(1:3, 1:3, lbl_endpoints(left = FALSE))
#' }
lbl_endpoints <- function (
                   left   = TRUE,
                   fmt    = NULL,
                   single = NULL,
                   first  = NULL,
                   last   = NULL,
                   raw    = FALSE
                 ) {
  assert_that(is.flag(left))

  if (! isFALSE(raw)) {
    lifecycle::deprecate_soft("0.9.0", "lbl_endpoints(raw)", "chop(raw)")
  }

  label <- if (left) "{l}" else "{r}"
  lbl_glue(label, fmt = fmt, single = single, first = first, last = last,
             raw = raw)
}


#' @rdname lbl_endpoints
#' @export
lbl_endpoint <- function (
                  fmt  = NULL,
                  raw  = FALSE,
                  left = TRUE
                ) {
  lifecycle::deprecate_warn(when = "0.8.0", what = "lbl_endpoint()",
                              with = "lbl_endpoints()")
   lbl_endpoints(fmt = fmt, raw = raw, left = left)
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
#' @doctest
#' @expect match(names(.), "1(-|\u2014)2", all = FALSE)
#' tab(1:7, c(1, 3, 5), lbl_discrete())
#'
#' @expect snapshot()
#' tab(1:7, c(3, 5), lbl_discrete(first = "<= {r}"))
#'
#' @pause
#' tab(1:7 * 1000, c(1, 3, 5) * 1000, lbl_discrete(unit = 1000))
#'
#' # Misleading labels for non-integer data
#' chop(2.5, c(1, 3, 5), lbl_discrete())
#'
lbl_discrete <- function (
                  symbol = em_dash(),
                  unit = 1,
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


#' Label chopped intervals in sequence
#'
#' `lbl_seq()` labels intervals sequentially, using numbers or letters.
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
#' @inherit label-doc return
#'
#' @export
#'
#' @doctest
#' @expect match(levels(.), "a", all = FALSE)
#' chop(1:10, c(2, 5, 8), lbl_seq())
#'
#' @expect match(levels(.), "i.", all = FALSE, fixed = TRUE)
#' chop(1:10, c(2, 5, 8), lbl_seq("i."))
#'
#' @expect match(levels(.), "(A)", all = FALSE, fixed = TRUE)
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
    "a" = function (breaks, raw = NULL) {
            if (length(breaks) > 27L) {
              stop("Can't use more than 26 intervals with lbl_seq(\"a\")")
            }
            sprintf(fmt, letters[seq_len(length(breaks) - 1L)])
          },
    "A" = function (breaks, raw = NULL) {
            if (length(breaks) > 27L) {
              stop("Can't use more than 26 intervals with lbl_seq(\"A\")")
            }
            sprintf(fmt, LETTERS[seq_len(length(breaks) - 1L)])
          },
    "i" = function (breaks, raw = NULL) {
           sprintf(fmt, tolower(utils::as.roman(seq_len(length(breaks) - 1L))))
         },
    "I" = function (breaks, raw = NULL) {
           sprintf(fmt, utils::as.roman(seq_len(length(breaks) - 1L)))
         },
    "1" = function (breaks, raw = NULL) {
            sprintf(fmt, seq_len(length(breaks) - 1L))
          }
    )

  return(res)
}


#' Label chopped intervals in a user-defined sequence
#'
#' `r lifecycle::badge("deprecated")`
#'
#' `lbl_manual()` is deprecated because it is little used and is not closely
#' related to the rest of the package. It also risks mislabelling intervals, e.g.
#' if intervals are extended.
#'
#' `lbl_manual()` uses an arbitrary sequence to label
#' intervals. If the sequence is too short, it will be pasted with itself and
#' repeated.
#'
#' @param sequence A character vector of labels.
#' @inherit label-doc
#'
#' @family labelling functions
#'
#' @export
#'
#' @keywords internal
#'
#' @examples
#' chop(1:10, c(2, 5, 8), lbl_manual(c("w", "x", "y", "z")))
#' # ->
#' chop(1:10, c(2, 5, 8), labels = c("w", "x", "y", "z"))
lbl_manual <- function (sequence, fmt = "%s") {
  lifecycle::deprecate_warn("0.9.0", "lbl_manual()",
                            details = "Just specify `labels = sequence` instead.")
  assert_that(is_format(fmt))

  if (anyDuplicated(sequence) > 0L) stop("`sequence` contains duplicate items")
  function (breaks, raw = NULL) {
    ls <- sequence
    latest <- ls
    while (length(breaks) - 1 > length(ls)) {
      latest <- paste0(latest, sequence)
      ls <- c(ls, latest)
    }
    apply_format(fmt, ls[seq(1L, length(breaks) - 1)])
  }
}