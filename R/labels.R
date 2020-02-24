
#' @name label-doc
#' @param fmt A [sprintf()]-style format.
#' @param raw Logical. Always use raw `breaks` in labels, rather than e.g. quantiles
#'   or standard deviations.
#' @param symbol String: symbol to use for the dash.
#' @return A vector of labels for `chop`, or a function that creates labels.
NULL


#' Labels using set notation
#'
#' @inherit label-doc params return
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
#' tab(-10:10, c(-3, 0, 0, 3), labels = lbl_intervals())
lbl_intervals <- function (raw = FALSE) {
  assert_that(is.flag(raw))

  function (breaks) {
    stopifnot(is.breaks(breaks))
    left <- attr(breaks, "left")
    break_labels <- choose_break_labels(breaks, raw)

    len_b <- length(breaks)
    if (len_b < 1L) return(character(0))

    lb <- break_labels[-len_b]
    rb <- break_labels[-1]
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

    return(sets)
  }
}


#' Labels with arbitrary formatting
#'
#' @param fmt1 Format for breaks consisting of a single value.
#' @inherit label-doc params return
#'
#' @family labelling functions
#'
#' @details
#' If `raw = FALSE`, breaks will be preformatted as strings
#' before being passed to [sprintf()], so only `"%s"` should be used in
#' format strings.
#'
#' @export
#'
#' @examples
#' tab(1:10, c(1,3, 3, 7), label = lbl_format("%s to %s"))
#' tab(1:10, c(1,3, 3, 7), label = lbl_format("%s to %s", "Exactly %s"))
lbl_format <- function(fmt, fmt1 = "%s", raw = FALSE) {
  assert_that(is.string(fmt), is.string(fmt1), is.flag(raw))

  function (breaks) {
    stopifnot(is.breaks(breaks))
    len_b <- length(breaks)

    labels <- character(len_b - 1)
    singletons <- singletons(breaks)

    break_labels <- if (raw) as.numeric(breaks) else
          choose_break_labels(breaks, raw)

    l <- break_labels[-len_b]
    r <- break_labels[-1]

    labels <- sprintf(fmt, l, r)
    labels[singletons] <- sprintf(fmt1, l[singletons])

    return(labels)
  }
}


#' Labels like 1 - 3, 4 - 5, ...
#'
#' @inherit label-doc params return
#'
#' @family labelling functions
#'
#' @export
#'
#' @examples
#' chop(1:10, c(2, 5, 8), lbl_dash())
#'
#' chop(1:10, c(2, 5, 8), lbl_dash(" to "))
#'
lbl_dash <- function (symbol = " - ", raw = FALSE) {
  assert_that(is.string(symbol), is.flag(raw))

  function (breaks) {
    break_labels <- choose_break_labels(breaks, raw)

    len_b <- length(breaks)
    singletons <- singletons(breaks)

    l <- break_labels[-len_b]
    r <- break_labels[-1]

    labels <- paste0(l, symbol, r)
    labels[singletons] <- l[singletons]

    return(labels)
  }
}


#' Labels for integer data
#'
#' `lbl_integer` creates labels for integer data. For example, breaks
#' `c(1, 3, 4, 6, 7)` get labels `"1 - 2", "3", "4 - 5", "6 - 7"`.
#'
#' @inherit label-doc params return
#'
#' @details
#' No check is done that the data is integer-valued. If it isn't, then
#' these labels may be misleading.
#'
#' @family labelling functions
#'
#' @export
#'
#' @examples
#' tab(1:7, c(1, 3, 5), lbl_integer())
#'
#' # Misleading labels for non=integer data
#' chop(2.5, c(1, 3, 5), lbl_integer())
lbl_integer <- function (symbol = " - ") {
  assert_that(is.string(symbol))

  function (breaks) {
    assert_that(all(ceiling(breaks) == floor(breaks)),
          msg = "Non-integer breaks")

    len_b <- length(breaks)
    singletons <- singletons(breaks)
    left <- attr(breaks, "left")

    l <- breaks[-len_b]
    r <- breaks[-1]
    left_l <- left[-len_b]
    left_r <- left[-1]
    l[! left_l] <- l[! left_l] + 1
    r[left_r] <- r[left_r] - 1
    singletons <- singletons | r == l

    labels <- paste0(l, symbol, r)
    labels[singletons] <- l[singletons]
    labels[r < l] <- "--"
    if (any(r < l)) {
      warning("Some intervals in breaks contain no integers.")
    }

    return(labels)
  }
}


#' Labels in sequence
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


#' Labels in a user-defined sequence
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
  assert_that(is.string(fmt))

  if (anyDuplicated(sequence) > 0L) stop("`sequence` contains duplicate items")
  function (breaks) {
    ls <- sequence
    latest <- ls
    while (length(breaks) - 1 > length(ls)) {
      latest <- paste0(latest, sequence)
      ls <- c(ls, latest)
    }
    sprintf(fmt, ls[seq(1L, length(breaks) - 1)])
  }
}


choose_break_labels <- function (breaks, raw) {
  bl <- attr(breaks, "break_labels")
  if (raw || is.null(bl)) {
    return(unique_truncation(as.numeric(breaks)))
  } else {
    return(bl)
  }
}
