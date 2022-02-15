
#' Categorize `x` according to breaks
#'
#' @param x A vector of data
#' @param breaks A breaks object
#'
#' @return A set of vector codes
#' @noRd
categorize <- function (x, breaks) {
  # we first cast to the most informative common type. Then to numeric.

  left <- attr(breaks, "left")
  res <- vctrs::vec_cast_common(x, unclass_breaks(breaks))
  # vec_cast won't accept e.g. characters but it also won't convert e.g. Dates
  # as.numeric accepts both
  # fuck you, world
  x <- tryCatch(strict_as_numeric(res[[1]]),
                  error   = function (...) res[[1]]
                )
  breaks <- tryCatch(strict_as_numeric(res[[2]]),
                       error   = function (...) res[[2]]
                     )

  codes <- if (is.numeric(x) && is.numeric(breaks)) {
    categorize_impl(x, breaks, left)
  } else {
    categorize_non_numeric(x, breaks, left)
  }

  codes
}


categorize_non_numeric <- function (x, breaks, left) {

  if (getOption("santoku.warn_character", TRUE)) {
    warning_statement <- paste0(
      "`%s` appears to be of type character, using lexical sorting.\n",
      "To turn off this warning, use:\n",
      "  options(santoku.warn_character = FALSE)",
      collapse = "")
    if (is.character(x)) {
      warning(sprintf(warning_statement, "x"))
    }
    if (is.character(breaks)) {
      warning(sprintf(warning_statement, "breaks"))
    }
  }

  codes <- rep(NA_integer_, length(x))

  # reimplementation of the C++ code... could probably be faster!
  for (i in seq_along(x)) {
    x_i <- x[i]
    for (j in seq_len(length(breaks) - 1)) {
      lb <- breaks[j]
      rb <- breaks[j + 1]
      if ((x_i > lb || (left[j] && x_i == lb)) &&
          (x_i < rb || (! left[j + 1] && x_i == rb))) {
        codes[i] = j
        break
      }
    }
  }

  codes
}