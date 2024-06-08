
#' Label chopped intervals using the `glue` package
#'
#' Use `"{l}"` and `"{r}"` to show the left and right endpoints of the intervals.
#'
#' @inherit label-doc
#' @inherit first-last-doc params
#' @param label A glue string passed to [glue::glue()].
#' @param ... Further arguments passed to [glue::glue()].
#'
#' @details
#'
#' The following variables are available in the glue string:
#'
#' * `l` is a character vector of left endpoints of intervals.
#' * `r` is a character vector of right endpoints of intervals.
#' * `l_closed` is a logical vector. Elements are `TRUE` when the left
#'   endpoint is closed.
#' * `r_closed` is a logical vector, `TRUE` when the right endpoint is closed.
#'
#' Endpoints will be formatted by `fmt` before being passed to `glue()`.
#'
#' @family labelling functions
#'
#' @export
#'
#' @examples
#' tab(1:10, c(1, 3, 3, 7),
#'     labels = lbl_glue("{l} to {r}", single = "Exactly {l}"))
#'
#' tab(1:10 * 1000, c(1, 3, 5, 7) * 1000,
#'     labels = lbl_glue("{l}-{r}",
#'                       fmt = function(x) prettyNum(x, big.mark=',')))
#'
#' # reproducing lbl_intervals():
#' interval_left <- "{ifelse(l_closed, '[', '(')}"
#' interval_right <- "{ifelse(r_closed, ']', ')')}"
#' glue_string <- paste0(interval_left, "{l}", ", ", "{r}", interval_right)
#' tab(1:10, c(1, 3, 3, 7), labels = lbl_glue(glue_string, single = "{{{l}}}"))
#'
lbl_glue <- function (
              label,
              fmt    = NULL,
              single = NULL,
              first  = NULL,
              last   = NULL,
              raw    = FALSE,
              ...
            ) {
  assert_that(
    is.string(label),
    is.null(fmt) || is_format(fmt),
    is.string(first) || is.null(first),
    is.string(last) || is.null(last),
    is.flag(raw)
  )

  if (! isFALSE(raw)) {
    lifecycle::deprecate_warn("0.9.0", "lbl_glue(raw)", "chop(raw)")
  }

  RAW <- raw # avoid "recursive default argument reference"
  function (breaks, raw = RAW) {
    assert_that(is.breaks(breaks))

    len_breaks <- length(breaks)

    labels <- character(len_breaks - 1)

    elabels <- endpoint_labels(breaks, raw = raw, fmt = fmt)

    l <- elabels[-len_breaks]
    r <- elabels[-1]

    left <- attr(breaks, "left")
    # Breaks like [1, 2) [2, 3] have
    # left TRUE, TRUE, FALSE for breaks 1,2,3
    # The first two TRUEs say that the left brackets are closed
    # The last two TRUE & FALSE say that the right brackets are open
    # and closed respectively. So:
    l_closed <- left[-len_breaks]
    r_closed <- ! left[-1]

    # check ... for anything not in glue::glue args
    # effectively, we move any user-supplied arguments into
    # an environment specifically for glue
    # this is mostly to make the lbl_midpoints() hack
    # of passing in `m` work
    dots <- rlang::enexprs(...)
    glue_env <- new.env()
    not_glue_args <- setdiff(names(dots), names(formals(glue::glue)))
    for (nm in not_glue_args) {
      assign(deparse(dots[[nm]]),
               eval(dots[[nm]], parent.frame()),
               glue_env
             )
    }
    labels <- glue::glue(label, l = l, r = r, l_closed = l_closed,
                         r_closed = r_closed, ..., .envir = glue_env)

    if (! is.null(single)) {
      # which breaks are singletons?
      singletons <- singletons(breaks)

      labels[singletons] <- glue::glue(single,
                                         l = l[singletons],
                                         r = r[singletons],
                                         l_closed = l_closed[singletons],
                                         r_closed = r_closed[singletons],
                                         ...,
                                         .envir = glue_env
                                       )
    }

    if (! is.null(first)) {
      labels[1] <- glue::glue(first, l = l[1], r = r[1],
                                l_closed = l_closed[1],
                                r_closed = r_closed[1],
                                ...,
                                .envir = glue_env
                              )
    }

    if (! is.null(last)) {
      ll <- len_breaks - 1
      labels[ll] <- glue::glue(last, l = l[ll], r = r[ll],
                                 l_closed = l_closed[ll],
                                 r_closed = r_closed[ll],
                                 ...,
                                 .envir = glue_env
                               )
    }

    return(labels)
  }
}