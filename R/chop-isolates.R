
#' Chop common values into singleton intervals
#'
#' `chop_spikes()` lets you chop common values of `x` into their own
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
#' @seealso [dissect()] for a different approach.
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
    ...,
    n = NULL,
    prop = NULL
) {
  chop(x, brk_spikes(breaks, n = n, prop = prop), ...)
}


#' Cut data into intervals, separating out common values
#'
#' Sometimes it's useful to separate out common elements of `x`.
#' `dissect()` chops `x`, but puts common elements of `x` ("spikes")
#' into separate categories.
#'
#' Unlike [chop_spikes()], `dissect()` doesn't break up
#' intervals which contain a spike. As a result, unlike `chop_*` functions,
#' `dissect()` does not chop `x` into disjoint intervals. See the examples.
#'
#' If breaks are data-dependent, their labels may be misleading after common
#' elements have been removed. See the example below. To get round this,
#' set `exclude_spikes` to `TRUE`. Then breaks will be calculated after
#' removing spikes from the data.
#'
#' Levels of the result are ordered by the minimum element in each level. As
#' a result, if `drop = FALSE`, empty levels will be placed last.
#'
#' This function is `r lifecycle::badge("experimental")`.
#'
#' @param x,breaks,... Passed to [chop()].
#' @inheritParams chop_spikes
#' @param spike_labels [Glue][glue::glue()] string for spike labels. Use `"{l}"`
#' for the spike value.
#' @param exclude_spikes Logical. Exclude spikes before chopping `x`? This
#'   can affect the location of data-dependent breaks.
#'
#' @return
#' `dissect()` returns the result of [chop()], but with common values put into
#' separate factor levels.
#'
#' `tab_dissect()` returns a contingency [table()].
#'
#' @seealso [chop_spikes()] for a different approach.
#' @export
#' @order 1
#'
#' @examples
#' x <- c(2, 3, 3, 3, 4)
#' dissect(x, c(2, 4), n = 3)
#' dissect(x, brk_width(2), prop = 0.5)
#'
#' set.seed(42)
#' x <- runif(40, 0, 10)
#' x <- sample(x, 200, replace = TRUE)
#' # Compare:
#' table(dissect(x, brk_width(2, 0), prop = 0.05))
#' # Versus:
#' tab_spikes(x, brk_width(2, 0), prop = 0.05)
#'
#' # Potentially confusing data-dependent breaks:
#' set.seed(42)
#' x <- rnorm(99)
#' x[1:9] <- x[1]
#' tab_quantiles(x, 1:2/3)
#' tab_dissect(x, brk_quantiles(1:2/3), n = 9)
#' # Calculate quantiles excluding spikes:
#' tab_dissect(x, brk_quantiles(1:2/3), n = 9, exclude_spikes = TRUE)
dissect <- function (x,
                     breaks,
                     ...,
                     n = NULL,
                     prop = NULL,
                     spike_labels = "{{{l}}}",
                     exclude_spikes = FALSE) {
  assert_that(
    is.number(n) || is.number(prop),
    is.null(n) || is.null(prop),
    is.string(spike_labels),
    is.flag(exclude_spikes),
    msg = "exactly one of `n` and `prop` must be a scalar numeric"
  )
  assert_that(
    # it's ok for one of these to be null
    n >= 0 || prop >= 0
  )

  spikes <- find_spikes(x, n, prop)
  x_spikes <- match(x, spikes)
  is_spike <- ! is.na(x_spikes)
  x_spikes <- x_spikes[is_spike]

  if (exclude_spikes) {
    x_not_spikes <- x[! is_spike]
    chopped_not_spikes <- chop(x_not_spikes, breaks, ...)
    chopped <- factor(rep(NA_integer_, length(x)),
                      levels = levels(chopped_not_spikes))
    chopped[! is_spike] <- chopped_not_spikes
  } else {
    chopped <- chop(x, breaks, ...)
  }

  elabels <- endpoint_labels(spikes, raw = TRUE)
  glue_env <- new.env()
  assign("l", elabels, envir = glue_env)
  spike_labels <- glue::glue(spike_labels, .envir = glue_env)

  new_levels <- c(levels(chopped), spike_labels)
  levels(chopped) <- new_levels

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
