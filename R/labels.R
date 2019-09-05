
#' @name label-doc
#' @param fmt A [sprintf()]-style format.
#' @param raw Logical. Always use raw `breaks` in labels, rather than e.g. quantiles
#'   or standard deviations?
#' @return A vector of labels for `chop`, or a function that creates labels.
NULL

#' Labels using set notation
#'
#' @inherit label-doc params return
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


#' Labels using breaks, with arbitrary formatting
#'
#' @param fmt1 Format for breaks consisting of a single value.
#' @inherit label-doc params return
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

    break_labels <- choose_break_labels(breaks, raw)
    l <- break_labels[-len_b]
    r <- break_labels[-1]

    labels <- sprintf(fmt, l, r)
    labels[singletons] <- sprintf(fmt1, l[singletons])

    return(labels)
  }
}


#' Labels like 1 - 3, 4 - 5, ...
#'
#' @param symbol String: symbol to use for the dash.
#' @inherit label-doc params return
#'
#' @export
#'
#' @examples
#' tab(0:20, c(0, 5, 5, 10), lbl_dash())
#' tab(0:20, c(0, 5, 5, 10), lbl_dash(" to "))
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


#' Label in sequence
#'
#' These functions label intervals sequentially from lowest to highest.
#'
#' `lbl_numerals()` uses arabic numerals.
#'
#' `lbl_letters()` and `lbl_LETTERS()`
#' uses lower-case and upper-case letters respectively.
#'
#' `lbl_roman()` and
#' `lbl_ROMAN()` use lower-case and upper-case Roman numerals respectively.
#'
#' `lbl_sequence()` uses an arbitrary sequence. If the sequence is shorter than
#' the number of breaks, it will be pasted with itself and repeated
#' as necessary.
#'
#' @name sequence-labels
#'
#' @inherit label-doc params return
#'
#' @examples
#' tab(1:10, c(3, 4), lbl_numerals())
#' tab(1:10, c(3, 4), lbl_numerals("(%s)"))
#' tab(1:10, c(3, 4), lbl_letters())
#' tab(1:10, c(3, 4), lbl_LETTERS())
#' tab(1:10, c(3, 4), lbl_roman())
#' tab(1:10, c(3, 4), lbl_ROMAN())
#' tab(1:10, c(3, 4), lbl_sequence(c("x", "y", "z")))
#'
#' # if labels need repeating:
#' tab(1:10, 1:10, lbl_sequence(c("x", "y", "z")))
NULL


#' @rdname sequence-labels
#' @export
lbl_numerals <- function (fmt = "%s") {
  assert_that(is.string(fmt))

  function (breaks) {
    sprintf(fmt, seq(1L, length(breaks) - 1))
  }
}


#' @rdname sequence-labels
#' @export
lbl_roman <- function (fmt = "%s") {
  assert_that(is.string(fmt))

  function (breaks) {
    sprintf(fmt, tolower(utils::as.roman(seq(1L, length(breaks) - 1))))
  }
}


#' @rdname sequence-labels
#' @export
lbl_ROMAN <- function (fmt = "%s") {
  assert_that(is.string(fmt))

  function (breaks) {
    sprintf(fmt, utils::as.roman(seq(1L, length(breaks) - 1)))
  }
}


#' @rdname sequence-labels
#' @export
lbl_letters <- function (fmt = "%s") {
  lbl_sequence(letters, fmt)
}


#' @rdname sequence-labels
#' @export
lbl_LETTERS <- function (fmt = "%s") {
  lbl_sequence(LETTERS, fmt)
}


#' @rdname sequence-labels
#' @param sequence A character vector.
#' @export
lbl_sequence <- function (sequence, fmt = "%s") {
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
