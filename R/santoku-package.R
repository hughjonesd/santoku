
#' @import assertthat
NULL

#' A versatile cutting tool for R
#'
#' santoku is a tool for cutting data into intervals. It provides
#' the function [chop()], which is similar to base R's [cut()] or `Hmisc::cut2()`.
#' `chop(x, breaks)` takes a vector `x` and returns a factor of the
#' same length, coding which interval each element of `x` falls into.
#'
#' Here are some advantages of santoku:
#'
#' * By default, `chop()` always covers the whole range of the data, so you
#'   won't get unexpected `NA` values.
#'
#' * Unlike `cut()` or `cut2()`, `chop()` can handle single values as well as
#'   intervals. For example, `chop(x, breaks = c(1, 2, 2, 3))` will create a
#'   separate factor level for values exactly equal to 2.
#'
#' * Flexible and easy labelling.
#'
#' * Convenience functions for creating quantile intervals, evenly-spaced
#'  intervals or equal-sized groups.
#'
#' * Convenience functions to quickly tabulate chopped data.
#'
#' * Can chop numbers, dates, date-times and other objects.
#'
#' These advantages make santoku especially useful for exploratory analysis,
#' where you may not know the range of your data in advance.
#'
#' To get started, read the vignette:
#'
#' ```r
#' vignette("santoku")
#' ```
#' For more details, start with the documentation for [chop()].
"_PACKAGE"

# The following block is used by usethis to automatically manage
# roxygen namespace tags. Modify with care!
## usethis namespace: start
#' @importFrom Rcpp sourceCpp
#' @useDynLib santoku, .registration = TRUE
## usethis namespace: end
NULL

