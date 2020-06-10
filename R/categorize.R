
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
  x <- as.numeric(res[[1]])
  breaks <- as.numeric(res[[2]])

  codes <- if (OLD) categorize_impl_old(x, breaks, left) else categorize_impl(x, breaks, left)

  codes
}