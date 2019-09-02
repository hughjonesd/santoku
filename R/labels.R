
#' @name label-doc
#' @param fmt A [sprintf()]-style format.
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
#' * `[a, b]`: all numbers `x` where `a <= x <= b`;
#' * `(a, b)`: all numbers where `a < x < b`;
#' * `[a, b)`: all numbers where `a <= x < b`;
#' * `(a, b]`: all numbers where `a < x <= b`;
#' * `{a}`: just the number `a`.
#'
#'
#' @export
#'
#' @examples
#' tab(rnorm(100), c(-3, 0, 0, 3), labels = lbl_intervals())
lbl_intervals <- function () {
  function (breaks, extend) {
    stopifnot(is.breaks(breaks))
    left <- attr(breaks, "left")
    make_interval_labels(as.numeric(breaks), left)
  }
}


#' Labels using breaks, with arbitrary formatting
#'
#' @param fmt1 Format for breaks consisting of a single value.
#'
#' @inherit label-doc params return
#'
#' @export
#'
#' @examples
#' tab(1:10, c(1,3, 3, 7), label = lbl_format("%s to %s"))
#' tab(1:10, c(1,3, 3, 7), label = lbl_format("%s to %s", "Exactly %s"))
lbl_format <- function(fmt, fmt1 = "%s") {
  function (breaks, extend) {
    stopifnot(is.breaks(breaks))
    len_b <- length(breaks)

    labels <- character(len_b - 1)
    len_i <- length(labels)
    singletons <- singletons(breaks)

    l <- breaks[-len_b]
    r <- breaks[-1]

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
lbl_dash <- function (symbol = " - ") {
  fmt <- paste0("%s", symbol, "%s")
  lbl_format(fmt, "%s")
}


#' Labels suitable for quantiles
#'
#' @param quantiles A vector of quantiles.
#' @inherit label-doc params return
#' @export
#'
#' @examples
#' lbl_quantiles(c(0.25, 0.5, 0.75))
lbl_quantiles <- function (quantiles) {
  function (breaks, extend) {
    if (extend) quantiles <- c(0, quantiles, 1)
    lqs <- quantiles[-length(quantiles)]
    rqs <- quantiles[-1]

    lqs <- sprintf("%s", lqs * 100)
    rqs <- sprintf("%s%%", rqs * 100)

    paste0(lqs, "-", rqs)
  }
}


#' Label standard deviations
#'
#' @param sd Number of standard deviations
#' @inherit label-doc params return
#'
#' @export
#'
lbl_mean_sd <- function (sd) {
  function (breaks, extend) {
    sds <- seq(-sd, sd, 1)
    left <- attr(breaks, "left")
    if (extend) left <- left[c(-1, -length(left))]
    labels <- make_interval_labels(sds, left)
    if (extend) {
      labels <- c(sprintf("< %s", -sd), labels, sprintf("> %s", sd))
    }
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
NULL


#' @rdname sequence-labels
#' @export
lbl_numerals <- function (fmt = "%s") {
  function (breaks, extend) {
    sprintf(fmt, seq(1L, length(breaks) - 1))
  }
}


#' @rdname sequence-labels
#' @export
lbl_roman <- function (fmt = "%s") {
  function (breaks, extend) {
    sprintf(fmt, tolower(utils::as.roman(seq(1L, length(breaks) - 1))))
  }
}


#' @rdname sequence-labels
#' @export
lbl_ROMAN <- function (fmt = "%s") {
  function (breaks, extend) {
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
  if (anyDuplicated(sequence) > 0L) stop("`sequence` contains duplicate items")
  function (breaks, extend) {
    ls <- sequence
    latest <- ls
    while (length(breaks) - 1 > length(ls)) {
      latest <- paste0(latest, sequence)
      ls <- c(ls, latest)
    }
    sprintf(fmt, ls[seq(1L, length(breaks) - 1)])
  }
}


make_interval_labels <- function (num, left) {
  len_b <- length(num)
  if (len_b < 1L) return(character(0))

  intervals <- character(len_b - 1)
  len_i <- length(intervals)
  singletons <- singletons(num)

  num <- unique_truncation(num)
  lb <- num[-len_b]
  rb <- num[-1]
  l_closed <- left[-len_b]
  r_closed <- ! left[-1]

  left_symbol <- rep("(", len_i)
  left_symbol[l_closed] <- "["

  right_symbol <- rep(")", len_i)
  right_symbol[r_closed] <- "]"

  intervals <- sprintf("%s%s, %s%s", left_symbol, lb, rb, right_symbol)
  intervals[singletons] <- sprintf("{%s}", lb[singletons])

  return(intervals)
}


unique_truncation <- function (num) {
  want_unique <- ! duplicated(num) # real duplicates can stay as they are!
                                   # we keep the first of each duplicate set.
  res <- format(num, trim = TRUE)
  if (! anyDuplicated(res[want_unique])) return(res)

  min_digits <- min(getOption("digits", 7), 21)
  for (digits in seq(min_digits, 22L)) {
    res <- formatC(num, digits = digits, width = -1)
    if (anyDuplicated(res[want_unique]) == 0L) break
  }
  if (anyDuplicated(res[want_unique]) > 0L) stop(
        "Could not format breaks to avoid duplicates")

  return(res)
}