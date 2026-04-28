#' Parse a `strftime` format string
#'
#' Splits a format string into literal and directive tokens.
#'
#' @param fmt A `strftime` format string.
#'
#' @return A data frame with columns `type` (`"literal"` or `"directive"`)
#'   and `token`.
#' @noRd
parse_strftime <- function(fmt) {
  assert_that(is.string(fmt))

  chars <- strsplit(fmt, "", fixed = TRUE)[[1]]
  n <- length(chars)
  i <- 1L
  types <- character(0)
  tokens <- character(0)

  while (i <= n) {
    if (chars[i] != "%") {
      start <- i
      while (i <= n && chars[i] != "%") i <- i + 1L
      types <- c(types, "literal")
      tokens <- c(tokens, paste0(chars[start:(i - 1L)], collapse = ""))
      next
    }

    if (i < n && chars[i + 1L] == "%") {
      types <- c(types, "literal")
      tokens <- c(tokens, "%")
      i <- i + 2L
      next
    }

    start <- i
    i <- i + 1L

    if (i <= n && chars[i] %in% c("E", "O")) i <- i + 1L
    while (i <= n && grepl("[0-9]", chars[i])) i <- i + 1L
    if (i <= n) i <- i + 1L

    types <- c(types, "directive")
    tokens <- c(tokens, paste0(chars[start:(i - 1L)], collapse = ""))
  }

  data.frame(type = types, token = tokens, stringsAsFactors = FALSE)
}

#' Return relative component rank for a strftime directive
#'
#' Lower values are "greater" components, e.g. year before month before day.
#'
#' @param token A single strftime directive token (e.g. "%Y").
#'
#' @return Numeric rank, or `NA_real_` if unknown.
#' @noRd
strftime_rank <- function(token) {
  code <- gsub("^%[EO]?([0-9]*)", "", token)

  if (code %in% c("Y", "y", "C", "G", "g")) return(1)
  if (code %in% c("m", "b", "B", "h")) return(2)
  if (code %in% c("d", "e", "j", "a", "A", "u", "w")) return(3)
  if (code %in% c("H", "I", "k", "l", "p", "P", "M", "S", "OS")) return(4)

  NA_real_
}


#' Format date/time endpoints into token matrix
#'
#' @param x Date/time-like vector.
#' @param fmt A `strftime` format string.
#' @param spec Parsed strftime spec.
#'
#' @return A character matrix: rows are endpoints, columns are format tokens.
#' @noRd
format_strftime_tokens <- function(x, fmt = NULL, spec = parse_strftime(fmt)) {
  n <- length(x)

  tokens <- lapply(seq_len(nrow(spec)), function(i) {
    if (identical(spec$type[[i]], "literal")) {
      rep(spec$token[[i]], n)
    } else {
      format(x, spec$token[[i]])
    }
  })

  do.call(cbind, tokens)
}


#' Collapse two formatted date/time labels
#'
#' @param l_tokens Left endpoint tokens.
#' @param r_tokens Right endpoint tokens.
#' @param symbol Separator for full ranges.
#'
#' @return A single collapsed range label.
#' @noRd
collapse_datetime_label <- function(
    l_tokens,
    r_tokens,
    spec,
    symbol = "-"
) {
  n <- length(l_tokens)
  spaced_symbol <- paste0(" ", symbol, " ")
  full <- paste0(paste0(l_tokens, collapse = ""), spaced_symbol,
                 paste0(r_tokens, collapse = ""))

  ranks <- vapply(spec$token, strftime_rank, FUN.VALUE = numeric(1))
  is_directive <- spec$type == "directive"
  comparable <- is_directive & !is.na(ranks)
  differs <- comparable & (l_tokens != r_tokens)

  if (any(differs)) {
    diff_rank <- min(ranks[differs])
    higher_differs <- comparable & (ranks < diff_rank) & (l_tokens != r_tokens)
    active_components <- which(comparable & (ranks >= diff_rank))

    if (!any(higher_differs) && length(active_components) > 0 && diff_rank %in% c(2, 3)) {
      left_end <- max(active_components)
      right_start <- min(active_components)
      left_part <- paste0(l_tokens[seq_len(left_end)], collapse = "")
      right_part <- paste0(r_tokens[right_start:n], collapse = "")

      if (nzchar(left_part) && nzchar(right_part)) {
        joiner <- if (diff_rank == 3) symbol else spaced_symbol
        return(paste0(left_part, joiner, right_part))
      }
    }
  }

  shared <- 0L

  while (shared < n && identical(l_tokens[[n - shared]], r_tokens[[n - shared]])) {
    shared <- shared + 1L
  }

  if (shared == 0L) {
    return(full)
  }

  l_head <- if (shared < n) paste0(l_tokens[seq_len(n - shared)], collapse = "") else ""
  r_head <- if (shared < n) paste0(r_tokens[seq_len(n - shared)], collapse = "") else ""
  suffix <- paste0(r_tokens[(n - shared + 1L):n], collapse = "")

  if (!nzchar(l_head) || !nzchar(r_head)) {
    return(full)
  }

  if (!grepl("^\\s", suffix)) {
    return(full)
  }

  joiner <- if (grepl("\\s", l_head) || grepl("\\s", r_head)) spaced_symbol else symbol

  paste0(l_head, joiner, r_head, suffix)
}


#' Label date ranges with collapsed shared components
#'
#' @inherit label-doc
#' @inherit first-last-doc
#' @param symbol String: separator to use for full ranges.
#' @param unit Optional interval unit for non-overlapping labels. If `NULL`, no
#'   discrete adjustment is applied. If not `NULL`, open endpoints are adjusted
#'   inward by `unit`, in the style of [lbl_discrete()].
#'
#' @family labelling functions
#'
#' @export
lbl_date <- function(
    fmt = "%e %b %Y",
    symbol = "-",
    unit = as.difftime(1, units = "days"),
    single = "{l}",
    first = NULL,
    last = NULL
) {
  lbl_datetime(
    fmt = fmt,
    symbol = symbol,
    unit = unit,
    single = single,
    first = first,
    last = last
  )
}


#' Label datetime ranges with collapsed shared components
#'
#' @inherit label-doc
#' @inherit first-last-doc
#' @param symbol String: separator to use for full ranges.
#' @param unit Optional interval unit for non-overlapping labels. If `NULL`, no
#'   discrete adjustment is applied. If not `NULL`, open endpoints are adjusted
#'   inward by `unit`, in the style of [lbl_discrete()].
#'
#' @family labelling functions
#'
#' @export
lbl_datetime <- function(
    fmt = "%H:%M %b %e %Y",
    symbol = "-",
    unit = NULL,
    single = "{l}",
    first = NULL,
    last = NULL
) {
  assert_that(
    is.string(fmt),
    is.string(symbol),
    length(unit) <= 1L,
    is.string(single) || is.null(single),
    is.string(first) || is.null(first),
    is.string(last) || is.null(last)
  )

  function(breaks, raw = NULL) {
    assert_that(is.breaks(breaks))

    len_breaks <- length(breaks)
    endpoints <- scaled_endpoints(breaks, raw = FALSE)
    pieces <- discrete_interval_endpoints(
      breaks = breaks,
      unit = unit,
      endpoints = endpoints
    )
    l <- pieces$l
    r <- pieces$r
    is_singleton <- pieces$singletons
    too_small <- pieces$too_small
    l_closed <- pieces$l_closed
    r_closed <- pieces$r_closed

    if (any(too_small)) {
      warning("Intervals smaller than `unit` are labelled as \"--\"")
    }

    spec <- parse_strftime(fmt)
    l_tokens <- format_strftime_tokens(l, spec = spec)
    r_tokens <- format_strftime_tokens(r, spec = spec)

    labels <- vapply(seq_len(len_breaks - 1L), function(i) {
      collapse_datetime_label(
        l_tokens = l_tokens[i, ],
        r_tokens = r_tokens[i, ],
        spec = spec,
        symbol = symbol
      )
    }, FUN.VALUE = character(1))

    l <- apply(l_tokens, 1, paste0, collapse = "")
    r <- apply(r_tokens, 1, paste0, collapse = "")

    labels[too_small] <- "--"

    if (!is.null(single)) {
      labels[is_singleton] <- glue::glue(single,
        l = l[is_singleton],
        r = r[is_singleton],
        l_closed = l_closed[is_singleton],
        r_closed = r_closed[is_singleton]
      )
    }

    if (!is.null(first)) {
      labels[1] <- glue::glue(first, l = l[1], r = r[1],
        l_closed = l_closed[1], r_closed = r_closed[1]
      )
    }

    if (!is.null(last)) {
      ll <- len_breaks - 1L
      labels[ll] <- glue::glue(last, l = l[ll], r = r[ll],
        l_closed = l_closed[ll], r_closed = r_closed[ll]
      )
    }

    labels
  }
}
