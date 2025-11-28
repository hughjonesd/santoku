# Label chopped intervals like 1-4, 4-5, ...

This label style is user-friendly, but doesn't distinguish between left-
and right-closed intervals. It's good for continuous data where you
don't expect points to be exactly on the breaks.

## Usage

``` r
lbl_dash(
  symbol = em_dash(),
  fmt = NULL,
  single = "{l}",
  first = NULL,
  last = NULL,
  raw = FALSE
)
```

## Arguments

- symbol:

  String: symbol to use for the dash.

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

## Details

If you don't want unicode output, use `lbl_dash("-")`.

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
[`lbl_discrete()`](https://hughjonesd.github.io/santoku/reference/lbl_discrete.md),
[`lbl_endpoints()`](https://hughjonesd.github.io/santoku/reference/lbl_endpoints.md),
[`lbl_glue()`](https://hughjonesd.github.io/santoku/reference/lbl_glue.md),
[`lbl_intervals()`](https://hughjonesd.github.io/santoku/reference/lbl_intervals.md),
[`lbl_manual()`](https://hughjonesd.github.io/santoku/reference/lbl_manual.md),
[`lbl_midpoints()`](https://hughjonesd.github.io/santoku/reference/lbl_midpoints.md),
[`lbl_seq()`](https://hughjonesd.github.io/santoku/reference/lbl_seq.md)

## Examples

``` r
chop(1:10, c(2, 5, 8), lbl_dash())
#>  [1] 1—2  2—5  2—5  2—5  5—8  5—8  5—8  8—10 8—10 8—10
#> Levels: 1—2 2—5 5—8 8—10

chop(1:10, c(2, 5, 8), lbl_dash(" to ", fmt = "%.1f"))
#>  [1] 1.0 to 2.0  2.0 to 5.0  2.0 to 5.0  2.0 to 5.0  5.0 to 8.0  5.0 to 8.0 
#>  [7] 5.0 to 8.0  8.0 to 10.0 8.0 to 10.0 8.0 to 10.0
#> Levels: 1.0 to 2.0 2.0 to 5.0 5.0 to 8.0 8.0 to 10.0

chop(1:10, c(2, 5, 8), lbl_dash(first = "<{r}"))
#>  [1] <2   2—5  2—5  2—5  5—8  5—8  5—8  8—10 8—10 8—10
#> Levels: <2 2—5 5—8 8—10

pretty <- function (x) prettyNum(x, big.mark = ",", digits = 1)
chop(runif(10) * 10000, c(3000, 7000), lbl_dash(" to ", fmt = pretty))
#>  [1] 7,000 to 9,677 7,000 to 9,677 7,000 to 9,677 3,000 to 7,000 7,000 to 9,677
#>  [6] 3,000 to 7,000 1,579 to 3,000 3,000 to 7,000 7,000 to 9,677 3,000 to 7,000
#> Levels: 1,579 to 3,000 3,000 to 7,000 7,000 to 9,677
```
