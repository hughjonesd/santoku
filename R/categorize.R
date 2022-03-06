
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
  # We want to convert things to numeric objects, but NB, not all
  # numeric objects will work OK in categorize_impl
  x <- tryCatch(strict_as_numeric(res[[1]]),
                  error   = function (...) res[[1]]
                )
  breaks <- tryCatch(strict_as_numeric(res[[2]]),
                       error   = function (...) res[[2]]
                     )

  # we use is_bare_numeric here because e.g. large integer64 vectors will
  # fail in categorize_impl()
  codes <- if (rlang::is_bare_numeric(x) && rlang::is_bare_numeric(breaks)) {
    categorize_impl(x, breaks, left)
  } else {
    categorize_non_numeric(x, breaks, left)
  }

  codes
}


categorize_non_numeric <- function (x, breaks, left) {

  if (is.character(x) || is.character(breaks)) {
    if (getOption("santoku.warn_character", TRUE)) {
      warning_statement <- paste(
        "`x` or `breaks` is of type character, using lexical sorting.",
        "To turn off this warning, run:",
        "  options(santoku.warn_character = FALSE)",
        collapse = "\n")
      warning(warning_statement)
    }
  }

  codes <- rep(NA_integer_, length(x))

  for (j in seq_len(length(breaks) - 1)) {
    more_than_j <- x > breaks[j]
    less_than_j_plus_one <- x < breaks[j+1]
    equals_j <- x == breaks[j]
    equals_j_plus_one <- x == breaks[j+1]

    codes[more_than_j & less_than_j_plus_one] <- j
    if (left[j]) codes[equals_j] <- j
    if (! left[j+1]) codes[equals_j_plus_one] <- j
  }

  codes
}