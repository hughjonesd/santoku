
#' Chop common values into separate categories
#'
#' `chop_spikes()` lets you isolate common values of `x` in their own
#' singleton intervals. This can help make unusual values visible.
#'
#' This function is `r lifecycle::badge("experimental")`.
#'
#' @param breaks A numeric vector of cut-points or a call to a `brk_*` function.
#'   The resulting [`breaks`][breaks-class] object will be modified to add
#'   singleton breaks.
#' @param n,prop Scalar. Provide either `n`, a number of values, or `prop`,
#'   a proportion of `length(x)`. Values of `x` which occur at least this
#'   often will get their own singleton break.
#' @inheritParams chop
#' @inherit chop-doc params return
#'
#' @export
#' @order 1
#' @family chopping functions
#' @seealso [isolate_chop()] for a different approach.
#' @examples
#' x <- c(1:4, rep(5, 5), 6:10)
#' chop_spikes(x, c(2, 7), n = 5)
#' chop_spikes(x, c(2, 7), prop = 0.25)
#' chop_spikes(x, brk_width(5), n = 5)
#'
#' set.seed(42)
#' x <- runif(40, 0, 10)
#' x <- sample(x, 200, replace = TRUE)
#' tab_spikes(x, brk_width(2, 0), prop = 0.05)
chop_spikes <- function (
    x,
    breaks,
    n = NULL,
    prop = NULL,
    ...
) {
  chop(x, brk_spikes(breaks, n = n, prop = prop), ...)
}


#' Cut data into intervals, isolating common elements
#'
#' Sometimes it's useful to separate out common elements of `x`.
#' `isolate_chop()` first chops `x`, then puts common elements of `x` ("spikes")
#' into separate categories.
#'
#' Unlike [chop_spikes()], `isolate_chop()` doesn't break up
#' intervals which contain a spike. As a result, unlike other `chop_*` functions,
#' `isolate_chop()` does not typically chop `x` into disjoint intervals. See
#' the examples.
#'
#' If breaks are data-dependent, their labels may be misleading after common
#' elements have been removed. See the example below.
#'
#' Levels of the result are ordered by the minimum element in each level. As
#' a result, if `drop = FALSE`, empty levels will be placed last.
#'
#' This function is `r lifecycle::badge("experimental")`.
#'
#' @param x,breaks,... Passed to [chop()].
#' @inheritParams chop_spikes
#' @param spike_labels Glue string for spike labels. Use `"{l}"` for the spike
#'   value.
#'
#' @return
#' The result of [chop()], but with common values given their own factor levels.
#'
#' @seealso [chop_spikes()] for a different approach.
#' @export
#'
#' @examples
#' x <- c(2, 3, 3, 3, 4)
#' isolate_chop(x, c(2, 4), n = 3)
#' isolate_chop(x, brk_width(2), prop = 0.5)
#'
#' set.seed(42)
#' x <- runif(40, 0, 10)
#' x <- sample(x, 200, replace = TRUE)
#' # Compare:
#' table(isolate_chop(x, brk_width(2, 0), prop = 0.05))
#' # Versus:
#' tab_spikes(x, brk_width(2, 0), prop = 0.05)
#'
#' # Misleading data-dependent breaks:
#' set.seed(42)
#' x <- rnorm(99)
#' x[1:10] <- x[1]
#' tab_quantiles(x, 1:2/3)
#' table(isolate_chop(x, brk_quantiles(1:2/3), prop = 0.1))
isolate_chop <- function (x,
                          breaks,
                          ...,
                          n = NULL,
                          prop = NULL,
                          spike_labels = "{{{l}}}") {
  assert_that(
    is.number(n) || is.number(prop),
    is.null(n) || is.null(prop),
    msg = "exactly one of `n` and `prop` must be specified as a scalar numeric"
  )

  chopped <- chop(x, breaks, ...)

  spikes <- find_spikes(x, n, prop)

  elabels <- endpoint_labels(spikes, raw = TRUE)
  glue_env <- new.env()
  assign("l", elabels, envir = glue_env)
  spike_labels <- glue::glue(spike_labels, .envir = glue_env)

  new_levels <- c(levels(chopped), spike_labels)
  levels(chopped) <- new_levels

  x_spikes <- match(x, spikes)
  is_spike <- ! is.na(x_spikes)
  x_spikes <- x_spikes[is_spike]
  chopped[is_spike] <- spike_labels[x_spikes]

  # We reorder the levels of chopped in order of their smallest elements.
  # Note that if `drop = FALSE`, empty intervals will be at the end.
  # The alternative would be to call `breaks` again and get the left endpoints
  # but this is complex.
  chopped <- stats::reorder(chopped, x, FUN = quiet_min)
  attr(chopped, "scores") <- NULL # remove leftover from reorder()

  chopped
}


#' Find common elements in `x`
#'
#' @param x A vector
#' @param n Number of elements that counts as common. Specify exactly one of `n`
#'   and `prop`.
#' @param prop Proportion of `length(x)` that counts as common
#'
#' @return The common elements, not necessarily in order. NA values are never
#' considered as common.
#' @noRd
find_spikes <- function (x, n, prop) {
  n <- n %||% (length(x) * prop)
  unique_x <- unique(x)
  x_counts <- tabulate(match(x, unique_x))
  spikes <- unique_x[x_counts >= n]
  spikes <- spikes[! is.na(spikes)]

  spikes
}