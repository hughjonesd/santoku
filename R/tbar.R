
#' Print a terminal barplot of data
#'
#' @param x A vector or table.
#' @param useNA Passed to [table()]: one of `"no"`, `"ifany"` or `"always"`.
#' @param ... Not currently used.
#' @param width Maximum width of the barplot in characters.
#'
#' @return `x` or `table(x)`, invisibly.
#' @export
#'
#' @examples
#' tbar(ChickWeight$Diet)
#' props <- proportions(table(ChickWeight$Diet))
#' tbar(props)
#' tbar(chop(rnorm(100), -3:3))
tbar <- function (x, ..., width = 60) {
  UseMethod("tbar")
}

#' @export
#' @rdname tbar
tbar.default <- function (x, ..., width = 60, useNA = "ifany") {
  x <- table(x, useNA = useNA)
  tbar(x, width = width)
}


#' @export
#' @rdname tbar
tbar.table <- function (x, ..., width = 60) {
  nms <- names(x)

  nm_widths <- nchar(nms, type = "width")
  max_nm_width <- max(nm_widths)
  padding <- max_nm_width - nm_widths
  padding <- strrep(" ", padding)
  nms <- paste0(nms, padding)

  hist_width <- getOption("width", 80)
  hist_width <- min(hist_width, width)
  # max(x) can be less than 1 if x is a table of proportions,
  # for example.
  if (max(x) > hist_width || max(x) < 1) {
    props <- proportions(x)
    props <- as.numeric(props)
    props <- props * hist_width
  } else  {
    props <- as.numeric(x)
  }

  props_floor <- floor(props)
  remainder <- props - props_floor
  part_blocks <- cut(remainder, seq(0, 1, 1/8),
                     labels = c(" ", "\U258F", "\U258E", "\U258D", "\U258C",
                                "\U258B", "\U258A", "\U2589"),
                     include.lowest = TRUE)
  part_blocks <- as.character(part_blocks)
  full_blocks <- strrep("\U2589", props_floor)
  hist <- paste0(full_blocks, part_blocks)

  counts <- as.numeric(x)
  counts <- round(x, 3) # e.g. if we have a table of proportions
  lines <- paste0(" ", nms, " ", hist, " [", counts, "]")

  cat(lines, sep = "\n")

  return(invisible(x))
}
