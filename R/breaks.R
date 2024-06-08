
#' @param breaks A numeric vector.
#' @name breaks-doc
#' @return A function which returns an object of class `breaks`.
NULL


#' Create a standard set of breaks
#'
#' @inherit breaks-doc params return
#' @export
#'
#' @examples
#'
#' chop(1:10, c(2, 5, 8))
#' chop(1:10, brk_default(c(2, 5, 8)))
#'
brk_default <- function (breaks) {
  assert_that(noNA(breaks))

  function (x, extend, left, close_end) {
    create_extended_breaks(breaks, x, extend, left, close_end)
  }
}


#' @rdname chop_spikes
#' @export
#' @order 2
brk_spikes <- function (breaks, n = NULL, prop = NULL) {
  assert_that(
    is.number(n) || is.number(prop),
    is.null(n) || is.null(prop),
    msg = "exactly one of `n` and `prop` must be specified as a scalar numeric"
  )
  if (! is.function(breaks)) breaks <- brk_default(breaks)

  function (x, extend, left, close_end) {
    breaks <- breaks(x, extend, left, close_end)
    break_elements <- unclass_breaks(breaks)
    left_vec <- attr(breaks, "left")

    spikes <- find_spikes(x, n, prop)
    # We sort spikes in decreasing order so that when we add elements,
    # earlier elements remain in place.
    spikes <- sort(spikes, decreasing = TRUE)

    for (spike in spikes) {
      # We could use match() here to go faster, or even put it outside the loop.
      match_location <- which(spike == break_elements)
      n_matches <- length(match_location)
      # If two break elements match the spike, it's already a singleton:
      # we don't need to do anything.
      if (n_matches >= 2L) next
      if (n_matches == 1L) {
        # We turn the single matching break into a singleton and make sure
        # that left is c(TRUE, FALSE)
        break_elements <- append(break_elements, spike, after = match_location)
        left_vec <- append(left_vec, FALSE, after = match_location)
        left_vec[match_location] <- TRUE
      } else {
        # We add a singleton break at `spike`
        insert_location <- quiet_max(which(spike > break_elements))
        if (insert_location <= 0) insert_location <- 0
        break_elements <- append(break_elements, rep(spike, 2),
                                 after = insert_location)
        left_vec <- append(left_vec, c(TRUE, FALSE), after = insert_location)
      }
    }

    create_breaks(break_elements, left = left_vec)
  }
}


#' Class representing a set of intervals
#'
#' @param x A breaks object
#' @param ... Unused
#'
#' @name breaks-class
NULL


#' @rdname breaks-class
#' @export
format.breaks <- function (x, ...) {
  if (length(x) < 2) return("Breaks object: no complete intervals")
  paste0("Breaks object: ", paste(lbl_intervals()(x), collapse = " "))
}


#' @rdname breaks-class
#' @export
print.breaks <- function (x, ...) cat(format(x, ...))


#' @rdname breaks-class
#' @export
is.breaks <- function (x, ...) inherits(x, "breaks")


on_failure(is.breaks) <- function (call, env) {
  paste0(deparse(call$x), " is not an object of class `breaks`")
}
