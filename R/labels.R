
#' @name label-doc
#' @param fmt A [sprintf()]-style format.
#' @return A vector of labels for `chop`, or a function that creates labels.
NULL

#' Interval labels using set notation
#'
#' @inherit label-doc params return
#'
#' @details
#' `fmt` is applied to interval endpoints.
#'
#' @export
#'
#' @examples
#' tab(rnorm(100), c(-3, 0, 0, 3), labels = lbl_intervals())
#' tab(rnorm(100), c(-3, 0, 0, 3), labels = lbl_intervals("%.2f"))
lbl_intervals <- function (fmt = "%.2g") {
  function (breaks) {
    stopifnot(is.breaks(breaks))
    left <- attr(breaks, "left")
    len_b <- length(breaks)

    intervals <- character(len_b - 1)
    len_i <- length(intervals)
    singletons <- singletons(breaks)

    lb <- sprintf(fmt, breaks[-len_b])
    rb <- sprintf(fmt, breaks[-1])
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
}


#' Format labels using sprintf
#'
#' @param fmt1 Format for breaks consisting of a single value.
#'
#' @inherit label-doc params return
#'
#' @export
#'
#' @examples
#' tab(1:10, c(1,3, 3, 7), label = lbl_format("%.3g to %.3g"))
#' tab(1:10, c(1,3, 3, 7), label = lbl_format("%.3g to %.3g", "Exactly %.3g"))
lbl_format <- function(fmt, fmt1 = "%.3g") {
  function (breaks) {
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


#' Interval labels like 1 - 3, 4 - 5, ...
#'
#' @param symbol String: symbol to use for the dash.
#' @inherit label-doc params return
#'
#' @export
#'
#' @examples
#' tab(0:20, c(0, 5, 5, 10), lbl_dash())
lbl_dash <- function (symbol = " - ") {
  fmt <- paste0("%.3g", symbol, "%.3g")
  lbl_format(fmt, "%.3g")
}


#' Labels suitable for quantiles.
#'
#' @param quantiles A vector of quantiles.
#' @inherit label-doc params return
#' @export
#'
#' @examples
#' lbl_quantiles(c(0.25, 0.5, 0.75))
lbl_quantiles <- function (quantiles) {
  lqs <- c(0, quantiles)
  rqs <- c(quantiles, 1)

  lqs <- sprintf("%.3g", lqs * 100)
  rqs <- sprintf("%.3g%%", rqs * 100)

  paste0(lqs, "-", rqs)
}


#' Label in sequence
#'
#' These functions label intervals sequentially from lowest to highest.
#' `lbl_numerals()` uses arabic numerals. `lbl_letters()` and `lbl_LETTERS()`
#' uses lower-case and upper-case letters respectively. `lbl_roman()` and
#' `lbl_ROMAN()` use lower-case and upper-case Roman numerals respectively.
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
NULL


#' @rdname sequence-labels
#' @export
lbl_numerals <- function (fmt = "%s") {
  function (breaks) {
    sprintf(fmt, seq(1L, length(breaks) - 1))
  }
}


#' @rdname sequence-labels
#' @export
lbl_roman <- function (fmt = "%s") {
  function (breaks) {
    sprintf(fmt, tolower(utils::as.roman(seq(1L, length(breaks) - 1))))
  }
}


#' @rdname sequence-labels
#' @export
lbl_ROMAN <- function (fmt = "%s") {
  function (breaks) {
    sprintf(fmt, utils::as.roman(seq(1L, length(breaks) - 1)))
  }
}


#' @rdname sequence-labels
#' @export
lbl_letters <- function (fmt = "%s") {
  sequence_labels(letters, fmt)
}


#' @rdname sequence-labels
#' @export
lbl_LETTERS <- function (fmt = "%s") {
  sequence_labels(LETTERS, fmt)
}


sequence_labels <- function (sequence, fmt) {
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


percent <- function (x) {
  sprintf("%.3g%%", x * 100)
}