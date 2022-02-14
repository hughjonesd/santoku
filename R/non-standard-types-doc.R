
#' Tips for chopping non-standard types
#'
#' Santoku can handle many non-standard types.
#'
#' * If objects can be compared using `<`, `==` etc. then they should
#'   be choppable.
#' * Objects which can't be converted to numeric are handled within R code,
#'   which may be slower.
#' * Character `x` and `breaks` are chopped with a warning.
#' * If `x` and `breaks` are not the same type, they should be able to
#'   be cast to the same type using [vctrs::vec_cast_common()].
#' * Not all chopping operations make sense, for example, [chop_mean_sd()]
#'   on a character vector.
#' * If you get errors, try setting `extend = FALSE`.
#' * To request support for a type, open an issue on Github.
#'
#' @name non-standard-types
#' @seealso brk-width-for-Datetime
NULL