
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
#' @examples
#' chop(1:10, c(2, 5, 8), lbl_midpoints())
lbl_midpoints <- function (
                   fmt    = NULL,
                   single = NULL,
                   first  = NULL,
                   last   = NULL,
                   raw    = FALSE
                 ) {
  if (! isFALSE(raw)) {
    lifecycle::deprecate_warn("0.9.0", "lbl_midpoints(raw)", "chop(raw)")
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


#' Label chopped intervals by their left or right endpoints
#'
#' This is useful when the left endpoint unambiguously indicates the
#' interval. In other cases it may give errors due to duplicate labels.
#'
#' `lbl_endpoint()` is `r lifecycle::badge("defunct")` and gives an
#' error since santoku 1.0.0.
#'
#' @inherit label-doc
#' @inherit first-last-doc
#' @param left Flag. Use left endpoint or right endpoint?
#'
#' @family labelling functions
#'
#' @export
#'
#' @examples
#' chop(1:10, c(2, 5, 8), lbl_endpoints(left = TRUE))
#' chop(1:10, c(2, 5, 8), lbl_endpoints(left = FALSE))
#' if (requireNamespace("lubridate")) {
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
    lifecycle::deprecate_warn("0.9.0", "lbl_endpoints(raw)", "chop(raw)")
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
  lifecycle::deprecate_stop(when = "0.8.0", what = "lbl_endpoint()",
                              with = "lbl_endpoints()")
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


#' Defunct: label chopped intervals in a user-defined sequence
#'
#' `r lifecycle::badge("defunct")`
#'
#' `lbl_manual()` is defunct since santoku 1.0.0. It is little used and is not
#' closely related to the rest of the package. It also risks mislabelling
#' intervals, e.g. if intervals are extended. Use of `lbl_manual()` will give
#' an error.
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
#' \dontrun{
#' chop(1:10, c(2, 5, 8), lbl_manual(c("w", "x", "y", "z")))
#' # ->
#' chop(1:10, c(2, 5, 8), labels = c("w", "x", "y", "z"))
#' }
lbl_manual <- function (sequence, fmt = "%s") {
  lifecycle::deprecate_stop("0.9.0", "lbl_manual()",
                            details = "Just specify `labels = sequence` instead.")
}