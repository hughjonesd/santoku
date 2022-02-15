

#' Create a breaks object
#'
#' @param obj A sorted vector or a `breaks` object.
#' @param left A logical vector, same length as `obj`.
#'
#' @return A breaks object
#'
#' @noRd
#'
create_breaks <- function (obj, left) {
  if (anyNA(obj)) stop("breaks contained NAs")
  stopifnot(all(obj == sort(obj)))
  stopifnot(is.logical(left))
  stopifnot(length(left) == length(obj))

  singletons <- singletons(obj)
  if (any(singletons[-1] & singletons[-length(singletons)])) {
    stop("breaks contained more than two consecutive equal values")
  }

  l_singletons <- c(singletons, FALSE)
  r_singletons <- c(FALSE, singletons)
  stopifnot(all(left[l_singletons]))
  stopifnot(all(! left[r_singletons]))

  break_classes <- class(obj)
  if (! inherits(obj, "breaks")) break_classes <- c("breaks", break_classes)

  structure(obj, left = left, class = break_classes)
}


create_lr_breaks <- function (obj, left, close_end) {
  assert_that(is.flag(left), is.flag(close_end))
  left_vec <- rep(left, length(obj))

  st <- singletons(obj)
  left_vec[which(st)]     <- TRUE
  left_vec[which(st) + 1] <- FALSE

  if (left && close_end) left_vec[length(left_vec)] <- FALSE
  if (! left && close_end) left_vec[1] <- TRUE

  create_breaks(obj, left_vec)
}


empty_breaks <- function () {
  create_breaks(c(-Inf, Inf), c(TRUE, FALSE))
}


NEITHER <- as.raw(0)
LEFT    <- as.raw(1)
RIGHT   <- as.raw(2)
BOTH <- LEFT | RIGHT


#' Reports if `breaks` will/should be extended.
#'
#' @param breaks A breaks object
#' @param x Data
#' @param extend Flag passed into `chop`
#'
#' @return Returns LEFT or RIGHT or BOTH only if `breaks` *will*/*must* be
#' extended i.e. gain an extra break, on the respective sides.
#'
#' @details
#' If `extend` is `FALSE`, always returns `NEITHER`. If `breaks` is length
#' zero, always returns `BOTH`.
#'
#' To test whether `breaks` will be extended on either side, use
#' `(needs & LEFT) > 0` or `(needs & RIGHT) > 0`.
#'
#' @noRd
needs_extend <- function (breaks, x, extend) {
  if (! is.null(extend) && ! extend) return(NEITHER)
  if (length(breaks) < 1L) return(BOTH)

  needs <- NEITHER
  left <- attr(breaks, "left")

  res <- vctrs::vec_cast_common(x, unclass_breaks(breaks))
  x <- res[[1]]
  breaks <- res[[2]]

  min_x <- quiet_min(x)
  max_x <- quiet_max(x)

  if (
          isTRUE(extend)      ||
          min_x < min(breaks) ||
          (! left[1] && min_x == min(breaks))
        ) {
    # "... and if ..."
    if (is_gt_minus_inf(breaks[1]) || ! left[1]) {
      needs <- needs | LEFT
    }
  }

  if (
          isTRUE(extend)      ||
          max_x > max(breaks) ||
          (left[length(left)] && max_x == max(breaks))
        ) {
    if (is_lt_inf(breaks[length(breaks)]) || left[length(left)]) {
      needs <- needs | RIGHT
    }
  }

  return(needs)
}


#' Possibly extend `breaks` to the left or right
#'
#' @param breaks,x,extend All passed in from `chop()` via a `brk_` inner
#' function
#'
#' @return A `breaks` object.
#' @noRd
maybe_extend <- function (breaks, x, extend) {
  extend_flags <- needs_extend(breaks, x, extend)

  if ((extend_flags & LEFT) > 0) {
    breaks <- extend_endpoint_left(breaks, x, extend)
  }
  if ((extend_flags & RIGHT) > 0) {
    breaks <- extend_endpoint_right(breaks, x, extend)
  }

  return(breaks)
}


extend_endpoint_left <- function (breaks, x, extend) {
  left <- attr(breaks, "left")
  q <- quiet_min(x)
  # non-finite q could be Inf if set is empty. Not appropriate for a left endpoint!
  extra_break <- if (is.null(extend) && is_gt_minus_inf(q)) q else class_bounds(x)[1]
  breaks <- vctrs::vec_c(extra_break, unclass_breaks(breaks))
  breaks <- create_breaks(breaks, c(TRUE, left))

  breaks
}


extend_endpoint_right <- function (breaks, x, extend) {
  left <- attr(breaks, "left")
  q <- quiet_max(x)
  extra_break <- if (is.null(extend) && is_lt_inf(q)) q else class_bounds(x)[2]
  breaks <- vctrs::vec_c(unclass_breaks(breaks), extra_break)
  breaks <- create_breaks(breaks, c(left, FALSE))

  breaks
}


is_lt_inf <- function (x) {
  x <- tryCatch(strict_as_numeric(x),
                  error = function (...) return(TRUE)
                )
  x < Inf
}


is_gt_minus_inf <- function (x) {
  x <- tryCatch(strict_as_numeric(x),
                  error = function (...) return(TRUE)
                )
  x > -Inf
}


#' Return the infimum and supremum of a class, or throw an error
#'
#' @param x Only used for its class
#'
#' @return A length-two object
#' @noRd
class_bounds <- function (x) {
  UseMethod("class_bounds")
}


#' @export
class_bounds.numeric <- function (x) c(-Inf, Inf)


#' @export
class_bounds.POSIXct <- function (x) {
  as.POSIXct(c(-Inf, Inf), origin = "1970-01-01")
}

#' @export
class_bounds.Date <- function (x) {
  as.Date(c(-Inf, Inf), origin = "1970-01-01")
}

#' @export
class_bounds.default <- function (x) {
  warning("Class '", paste(class(x), sep = "', '"),
        "' has no natural endpoints corresponding to +/-Inf for `extend = TRUE`;")
  c(quiet_min(x), quiet_max(x))
}


#' Removes the "breaks" class, and all subclasses, from a break object
#'
#' @param breaks A breaks object
#'
#' @return The object, with any remaining (super)classes
#' @noRd
unclass_breaks <- function (breaks) {
  assert_that(is.breaks(breaks))

  class_pos <- inherits(breaks, "breaks", which = TRUE)
  superclasses <- class(breaks)[-seq_len(class_pos)]

  class(breaks) <- if (length(superclasses) == 0 ) {
                     NULL
                   } else {
                     superclasses
                   }


  # this helps vec_cast_common deal with unusual types of breaks
  attr(breaks, "left") <- NULL

  breaks
}
