

#' Define singleton intervals explicitly
#'
#' `exactly()` duplicates its input.
#' It lets you define singleton intervals like this: `chop(x, c(1, exactly(2), 3))`.
#' This is the same as `chop(x, c(1, 2, 2, 3))` but conveys your intent more
#' clearly.
#'
#' @param x A numeric vector.
#'
#' @return The same as `rep(x, each = 2)`.
#' @export
#'
#' @examples
#' chop(1:10, c(2, exactly(5), 8))
#'
#' # same:
#' chop(1:10, c(2, 5, 5, 8))
exactly <- function (x) rep(x, each = 2)



#' Simple percentage formatter
#'
#' `percent()` formats `x` as a percentage.
#' For a wider range of formatters, consider the [`scales`
#' package](https://cran.r-project.org/package=scales).
#'
#' @param x Numeric values.
#'
#' @return `x` formatted as a percent.
#' @export
#'
#' @examples
#' percent(0.5)
percent <- function (x) {
  paste0(unique_truncation(x * 100), "%")
}


#' Report singleton intervals
#'
#' @param breaks A breaks object
#'
#' @return
#' A logical vector of `length(breaks) - 1`, `TRUE`
#' if the corresponding interval is a singleton.
#' @noRd
#'
#' @examples
#' brk <- brk_res(brk_default(c(1, 1, 2, 3, 3, 4)))
#' brk
#' # Breaks object: {1} (1, 2) [2, 3) {3} (3, 4)
#'
#' singletons(brk)
#' # TRUE FALSE FALSE TRUE FALSE
singletons <- function (breaks) {
  duplicated(breaks)[-1]
}


#' Find duplicates that would be illegal breaks
#'
#' @param x A vector, which should be sorted
#'
#' @return A logical vector of length(x), TRUE if the corresponding element
#'   is the second duplicate in a row.
#' @noRd
#'
#' @examples
#' find_illegal_duplicates(c(1, 2, 2, 3, 3, 3, 4))
find_illegal_duplicates <- function (x) {
  if (length(x) == 0) return(logical(0))
  dupes <- duplicated(x)
  # If element n is duplicated, and element n+1 is duplicated, then n + 1
  # is illegal.
  # The first element is never a duplicated middle.
  c(FALSE, dupes[-length(dupes)] & dupes[-1])
}


`%||%` <- function (x, y) if (is.null(x)) y else x


quiet_min <- function (x) suppressWarnings(min(x, na.rm = TRUE))


quiet_max <- function (x) suppressWarnings(max(x, na.rm = TRUE))



#' Stricter `as.numeric`
#'
#' This converts warnings to errors, and errors if any NAs are introduced,
#' but is less strict than `vctrs::vec_cast()`
#'
#' @param x A vector
#'
#' @return `as.numeric(x)`, with no new NAs
#' @noRd
#'
strict_as_numeric <- function (x) {
  nas <- is.na(x)

  x <- tryCatch(as.numeric(x),
                  warning = function (w) stop("Warning from as.numeric(x)")
                )
  if (any(is.na(x) & ! nas)) stop("Could not convert some elements")

  x
}


#' Test a break
#'
#' @param brk_fun A call to a `brk_` function
#' @param x,extend,left,close_end Passed in to `brk_fun`
#'
#' @return A `breaks` object.
#' @noRd
#'
#' @examples
#' brk_res(brk_default(1:3))
#'
brk_res <- function (
  brk_fun,
  x         = 1:2,
  extend    = FALSE,
  left      = TRUE,
  close_end = FALSE
) {
  brk_fun(x, extend = extend, left = left, close_end = close_end)
}
