# Label chopped intervals by their midpoints

This uses the midpoint of each interval for its label.

## Usage

``` r
lbl_midpoints(
  fmt = NULL,
  single = NULL,
  first = NULL,
  last = NULL,
  raw = FALSE
)
```

## Arguments

- fmt:

  String, list or function. A format for break endpoints.

- single:

  Glue string: label for singleton intervals. See
  [`lbl_glue()`](https://hughjonesd.github.io/santoku/reference/lbl_glue.md)
  for details. If `NULL`, singleton intervals will be labelled the same
  way as other intervals.

- first:

  Glue string: override label for the first category. Write e.g.
  `first = "<{r}"` to create a label like `"<18"`. See
  [`lbl_glue()`](https://hughjonesd.github.io/santoku/reference/lbl_glue.md)
  for details.

- last:

  String: override label for the last category. Write e.g.
  `last = ">{l}"` to create a label like `">65"`. See
  [`lbl_glue()`](https://hughjonesd.github.io/santoku/reference/lbl_glue.md)
  for details.

- raw:

  **\[deprecated\]**. Use the `raw` argument to
  [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md)
  instead.

## Value

A function that creates a vector of labels.

## Formatting endpoints

If `fmt` is not `NULL` then it is used to format the endpoints.

- If `fmt` is a string, then numeric endpoints will be formatted by
  `sprintf(fmt, breaks)`; other endpoints, e.g.
  [Date](https://lubridate.tidyverse.org/reference/date_utils.html)
  objects, will be formatted by `format(breaks, fmt)`.

- If `fmt` is a list, then it will be used as arguments to
  [format](https://rdrr.io/r/base/format.html).

- If `fmt` is a function, it should take a vector of numbers (or other
  objects that can be used as breaks) and return a character vector. It
  may be helpful to use functions from the `{scales}` package, e.g.
  [`scales::label_comma()`](https://scales.r-lib.org/reference/label_number.html).

## See also

Other labelling functions:
[`lbl_dash()`](https://hughjonesd.github.io/santoku/reference/lbl_dash.md),
[`lbl_discrete()`](https://hughjonesd.github.io/santoku/reference/lbl_discrete.md),
[`lbl_endpoints()`](https://hughjonesd.github.io/santoku/reference/lbl_endpoints.md),
[`lbl_glue()`](https://hughjonesd.github.io/santoku/reference/lbl_glue.md),
[`lbl_intervals()`](https://hughjonesd.github.io/santoku/reference/lbl_intervals.md),
[`lbl_manual()`](https://hughjonesd.github.io/santoku/reference/lbl_manual.md),
[`lbl_seq()`](https://hughjonesd.github.io/santoku/reference/lbl_seq.md)

## Examples

``` r
chop(1:10, c(2, 5, 8), lbl_midpoints())
#>  [1] 1.5 3.5 3.5 3.5 6.5 6.5 6.5 9   9   9  
#> Levels: 1.5 3.5 6.5 9
```
