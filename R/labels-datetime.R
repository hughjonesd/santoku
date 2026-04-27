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


#' Format date/time endpoints into token matrix
#'
#' @param x Date/time-like vector.
#' @param fmt A `strftime` format string.
#'
#' @return A character matrix: rows are endpoints, columns are format tokens.
#' @noRd
format_strftime_tokens <- function(x, fmt) {
  spec <- parse_strftime(fmt)
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
#' @param collapsed_symbol Separator when suffix is collapsed.
#'
#' @return A single collapsed range label.
#' @noRd
collapse_datetime_label <- function(
    l_tokens,
    r_tokens,
    symbol = " - ",
    collapsed_symbol = "-"
) {
  n <- length(l_tokens)
  shared <- 0L

  while (shared < n && identical(l_tokens[[n - shared]], r_tokens[[n - shared]])) {
    shared <- shared + 1L
  }

  if (shared == 0L) {
    return(paste0(paste0(l_tokens, collapse = ""), symbol,
                  paste0(r_tokens, collapse = "")))
  }

  l_head <- if (shared < n) paste0(l_tokens[seq_len(n - shared)], collapse = "") else ""
  r_head <- if (shared < n) paste0(r_tokens[seq_len(n - shared)], collapse = "") else ""
  suffix <- paste0(r_tokens[(n - shared + 1L):n], collapse = "")

  if (!nzchar(l_head) || !nzchar(r_head)) {
    return(paste0(paste0(l_tokens, collapse = ""), symbol,
                  paste0(r_tokens, collapse = "")))
  }

  joiner <- if (grepl("\\s", l_head) || grepl("\\s", r_head)) symbol else collapsed_symbol

  paste0(l_head, joiner, r_head, suffix)
}


#' Label date ranges with collapsed shared components
#'
#' @inherit label-doc
#' @inherit first-last-doc
#' @param symbol String: separator to use for full ranges.
#' @param collapsed_symbol String: separator to use when shared date suffixes are
#'   collapsed.
#'
#' @family labelling functions
#'
#' @export
lbl_date <- function(
    fmt = "%e %b %Y",
    symbol = " - ",
    collapsed_symbol = "-",
    single = "{l}",
    first = NULL,
    last = NULL,
    raw = FALSE
) {
  lbl_datetime(
    fmt = fmt,
    symbol = symbol,
    collapsed_symbol = collapsed_symbol,
    single = single,
    first = first,
    last = last,
    raw = raw
  )
}


#' Label datetime ranges with collapsed shared components
#'
#' @inherit label-doc
#' @inherit first-last-doc
#' @param symbol String: separator to use for full ranges.
#' @param collapsed_symbol String: separator to use when shared date/time suffixes
#'   are collapsed.
#'
#' @family labelling functions
#'
#' @export
lbl_datetime <- function(
    fmt = "%l.%M %P %b %e %Y",
    symbol = " - ",
    collapsed_symbol = "-",
    single = "{l}",
    first = NULL,
    last = NULL,
    raw = FALSE
) {
  assert_that(
    is.string(fmt),
    is.string(symbol),
    is.string(collapsed_symbol),
    is.string(single) || is.null(single),
    is.string(first) || is.null(first),
    is.string(last) || is.null(last),
    is.flag(raw)
  )

  if (!isFALSE(raw)) {
    lifecycle::deprecate_warn("0.9.0", "lbl_datetime(raw)", "chop(raw)")
  }

  RAW <- raw

  function(breaks, raw = RAW) {
    assert_that(is.breaks(breaks))

    len_breaks <- length(breaks)
    endpoints <- scaled_endpoints(breaks, raw = raw)
    token_matrix <- format_strftime_tokens(endpoints, fmt = fmt)

    labels <- vapply(seq_len(len_breaks - 1L), function(i) {
      collapse_datetime_label(
        l_tokens = token_matrix[i, ],
        r_tokens = token_matrix[i + 1L, ],
        symbol = symbol,
        collapsed_symbol = collapsed_symbol
      )
    }, FUN.VALUE = character(1))

    l <- apply(token_matrix[-len_breaks, , drop = FALSE], 1, paste0, collapse = "")
    r <- apply(token_matrix[-1, , drop = FALSE], 1, paste0, collapse = "")

    left <- attr(breaks, "left")
    l_closed <- left[-len_breaks]
    r_closed <- !left[-1]

    if (!is.null(single)) {
      is_singleton <- singletons(breaks)
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
