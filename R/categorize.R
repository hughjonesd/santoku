
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
  x <- tryCatch(as.numeric(res[[1]]), error = function (...) res[[1]])
  breaks <- tryCatch(as.numeric(res[[2]]), error = function (...) res[[2]])

  codes <- if (is.numeric(x) && is.numeric(breaks)) {
    categorize_impl(x, breaks, left)
  } else {
    categorize_non_numeric(x, breaks, left)
  }

  codes
}


categorize_non_numeric <- function (x, breaks, left) {
  stopifnot(length(breaks) == length(left))

  codes <- rep(NA_integer_, length(x))

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